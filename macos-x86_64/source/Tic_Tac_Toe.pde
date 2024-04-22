int WindowLen = 600; //Size of the playing field
int Div = WindowLen / 3; //200
int margin = 70;
int offset = 20;
//Formula for cols and rows size:
//(Div * 2 - offset) - (Div + offset) = (Div + offset) - margin
int displacement = 160;
int TLCP = 140; //Top Left Center Position (relative to the grid)
int[] objects = {-1, -1, -1, -1, -1, -1, -1, -1, -1};
int counter = 0;
int currPlayer = 1;
boolean makeCross = false;
boolean makeCircle = false;
boolean makeLine = true;
int winnerColor = -1; //Default winner color is player 1 (black)
int[] currObj = {-1, -1};
int Player1Score = 0;
int Player2Score = 0;
int TieScore = 0;  
boolean hasScored = false; //prevents multiple players (a player and tie) from scoring at the same time
int setPlayer = 1; //Sets the player to go first
int[] MenuColor = {40, 40, 40};
int ImageColor = 255;
int[] BGColor = {110, 200, 190};
int[] GridColor = {60, 150, 140};
boolean isCPUPlaying = false;
boolean hasMadeMove = false;
PFont f;
PFont r;
PFont p;

int[] WinCondition(){
  int[] arr = {-1, -1};
  for(int i = 0; i < 3; i++){
    if (objects[0 + 3*i] == objects[1 + 3*i] && objects[1 + 3*i] == objects[2 + 3*i] && objects[0 + 3*i] != -1){
      arr[0] = 0 + 3*i;
      arr[1] = 2 + 3*i;
    }
    if (objects[0 + i] == objects[3 + i] && objects[3 + i] == objects[6 + i] && objects[0 + i] != -1){
      arr[0] = 0 + i;
      arr[1] = 6 + i;
    }
  }
  if (objects[2] == objects[4] && objects[4] == objects[6] && objects[2] != -1){
    arr[0] = 2;
    arr[1] = 6;
  }
  if (objects[0] == objects[4] && objects[4] == objects[8] && objects[0] != -1){
    arr[0] = 0;
    arr[1] = 8;
  }
  return arr;
}

void DrawCross(int col, int row, int len){
  int crossThickness = 15;
  int crossPosX = 97 + displacement * col;
  int crossPosY = 83 + displacement * row;
  int crossSize = 100;
  //Top left to bottom right rectangle
  int xCL = crossPosX;
  int yCL = crossPosY;
  int xFL = xCL - crossThickness;
  int yFL = yCL + crossThickness;
  //Top right to bottom left rectangle
  int xCR = xFL + crossSize;
  int yCR = yFL - crossThickness;
  int xFR = xCR + crossThickness;
  int yFR = yCR + crossThickness;
  
  //Black Cross
  fill(60);
  noStroke();
  quad(xCL, yCL, xFL, yFL, xFL + len, yFL + len, xCL + len, yCL + len);
  quad(xCR, yCR, xFR, yFR, xFR - len, yFR + len, xCR - len, yCR + len);
}

void DrawCircle(int col, int row, float len){
  int circlePosX = TLCP + displacement * col;
  int circlePosY = TLCP + displacement * row;
  int circleSize = 100;

  //White Circle
  stroke(255, 255, 230);
  noFill();
  arc(circlePosX, circlePosY, circleSize, circleSize, PI*3/2 - len, PI*3/2);
}

void DrawVictoryLine(int startPos, int endPos, int len, int greyscale){
  int offset = 20; //0 = Flush with the left/up border; 40 = Flush with right/down border
  strokeWeight(15);
  stroke(greyscale);
  if (endPos - startPos == 6){ // Row Clear
    line(margin - offset, TLCP + displacement*startPos, margin - offset + len, TLCP + displacement*startPos);
  }
  else if(endPos - startPos == 2){ //Column Clear
    line(TLCP + displacement*startPos/3, margin - offset, TLCP + displacement*startPos/3, margin - offset + len);
  }
  else if(startPos == 0 && endPos == 8){ //Top Left Diagonal Clear
    line(margin - offset, margin - offset, margin - offset + len, margin - offset + len);
  }
  else if(startPos == 2 && endPos == 6){ //Top Right Diagonal Clear
    line(WindowLen - margin + offset, margin - offset, WindowLen - margin + offset - len, margin - offset + len);
  }
}

