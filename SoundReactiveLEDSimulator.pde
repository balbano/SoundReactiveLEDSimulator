/**
  Processing simulation of sound reactive LED installation for the University of Chicago Arts Incubator.
  MFA 6009-004: Nodes II | Spring 2014 | SAIC
  SAIC Students: Brendan Albano, Haley Shonkwiler, Maggie Grady
  External Collaborators: Kate Barbaria
  
  Copyright (c) 2014 Brendan Albano, Haley Shonkwiler, Kate Barbaria, Maggie Grady.
  The MIT License (MIT)
*/

import ddf.minim.*;

Minim minim;
// AudioPlayers for each simulated microphone location
AudioPlayer conversation, music, woodshop, typing, street;
// AudioInput for mic input
AudioInput micInput;

// Representation of grid of LEDs
LED[][] grid;
// Buffer for Game of Life stuff
LED[][] gridBuffer;

// Number of columns and rows
int cols = 180;
int rows = 10;

// Grid offsets
int mullion = 3;
int thinColumn = 9;
int wideColumn = 18;
int[][] horizontalOffsets = { 
  {17, mullion}, {35, thinColumn}, {53, mullion}, {71, wideColumn}, {89, mullion}, 
  {107, thinColumn}, {125, mullion}, {143, wideColumn}, {161, mullion}
};

// Parameters for LED grid.
int LEDSize = 2;
int spacing = 5;
int baseXOffset = 20;
int baseYOffset = 20;
int xOffset;
int yOffset;

void setup() {
  frameRate(15); // 15 looks good, can be modified.
  size(1000, 150);
  
  // Set up grid
  grid = new LED[cols][rows];
  gridBuffer = new LED[cols][rows];
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      // Calculate offsets (for mullions, columns, etc.)
      xOffset = baseXOffset + calcOffset(i, horizontalOffsets);
      yOffset = baseYOffset;

      // Initialize LEDs (x, y, w, h, red, green, blue, alive)
      grid[i][j] = new LED(i*spacing + xOffset, j*spacing + yOffset, 
                            LEDSize, LEDSize, 255,255,255, false);
      gridBuffer[i][j] = new LED(i*spacing + xOffset, j*spacing + yOffset, 
                            LEDSize, LEDSize, 255, 255, 255, false);
    }
  }
  
  // Set up audio
  minim = new Minim(this);
  // load the files, give the AudioPlayers buffers that are 1024 samples long
  conversation = minim.loadFile("conversation.wav", 1024);
  music = minim.loadFile("death-grips_get-got.mp3", 1024);
  woodshop = minim.loadFile("woodshop.wav", 1024);
  typing = minim.loadFile("typing.wav", 1024);
  street = minim.loadFile("street.wav", 1024);
  
  // use the getLineIn method of the Minim object to get an AudioInput
  micInput = minim.getLineIn();
  
  // play the files
  conversation.loop();
  music.loop();
  woodshop.loop();
  typing.loop();
  street.loop();
}

void draw() {
  background(0);
  
  // Set audio node LEDs to alive and magenta.
  LED[] audioNodes = {grid[20][2], grid[50][5], grid[80][8], grid[100][3], grid[130][4], grid[170][5]};
  for (int i = 0; i < audioNodes.length; i++){
    audioNodes[i].alive = true;
    audioNodes[i].red = 255;
    audioNodes[i].green = 0;
    audioNodes[i].blue = 255;
  }
  // Birth cells based on volume and display cells
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {      
      float conversationLevel = factorLevelByDistance(audioNodes[0].x, audioNodes[0].y, grid[x][y].x, grid[x][y].y, 
                                                      conversation.mix.level(), 500.);
      float musicLevel = factorLevelByDistance(audioNodes[1].x, audioNodes[1].y, grid[x][y].x, grid[x][y].y,
                                               music.mix.level(), 500.);
      float woodshopLevel = factorLevelByDistance(audioNodes[2].x, audioNodes[2].y, grid[x][y].x, grid[x][y].y,
                                                  woodshop.mix.level(), 300.);
      float typingLevel = factorLevelByDistance(audioNodes[3].x, audioNodes[3].y, grid[x][y].x, grid[x][y].y,
                                                typing.mix.level(), 700.);
      float micLevel = factorLevelByDistance(audioNodes[4].x, audioNodes[4].y, grid[x][y].x, grid[x][y].y,
                                                micInput.mix.level(), 50.);
      float streetLevel = factorLevelByDistance(audioNodes[5].x, audioNodes[5].y, grid[x][y].x, grid[x][y].y, 
                                          street.mix.level(), 500.);
      float level = conversationLevel + musicLevel + woodshopLevel + typingLevel + micLevel + streetLevel;
      
      if (level > 0.01){
        println(level);
      }
      
      // NOTE: the relationship between the random  number below and the level above
      // determines how big the outer ring of the circle that generates some live LEDs
      // randomly vs the inner ring of the circle that is 100% live.
      
      if (random(20) < level) {
        grid[x][y].alive = true;    
      } 

      // Display alive cells
      grid[x][y].display();
    }
  }
  // Run game of life iteration.
  iteration();
}
