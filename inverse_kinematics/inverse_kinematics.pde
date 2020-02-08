import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;

class Effector {
  
  private int _x, _y, _size;
  
  Effector(int size) {
    _size = size;
  }
  
  void setPosition(int x, int y) {
    _x = x;
    _y = y;
  }
  
  float distanceFrom(PVector point) {
    float a = point.x - _x;
    float b = point.y - _y;
    return sqrt(a * a + b * b);
  }
  
  void draw() {
    pushStyle();
    fill(200, 0, 0);
    circle(_x, _y, _size);
    popStyle();
  }
}

int HEIGHT = 5;

Effector e1 = new Effector(20), e2 = new Effector(20);

class Limb {
  float angle;
  final int length;
  final float minAngle;
  final float maxAngle;
  
  public Limb(int length) {
    this(length, 0, -2*PI, 2*PI); 
  }
  
  public Limb(int length, float angle, float minAngle, float maxAngle) {
    this.angle = angle;
    this.length = length;
    this.minAngle = minAngle;
    this.maxAngle = maxAngle;
  }
}


class Arm {
  PVector position;
  List<Integer> lengths;
  List<Float> angles;
  List<Float> minAngles;
  List<Float> maxAngles;
  Effector effector;
  float rotation;
  
  public Arm(PVector position, List<Integer> lengths, List<Float> angles, List<Float> minAngles, List<Float> maxAngles) {
    this.position = position;
    this.lengths = new ArrayList<Integer>(lengths);
    this.angles = new ArrayList<Float>(angles);
    this.minAngles = new ArrayList<Float>(minAngles);
    this.maxAngles = new ArrayList<Float>(maxAngles);
  }
  
  PVector calculatePosition() {
    PMatrix2D matrix = new PMatrix2D();
    matrix.translate(position.x, position.y);
    for (int i = 0; i < angles.size(); i++) {
      matrix.translate(0, HEIGHT/2);
      matrix.rotate(angles.get(i));
      matrix.translate(lengths.get(i), -HEIGHT/2);
    }
    return matrix.mult(new PVector(0, HEIGHT/2, 0), null);
  }

  void updateAngles() {
    List<Float> originalAngles = new ArrayList<Float>(angles);
    for (int i = angles.size() - 1; i >= 0; i--) {
      float original = angles.get(i);
      angles.set(i, original - step / 2);
      boolean leftCollide = collisions(i);
      float x1 = effector.distanceFrom(calculatePosition());
      angles.set(i, original + step / 2);
      boolean rightCollide = collisions(i);
      float x2 = effector.distanceFrom(calculatePosition());
      float gradient = x2 - x1;
      float recovery = 0.01;
  
      if (gradient > 0 && leftCollide) {
        angles.set(i, original + recovery);
      } else if (gradient < 0 && rightCollide) {
        angles.set(i, original - recovery);
      } else { 
        angles.set(i, constrain(original - gradient * 0.005, minAngles.get(i), maxAngles.get(i)));
      }
    }
    float originalDistance = effector.distanceFrom(calculatePosition()),
          newDistance = effector.distanceFrom(calculatePosition()),
          resolution = 0.00001;
    if (originalDistance - newDistance < -resolution) {
       for (int i = 0; i < angles.size(); i++) {
         angles.set(i, originalAngles.get(i));
       }
    }
  }
  
  List<PVector[]> screenCoords() {
    pushMatrix();
    List<PVector[]> coords = new ArrayList<PVector[]>(angles.size());
    for (int i = 0; i < angles.size(); i++) {
       translate(0, HEIGHT/2);
       rotate(angles.get(i));
       translate(0, -HEIGHT/2);
       PVector[] here = new PVector[4];
       float margin = 0.1;
       int xMargin = (int)(lengths.get(i) * margin),
           yMargin = (int)(HEIGHT * margin);
       here[0] = screenPoint(xMargin, yMargin);
       here[1] = screenPoint(lengths.get(i) - xMargin, yMargin);
       here[2] = screenPoint(lengths.get(i) - xMargin, HEIGHT - yMargin);
       here[3] = screenPoint(xMargin, HEIGHT - yMargin);
       coords.add(here);
       translate(lengths.get(i), 0);
    }
    popMatrix();
    return coords;
  }

  boolean collisions(int i) {
    List<PVector[]> coords = screenCoords();
    for (int j = 0; j < coords.size(); j++) {
      if (abs(i-j) < 2) continue;
        if (polyPoly(coords.get(i), coords.get(j))) {
          return true;
        }
    }
    return false;
  }
  