void ResetBoardState(){
  for (int i = 0; i < objects.length; i++){
      objects[i] = -1;
    }
    //println("P1: " + str(Player1Score) + " Ties: " + str(TieScore) + " P2: " + str(Player2Score));
    counter = 0;
    makeLine = true;
    makeCross = false;
    makeCircle = false;
    hasScored = false;
    currObj[1] = -1;
    currPlayer = setPlayer;
}

int CPUCheckPositions(){
  int currSum = -1;
  int target1 = 1;
  int target2 = 3;
  for(int i = 0; i < 3; i++){
    currSum = objects[0 + 3*i] + objects[1 + 3*i] + objects[2 + 3*i];
    if (currSum == target1 || (currSum == target2 && objects[0 + 3*i] != 1)){
      for(int j = 0; j < 3; j++){
        if (objects[j + 3*i] == -1){
          return j + 3*i;
        }
      }
    }
    currSum = objects[0 + i] + objects[3 + i] + objects[6 + i];
    if (currSum == target1 || (currSum == target2 && objects[0 + 3*i] != 1)){
      for(int j = 0; j < 3; j++){
        if (objects[j*3 + i] == -1){
          return j*3 + i;
        }
      }
    }
  }
  currSum = objects[2] + objects[4] + objects[6];
  if (currSum == target1 || (currSum == target2 && objects[0 + 3*i] != 1)){
    for(int j = 1; j < 4; j++){
        if (objects[j*2] == -1){
          return j*2;
        }
      }
  }
  currSum = objects[0] + objects[4] + objects[8];
  if (currSum == target1 || (currSum == target2 && objects[0 + 3*i] != 1)){
    for(int j = 0; j < 3; j++){
      if (objects[j*4] == -1){
        return j*4;
      }
    }
  }
  return -1;
}

void CPUMakesMove(){
  int pos = CPUCheckPositions();
  if (pos == -1){
    while (counter < 9){
      pos = int(random(0, objects.length));
      if (objects[pos] == -1){
        break;
      }
    }
  }
  currObj[0] = pos;
  currObj[1] = 2;
  makeCircle = true;
}

void setup() {
  //Window Size (P3D helps the animation to run smoother and removes jittery arcs)
  size(1066, 600, P3D);
  f = createFont("Helvetica-Bold",120,true);
  r = createFont("Mali", 36, true);
  p = createFont("Zapfino", 18, true);
}

