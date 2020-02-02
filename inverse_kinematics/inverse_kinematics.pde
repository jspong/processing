import java.util.Arrays;
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

PVector calculatePosition(List<Float> angles, List<Integer> lengths) {
  PMatrix2D matrix = new PMatrix2D();
  for (int i = 0; i < angles.size(); i++) {
    matrix.translate(0, HEIGHT/2);
    matrix.rotate(angles.get(i));
    matrix.translate(lengths.get(i), -HEIGHT/2);
  }
  return matrix.mult(new PVector(0, HEIGHT/2, 0), null);
}

Effector e = new Effector(20);

List<Float> calculateGradient(List<Float> angles, List<Integer> lengths) {
  List<Float> gradient = new ArrayList<Float>(angles.size());
  for (int i = 0; i < angles.size(); i++) {
    float original = angles.get(i);
    
    angles.set(i, original - step / 2);
    float x1 = e.distanceFrom(calculatePosition(angles, lengths));
    
    angles.set(i, original + step / 2);
    float x2 = e.distanceFrom(calculatePosition(angles, lengths));
    
    angles.set(i, original);
    gradient.add(x2 - x1);
  }
  return gradient;
}

float lengthOf(List<Float> vector) {
   float size = 0;
   for (int i = 0; i < vector.size(); i++) {
      size += vector.get(i) * vector.get(i); 
   }
   return sqrt(size);
}

void draw(List<Float> angles, List<Integer> lengths) {
  pushMatrix();
  pushStyle();
  fill(255);
  for (int i = 0; i < angles.size(); i++) {
    translate(0, HEIGHT/2);
    rotate(angles.get(i));
    translate(0, -HEIGHT/2);
    rect(0, 0, lengths.get(i), HEIGHT);
    translate(lengths.get(i), 0);
  }  
  popStyle();
  popMatrix(); 
}

List<Float> angles;
List<Integer> lengths;
float step = 0.09;

void setup() {
  size(640, 480);
  frameRate(24);
  
  int n = 10;
  angles = new ArrayList<Float>(n);
  lengths = new ArrayList<Integer>(n);
  for (int i = 0; i < n; i++) {
    angles.add(0f);
    lengths.add(30);
  }
}

void draw() {
  background(140, 200, 100);
  int x = width / 2, y = height / 2;
  e.setPosition(mouseX-x, mouseY-y);
  translate(x, y);
  List<Float> gradient = calculateGradient(angles, lengths);
  
  float distance = e.distanceFrom(calculatePosition(angles, lengths));
  float scale = distance / width * 0.5;
  for (int i = 0; i < angles.size(); i++) {
    angles.set(i, angles.get(i) - gradient.get(i) / lengthOf(gradient) * scale); 
  }
  
  draw(angles, lengths);
  e.draw();
  
  PVector tip = calculatePosition(angles, lengths);
  fill(100, 100, 230);
  circle(tip.x, tip.y, 10);
  
}
