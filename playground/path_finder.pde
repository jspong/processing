import java.util.Set;
import java.util.HashSet;

public class Edge {
  Node a, b;
  float cost;
  
  public Edge(Node a, Node b) {
    this(a, b, 1); 
  }
  
  public Edge(Node a, Node b, float cost) {
    this.a = a;
    this.b = b;
    this.cost = cost;
  }
  
  public String toString() {
    return a + " <=> " + b; 
  }
  
  public boolean equals(Object other) {
    if (!(other instanceof Edge)) {
      return false;
    }
    Edge otherEdge = (Edge)other;
    return a.equals(otherEdge.a) && b.equals(otherEdge.b) || a.equals(otherEdge.b) && b.equals(otherEdge.a);
  }
  
  public int hashCode() {
    Node closer, farther;
    if (a.position.x == b.position.x) {
      if (a.position.y <= b.position.y) {
        closer = a;
        farther = b;
      } else {
        closer = b;
        farther = a;
      }
    } else if (a.position.x < b.position.x) {
      closer = a;
      farther = b;
    } else {
      closer = b;
      farther = a;
    }
    return updateHash(updateHash(int(cost * 31), closer), farther);
  }
}

int updateHash(int hash, Object b) {
  return hash * 31 + b.hashCode(); 
}

class Node {
  PVector position;

  public boolean equals(Object other) {
    if (!(other instanceof Node)) {
      return false;
    }
    return ((Node)other).position.equals(position);
  }
  
  public Node(PVector position) {
    this.position = position;
  }
  
  public String toString() {
    return "Node(" + position.x + ", " + position.y + ")"; 
  }
  
  public int hashCode() {
    return position.hashCode(); 
  }
}

class Graph {
  Set<Node> nodes;
  Set<Edge> edges;
  
  public Graph() {
    nodes = new HashSet<Node>();
    edges = new HashSet<Edge>();
  }
  
  Node addNode(PVector position) {
    Node newNode = new Node(position);
    nodes.add(new Node(position));
    return newNode;
  }
  
  Edge addEdge(PVector a, PVector b) {
    return addEdge(a, b, 1.0); 
  }
  
  Edge addEdge(PVector a, PVector b, float cost) {
    Node nodeA = new Node(a);
    Node nodeB = new Node(b);
    Edge edge = new Edge(nodeA, nodeB, cost);
    edges.add(edge);
    nodes.add(nodeA);
    nodes.add(nodeB);
    return edge;
  }
}

class Board {
  
  int circleSize;
  color[][] spaces;
  
  public Board(int circleSize) {
    this.circleSize = circleSize;
    
    int w = width / circleSize + 2;
    int h = width / circleSize + 2;
    spaces = new color[h][];
    for (int i = 0; i < h; i++) {
      spaces[i] = new color[w];
    }
  }
  
  public void draw() {
    for (int y = 0; y < spaces.length; y++) {
      for (int x = 0; x < spaces[y].length; x++) {
        spaces[y][x] = color(200, 200, 200);
        PVector center = new PVector(x * circleSize + (y % 2 == 1 ? 0 : circleSize / 2), y * circleSize);
        fill(spaces[y][x]);
        circle(center.x, center.y, circleSize);
      }
    }
  }
}

Board board;

public void setupPathFinder() {
  board = new Board(50);
  noLoop();
}

public void drawPathFinder() {
  background(255);
  board.draw();
}

public class GraphTests extends TestCase {
  
  public void testNodeEquals() {
    assertEqual(new Node(new PVector()), new Node(new PVector()));
    assertEqual(new Node(new PVector(1,2)), new Node(new PVector(1,2)));
    assertNotEqual(new Node(new PVector()), new Node(new PVector(1,2)));
    assertNotEqual(new Node(new PVector()), new PVector());
  }
  
  public void testEdgeEquals() {
    Node a1 = new Node(new PVector()), a2 = new Node(new PVector());
    Node b1 = new Node(new PVector(1, 2)), b2 = new Node(new PVector(1, 2));
    Node c = new Node(new PVector(3, 4));
    assertEqual(new Edge(a1, b1), new Edge(a2, b2));
    assertEqual(new Edge(a1, a2), new Edge(a2, a1));
    assertEqual(new Edge(a1, b1), new Edge(b2, a2));
    assertNotEqual(new Edge(a1, b1), new Edge(a1, c));
  }
  
  public void testGraphCreation() {
    Graph g = new Graph();
    g.addEdge(new PVector(), new PVector(1,2));
    g.addEdge(new PVector(), new PVector(2,3));
    g.addEdge(new PVector(), new PVector(1,2));
    g.addEdge(new PVector(1,2), new PVector(2,3));
    assertEqual(g.nodes.size(), 3);
    assertEqual(g.edges.size(), 3);
  }
}

public void testPathFinder() {
  runTests(GraphTests.class);
}
