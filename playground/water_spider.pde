
int HEIGHT = 4;

float step = 0.09;
List<Arm> arms;
List<PVector> effector_origins;

int frame = 0;
float period = 50f;
float step_length = 20;
float spider_speed = 5f;

PVector spider_position;
PVector spider_forwards;
PVector up = new PVector(0, 1, 0);
Effector target = new Effector(10);

void mouseClicked() {
  target.position = new PVector(mouseX, mouseY);
}

float effector_gravity = 100;

int captured_arms = 0;
int max_captures = 4;

boolean drawEffectors = false;

void setupWaterSpider() {

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

void drawWaterSpider() {
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
