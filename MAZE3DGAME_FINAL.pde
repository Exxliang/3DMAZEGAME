int l = 15; //x-axis
int w = 15; //y-axis
int h = 15; //z-axis
int[][][][] walls = new int[l+2][w+2][h+2][7];
IntList sides = new IntList();
ArrayList<MARKER> mark = new ArrayList<MARKER>();
char moving;
boolean initiated,done,randomized;
float s,dx,dy,dz,devx,devy,speed;
int mx,my,mz,Px,Py,Pz,fAxis,rAxis,uAxis,markerCount,t;

void setup(){
  size(900,900,P3D);
  background(0);
  smooth();
  frameRate(60);
  rectMode(CENTER);
  /////////////////////////////////////////////////////////
  moving = 's'; //whether moving or not and direction of movement
  initiated = false; //starts the maze making process at (1,1,1)
  done = false; //determines whether maze is completely filled (eliminates continued checking)
  randomized = false; //randomly removes some walls so there isn't just one path
  s = 100; //scale of the maze (2s is the size of one cell)
  dx = 1; //dx, dy, and dz are small distances away from the center of a cell to aim the camera and to allow rotation of view with mouse
  dy = 0;
  dz = 0;
  speed = 30; //how fast the player is automatically moving (lower number means high speed and higher number means less speed)
  t = 0;
  mx = 0; //mx, my, and mz are translational movements that happen as the player is moving automatically (domain:[0,1))
  my = 0;
  mz = 0;
  Px = 1; //Px, Py, and Pz are the player's position in the maze
  Py = 1; //domain for all: [1,(l or w or h)]
  Pz = 1;
  fAxis = 1; //fAxis, rAxis, and uAxis represent the player's axis facing forward, axis on the right, and axis facing upward
  rAxis = -3; //1 is x-axis, 2 is y-axis, 3 is z-axis; + is positive side of axis, - is negative side of axis
  uAxis = 2;
  markerCount = 0; //counts how many markers have been placed on maze path (max 12)
  ////////////////////////////////////////////////////////
  for (int i=0;i<=l+1;i++){
    for (int j=0;j<=w+1;j++){
      for (int k=0;k<=h+1;k++){
        walls[i][j][k][0] = 1;
        for (int s=1;s<=6;s++){
          walls[i][j][k][s] = 0;
        }
      }
    }
  }
  for (int i=1;i<=l;i++){
    for (int j=1;j<=w;j++){
      for (int k=1;k<=h;k++){
        walls[i][j][k][0] = 0;
        for (int s=1;s<=6;s++){
          walls[i][j][k][s] = 1;
        }
      }
    }
  }
  sides.append(0);
  sides.append(1);
  sides.append(2);
  sides.append(3);
  sides.append(4);
  sides.append(5);
}

void draw(){
  background(0);
  camera(2*s*(Px+mx/speed),2*s*(Py+my/speed),2*s*(Pz+mz/speed),2*s*(Px+mx/speed)+dx,2*s*(Py+my/speed)+dy,2*s*(Pz+mz/speed)+dz,0,-1,0);
  devx = map(mouseX-width/2,-width/2,width/2,-PI/4+0.01,PI/4-0.01);
  devy = map(-mouseY+height/2,-height/2,height/2,-PI/4+0.01,PI/4-0.01);
  stroke(255);
  fill(255);
  MAZE();
  if (mark.size()>0){
    for (int i=0;i<mark.size();i++){
      MARKER marker = mark.get(i);
      marker.MAKE();
    }
  }
  if (moving != 's'){
    move_animate(moving);
  }
  fLook();
  pushStyle();
  stroke(255);
  fill(255);
  rect(width/2,height/2,400,400);
  popStyle();
  println(distance(2*s*l,2*s*w,2*s*h));
}

