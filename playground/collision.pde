static class Collision {
  static boolean polyPoly(PVector[] p1, PVector[] p2) {
    int j = 0;
    for (int i = 0; i < p1.length; i++) {
      j = (i + 1) % p1.length;
      PVector current = p1[i];
      PVector next = p1[j];
  
      if (polyLine(p2, current, next)) return true;
    }
    return polyPoint(p1, p2[0]);
  }
  
  static boolean polyCircle(PVector[] vertices, PVector center, float radius) {
    for (int i = 0; i < vertices.length; i++) {
      int j = (i + 1) % vertices.length;
      PVector current = vertices[i];
      PVector next = vertices[j];
      if (circleLine(center, radius, current, next)) {
        return true;
      }
    }
    return polyPoint(vertices, center); 
  }
  
  static boolean circleLine(PVector center, float radius, PVector p1, PVector p2) {
    if (circlePoint(center, radius, p1)) return true;
    if (circlePoint(center, radius, p2)) return true;
    
    PVector dist = p2.copy();
    dist.sub(p1);
    float len = dist.mag();
    float dot = p1.dot(p2);
    PVector closest = dist.copy();
    closest.mult(dot);
    closest.add(p1);
    if (!linePoint(p1, p2, closest)) return false;
    closest.sub(center);
    return closest.mag() <= radius;
  }
  
  static boolean circlePoint(PVector center, float radius, PVector point) {
    PVector distance = point.copy();
    distance.sub(center);
    return distance.mag() <= radius; 
  }
  
  static boolean linePoint(PVector p1, PVector p2, PVector point) {
     PVector line = p2.copy();
     p2.sub(p1);
     PVector edge1 = p2.copy();
     edge1.sub(point);
     PVector edge2 = p1.copy();
     edge2.sub(point);
     float precision = 0.01;
     
     return line.mag() - edge1.mag() - edge2.mag() <= precision;
  }
  
  static boolean polyLine(PVector[] vertices, PVector p1, PVector p2) {
    int j = 0;
    for (int i = 0; i < vertices.length; i++) {
      j = (i + 1) % vertices.length;
      if (lineLine(p1, p2, vertices[i], vertices[j])) return true;
    }
    return false;
  }
  
  static boolean lineLine(PVector a1, PVector a2, PVector b1, PVector b2) {
    float x1 = a1.x,
          y1 = a1.y,
          x2 = a2.x,
          y2 = a2.y,
          x3 = b1.x,
          y3 = b1.y,
          x4 = b2.x,
          y4 = b2.y;
    float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
    float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
    return uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1;
  }
  
  static boolean polyPoint(PVector[] vertices, PVector point) {
    boolean collision = false;
  
    int j = 0;
    for (int i = 0; i < vertices.length; i++) {
      j = (i + 1) % vertices.length;
  
      PVector current = vertices[i];
      PVector next = vertices[j];
  
      if ( ((current.y > point.y && next.y < point.y) || (current.y < point.y && next.y > point.y)) && 
        (point.x < (next.x-current.x) * (point.y - current.y) / (next.y - current.y) + current.x) ) {
        collision = !collision;
      }
    }
    return collision;
  }
}