  void draw() {
    pushMatrix();
    List<PVector[]> screen_coordinates = screenCoords();
    pushStyle();
    fill(255);
    int[] collisions = new int[screen_coordinates.size()];
    for (int i = 0; i < collisions.length; i++) {
      collisions[i] = 0; 
    }
    for (int i = 0; i < collisions.length; i++) {
      for (int j = i + 1; j < collisions.length; j++) {
         if (polyPoly(screen_coordinates.get(i), screen_coordinates.get(j))) {
           collisions[i]++;
           collisions[j]++;
         }
      }
    }
    translate(position.x, position.y);
    for (int i = 0; i < angles.size(); i++) {
      translate(0, HEIGHT/2);
      rotate(angles.get(i));
      translate(0, -HEIGHT/2);
      float t = (float)collisions[i] / collisions.length;
      fill(color(lerp(255,200,t), lerp(255, 20,t), lerp(255, 140, t)));
      ellipse(lengths.get(i)/2, HEIGHT/2, lengths.get(i), HEIGHT);
      translate(lengths.get(i), 0);
    }
    popStyle();
    popMatrix();
  }

}
float lengthOf(List<Float> vector) {
   float size = 0;
   for (int i = 0; i < vector.size(); i++) {
      size += vector.get(i) * vector.get(i); 
   }
   return sqrt(size);
}

boolean polyPoly(PVector[] p1, PVector[] p2) {
  int j = 0;
  for (int i = 0; i < p1.length; i++) {
    j = (i + 1) % p1.length;
    PVector current = p1[i];
    PVector next = p1[j];
    
    if (polyLine(p2, current.x, current.y, next.x, next.y)) return true;
  }
  return polyPoint(p1, p2[0].x, p2[0].y);
}

boolean polyLine(PVector[] vertices, float x1, float y1, float x2, float y2) {
  int j = 0;
  for (int i = 0; i < vertices.length; i++) {
    j = (i + 1) % vertices.length;
    float x3 = vertices[i].x,
          y3 = vertices[i].y,
          x4 = vertices[j].x,
          y4 = vertices[j].y;
    if (lineLine(x1, y1, x2, y2, x3, y3, x4, y4)) return true;
  }
  return false;
}

boolean lineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  return uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1;
}

boolean polyPoint(PVector[] vertices, float x, float y) {
   boolean collision = false;
   
   int j = 0;
   for (int i = 0; i < vertices.length; i++) {
     j = (i + 1) % vertices.length;
     
     PVector current = vertices[i];
     PVector next = vertices[j];
     
     if ( ((current.y > y && next.y < y) || (current.y < y && next.y > y)) && 
          (x < (next.x-current.x) * (y - current.y) / (next.y - current.y) + current.x) ) {
       collision = !collision;
     }
   }
   return collision;
}

PVector screenPoint(int x, int y) {
  return new PVector(screenX(x, y), screenY(x, y)); 
}

float step = 0.09;
List<Arm> arms;
void setup() {
  size(640, 480);
  frameRate(24);
  
  int n = 4;
  List<Integer> lengths = new ArrayList<Integer>(n);
  List<Float> minAngles = new ArrayList<Float>(n);
  List<Float> maxAngles = new ArrayList<Float>(n);
  for (int i = 0; i < n; i++) {
    lengths.add(200 / n + 20 * i);
    float magnitude = 3 *
    PI / 2;
    if (i == 0) {
      minAngles.add(PI*0.75);
      maxAngles.add(PI*1.5);
    } else {
      minAngles.add(-magnitude);
      maxAngles.add(magnitude);
    }
  }
  List<Float> angles = new ArrayList<Float>(lengths.size());
  for (int i = 0; i < lengths.size(); i++) {
    angles.add(0f);
  }
  int num_arms = 8;
  arms = new ArrayList<Arm>(num_arms);
  e1.setPosition(50, height / 2);
  e2.setPosition(width - 50, height / 2);
  for (int i = 0; i < num_arms / 2; i++) {
    angles.set(1, (1.5-i) * PI / 8);
    Arm leftArm = new Arm(new PVector(-40, (i-1.5) * 100, 0), lengths, angles, minAngles, maxAngles);
    angles.set(1, (i-1.5) * PI / 8);
    leftArm.rotation = PI;
    Arm rightArm = new Arm(new PVector(40, (i-1.5) * 100, 0), lengths, angles, minAngles, maxAngles);
    leftArm.effector = e1;
    rightArm.effector = e2;
    arms.add(leftArm);
    arms.add(rightArm);
  }
}

void draw() {
  background(140, 200, 100);
  int x = width / 2, y = height / 2;
  e1.setPosition(50-mouseX, mouseY-y);
  e2.setPosition(mouseX-50, mouseY-y);
  translate(x, y);
  for (Arm arm : arms) {
    arm.updateAngles();
    arm.draw();
  PVector tip = arm.calculatePosition();
  fill(100, 100, 230);
  circle(tip.x, tip.y, 10);
  }
  e1.draw();
  e2.draw();
}
