import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer conversation, music, woodshop, typing, street;
FFT fftLog;
FFT fftLog2;

// 2D Array of cell objects represents LEDs
Cell[][] grid;
// Buffer for Game of Life stuff
Cell[][] gridBuffer;

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

int numberOfOffsets = 9;

int size = 2;
int spacing = 5;
int baseXOffset = 20;
int baseYOffset = 20;
int xOffset;
int yOffset;

void setup() {
  frameRate(15);
  size(1000, 150);
  // Set up grid
  grid = new Cell[cols][rows];
  gridBuffer = new Cell[cols][rows];
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      // Calculate offsets
      xOffset = baseXOffset + calcOffset(i, numberOfOffsets, horizontalOffsets);
      yOffset = baseYOffset;

      // Initialize each object
      grid[i][j] = new Cell(i*spacing + xOffset, j*spacing + yOffset, 
                            size, size, 255,255,255, false); // x, y, w, h, red, green, blue, alive
      gridBuffer[i][j] = new Cell(i*spacing + xOffset, j*spacing + yOffset, 
                            size, size, 255, 255, 255, false); // x, y, w, h, red, green, blue, alive
    }
  }
  // Line wiggler test
  // grid[2][2].alive = true;
  // grid[3][2].alive = true;
  // grid[4][2].alive = true;
  
  
  // Set up audio
  minim = new Minim(this);
  // load the files, give the AudioPlayers buffers that are 1024 samples long
  conversation = minim.loadFile("conversation.wav", 1024);
  music = minim.loadFile("death-grips_get-got.mp3", 1024);
  woodshop = minim.loadFile("woodshop.wav", 1024);
  typing = minim.loadFile("typing.wav", 1024);
  street = minim.loadFile("street.wav", 1024);
  // play the files
  conversation.loop();
  music.loop();
  woodshop.loop();
  typing.loop();
  street.loop();
  
  // create FFT objects that have a time-domain buffer 
  // the same size as jingle's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be half as large.
  /*
  fftLog = new FFT(conversation.bufferSize(), conversation.sampleRate());
  fftLog.logAverages( 22, 1 );
  fftLog2 = new FFT(music.bufferSize(), music.sampleRate());
  fftLog2.logAverages( 22, 1 );
  */
}

void draw() {
  background(0);
  
  // Compute the FFTs and bin by octaves
  /*
  fftLog.forward(conversation.mix);
  fftLog2.forward(music.mix);
  */
  
  // The counter i and j are also the column and
  // row numbers and are used as arguments to the
  // constructor for each object in the grid.
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      // Birth cells based on volume
      float distanceFactor1 = pointDistFactor(grid[20][2].x, grid[20][2].y, grid[x][y].x, grid[x][y].y, 0, 500 * conversation.mix.level());
      float distanceFactor2 = pointDistFactor(grid[50][5].x, grid[50][5].y, grid[x][y].x, grid[x][y].y, 0, 500 * music.mix.level());
      float distanceFactor3 = pointDistFactor(grid[80][8].x, grid[80][8].y, grid[x][y].x, grid[x][y].y, 0, 300 * woodshop.mix.level());
      float distanceFactor4 = pointDistFactor(grid[100][3].x, grid[100][3].y, grid[x][y].x, grid[x][y].y, 0, 700 * typing.mix.level());
      float distanceFactor5 = pointDistFactor(grid[170][5].x, grid[170][5].y, grid[x][y].x, grid[x][y].y, 0, 500 * street.mix.level());
      float level1 = distanceFactor1 * conversation.mix.level();
      float level2 = distanceFactor2 * music.mix.level();
      float level3 = distanceFactor3 * woodshop.mix.level();
      float level4 = distanceFactor4 * typing.mix.level();
      float level5 = distanceFactor5 * street.mix.level();
      float level = constrain(level1 + level2 + level3 + level4 + level5, 0, 1);
      /*
      if (level > 0.01){
        println(level);
      }
      */
      if (random(.5) < level) {
        grid[x][y].alive = true;
        /*
        grid[x][y].red = constrain(int(map(level1 + level2, 0, .05, 0, 255)),0, 255);
        grid[x][y].green = constrain(int(map(level3 + level4, 0, .05, 0, 255)),0, 255);
        grid[x][y].blue = constrain(int(map(level5, 0, .02, 0, 255)),0, 255);
        */      
      } 
      grid[20][2].alive = true;
      grid[20][2].green = 0;
      grid[50][5].alive = true;
      grid[50][5].green = 0;
      grid[80][8].alive = true;
      grid[80][8].green = 0;
      grid[100][3].alive = true;
      grid[100][3].green = 0;
      grid[170][5].alive = true;
      grid[170][5].green = 0;

      // Display alive cells
      grid[x][y].display();
    }
  }
  // Update the cells
  iteration();
  
  /*
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {                         
      float distanceFactor1 = pointDistFactor(grid[40][2].x, grid[40][2].y, grid[i][j].x, grid[i][j].y, 0, 100);
      float distanceFactor2 = pointDistFactor(grid[165][5].x, grid[165][5].y, grid[i][j].x, grid[i][j].y, 0, 100);
      float bass1 = distanceFactor1 * fftLog.getAvg(0) * 2;
      float bass2 = distanceFactor2 * fftLog2.getAvg(2) * 5;
      int bass = int(constrain(bass1 + bass2, 0, 255));
      grid[i][j].display(bass, 32, 32); // Bass controls red channel
    }
  }
  */
}