void MAZE(){
  makeStructure();
  if (!initiated){
    walk(1,1,1);
    initiated = true;
    println("initiated");
  }
  if (!done){
    check();
    int i = floor(random(1,l+1));
    int j = floor(random(1,w+1));
    int k = floor(random(1,h+1));
    if (walls[i][j][k][0]==1){
      walk(i,j,k);
    }
  }
  if (!randomized && done){
    for (int i=0;i<int(l*w*h/10);i++){
      int a = floor(random(2,l));
      int b = floor(random(2,w));
      int c = floor(random(2,h));
      int side = floor(random(1,7));
      if (walls[a][b][c][side]==1){
        if (side==1){
          walls[a][b][c][1]=0;
          walls[a][b][c-1][2]=0;
        } else if (side==2){
          walls[a][b][c][2]=0;
          walls[a][b][c+1][1]=0;
        } else if (side==3){
          walls[a][b][c][3]=0;
          walls[a][b-1][c][4]=0;
        } else if (side==4){
          walls[a][b][c][4]=0;
          walls[a][b+1][c][3]=0;
        } else if (side==5){
          walls[a][b][c][5]=0;
          walls[a-1][b][c][6]=0;
        } else if (side==6){
          walls[a][b][c][6]=0;
          walls[a+1][b][c][5]=0;
        }
      }
    }
    randomized = true;
    println("done & randomized");
  }
}

void makeStructure(){
  stroke(0);
  for (int i=1;i<=l;i++){
    for (int j=1;j<=w;j++){
      for (int k=1;k<=h;k++){
        float abs_d = distance(2*s*i,2*s*j,2*s*k);
        if (walls[i][j][k][1] == 1 && abs_d<=6*s){
          float x = distance(2*s*i,2*s*j,2*s*k-s);
          float v = 200*exp(-pow(x,2)/100000);
          fill(v);
          //stroke(v);
          translate(2*s*i,2*s*j,2*s*k-s);
          rect(0,0,2*s,2*s);
          translate(-2*s*i,-2*s*j,-2*s*k+s);
        }
        if (walls[i][j][k][2] == 1 && abs_d<=6*s){
          float x = distance(2*s*i,2*s*j,2*s*k+s);
          float v = 200*exp(-pow(x,2)/100000);
          fill(v);
          //stroke(v);
          translate(2*s*i,2*s*j,2*s*k+s);
          rect(0,0,2*s,2*s);
          translate(-2*s*i,-2*s*j,-2*s*k-s);
        }
        if (walls[i][j][k][3] == 1 && abs_d<=6*s){
          float x = distance(2*s*i,2*s*j-s,2*s*k);
          float v = 200*exp(-pow(x,2)/100000);
          fill(v);
          //stroke(v);
          translate(2*s*i,2*s*j-s,2*s*k);
          rotateX(PI/2);
          rect(0,0,2*s,2*s);
          rotateX(-PI/2);
          translate(-2*s*i,-2*s*j+s,-2*s*k);
        }
        if (walls[i][j][k][4] == 1 && abs_d<=6*s){
          float x = distance(2*s*i,2*s*j+s,2*s*k);
          float v = 200*exp(-pow(x,2)/100000);
          fill(v);
          //stroke(v);
          translate(2*s*i,2*s*j+s,2*s*k);
          rotateX(PI/2);
          rect(0,0,2*s,2*s);
          rotateX(-PI/2);
          translate(-2*s*i,-2*s*j-s,-2*s*k);
        }
        if (walls[i][j][k][5] == 1 && abs_d<=6*s){
          float x = distance(2*s*i-s,2*s*j,2*s*k);
          float v = 200*exp(-pow(x,2)/100000);
          fill(v);
          //stroke(v);
          translate(2*s*i-s,2*s*j,2*s*k);
          rotateY(PI/2);
          rect(0,0,2*s,2*s);
          rotateY(-PI/2);
          translate(-2*s*i+s,-2*s*j,-2*s*k);
        }
        if (walls[i][j][k][6] == 1 && abs_d<=6*s){
          float x = distance(2*s*i+s,2*s*j,2*s*k);
          float v = 200*exp(-pow(x,2)/100000);
          fill(v);
          //stroke(v);
          translate(2*s*i+s,2*s*j,2*s*k);
          rotateY(PI/2);
          rect(0,0,2*s,2*s);
          rotateY(-PI/2);
          translate(-2*s*i-s,-2*s*j,-2*s*k);
        }
        fill(255);
      }
    }
  }
}

float distance(float x,float y,float z){
  return sqrt(pow(x-2*s*(Px+mx/speed)-dx,2)+pow(y-2*s*(Py+my/speed)-dy,2)+pow(z-2*s*(Pz+mz/speed)-dz,2));
}

