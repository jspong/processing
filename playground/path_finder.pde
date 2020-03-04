class Board {
  
  int circleSize;
  color[][] spaces;
  
  public Board(int circleSize) {
    this.circleSize = circleSize;
    
    int w = width / circleSize + 2;
    int h = width / circleSize + 2;
    print(h + " " + w);
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
