void iteration() {
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      gridBuffer[x][y].x = grid[x][y].x;
      gridBuffer[x][y].y = grid[x][y].y;
      gridBuffer[x][y].w = grid[x][y].w;
      gridBuffer[x][y].h = grid[x][y].h;
      gridBuffer[x][y].red = grid[x][y].red;
      gridBuffer[x][y].green = grid[x][y].green;
      gridBuffer[x][y].blue = grid[x][y].blue;
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
                neighbor_red_sum += gridBuffer[xx][yy].red;
                neighbor_green_sum += gridBuffer[xx][yy].green;
                neighbor_blue_sum += gridBuffer[xx][yy].blue;
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
          // grid[x][y].red = neighbor_red_sum / neighbors;
          // grid[x][y].green = neighbor_green_sum / neighbors;
          // grid[x][y].blue = neighbor_blue_sum / neighbors;
        }
      }
    }
  }
}

float pointDistFactor(float x1, float y1, float x2, float y2, float mapMin, float mapMax) {
  float pointDistance = dist(x1, y1, x2, y2);
  float distanceFactor = map(pointDistance, mapMin, mapMax, 1, 0);
  distanceFactor = constrain(distanceFactor, 0, 1);
  return distanceFactor;
}

int calcOffset(int x, int numOffsets, int offsets[][]) {
  int offset = 0;
  for (int i = 0; i < numOffsets; i++) {
    if (x > offsets[i][0]) {
      offset += offsets[i][1];
    }
  }
  return offset;
}

void stop()
 {
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
 
