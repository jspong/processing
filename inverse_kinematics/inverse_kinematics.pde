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
      }
    }
  }

  List<PVector[]> screenCoords() {
    List<PVector[]> screen_coords = new ArrayList<PVector[]>(angles.size());
    pushMatrix();
    resetMatrix();
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
      screen_coords.add(here);
      translate(lengths.get(i), 0);
    }
    popMatrix();
    return screen_coords;
  }

  boolean collisions(int i) {
    List<PVector[]> coords = screenCoords();
    for (int j = 0; j < coords.size(); j++) {
      if (abs(i-j) < 2) continue;
      if (Collision.polyPoly(coords.get(i), coords.get(j))) {
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
        if (Collision.polyPoly(a, b)) {
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
        if (Collision.polyPoly(screen_coordinates.get(i), screen_coordinates.get(j))) {
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
      fill(color(lerp(255, 200, t), lerp(255, 20, t), lerp(255, 140, t)));
      ellipse(lengths.get(i)/2, HEIGHT/2, lengths.get(i), HEIGHT);
      translate(lengths.get(i), 0);
    }

    popStyle();
    popMatrix();

    pushMatrix();
    resetMatrix();
    boolean boundingBoxes = false;
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
    popMatrix();
  }
}


void setup() {
  size(640, 480);
  frameRate(24);

  List<Float> placementAngles = Arrays.asList(
    radians(70), // right antenna
    radians(110), // left antenna
    radians(30), // right front
    radians(150), // left front
    radians(10), // right front-middle
    radians(170), // left front-middle
    radians(-10), // right rear-middle
    radians(-170), // left rear-middle
    radians(-30), // right rear
    radians(-150), // left rear
    radians(-90)   // flagellum
    );
  final float LOW_DOF = radians(10), 
    MEDIUM_DOF = radians(30), 
    HIGH_DOF = radians(60), 
    INF_DOF = radians(1000 * PI);
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
    Arrays.asList(radians(70), -radians(30), 0f, 0f), 
    Arrays.asList(radians(110), radians(30), 0f, 0f), 
    Arrays.asList(radians(40), -radians(40), -radians(30), -radians(10)), 
    Arrays.asList(radians(140), radians(40), radians(30), radians(10)), 
    Arrays.asList(radians(20), -radians(20), -radians(20), -radians(20)), 
    Arrays.asList(-radians(160), radians(20), radians(20), radians(20)), 
    Arrays.asList(radians(20), -radians(30), -radians(20), -radians(10)), 
    Arrays.asList(-radians(160), radians(30), radians(20), radians(10)), 
    Arrays.asList(-radians(10), -radians(50), -radians(40), -radians(40)), 
    Arrays.asList(-radians(170), radians(50), radians(40), radians(40)), 
    Arrays.asList(-radians(90), radians(45), -radians(45), radians(45), -radians(45), radians(45), -radians(45), radians(45), -radians(45), radians(45), -radians(45), radians(45), -radians(45), radians(45), -radians(45))
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
  arms = new ArrayList<Arm>(angles.size());
  effector_origins = new ArrayList<PVector>(angles.size());
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
