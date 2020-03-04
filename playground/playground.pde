
void setup() {
  size(640, 480);
  frameRate(1);
  setupPathFinder();
  noLoop();
}

void draw() {
  drawPathFinder();
  testPathFinder();
}
