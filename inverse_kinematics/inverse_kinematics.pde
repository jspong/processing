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

int HEIGHT = 20;

class Arm {
  private int _length, _height;
  private float _theta;
  private Arm _next;
  
  Arm(int length) {
    _length = length;
    _height = HEIGHT;
    _theta = 0f;
    _next = null;
  }
  
  void set_next(Arm next) {
    _next = next;
  }
  
  void setRotation(float theta) {
    _theta = theta;
  }
  
  public void getAngles(List<Float> angles) {
    angles.add(_theta);
    if (_next != null) {
      _next.getAngles(angles);
    }
  }
  
  public void getLengths(List<Integer> lengths) {
    lengths.add(_length);
    if (_next != null) {
      _next.getLengths(lengths);
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

PVector calculatePosition(List<Float> angles, List<Integer> lengths) {
  PMatrix2D matrix = new PMatrix2D();
  for (int i = 0; i < angles.size(); i++) {
    matrix.translate(0, HEIGHT/2);
    matrix.rotate(angles.get(i));
    matrix.translate(lengths.get(i), -HEIGHT/2);
  }
  return matrix.mult(new PVector(0, HEIGHT/2), null);
}


Effector e = new Effector(20);

Arm a = new Arm(100);
Arm b = new Arm(50);
Arm c = new Arm(80);

void setup() {
  size(640, 480);
  frameRate(4);
  a.set_next(b);
  b.set_next(c);
  
}

float rotX = 0.0f, rotY = 0.0f, rotZ = 0.0f;

float step = 0.6;
PVector rot = new PVector();


void draw() {
  background(255);
  e.setPosition(mouseX, mouseY);
  e.draw();
  translate(320, 240);
  
  rot.add(new PVector(random(-step, step), random(-step, step), random(-step, step)));
  a.setRotation(rot.x);
  b.setRotation(rot.y);
  c.setRotation(rot.z);
  
  List<Float> angles = new ArrayList<Float>();
  List<Integer> lengths = new ArrayList<Integer>();
  a.getAngles(angles);
  a.getLengths(lengths);
  PVector position = calculatePosition(angles, lengths);
  fill(100, 100, 230);
  circle(position.x, position.y, 10);
  
  
  
  a.draw();
}
