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
    gradient.add((x2 - x1) / step);
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
  List<PVector[]> screen_coordinates = screenCoords(angles);
  pushStyle();
  fill(255);
  int[] collisions = new int[screen_coordinates.size()];
  for (int i = 0; i < collisions.length; i++) {
    collisions[i] = 0; 
  }
  for (int i = 0; i < collisions.length; i++) {
    for (int j = i + 1; j < collisions.length; j++) {
       if (polyPoly(screen_coordinates.get(i), screen_coordinates.get(j))) {
         collisions[i]++;
         collisions[j]++;
       }
    }
  }
  for (int i = 0; i < angles.size(); i++) {
    translate(0, HEIGHT/2);
    rotate(angles.get(i));
    translate(0, -HEIGHT/2);
    float t = (float)collisions[i] / collisions.length;
    fill(color(lerp(255,200,t), lerp(255, 20,t), lerp(255, 140, t)));
    rect(0, 0, lengths.get(i), HEIGHT);
    translate(lengths.get(i), 0);
  }  
  popStyle();
  popMatrix(); 
}

List<PVector[]> screenCoords(List<Float> angles) {
  pushMatrix();
  List<PVector[]> coords = new ArrayList<PVector[]>(angles.size());
  for (int i = 0; i < angles.size(); i++) {
     translate(0, HEIGHT/2);
     rotate(angles.get(i));
     translate(0, -HEIGHT/2);
     PVector[] here = new PVector[4];
     here[0] = screenPoint(0, 0);
     here[1] = screenPoint(lengths.get(i), 0);
     here[2] = screenPoint(lengths.get(i), HEIGHT);
     here[3] = screenPoint(0, HEIGHT);
     coords.add(here);
     translate(lengths.get(i), 0);
  }
  popMatrix();
  return coords;
}

boolean polyPoly(PVector[] p1, PVector[] p2) {
  int j = 0;
  for (int i = 0; i < p1.length; i++) {
    j = (i + 1) % p1.length;
    PVector current = p1[i];
    PVector next = p1[j];
    
    if (polyLine(p2, current.x, current.y, next.x, next.y)) return true;
  }
  return polyPoint(p1, p2[0].x, p2[0].y);
}

boolean polyLine(PVector[] vertices, float x1, float y1, float x2, float y2) {
  int j = 0;
  for (int i = 0; i < vertices.length; i++) {
    j = (i + 1) % vertices.length;
    float x3 = vertices[i].x,
          y3 = vertices[i].y,
          x4 = vertices[j].x,
          y4 = vertices[j].y;
    if (lineLine(x1, y1, x2, y2, x3, y3, x4, y4)) return true;
  }
  return false;
}

boolean lineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  return uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1;
}

boolean polyPoint(PVector[] vertices, float x, float y) {
   boolean collision = false;
   
   int j = 0;
   for (int i = 0; i < vertices.length; i++) {
     j = (i + 1) % vertices.length;
     
     PVector current = vertices[i];
     PVector next = vertices[j];
     
     if ( ((current.y > y && next.y < y) || (current.y < y && next.y > y)) && 
          (x < (next.x-current.x) * (y - current.y) / (next.y - current.y) + current.x) ) {
       collision = !collision;
     }
   }
   return collision;
}

PVector screenPoint(int x, int y) {
  return new PVector(screenX(x, y), screenY(x, y)); 
}

List<Float> angles;
List<Integer> lengths;
float step = 0.09;

void setup() {
  size(640, 480);
  frameRate(24);
  
  lengths = Arrays.asList(10, 20, 30, 40, 30, 30, 30, 20, 20, 30, 10, 30, 30, 5);
  angles = new ArrayList<Float>(lengths.size());
  for (int i = 0; i < lengths.size(); i++) {
    angles.add(0f);
  }
}

void draw() {
  background(140, 200, 100);
  int x = width / 2, y = height / 2;
  e.setPosition(mouseX-x, mouseY-y);
  translate(x, y);
  List<Float> gradient = calculateGradient(angles, lengths);
  
  float distance = e.distanceFrom(calculatePosition(angles, lengths));
  float scale = distance / width * 0.001;
  for (int i = angles.size() - 1; i >= 0; i--) {
    angles.set(i, angles.get(i) - gradient.get(i) * scale); 
  }
  
  draw(angles, lengths);
  e.draw();
  
  PVector tip = calculatePosition(angles, lengths);
  fill(100, 100, 230);
  circle(tip.x, tip.y, 10);
}
