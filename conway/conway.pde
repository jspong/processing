// CONFIGURATION VARIABLES

int NUM_CELLS = 32;              // The width and height of the board in cells
boolean ANIMATE = true;          // Whether or not to animate state transitions

int UPDATES_PER_SECOND = 4;      // The number of simulation steps per second
int STARTING_PERCENT = 30;       // How much of the board should be filled in setup
int FRAME_RATE = 32;             // The overall framerate of the simulation

// SYSTEM STATE
Cell[][] cells = new Cell[NUM_CELLS][NUM_CELLS];

// EVENT FUNCTIONS
void setup() {
  size(1024,1024);
  frameRate(FRAME_RATE);
  background(255);

  for (int i = 0; i < NUM_CELLS; i++) {
    for (int j = 0; j < NUM_CELLS; j++) {
      cells[i][j] = new Cell(random(100) < STARTING_PERCENT ? ALIVE : DEAD);
    }
  }
}

void draw() {
  step();
  
  for (int i = 0; i < NUM_CELLS; i++) {
    for (int j = 0; j < NUM_CELLS; j++) {
      cells[i][j].draw(i, j);
      cells[i][j].tick();
    }
  }
}

// GAME LOGIC

void step() {
  for (int i = 0; i < NUM_CELLS; i++) {
    for (int j = 0; j < NUM_CELLS; j++) {
      int neighbors = numNeighbors(i,j);
      if (cells[i][j].state == DEAD) {
         if (neighbors == 3) {
           cells[i][j].revive();
         }  
      } else if (cells[i][j].state == ALIVE) {
        if (neighbors < 2 || neighbors > 3) {
           cells[i][j].kill();
         }
      }
    }
  }
}

// HELPERS

Color lerp(Color a, Color b, float t) {
  return new Color(lerp(a.r, b.r, t),
                   lerp(a.g, b.g, t),
                   lerp(a.b, b.b, t));
}

int getValue(int x, int y) {
   if (x < 0 || y < 0 || x >= NUM_CELLS || y >= NUM_CELLS) {
     return 0;
   }
   return cells[x][y].state;
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

// CLASSES

class Cell {
  int state,                // The current state, for calculating simulation
      next_state;   // The next computed state, to be updated after animation
  private float count;      // The number of remaining animation steps
  
  Cell(int state) {
    this.state = this.next_state = state;
    this.count = 0;
  }
  
  void kill() {
    if (next_state != DEAD) {
      next_state = DEAD;
      count = TRANSITION_COUNT;
    }
  }
  
  void revive() {
    if (next_state != ALIVE) {
      next_state = ALIVE;
      count = TRANSITION_COUNT;
    }
  }
  
  void tick() {
    if (count > 0) {
      count -= 1;
    }
    if (count <= 0) {
      state = next_state;
    }
  }
  
  void draw(int x, int y) {
    int cell_width = width / NUM_CELLS;
    int cell_height = height / NUM_CELLS;
    _color().set_fill();
    rect(x * cell_width, y * cell_height, cell_width, cell_height);
  }
  
  private Color _color() {
    Color target = next_state == ALIVE ? BLACK : WHITE;
    if (ANIMATE && count > 0) {
      Color other = next_state == ALIVE ? BLUE : RED;
      float t = pow(count / TRANSITION_COUNT, 1.5);
      return lerp(target, other, t);
    }
    return target;
  }
}

class Color {
  private float r, g, b;
  
  Color(float r, float g, float b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  void set_fill() {
    fill(r, g, b);
  }
}

// CONSTANTS

Color WHITE = new Color(255,255,255);
Color BLACK = new Color(0, 0, 0);
Color RED = new Color(255, 128, 128);
Color BLUE = new Color(128, 200, 255);

int DEAD = 0;
int ALIVE = 1;

float TRANSITION_COUNT = FRAME_RATE / UPDATES_PER_SECOND;
