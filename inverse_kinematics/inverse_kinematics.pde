import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;

class Effector {
  
  PVector position;
  private int _size;
  
  Effector(int size) {
    _size = size;
  }
  
  void setPosition(PVector position) {
    this.position = position.copy();
  } 
  
  void setPosition(int x, int y) {
    setPosition(new PVector(x, y));
  }
  
  float distanceFrom(PVector point) {
    point = point.copy();
    point.sub(position);
    return point.mag();
  }
  
  void draw() {
    pushStyle();
    fill(200, 0, 0);
    circle(position.x, position.y, _size);
    popStyle();
  }
}

class Arm {
  PVector position;
  List<Integer> lengths;
  List<Float> angles;
  List<Float> minAngles;
  List<Float> maxAngles;
  Effector effector;
  Effector lastEffector;
  
  public Arm(PVector position, List<Integer> lengths, List<Float> angles, List<Float> minAngles, List<Float> maxAngles) {
    this.position = position;
    this.lengths = new ArrayList<Integer>(lengths);
    this.angles = new ArrayList<Float>(angles);
    this.minAngles = new ArrayList<Float>(minAngles);
    this.maxAngles = new ArrayList<Float>(maxAngles);
    effector = new Effector(10);
    PVector end_position = calculatePosition();
    effector.setPosition((int)end_position.x, (int)end_position.y);
  }
  
  void pushEffector(Effector e) {
    lastEffector = effector;
    effector = e;
  }
  
  void popEffector() {
    effector = lastEffector;
    lastEffector = null;
  }
  
  PVector calculatePosition() {
    PMatrix2D matrix = new PMatrix2D();
    matrix.translate(position.x, position.y);
    for (int i = 0; i < angles.size(); i++) {
      matrix.translate(0, HEIGHT/2);
      matrix.rotate(angles.get(i));
      matrix.translate(lengths.get(i), -HEIGHT/2);
    }
    return screenPoint(matrix.mult(new PVector(0, HEIGHT/2, 0), null));
  }

