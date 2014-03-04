/**
 Processing simulation of sound reactive LED installation for the University of Chicago Arts Incubator.
 MFA 6009-004: Nodes II | Spring 2014 | SAIC
 SAIC Students: Brendan Albano, Haley Shonkwiler, Maggie Grady
 External Collaborators: Kate Barbaria
 
 Copyright (c) 2014 Brendan Albano, Haley Shonkwiler, Kate Barbaria, Maggie Grady.
 The MIT License (MIT)
 */

void iteration() {
  // Iterate Game of Life simulation.
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      gridBuffer[x][y].x = grid[x][y].x;
      gridBuffer[x][y].y = grid[x][y].y;
      gridBuffer[x][y].w = grid[x][y].w;
      gridBuffer[x][y].h = grid[x][y].h;
      if (colorMixing) {
        gridBuffer[x][y].red = grid[x][y].red;
        gridBuffer[x][y].green = grid[x][y].green;
        gridBuffer[x][y].blue = grid[x][y].blue;
      }
      gridBuffer[x][y].alive = grid[x][y].alive;
    }
  }
  // Count each cell's neighbors.
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      int neighbors = 0;
      int neighbor_red_sum = 0;
      int neighbor_green_sum = 0;
      int neighbor_blue_sum = 0;
      for (int xx = x-1; xx <= x+1; xx++) {
        for (int yy = y-1; yy <= y+1; yy++) {
          if ( ((xx >= 0)&&(xx < cols)) && ((yy >= 0)&&(yy < rows)) ) {
            if (!((xx == x) && (yy == y))) {
              if (gridBuffer[xx][yy].alive) {
                neighbors++;
                if (colorMixing) {
                  neighbor_red_sum += gridBuffer[xx][yy].red;
                  neighbor_green_sum += gridBuffer[xx][yy].green;
                  neighbor_blue_sum += gridBuffer[xx][yy].blue;
                }
              }
            }
          }
        }
      }
      // Birth and death!
      if (gridBuffer[x][y].alive) {
        if ((neighbors < 2) || (neighbors > 3)) {
          grid[x][y].alive = false;
        }
      }
      else {
        if (neighbors == 3) {
          grid[x][y].alive = true;
          if (colorMixing) {
            grid[x][y].red = neighbor_red_sum / neighbors;
            grid[x][y].green = neighbor_green_sum / neighbors;
            grid[x][y].blue = neighbor_blue_sum / neighbors;
          }
        }
      }
    }
  }
}

float factorByDistance(float x1, float y1, float x2, float y2, float level, float scalingFactor) {
  // Used for the "loudness gradient" circles around each audio node
  // x1, y1 is the source of the sound. x2, y2, is the position at which to return the factored level.
  level = level * scalingFactor;
  float pointDistance = dist(x1, y1, x2, y2);
  float levelByDistance = map(pointDistance, 0, level, level, 0);
  levelByDistance = constrain(levelByDistance, 0, level);
  return levelByDistance;
}

int calcOffset(int x, int offsets[][]) {
  // Calculate offsets for mullions and such.
  int offset = 0;
  for (int i = 0; i < offsets.length; i++) {
    if (x > offsets[i][0]) {
      offset += offsets[i][1];
    }
  }
  return offset;
}

void keyPressed() {
  // Turn the background on and off
  if (key == 'm' || key == 'M') {
    if (colorMixing) {
      colorMixing = false;
      println("colorMixing set to false");
    } 
    else {
      colorMixing = true;
      println("colorMixing set to true");
    }
  }
  else if (key == 'c' || key == 'C') {
    if (colorSource == "white") {
      colorSource = "location";
      println("colorSource set to location");
    } 
    else {
      colorSource = "white";
      println("colorSource set to white");
    }
  }
  else if (key == 'a' || key == 'A') {
    if (annotationToggle) {
      annotationToggle = false;
    } 
    else {
      annotationToggle = true;
    }
  }
  else if (key == '1') {
    if (woodshopVolume == 1.) {
      woodshopVolume = 50.;
    } 
    else {
      woodshopVolume = 1.;
    }
  }
  else if (key == '2') {
    if (musicVolume == 1.) {
      musicVolume = 50.;
    } 
    else {
      musicVolume = 1.;
    }
  }
  else if (key == ' ') {
    record = true;
  }
}

void stop() {
  // always close Minim audio classes when you are done with them
  conversation.close();
  music.close();
  woodshop.close();
  typing.close();
  street.close();
  // always stop Minim before exiting
  minim.stop();
  super.stop();
}

