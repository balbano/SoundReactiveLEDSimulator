/**
  Processing simulation of sound reactive LED installation for the University of Chicago Arts Incubator.
  MFA 6009-004: Nodes II | Spring 2014 | SAIC
  SAIC Students: Brendan Albano, Haley Shonkwiler, Maggie Grady
  External Collaborators: Kate Barbaria
  
  Copyright (c) 2014 Brendan Albano, Haley Shonkwiler, Kate Barbaria, Maggie Grady.
  The MIT License (MIT)
*/

import ddf.minim.*;
import processing.pdf.*;

// Bool to control pdf screenshots
boolean record;

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
int cols = 110;
int rows = 7;

// Grid offsets
int mullion = 3;
int thinColumn = 9;
int wideColumn = 18;
int[][] horizontalOffsets = { 
  {11, mullion}, {22, thinColumn}, {33, mullion}, {44, wideColumn}, {55, mullion}, 
  {66, thinColumn}, {77, mullion}, {88, wideColumn}, {99, mullion}
};
int totalOffset = calcOffset(cols, horizontalOffsets);

// Toggle background image by pressing any key
boolean annotationToggle = false;
PImage annotation;

// Parameters for LED grid.
int LEDSize = 4;
int spacing = 10;
int baseXOffset;
int baseYOffset;
int xOffset;
int yOffset;

// Use color mixing
boolean colorMixing = false;
String colorSource = "white"; // "white", "random", "location"

// Level scaling factor "silencers"
float woodshopVolume = 1.;
float musicVolume = 1.;

boolean sketchFullScreen() {
  // Always run in "present" mode.
  return true;
}

void setup() {
  frameRate(15); // 15 looks good, can be modified.
  size(1440, 900);
  baseXOffset = (width - ((cols-1)*spacing + totalOffset)) / 2;
  baseYOffset = (height - ((rows-1)*spacing)) / 2;
  
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
  
  // Background image
  annotation = loadImage("annotation.png");
  
  // noLoop();
}

void draw() {
  if (record) {
    // Note that #### will be replaced with the frame number. Fancy!
    beginRecord(PDF, "frame-####.pdf"); 
  }
  background(0);
  fill(255);
  text("c: toggle color. m: toggle color mixing. a: toggle annotations.", 10, 10);
  text("1: toggle woodshop activity. 2: toggle music activity.", 10, 25);
  text("<space>: take screenshot", 10, 40);
    
  // Set audio node LEDs to alive and magenta.
  LED[] audioNodes = {grid[5][3], grid[18][2], grid[37][3], grid[50][3], grid[68][2], grid[86][1], grid[105][1],
                      grid[17][5], grid[32][5], grid[55][5], grid[76][5], grid[99][5]};
  int[][] nodeColors = {{255, 128, 0}, {128, 255, 0}, {128, 0, 255}, {255, 0, 128}, {0, 255, 128}, {0, 128, 255}, {255, 255, 0},
                       {255, 255, 255}, {255, 255, 255}, {255, 255, 255}, {255, 255, 255}, {255, 255, 255}};
  float audioLevels[] = {conversation.mix.level(), conversation.mix.level(), conversation.mix.level(), woodshop.mix.level(), conversation.mix.level(), music.mix.level(), typing.mix.level(),
                       street.mix.level(), street.mix.level(), micInput.mix.level(), street.mix.level(), street.mix.level()};
  // Minim gives levels in a range of 0 to 1. Multiply by 255 to match Arduino readings.
  for (int i = 0; i < audioLevels.length; i++) {
    audioLevels[i] = audioLevels[i] * 255; 
  }    
  float scalingFactors[] = {.5, 1, .5, 1/woodshopVolume, 1, 1/musicVolume, 1,
                         2, 1, .5, 1, 1};
                       
             
  // Birth cells based on volume and display cells
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {                               
      float level = 0;
      int nodeRed = 0;
      int nodeGreen = 0;
      int nodeBlue = 0;
      for (int i = 0; i < audioNodes.length; i++) {
        float factoredLevel = factorByDistance(audioNodes[i].x, audioNodes[i].y, grid[x][y].x, grid[x][y].y, audioLevels[i], scalingFactors[i]);
        level += factoredLevel;
        nodeRed += int(factorByDistance(audioNodes[i].x, audioNodes[i].y, grid[x][y].x, grid[x][y].y, nodeColors[i][0], 1.));
        nodeGreen += int(factorByDistance(audioNodes[i].x, audioNodes[i].y, grid[x][y].x, grid[x][y].y, nodeColors[i][1], 1.));
        nodeBlue += int(factorByDistance(audioNodes[i].x, audioNodes[i].y, grid[x][y].x, grid[x][y].y, nodeColors[i][2], 1.));  
      }
      
      nodeRed = constrain(nodeRed, 0, 255);
      nodeGreen = constrain(nodeGreen, 0, 255);
      nodeBlue = constrain(nodeBlue, 0, 255);
      
      //if (level > 0.01){
      //  println(level);
      //}
      
      // NOTE: the relationship between the random  number below and the level above
      // determines how big the outer ring of the circle that generates some live LEDs
      // randomly vs the inner ring of the circle that is 100% live.
      
      if (!colorMixing) {
        grid[x][y].red = 255;
        grid[x][y].green = 255;
        grid[x][y].blue = 255;
      }
      
      if (random(32) < level) {
        grid[x][y].alive = true;
        if (colorSource == "white") {
          grid[x][y].red = 255;
          grid[x][y].green = 255;
          grid[x][y].blue = 255;
        }
        else if (colorSource == "random") {
          grid[x][y].red = int(random(255));
          grid[x][y].green = int(random(255));
          grid[x][y].blue = int(random(255));
        }
        else if (colorSource == "location") {
          grid[x][y].red = nodeRed;
          grid[x][y].green = nodeGreen;
          grid[x][y].blue = nodeBlue;
        }    
      } 
      
      for (int i = 0; i < audioNodes.length; i++){
        audioNodes[i].alive = true;
        if (colorSource == "location") {
          audioNodes[i].red = nodeColors[i][0];
          audioNodes[i].green = nodeColors[i][1];
          audioNodes[i].blue = nodeColors[i][2];
        }
        else {
        audioNodes[i].red = 255;
        audioNodes[i].green = 0;
        audioNodes[i].blue = 255;
        }
      }

      // Display alive cells
      grid[x][y].display();
    }
  }
  // Display annotation
  if (annotationToggle) {
    image(annotation, baseXOffset + 94, baseYOffset - 30);
  }
  // Run game of life iteration.
  iteration();
  if (record) {
    endRecord();
  record = false;
  }
}
