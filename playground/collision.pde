static class Collision {
  static PVector polyPoly(PVector[] p1, PVector[] p2) {
    int j = 0;
    for (int i = 0; i < p1.length; i++) {
      j = (i + 1) % p1.length;
      PVector current = p1[i];
      PVector next = p1[j];
  
      if (polyLine(p2, current, next) != null) return polyLine(p2, current, next);
    }
    return polyPoint(p1, p2[0]);
  }
  
  static PVector polyCircle(PVector[] vertices, PVector center, float radius) {
    for (int i = 0; i < vertices.length; i++) {
      int j = (i + 1) % vertices.length;
      PVector current = vertices[i];
      PVector next = vertices[j];
      if (circleLine(center, radius, current, next) != null) {
        return circleLine(center, radius, current, next);
      }
    }
    return polyPoint(vertices, center);
  }
  
  static PVector circleLine(PVector center, float radius, PVector p1, PVector p2) {
    if (circlePoint(center, radius, p1) != null) return p1;
    if (circlePoint(center, radius, p2) != null) return p2;
    
    PVector dist = PVector.sub(p2, p1);
    PVector dist2 = PVector.sub(center, p1);
    float dot = dist.dot(dist2) / pow(dist.mag(), 2);
    PVector closest = PVector.add(p1, PVector.mult(dist, dot));
    closest = new PVector(p1.x + dot * (p2.x - p1.x), p1.y + dot * (p2.y - p1.y));
    if (linePoint(p1, p2, closest) == null) {
      return null;
    }
    return circlePoint(center, radius, closest);
  }
  
  static PVector circlePoint(PVector center, float radius, PVector point) {
    if (PVector.sub(center, point).mag() <= radius) {
      return point;
    } 
    return null;
  }
  
  static PVector circleCircle(PVector c1, float r1, PVector c2, float r2) {
    if (PVector.sub(c1, c2).mag() <= r1 + r2) {
       
    }
    return null;
  }
  
  static PVector linePoint(PVector p1, PVector p2, PVector point) {
     float lineLength = PVector.sub(p2, p1).mag();
     float dist1 = PVector.sub(p1, point).mag();
     float dist2 = PVector.sub(p2, point).mag();
     float precision = 0.001;
     
     if (abs(lineLength - dist1 - dist2) <= precision) {
       return point;
     } else {
       return null;
     }
  }
  
  static PVector polyLine(PVector[] vertices, PVector p1, PVector p2) {
    for (int i = 0; i < vertices.length; i++) {
      int j = (i + 1) % vertices.length;
      if (lineLine(p1, p2, vertices[i], vertices[j]) != null) {
        return lineLine(p1, p2, vertices[i], vertices[j]);
      }
    }
    return null;
  }
  
  static PVector lineLine(PVector a1, PVector a2, PVector b1, PVector b2) {
    float uA = ((b2.x-b1.x)*(a1.y-b1.y) - (b2.y-b1.y)*(a1.x-b1.x)) / ((b2.y-b1.y)*(a2.x-a1.x) - (b2.x-b1.x)*(a2.y-a1.y));
    float uB = ((a2.x-a1.x)*(a1.y-b1.y) - (a2.y-a1.y)*(a1.x-b1.x)) / ((b2.y-b1.y)*(a2.x-a1.x) - (b2.x-b1.x)*(a2.y-a1.y));
    if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
      return PVector.add(a1, PVector.mult(PVector.sub(a2, a1), uA)); 
    } else {
      return null;
    }
  }
  
  static PVector polyPoint(PVector[] vertices, PVector point) {
    boolean collision = false;
  
    int j = 0;
    for (int i = 0; i < vertices.length; i++) {
      j = (i + 1) % vertices.length;
  
      PVector current = vertices[i];
      PVector next = vertices[j];
      
      if (linePoint(current, next, point) != null) {
        return linePoint(current, next, point);
      }
  
      if ( ((current.y > point.y && next.y < point.y) || (current.y < point.y && next.y > point.y)) && 
        (point.x < (next.x-current.x) * (point.y - current.y) / (next.y - current.y) + current.x) ) {
        collision = !collision;
      }
    }
    if (collision) {
       return new PVector(); // TODO 
    } else {
      return null;
    }
  }
}

