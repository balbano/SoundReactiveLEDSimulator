// Cell object represents LEDs
class Cell {
  // A cell object knows about its location in
  // the grid as well as its size with the
  // variables x, y, w, h
  float x, y;
  float w, h;
  int red, green, blue;
  boolean alive;
  
  // Cell Constructor
  Cell(float tempX, float tempY, float tempW, 
  float tempH, int tempRed, int tempGreen, int tempBlue, boolean tempAlive) {
    x = tempX;
    y = tempY;
    w = tempW;
    h = tempH;
    red = tempRed;
    green = tempGreen;
    blue = tempBlue;
    alive = tempAlive;
  }

  void display() {
    noStroke();
    // Color calculated using sine wave
    if (alive) {
    fill(red, green, blue);
    }
    else {
    fill(16, 16, 16);
    }
    ellipse(x, y, w, h);
  }
}