  void updateAngles() {
    List<Float> originalAngles = new ArrayList<Float>(angles);
    for (int i = angles.size() - 1; i >= 0; i--) {
      float original = angles.get(i);
      angles.set(i, original - step / 2);
      boolean leftCollide = collisions(i);
      for (Arm arm : arms) {
        if (leftCollide) break;
        leftCollide = collisions(arm);
      }
      float x1 = effector.distanceFrom(calculatePosition());
      angles.set(i, original + step / 2);
      boolean rightCollide = collisions(i);
      for (Arm arm : arms) {
        if (rightCollide) break;
        rightCollide = collisions(arm);
      }
      float x2 = effector.distanceFrom(calculatePosition());
      float gradient = x2 - x1;
      float recovery = 0.01;
      
      float offset = gradient * 0.005 * recovery;
      if (gradient > 0 && leftCollide) {
        angles.set(i, original - offset);
      } else if (gradient < 0 && rightCollide) {
        angles.set(i, original + offset);
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
    resetMatrix();
    List<PVector[]> coords = new ArrayList<PVector[]>(angles.size());
    translate(position.x, position.y);
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
  
  boolean collisions(Arm other) {
    if (other == this) {
      return false;
    }
    List<PVector[]> myCoords = screenCoords();
    List<PVector[]> theirCoords = other.screenCoords();
    for (PVector[] a : myCoords) {
      for (PVector[] b : theirCoords) {
        if (polyPoly(a, b)) {
          return true;
        }
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
    
    boolean boundingBoxes = true;
    if (boundingBoxes) {
      for (PVector[] shape : screen_coordinates) {
        beginShape();
        vertex(shape[0].x, shape[0].y);
        vertex(shape[1].x, shape[1].y);
        vertex(shape[2].x, shape[2].y);
        vertex(shape[3].x, shape[3].y);
        endShape(CLOSE);
      }
    }
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

PVector screenPoint(PVector p) {
  return new PVector(screenX(p.x, p.y), screenY(p.x, p.y)); 
}

int HEIGHT = 4;

int num_arms = 8; 
float step = 0.09;
List<Arm> arms;
List<PVector> effector_origins;

void setup() {
  size(1280, 1024);
  frameRate(24);
  
  List<Integer> lengths = Arrays.asList(10, 40, 40, 20);
  int n = lengths.size();
  List<Float> minAngles = Arrays.asList(0f, -45f * PI/180, -100f * PI/180, -40f*PI/180);
  List<Float> maxAngles = Arrays.asList(0f, -10f * PI/180, -20f * PI/180, -10f*PI/180);

  List<Float> angles = new ArrayList<Float>(lengths.size());
  for (int i = 0; i < lengths.size(); i++) {
    angles.add(0f);
  }
  int radius = 40;
  arms = new ArrayList<Arm>(num_arms);
  effector_origins = new ArrayList<PVector>(num_arms);
  float range_of_motion = PI / 4;

  for (float angle = PI/8; angle < 2 * PI + PI/8 - 0.0001; angle += 2 * PI / num_arms) {
    float start_angle = angle - 2 * PI;
    angles.set(0, start_angle);
    List<Float> temp_minAngles = new ArrayList<Float>(minAngles.size());
    List<Float> temp_maxAngles = new ArrayList<Float>(maxAngles.size());
    temp_minAngles.add(start_angle - range_of_motion);
    temp_maxAngles.add(start_angle + range_of_motion);
   
    boolean onLeft = angle > PI / 2 && angle < 3 * PI / 2;
    for (int j = 1; j < minAngles.size(); j++) {
      if (onLeft) {
        temp_minAngles.add(-maxAngles.get(j));
        temp_maxAngles.add(-minAngles.get(j));
      } else {
        temp_minAngles.add(minAngles.get(j));
        temp_maxAngles.add(maxAngles.get(j));
      }
    }
    float circleX = radius * cos(angle),
          circleY = radius * sin(angle);
    Arm arm = new Arm(new PVector(circleX / 2, circleY, 0), lengths, angles, temp_minAngles, temp_maxAngles);
    PVector origin = arm.calculatePosition();
    origin.mult(1.2);
    origin.sub(0, 20);
    origin.add(10 * cos(angle), 10 * sin(angle));
    arm.effector.setPosition(origin);
    effector_origins.add(origin);
    arms.add(arm);
  }
  spider_position = new PVector(width / 2, height / 2, 0);
  spider_forwards = up.copy();
  target.setPosition(-width/2, -height/2);
}

int frame = 0;
float period = 50f;
float step_length = 20;
float spider_speed = 5f;

PVector spider_position;
PVector spider_forwards;
PVector up = new PVector(0,1,0);
Effector target = new Effector(10);

void mouseClicked() {
 target.setPosition(mouseX, mouseY);
}

float effector_gravity = 100;

int captured_arms = 0;
void draw() {
  background(20, 200, 220);
  pushMatrix();
  translate(spider_position.x, spider_position.y);
  int sign = spider_forwards.x < 0 ? 1 : -1;
  rotate(sign * PVector.angleBetween(up, spider_forwards));
  ellipse(0, 4, 40, 80);
  int max_captures = 3;
  for (int i = 0; i < arms.size(); i++) {
    Arm arm = arms.get(i);
    PVector end_position = arm.calculatePosition();
    if (i == 0) print(end_position.x + " " + end_position.y + "\n");
    float distance = target.distanceFrom(end_position);
    if (i == 0) print(distance + "\n");
    if (distance < effector_gravity && arm.effector != target) {
      if (captured_arms < max_captures) {
        arm.pushEffector(target);
        captured_arms++;
      }
    } else if (distance > effector_gravity && arm.effector == target) {
      arm.popEffector();
      captured_arms--;
    }
    if (arm.effector != target) {
      PVector origin = effector_origins.get(i).copy();
      origin.add(0, step_length * (i % 2 == 1 ? -1 : 1) * sin(frame++ / period));
      origin.add(step_length * cos(frame / period), 0);
      arm.effector.setPosition(screenPoint(origin));
    }
    arm.updateAngles();
    arm.draw();
  }
  popMatrix();
  for (Arm arm : arms) {
    arm.effector.draw(); 
  }
  pushMatrix();
  target.draw();
  pushStyle();
  noFill();
  circle(target.position.x, target.position.y, effector_gravity*2);
  popStyle();
  popMatrix();
  PVector direction = new PVector(mouseX - spider_position.x, mouseY - spider_position.y, 0f);
  float distance = direction.mag();
  direction.normalize();
  if (distance >= 40) {
    spider_forwards = direction.copy();
    direction.mult(min(distance, spider_speed));
    spider_position.add(direction);
  }
}
