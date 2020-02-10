import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;

class Effector {
  
  public PVector position;
  private int _size;
  
  Effector(int size) {
    _size = size;
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
    effector.position = calculatePosition();
    _screenCoords = new ArrayList<PVector[]>(angles.size());
    for (int i = 0; i < angles.size(); i++) {
      _screenCoords.add(new PVector[] {new PVector(), new PVector(), new PVector(), new PVector()}); 
    }
  }
  
  void holdTemporaryEffector(Effector e) {
    lastEffector = effector;
    effector = e;
  }
  
  void releaseTemporaryEffector() {
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
  
  List<PVector[]> _screenCoords;

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
      float x1 = effector.position.dist(calculatePosition());
      angles.set(i, original + step / 2);
      boolean rightCollide = collisions(i);
      for (Arm arm : arms) {
        if (rightCollide) break;
        rightCollide = collisions(arm);
      }
      float x2 = effector.position.dist(calculatePosition());
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
    float originalDistance = effector.position.dist(calculatePosition()),
          newDistance = effector.position.dist(calculatePosition()),
          resolution = 0.00001;
    if (originalDistance - newDistance < -resolution) {
       for (int i = 0; i < angles.size(); i++) {
         angles.set(i, originalAngles.get(i));
         PVector[] here = new PVector[4];
         float margin = 0.1;
         int xMargin = (int)(lengths.get(i) * margin),
             yMargin = (int)(HEIGHT * margin);
         here[0] = screenPoint(xMargin, yMargin);
         here[1] = screenPoint(lengths.get(i) - xMargin, yMargin);
         here[2] = screenPoint(lengths.get(i) - xMargin, HEIGHT - yMargin);
         here[3] = screenPoint(xMargin, HEIGHT - yMargin);
         _screenCoords.set(i, here);
       }
    }
  }
  
