void setup() {
  size(640, 480);
}

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

Effector e = new Effector(20);

void draw() {
  background(255);
  e.setPosition(mouseX, mouseY);
  e.draw();
}
