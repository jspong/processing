
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
