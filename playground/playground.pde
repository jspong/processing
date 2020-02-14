
void setup() {
  size(640, 480);
  frameRate(24);
  setupPhysics();
  testCollisions();
  noLoop();
}

void draw() {
  drawPhysics();
}