public class CollisionTests extends TestCase {

  void testLineLine() {
    assertEqual(Collision.lineLine(new PVector(1,0), new PVector(-1,0), new PVector(0, 1), new PVector(0, -1)), new PVector(0,0));
    assertNull(Collision.lineLine(new PVector(0,0), new PVector(1,1), new PVector(1, 0), new PVector(0.9, 0.8)));
    assertNotNull(Collision.lineLine(new PVector(-1,-1), new PVector(1,1), new PVector(-1, 1), new PVector(1, -1)));
  }
  
  void testCirceLine() {
     assertNotNull(Collision.circleLine(new PVector(), 1, new PVector(), new PVector(0, 0.5))); // Line fully inside circle
     assertNotNull(Collision.circleLine(new PVector(), 1, new PVector(-1, 1), new PVector(1, 1))); // Tangential to top
     assertNotNull(Collision.circleLine(new PVector(), 1, new PVector(0.3, 0.4), new PVector(4,4))); // First end in circle
     assertNotNull(Collision.circleLine(new PVector(), 1, new PVector(4,4), new PVector(.3, .4))); // Second end in circle
     assertNotNull(Collision.circleLine(new PVector(), 1, new PVector(-2, 0), new PVector(2, 0))); // Line cuts through circle
     assertNull(Collision.circleLine(new PVector(), 1, new PVector(3, 0), new PVector(4, 1))); // Line outside circle
     assertNull(Collision.circleLine(new PVector(), 1, new PVector(2, 0), new PVector(2, 1.1)));
     
     assertNull(Collision.circleLine(new PVector(-2.1, 0), 1, new PVector(-1, 1), new PVector(1, 1)));
     assertNull(Collision.circleLine(new PVector(-2.1, 0), 1, new PVector(1, 1), new PVector(1, -1)));
     assertNull(Collision.circleLine(new PVector(-2.1, 0), 1, new PVector(1, -1), new PVector(-1, -1)));
     assertNull(Collision.circleLine(new PVector(-2.1, 0), 1, new PVector(-1, -1), new PVector(-1, 1)));
  }
  
  void testPolyLine() {
    PVector[] triangle = new PVector[] { new PVector(-1, -1), new PVector(0, 1), new PVector(1, -1) };
    assertNotNull(Collision.polyLine(triangle, triangle[0], triangle[1]), "a");
    assertNotNull(Collision.polyLine(triangle, triangle[1], triangle[2]), "b");
    assertNotNull(Collision.polyLine(triangle, triangle[2], triangle[0]), "c");
    assertEqual(Collision.polyLine(triangle, new PVector(-1, 0), new PVector(1, 0)), new PVector(-0.5,  0));
    assertNull(Collision.polyLine(triangle, new PVector(5, 0), new PVector(6, 0)));
  }
  
  void testPolyCircle() {
    PVector[] square = new PVector[] { new PVector(-1, 1), new PVector(1, 1), new PVector(1, -1), new PVector(-1, -1) };
    PVector center = new PVector();
    float radius = 1f;
    
    assertNotNull(Collision.polyCircle(square, center, radius));
    assertNotNull(Collision.polyCircle(square, new PVector(-1.9, 0), radius));
    assertNull(Collision.polyCircle(square, new PVector(-2.1, 0), radius));
  }
  
  void testPolyPoint() {
    PVector[] square = new PVector[] { new PVector(-1, 1), new PVector(1, 1), new PVector(1, -1), new PVector(-1, -1) };
    assertNotNull(Collision.polyPoint(square, new PVector()));
    assertNotNull(Collision.polyPoint(square, new PVector(0.9, 0.9)));
    assertNotNull(Collision.polyPoint(square, new PVector(0.9, -0.9)));
    assertNotNull(Collision.polyPoint(square, new PVector(-0.9, 0.9)));
    assertNull(Collision.polyPoint(square, new PVector(5,0)));
  }
}

void testCollisions() {
  runTests(CollisionTests.class); 
}
