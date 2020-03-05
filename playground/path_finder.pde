import java.util.ArrayList;
import java.util.List;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

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
  
  Set<Node> getNeighbors(PVector position) {
    return getNeighbors(new Node(position));
  }
  
  Set<Node> getNeighbors(Node n) {
    Set<Node> nodes = new HashSet<Node>();
    for (Edge e : edges) {
      if (e.a.equals(n) && !e.b.equals(n)) {
        nodes.add(e.b);
      } else if (e.b.equals(n) && !e.a.equals(n)) {
        nodes.add(e.a);
      }
    }
    return nodes;
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
  
  List<Edge> shortestPath(PVector a, PVector b) {
    Set<Node> visited = new HashSet<Node>();
    Map<Node, Float> distances = new HashMap<Node, Float>();
    for (Node n : nodes) {
      distances.put(n, 0f); 
    }
    Set<Node> toVisit = new HashSet<Node>();
    toVisit.add(new Node(a));
    while (visited.size() < nodes.size()) {
      Node current = null;
      float distance = Integer.MAX_VALUE;
      for (Node n : (toVisit.size() == 0 ? nodes : toVisit)) {
        if (visited.contains(n)) continue;
        if (distances.get(n) < distance) {
          distance = distances.get(n);
          current = n;
          print(distance + " " + current + " ");
        }
      }
      
      toVisit.remove(current);
      
      print("\n");
      Set<Node> neighbors = getNeighbors(current);
      boolean unvisitedNeighbors = false;
      for (Node neighbor : neighbors) {
        if (visited.contains(neighbor)) continue;
        unvisitedNeighbors = true;
        if (distances.get(neighbor) == 0 || distances.get(neighbor) > distances.get(current) + 1) { // TODO: cost != 1
          distances.put(neighbor, distances.get(current) + 1);
        }
        toVisit.add(neighbor);
      }
      visited.add(current);
    }
    
    for (Node node : visited) {
      fill(0);
      textSize(18);
      text((int)distances.get(node).floatValue(), node.position.x, node.position.y);
      print(distances.get(node) + " " + node.position.x + " " + node.position.y + "\n");
    }
    
    Node target = new Node(b);
    Node start = new Node(a);
    Node current = target;
    
    List<Edge> path = new ArrayList<Edge>();
    
    while (!current.equals(start)) {
      Node last = current;
      float distance = distances.get(current);
      for (Node neighbor : getNeighbors(current)) {
        if (distances.get(neighbor) < distance) {
          distance = distances.get(neighbor);
          current = neighbor;
        }
      }
      path.add(0, new Edge(current, last));
    }
    
    return path;
  }
}

class Board {
  
  int circleSize;
  color[][] spaces;
  Graph g;
  
  public Board(int circleSize) {
    this.circleSize = circleSize;
    
    int w = width / circleSize + 2;
    int h = width / circleSize + 2;
    spaces = new color[h][];
    for (int i = 0; i < h; i++) {
      spaces[i] = new color[w];
    }
    g = new Graph();
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        if (x > 0) {
          g.addEdge(positionOf(x, y), positionOf(x-1, y));
        }
        if (x < w-1) {
          g.addEdge(positionOf(x, y), positionOf(x+1, y)); 
        }
        if (y > 0) {
          g.addEdge(positionOf(x, y), positionOf(x, y-1));
        }
        if (y < h-1) {
          g.addEdge(positionOf(x, y), positionOf(x, y+1));
        }
        if (y % 2 == 1) {
          if (y > 0 && x > 0) {
            g.addEdge(positionOf(x, y), positionOf(x-1, y-1));
          }
          if (y < h-1 && x > 0) {
            g.addEdge(positionOf(x, y), positionOf(x-1, y+1)); 
          }
        }
      }
    }
  }
  
  PVector positionOf(int x, int y) {
    return new PVector(x * circleSize + (y % 2 == 1 ? 0 : circleSize / 2), y * circleSize); 
  }
  
  public void draw() {
    for (Node n : board.g.nodes) {
      fill(200);
      circle(n.position.x, n.position.y, circleSize);
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
  List<Edge> path = board.g.shortestPath(board.positionOf(3, 3), board.positionOf(10, 5));
 
  strokeWeight(4);
  for (Edge e : path) {
    stroke(255,0,0);
    line(e.a.position.x, e.a.position.y, e.b.position.x, e.b.position.y);
  }
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