void walk(int x,int y,int z){
  walls[x][y][z][0] = 1;
  sides.shuffle();
  int[][] dir = {{x,y,z+1},{x,y,z-1},{x,y+1,z},{x,y-1,z},{x+1,y,z},{x-1,y,z}}; 
  int xx,yy,zz;
  
  for (int p=0;p<=5;p++){
    int n = sides.get(p);
    xx = dir[n][0];
    yy = dir[n][1];
    zz = dir[n][2];
    if (walls[xx][yy][zz][0] == 0){
      if (xx==x && yy==y){
        walls[xx][yy][min(zz,z)][2] = 0;
        walls[xx][yy][max(zz,z)][1] = 0;
      } else if (xx==x && zz==z){
        walls[xx][min(yy,y)][zz][4] = 0;
        walls[xx][max(yy,y)][zz][3] = 0;
      } else if (yy==y && zz==z){
        walls[min(xx,x)][yy][zz][6] = 0;
        walls[max(xx,x)][yy][zz][5] = 0;
      }
      walk(xx,yy,zz);
    }
  }
}

void check(){
  boolean temp_done = true;
  for (int i=0;i<=l+1;i++){
    for (int j=0;j<=w+1;j++){
      for (int k=0;k<=h+1;k++){
        if (walls[i][j][k][0]==0){
          temp_done = false;
        }
      }
    }
  }
  done = temp_done;
}

void keyPressed(){
  if (key=='d' && abs(mx+my+mz)==0){
    moving = 'R';
  } else if (key=='a' && abs(mx+my+mz)==0){
    moving = 'L';
  } else if (key=='w' && abs(mx+my+mz)==0){
    if (valid_move('U')){
      moving = 'U';
    }
  } else if (key=='x' && abs(mx+my+mz)==0){
    if (valid_move('D')){
      moving = 'D';
    }
  } else if (key=='s' && abs(mx+my+mz)==0){
    if (valid_move('F')){
      moving = 'F';
    }
  } else if (key==' '){
    if (markerCount<12){
      mark.add(new MARKER(2*s*(Px+mx/speed)+dx,2*s*(Py+my/speed)+dy,2*s*(Pz+mz/speed)+dz));
    }
  }
}

void move_animate(char dir){
  if (dir=='U'){
    my += 1;
    if (abs(my)==speed){
      my=0;
      Py+=1;
      moving = 's';
    }
  } else if (dir=='D'){
    my -= 1;
    if (abs(my)==speed){
      my=0;
      Py-=1;
      moving = 's';
    }
  } else if (dir=='F'){
    if (abs(fAxis)==1){
      mx += fAxis/abs(fAxis);
      if (abs(mx)==speed){
        mx = 0;
        Px += fAxis/abs(fAxis);
        moving = 's';
      }
    } else if (abs(fAxis)==3){
      mz += fAxis/abs(fAxis);
      if (abs(mz)==speed){
        mz = 0;
        Pz += fAxis/abs(fAxis);
        moving = 's';
      }
    }
  } else if (dir=='R'){
    t += 1;
    if (t==int(speed)/2){
      dSwitch('R');
      t=-int(speed)/2;
    } else if (t==0){
      moving = 's';
    }
  } else if (dir=='L'){
    t -= 1;
    if (t==-int(speed)/2){
      dSwitch('L');
      t = int(speed)/2;
    } else if (t==0){
      moving = 's';
    }
  }      
}

boolean valid_move(char dir){
  if (dir=='F'){
    if (fAxis==1 && walls[Px][Py][Pz][6]==0){
      return true;
    } else if (fAxis==-1 && walls[Px][Py][Pz][5]==0){
      return true;
    } else if (fAxis==3 && walls[Px][Py][Pz][2]==0){
      return true;
    } else if (fAxis==-3 && walls[Px][Py][Pz][1]==0){
      return true;
    } else {
      return false;
    }
  } else if (dir=='U' && walls[Px][Py][Pz][4]==0){
    return true;
  } else if (dir=='D' && walls[Px][Py][Pz][3]==0){
    return true;
  } else {
    return false;
  }
}

void dSwitch(char dir){
  int temp = fAxis;
  if (dir=='R'){
    fAxis = rAxis;
    rAxis = -temp;
  } else if (dir=='L'){
    fAxis = -rAxis;
    rAxis = temp;
  }
}

void fLook(){
  if (abs(fAxis)==1){
    dx = fAxis/abs(fAxis);
    dz = rAxis/abs(rAxis)*tan(devx+PI*t/(2*speed));
  } else if (abs(fAxis)==3){
    dz = fAxis/abs(fAxis);
    dx = rAxis/abs(rAxis)*tan(devx+PI*t/(2*speed));
  }
  dy = tan(devy);
}