int i = 0;
float j = 0;
int k = 0;
void draw(){
  //Light green color
  background(BGColor[0], BGColor[1], BGColor[2]);
  
  //Dark Grey Rectangle on the right side of the window
  noStroke();
  fill(MenuColor[0], MenuColor[1], MenuColor[2]);
  rect(WindowLen, 0, 1000, WindowLen);
  
  //Creator information
  fill(ImageColor);
  textFont(p, 18);
  text("Made by: Jozka N.T. (In 5 days)", 635, 60);
  
  //White circular arrow with square outline (restart button)
  //Triangle
  triangle(892, 543, 896, 532, 903, 545);
  //Almost-full circle
  noFill();
  strokeWeight(7);
  stroke(ImageColor);
  arc(910, 550, 30, 30, PI + PI/4, 3*PI);
  //Square outline
  strokeWeight(1);
  square(885, 525, 50);
  
  //Reset button (resets score, board, and which player goes first)
  rect(643, 525, 120, 50);
  textFont(r, 36);
  text("Reset", 652, 562);

  //White swap arrow with square outline (switches which player goes first)
  square(800, 525, 50);
  strokeWeight(7);
  line(807, 540, 833, 540);
  line(817, 560, 842, 560);
  noStroke();
  fill(ImageColor);
  triangle(833, 530, 833, 550, 843, 540);
  triangle(817, 550, 817, 570, 808, 560);
  
  //Cross, dash, and circle for score representation (next 4 lines for calibration)
  //strokeWeight(1);
  //line(700, 0, 700, 600);
  //line(867, 0, 867, 600);
  //line(950, 0, 950, 600);
  noFill();
  stroke(ImageColor);
  strokeWeight(15);
  //Cross
  line(660, 110, 740, 190);
  line(740, 110, 660, 190);
  //Dash
  line(650, 300, 750, 300);
  //Circle
  circle(700, 450, 80);
  //Player scores & ties
  textFont(f, 120);
  text(Player1Score, 800, 190);
  text(TieScore, 800, 340);
  text(Player2Score, 800, 490);
  
  //SinglePlayer and MultiPlayer Icon
  noStroke();
  strokeWeight(10);
  stroke(ImageColor);
  if (isCPUPlaying){
    //SinglePlayer icon
    line(994, 551, 994, 570);
    strokeWeight(16);
    point(994, 539);
  } else{
    //Multiplayer icon
    line(983, 551, 983, 570);
    line(1005, 551, 1005, 570);
    strokeWeight(16);
    point(983, 539);
    point(1005, 539);
  }
  //Square border
  noFill();
  strokeWeight(1);
  stroke(ImageColor);
  square(969, 525, 50);
  
  //(Grid) Dark Green Lines
  stroke(GridColor[0], GridColor[1], GridColor[2]);
  strokeWeight(15);
  line(Div + offset, margin, Div + offset, WindowLen - margin);
  line(Div * 2 - offset, margin, Div * 2 - offset, WindowLen - margin);
  line(margin, Div + offset, WindowLen - margin, Div + offset);
  line(margin, Div * 2 - offset, WindowLen - margin, Div * 2 - offset);
  
  if (currPlayer == 2 && isCPUPlaying && !hasScored && counter < 9 && hasMadeMove){
    CPUMakesMove();
  }
  
  int[] state = WinCondition();
  if (state[0] == -1 && !hasScored){ //Case where a winner hasn't been found yet
    if (counter == 9){ //Case where whole board is filled and no winner has been found yet
      TieScore++;
      hasScored = true;
    }
    if (makeCircle && !makeCross){ //Circle Animation
      hasMadeMove = false;
      if (j < 2*PI){
        DrawCircle(Math.round(currObj[0] / 3), currObj[0] % 3, j);
        j += 2*PI / 20; //Rate of increase
      }
      else{
        j = 0;
        makeCircle = false;
        currPlayer = 1; //Switch to player 1 (after circle is drawn)
      }
    }
  
    if (makeCross && !makeCircle){ //Cross Animation
      hasMadeMove = true;
      if (i < 100){
        DrawCross(Math.round(currObj[0] / 3), currObj[0] % 3, i);
        i += 8; //Rate of increase
      }
      else{
        i = 0;
        makeCross = false;
        currPlayer = 2; //Switch to player 2 (after cross is drawn)
      }
    }
    
    if (!makeCross && !makeCircle){ //Adds object to list of objects after animation is done
      if (currObj[1] != -1){
        objects[currObj[0]] = currObj[1];
        counter++;
        currObj[1] = -1;
      }
    }
  }
  
  for(int i = 0; i < objects.length; i++){ //Draws all stored objects
    if (objects[i] == 1){
      DrawCross(Math.round(i / 3), i % 3, 100);
    }
    else if (objects[i] == 2){
      DrawCircle(Math.round(i / 3), i % 3, 2*PI);
    }
  }
  
  if (state[0] != -1 && !hasScored){ //Case where a winner has been found (currPlayer is inverted here because it changes players each time a move is made)
    if (currPlayer == 1){ //Change the color to white in case player 2 wins
      winnerColor = 255;
    }
    else if(currPlayer == 2){ //Change the color to black in case player 1 wins
      winnerColor = 80;
    }
    if(makeLine){ //Victory Line animation
      if (k < 480){
        DrawVictoryLine(state[0], state[1], k, winnerColor);
        k += 30; //Rate of increase
      }
      else{
        k = 0;
        makeLine = false;
        hasScored = true;
        //Update player scores after drawing line
        if (currPlayer == 1){
          Player2Score++;
        }
        else if(currPlayer == 2){
          Player1Score++;
        }
      }
    }
  }
  
  if (!makeLine){ //Case where Victory Line has been drawn
    DrawVictoryLine(state[0], state[1], 500, winnerColor);
  }
}

