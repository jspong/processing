

class Effector {
  
  private int _x, _y, _size;
  
  Effector(int size) {
    _size = size;
  }
    
  
  void setPosition(int x, int y) {
    _x = x;
    _y = y;
  }
  
  void draw() {
    pushStyle();
    fill(200, 0, 0);
    circle(_x, _y, _size);
  }

}

class Arm {
  private int _length, _height;
  private float _theta;
  private Arm _next;
  
  Arm(int length) {
    _length = length;
    _height = 20;
    _theta = 0f;
    _next = null;
  }
  
  void set_next(Arm next) {
    _next = next;
  }
  
  void setRotation(float theta) {
    _theta = theta;
  }
  
  public PVector tipPosition() {
    PMatrix2D matrix = new PMatrix2D();
    tipPosition(matrix);
    return matrix.mult(new PVector(0, _height/2, 0), null);
  }
  
  public void tipPosition(PMatrix2D matrix) {
    matrix.translate(0,_height/2);
    matrix.rotate(_theta);
    matrix.translate(0,-_height/2);
    matrix.translate(_length, 0);
    if (_next != null) {
      _next.tipPosition(matrix);
    }
  }
  
  void draw() {
    pushMatrix();
    pushStyle();
    fill(255);
    translate(0, _height/2);
    rotate(_theta);
    translate(0, -_height/2);
    rect(0, 0, _length, _height);
    translate(_length, 0);
    if (_next != null) {
      _next.draw();
    }
    popStyle();
    popMatrix();
  }
  
  
}


Effector e = new Effector(20);

Arm a = new Arm(100);
Arm b = new Arm(50);
Arm c = new Arm(80);

void setup() {
  size(640, 480);
  frameRate(2);
  a.set_next(b);
  b.set_next(c);
}

float rotX = 0.0f, rotY = 0.0f, rotZ = 0.0f;

void draw() {
  background(255);
  e.setPosition(mouseX, mouseY);
  e.draw();
  translate(320, 240);
  
  float thrash = PI/4;
  rotX += random(-thrash, thrash);
  rotY += random(-thrash, thrash);
  rotZ += random(-thrash, thrash);
  a.setRotation(rotX);
  b.setRotation(rotY);
  c.setRotation(rotZ);
  
  a.draw();
  PVector spot = a.tipPosition();
  fill(100, 100, 200);
  circle(spot.x, spot.y, 10);
}
