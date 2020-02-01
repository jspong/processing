

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
    rect(_x - _size / 2, _y - _size / 2, _size, _size);
  }

}

class Arm {
  private int _length, _height;
  private float _theta;
  private Arm _next;
  
  Arm(int length) {
    _length = length;
    _height = 5;
    _theta = 0f;
    _next = null;
  }
  
  void set_next(Arm next) {
    _next = next;
  }
  
  void setRotation(float theta) {
    _theta = theta;
  }
  
  void draw() {
    pushMatrix();
    translate(0, _height/2);
    rotate(_theta);
    translate(0, -_height/2);
    rect(0, 0, _length, _height);
    translate(_length, 0);
    if (_next != null) {
      _next.draw();
    }
    
    popMatrix();
  }
}


Effector e = new Effector(20);

Arm a = new Arm(100);
Arm b = new Arm(50);
Arm c = new Arm(80);

void setup() {
  size(640, 480);
  frameRate(24);
  a.set_next(b);
  b.set_next(c);
}

float rot = 0.1f;

void draw() {
  background(255);
  e.setPosition(mouseX, mouseY);
  e.draw();
  translate(320, 240);
  a.draw();
  rot += 0.1f;
  a.setRotation(rot);
  b.setRotation(rot);
  c.setRotation(rot);
}
