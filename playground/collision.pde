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
    
    PVector dist = PVector.sub(p2, p1);
    PVector dist2 = PVector.sub(center, p1);
    float dot = dist.dot(dist2) / pow(dist.mag(), 2);
    PVector closest = PVector.add(p1, PVector.mult(dist, dot));
    closest = new PVector(p1.x + dot * (p2.x - p1.x), p1.y + dot * (p2.y - p1.y));
    if (!linePoint(p1, p2, closest)) {
      return false;
    }
    return circlePoint(center, radius, closest);
  }
  
  static boolean circlePoint(PVector center, float radius, PVector point) {
    return PVector.sub(center, point).mag() <= radius;
  }
  
  static boolean circleCircle(PVector c1, float r1, PVector c2, float r2) {
    return PVector.sub(c1, c2).mag() <= r1 + r2; 
  }
  
  static boolean linePoint(PVector p1, PVector p2, PVector point) {
     float lineLength = PVector.sub(p2, p1).mag();
     float dist1 = PVector.sub(p1, point).mag();
     float dist2 = PVector.sub(p2, point).mag();
     float precision = 0.001;
     
     return abs(lineLength - dist1 - dist2) <= precision;
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
    float uA = ((b2.x-b1.x)*(a1.y-b1.y) - (b2.y-b1.y)*(a1.x-b1.x)) / ((b2.y-b1.y)*(a2.x-a1.x) - (b2.x-b1.x)*(a2.y-a1.y));
    float uB = ((a2.x-a1.x)*(a1.y-b1.y) - (a2.y-a1.y)*(a1.x-b1.x)) / ((b2.y-b1.y)*(a2.x-a1.x) - (b2.x-b1.x)*(a2.y-a1.y));
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

public static class CollisionTests extends TestCase {
  public CollisionTests() {
    super();
  }
  void testLineLine() {
    assertTrue(Collision.lineLine(new PVector(1,0), new PVector(-1,0), new PVector(0, 1), new PVector(0, -1)));
    assertFalse(Collision.lineLine(new PVector(0,0), new PVector(1,1), new PVector(1, 0), new PVector(0.9, 0.8)));
    assertTrue(Collision.lineLine(new PVector(-1,-1), new PVector(1,1), new PVector(-1, 1), new PVector(1, -1)));
  }
  
  void testCirceLine() {
     assertTrue(Collision.circleLine(new PVector(), 1, new PVector(), new PVector(0, 0.5))); // Line fully inside circle
     assertTrue(Collision.circleLine(new PVector(), 1, new PVector(-1, 1), new PVector(1, 1))); // Tangential to top
     assertTrue(Collision.circleLine(new PVector(), 1, new PVector(0.3, 0.4), new PVector(4,4))); // First end in circle
     assertTrue(Collision.circleLine(new PVector(), 1, new PVector(4,4), new PVector(.3, .4))); // Second end in circle
     assertTrue(Collision.circleLine(new PVector(), 1, new PVector(-2, 0), new PVector(2, 0))); // Line cuts through circle
     assertFalse(Collision.circleLine(new PVector(), 1, new PVector(3, 0), new PVector(4, 1))); // Line outside circle
     assertFalse(Collision.circleLine(new PVector(), 1, new PVector(2, 0), new PVector(2, 1.1)));
     
     assertFalse(Collision.circleLine(new PVector(-2.1, 0), 1, new PVector(-1, 1), new PVector(1, 1)), "top");
     assertFalse(Collision.circleLine(new PVector(-2.1, 0), 1, new PVector(1, 1), new PVector(1, -1)), "right");
     assertFalse(Collision.circleLine(new PVector(-2.1, 0), 1, new PVector(1, -1), new PVector(-1, -1)), "bottom");
     assertFalse(Collision.circleLine(new PVector(-2.1, 0), 1, new PVector(-1, -1), new PVector(-1, 1)), "left");
  }
  
  void testPolyLine() {
    PVector[] triangle = new PVector[] { new PVector(-1, -1), new PVector(0, 1), new PVector(1, -1) };
    assertTrue(Collision.polyLine(triangle, triangle[0], triangle[1]));
    assertTrue(Collision.polyLine(triangle, triangle[1], triangle[2]));
    assertTrue(Collision.polyLine(triangle, triangle[2], triangle[0]));
    assertTrue(Collision.polyLine(triangle, new PVector(-1, 0), new PVector(1, 0)));
    assertFalse(Collision.polyLine(triangle, new PVector(5, 0), new PVector(6, 0)));
  }
  
  void testPolyCircle() {
    PVector[] square = new PVector[] { new PVector(-1, 1), new PVector(1, 1), new PVector(1, -1), new PVector(-1, -1) };
    PVector center = new PVector();
    float radius = 1f;
    
    assertTrue(Collision.polyCircle(square, center, radius));
    assertTrue(Collision.polyCircle(square, new PVector(-1.9, 0), radius));
    assertFalse(Collision.polyCircle(square, new PVector(-2.1, 0), radius));
  }
  
  void testPolyPoint() {
    PVector[] square = new PVector[] { new PVector(-1, 1), new PVector(1, 1), new PVector(1, -1), new PVector(-1, -1) };
    assertTrue(Collision.polyPoint(square, new PVector()));
    assertTrue(Collision.polyPoint(square, new PVector(-0.9, -0.9)));
    assertTrue(Collision.polyPoint(square, new PVector(0.9, 0.9)));
    assertTrue(Collision.polyPoint(square, new PVector(0.9, -0.9)));
    assertTrue(Collision.polyPoint(square, new PVector(-0.9, 0.9)));
    assertFalse(Collision.polyPoint(square, new PVector(5,0)));
  }
}

void testCollisions() {
  runTests(CollisionTests.class); 
}