  List<PVector[]> screenCoords() {
    return new ArrayList<PVector[]>(_screenCoords);
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

float rad(float degrees) {
  return degrees * PI / 180; 
}

void setup() {
  size(640,480);
  frameRate(24);
  
  List<Float> placementAngles = Arrays.asList(
    rad(70),   // right antenna
    rad(110),  // left antenna
    rad(30),   // right front
    rad(150),  // left front
    rad(10),   // right front-middle
    rad(170),  // left front-middle
    rad(-10),  // right rear-middle
    rad(-170), // left rear-middle
    rad(-30),  // right rear
    rad(-150), // left rear
    rad(-90)   // flagellum
  );
  final float LOW_DOF = rad(10),
              MEDIUM_DOF = rad(30),
              HIGH_DOF = rad(60),
              INF_DOF = rad(1000 * PI);
  List<List<Integer>> lengths = Arrays.asList(
    Arrays.asList(30, 30, 30, 30),
    Arrays.asList(30, 30, 30, 30),
    Arrays.asList(20, 10, 20, 10),
    Arrays.asList(20, 10, 20, 10),
    Arrays.asList(20, 10, 20, 10),
    Arrays.asList(20, 10, 20, 10),
    Arrays.asList(20, 20, 20, 20),
    Arrays.asList(20, 20, 20, 20),
    Arrays.asList(20, 10, 20, 10),
    Arrays.asList(20, 10, 20, 10),
    Arrays.asList(10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10)
  );
  List<List<Float>> angles = Arrays.asList(
    Arrays.asList(rad(70), -rad(30), 0f, 0f),
    Arrays.asList(rad(110), rad(30), 0f, 0f),
    Arrays.asList(rad(30), -rad(40), -rad(30), -rad(10)),
    Arrays.asList(rad(150), rad(40), rad(30), rad(10)),
    Arrays.asList(rad(20), -rad(20), -rad(20), -rad(20)),
    Arrays.asList(-rad(160), rad(20), rad(20), rad(20)),
    Arrays.asList(rad(20), -rad(30), -rad(20), -rad(10)),
    Arrays.asList(-rad(160), rad(30), rad(20), rad(10)),
    Arrays.asList(-rad(10), -rad(50), -rad(40), -rad(40)),
    Arrays.asList(-rad(170), rad(50), rad(40), rad(40)),
    Arrays.asList(-rad(90), rad(45), -rad(45), rad(45), -rad(45), rad(45), -rad(45), rad(45), -rad(45), rad(45), -rad(45), rad(45), -rad(45), rad(45), -rad(45))
  );
  List<List<Float>> freedom = Arrays.asList(
    Arrays.asList(LOW_DOF, HIGH_DOF, MEDIUM_DOF, HIGH_DOF),
    Arrays.asList(LOW_DOF, MEDIUM_DOF, HIGH_DOF, HIGH_DOF),
    Arrays.asList(LOW_DOF, MEDIUM_DOF, HIGH_DOF, HIGH_DOF),
    Arrays.asList(LOW_DOF, MEDIUM_DOF, HIGH_DOF, HIGH_DOF),
    Arrays.asList(LOW_DOF, MEDIUM_DOF, HIGH_DOF, HIGH_DOF),
    Arrays.asList(LOW_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF),
    Arrays.asList(LOW_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF),
    Arrays.asList(LOW_DOF, MEDIUM_DOF, HIGH_DOF, HIGH_DOF),
    Arrays.asList(LOW_DOF, MEDIUM_DOF, HIGH_DOF, HIGH_DOF),
    Arrays.asList(LOW_DOF, MEDIUM_DOF, HIGH_DOF, HIGH_DOF),
    Arrays.asList(LOW_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF, HIGH_DOF)
    
  );
  int radius = 40;
  arms = new ArrayList<Arm>(num_arms);
  effector_origins = new ArrayList<PVector>(num_arms);
  for (int i = 0; i < placementAngles.size(); i++) {
    float angle = placementAngles.get(i);
    float circleX = radius * cos(angle),
          circleY = radius * sin(angle);
    List<Float> minAngles = new ArrayList<Float>(angles.get(i)),
                maxAngles = new ArrayList<Float>(angles.get(i));
    for (int j = 0; j < minAngles.size(); j++) {
      minAngles.set(j, minAngles.get(j) - freedom.get(i).get(j));
      maxAngles.set(j, maxAngles.get(j) + freedom.get(i).get(j));
    }
    Arm arm = new Arm(new PVector(circleX / 2, circleY, 0), lengths.get(i), angles.get(i), minAngles, maxAngles);
    PVector origin = arm.calculatePosition();
    origin.mult(1.2);
    origin.sub(0, 20);
    origin.add(10 * cos(angle), 10 * sin(angle));
    arm.effector.position = origin;
    effector_origins.add(origin);
    arms.add(arm);
  }
  spider_position = new PVector(width / 2, height / 2, 0);
  spider_forwards = up.copy();
  target.position = new PVector(-width/2, -height/2);
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
 target.position = new PVector(mouseX, mouseY);
}

float effector_gravity = 100;

int captured_arms = 0;
int max_captures = 4;

boolean drawEffectors = false;

void draw() {
  background(20, 200, 220);
  
  pushMatrix();
  pushStyle();
  noStroke();
  fill(20, 190, 220);
  circle(target.position.x, target.position.y, effector_gravity*2);
  popStyle();
  popMatrix();
  pushMatrix();
  translate(spider_position.x, spider_position.y);
  int sign = spider_forwards.x < 0 ? 1 : -1;
  rotate(sign * PVector.angleBetween(up, spider_forwards));
  ellipse(0, 4, 40, 80);
  for (int i = 0; i < arms.size(); i++) {
    Arm arm = arms.get(i);
    PVector end_position = arm.calculatePosition();
    float distance = target.position.dist(end_position);
    if (distance < effector_gravity && arm.effector != target) {
      if (captured_arms < max_captures) {
        arm.holdTemporaryEffector(target);
        captured_arms++;
      }
    } else if (distance > effector_gravity && arm.effector == target) {
      arm.releaseTemporaryEffector();
      captured_arms--;
    }
    if (arm.effector != target) {
      PVector origin = effector_origins.get(i).copy();
      origin.add(0, step_length * (i % 2 == 1 ? -1 : 1) * sin(frame++ / period));
      origin.add(step_length * cos((frame+3*i) / (period+i)), 0);
      arm.effector.position = screenPoint(origin);
    }
    arm.updateAngles();
    arm.draw();
  }
  popMatrix();
  if (drawEffectors) {
    for (Arm arm : arms) {
      arm.effector.draw(); 
    }
  }
  target.draw();
  PVector direction = new PVector(mouseX - spider_position.x, mouseY - spider_position.y, 0f);
  float distance = direction.mag();
  direction.normalize();
  if (distance >= 40) {
    spider_forwards = direction.copy();
    direction.mult(min(distance, spider_speed));
    spider_position.add(direction);
  }
}
