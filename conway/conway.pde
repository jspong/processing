int num_cells = 32;

int[][] cells = new int[num_cells][num_cells];

void setup() {
  size(1024,1024);
  frameRate(4);
  background(255);

  for (int i = 0; i < num_cells; i++) {
    for (int j = 0; j < num_cells; j++) {
      cells[i][j] = random(10) < 3 ? 1 : 0;
    }
  }
}

void draw() {
  
  int cell_width = width / num_cells;
  int cell_height = height / num_cells;
  
  for (int i = 0; i < num_cells; i++) {
    for (int j = 0; j < num_cells; j++) {
      fill(255*(1-cells[i][j]));
      rect(i * cell_width, j * cell_height, cell_width, cell_height);
    }
  }
  int[][] next = new int[num_cells][num_cells];
  for (int i = 0; i < num_cells; i++) {
    for (int j = 0; j < num_cells; j++) {
      int neighbors = numNeighbors(i,j);
       if (cells[i][j] == 0) {
          if (neighbors == 3) {
            next[i][j] = 1;
          }  
       } else {
          if (neighbors == 2 || neighbors == 3) {
            next[i][j] = 1;          }
       }
    }
  }
  cells = next;
}

int getValue(int x, int y) {
   if (x < 0 || y < 0 || x >= num_cells || y >= num_cells) {
     return 0;
   }
   return cells[x][y];
}

int numNeighbors(int x, int y) {
  return getValue(x-1, y-1) +
         getValue(x-1, y+0) +
         getValue(x-1, y+1) +
         getValue(x+0, y-1) +
         getValue(x+0, y+1) +
         getValue(x+1, y-1) +
         getValue(x+1, y+0) +
         getValue(x+1, y+1);
}

void mousePressed() {
  redraw();
}
