static class Collision {
  static boolean polyPoly(PVector[] p1, PVector[] p2) {
    int j = 0;
    for (int i = 0; i < p1.length; i++) {
      j = (i + 1) % p1.length;
      PVector current = p1[i];
      PVector next = p1[j];
  
      if (polyLine(p2, current.x, current.y, next.x, next.y)) return true;
    }
    return polyPoint(p1, p2[0].x, p2[0].y);
  }
  
  static boolean polyLine(PVector[] vertices, float x1, float y1, float x2, float y2) {
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
  
  static boolean lineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
    float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
    float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
    return uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1;
  }
  
  static boolean polyPoint(PVector[] vertices, float x, float y) {
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
}