void mousePressed(){
  if (mouseX >= 969 && mouseX <= 1019 && mouseY >= 525 && mouseY <= 575){ //Case where switch players button is pushed
    isCPUPlaying = !isCPUPlaying;
    if (setPlayer == 2){
      hasMadeMove = true;
    } else{
      hasMadeMove = false;
    }
    ResetBoardState();
    Player1Score = 0;
    Player2Score = 0;
    TieScore = 0;
  }
  
  if (mouseX >= 800 && mouseX <= 850 && mouseY >= 525 && mouseY <= 575){ //Case where swap button is pushed
    setPlayer = setPlayer % 2 + 1;
    if (setPlayer == 2){ //Case where circle goes first
      MenuColor[0] = 255;
      MenuColor[1] = 255;
      MenuColor[2] = 230;
      ImageColor = 40;
      BGColor[0] = 60;
      BGColor[1] = 130;
      BGColor[2] = 240;
      GridColor[0] = 10;
      GridColor[1] = 30;
      GridColor[2] = 220;
      hasMadeMove = true;
    } else{ //Case where cross goes first
      MenuColor[0] = 40;
      MenuColor[1] = 40;
      MenuColor[2] = 40;
      ImageColor = 255;
      BGColor[0] = 110;
      BGColor[1] = 200;
      BGColor[2] = 190;
      GridColor[0] = 60;
      GridColor[1] = 150;
      GridColor[2] = 140;
      hasMadeMove = false;
    }
    ResetBoardState();
  }
  if (mouseX >= 643 && mouseX <= 763 && mouseY >= 525 && mouseY <= 575){ //Case where reset button is pushed
    Player1Score = 0;
    Player2Score = 0;
    TieScore = 0;
    setPlayer = 1;
    MenuColor[0] = 40;
    MenuColor[1] = 40;
    MenuColor[2] = 40;
    ImageColor = 255;
    BGColor[0] = 110;
    BGColor[1] = 200;
    BGColor[2] = 190;
    GridColor[0] = 60;
    GridColor[1] = 150;
    GridColor[2] = 140;
    ResetBoardState();
    if (setPlayer == 2){
      hasMadeMove = true;
    } else{
      hasMadeMove = false;
    }
  }
  if (mouseX >= 885 && mouseX <= 935 && mouseY >= 525 && mouseY <= 575){ //Case where restart button is pushed
    ResetBoardState();
    if (setPlayer == 2){
      hasMadeMove = true;
    } else{
      hasMadeMove = false;
    }
  }
  if (makeLine && !makeCross && !makeCircle && counter < 9 && mouseX >= margin && mouseX <= WindowLen - margin && mouseY >= margin && mouseY <= WindowLen - margin){
    Double col = Math.floor((mouseX - margin) / displacement);
    Double row = Math.floor((mouseY - margin) / displacement);
    
    if (objects[col.intValue() * 3 + row.intValue()] == -1){
      currObj[0] = col.intValue() * 3 + row.intValue();
      currObj[1] = currPlayer;
      
      if (currPlayer == 1){
        makeCross = true;
      }
      else if (currPlayer == 2){
        makeCircle = true;
      }
    }
  }
}

/*
Notes: 
- 12 Dec: Made initial designs (made grid window, black square, white circle)
- 13 Dec: Made black cross design, calibrated positions of objects, added animations on mouse click
- 14 Dec: Optimised memory usage of the objects array, prevented multiple objects from being added to the same space
- 14 Dec: Removed unnecessary variables and (duplicate) functions, added a win condition function
- 14 Dec: Added Victory Line (with color respective to the winner), Reset button implemented, fixed some bugs
- 14 Dec: Added scoring system in the game window, fixed scoring bug where P1 and Tie can both score simultaneously
- 15 Dec: Added Reset button and Swap button (with functionality), optimised the drawing order a little bit
- 15 Dec: Added feature that swaps the right side color when the swap button is pressed, reset button defaults to player 1
- 15 Dec: The right side of the screen now represents the color of the player who goes first, grid color now also changes with swap button
- 15 Dec: Added CPU feature (still completely random choosing), added 1P and 2P icon (to be moved)
- 16 Dec: Repositioned the buttons, increased window size, Optimised the Computer's decision making
- 16 Dec: fixed some CPU bugs (CPU wouldn't start when switching players in swapped mode), added creator's information

THIS PROJECT IS NOW FINISHED (May be modified in the future in case I feel like it)
*/
