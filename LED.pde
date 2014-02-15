/**
  Processing simulation of sound reactive LED installation for the University of Chicago Arts Incubator.
  MFA 6009-004: Nodes II | Spring 2014 | SAIC
  SAIC Students: Brendan Albano, Haley Shonkwiler, Maggie Grady
  External Collaborators: Kate Barbaria
  
  Copyright (c) 2014 Brendan Albano, Haley Shonkwiler, Kate Barbaria, Maggie Grady.
  The MIT License (MIT)
*/

// LED object represents LEDs
class LED {
  // LEDs know their position, size, color and if they are alive (for Game of Life)
  float x, y;
  float w, h;
  int red, green, blue;
  boolean alive;
  
  // LED Constructor
  LED(float tempX, float tempY, float tempW, 
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
    if (alive) {
      fill(red, green, blue);
    }
    else {
      fill(16, 16, 16);
    }
    ellipse(x, y, w, h);
  }
}
