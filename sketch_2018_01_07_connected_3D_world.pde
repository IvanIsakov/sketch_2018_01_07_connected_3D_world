ArrayList<Lines> vectorField = new ArrayList<Lines>();
ArrayList<Interaction> interactionField = new ArrayList<Interaction>();
int gridSize = 50;
float boxFraction = 0.05;
int interactDist = 150;
float repulsCoeff = 0.0005;

float viscosity = 0.01;
float IntCoeff = 0.0005;
int w = 400;
int h = 800;
long timer;

// emulateMouse
boolean emulate = false;
boolean mousePressedBool = false;
float emulateMouseX;
float emulateMouseY;
float pemulateMouseX;
float pemulateMouseY;

void setup() {
  size(800,800,P3D);
  background(255);
  
  for (int i = -w/gridSize; i < w/gridSize; i++) {
    for (int j = -w/gridSize; j < w/gridSize; j++) {      
      for (int k = -w/gridSize; k < w/gridSize; k++) {
        // Lines l = new Lines(i*gridSize, j*gridSize,k*gridSize);
        Lines l = new Lines(random(-width,width),random(-width,width),random(-width,width));
        vectorField.add(l);
      }
    }
  }
  for (Lines l : vectorField) {
    for (Lines k : vectorField) {
      if (l.ax <= k.ax + interactDist && l.ax >= k.ax - interactDist && 
          l.ay <= k.ay + interactDist && l.ay >= k.ay - interactDist && 
          l.az <= k.az + interactDist && l.az >= k.az - interactDist) {
          Interaction a = new Interaction(l,k);    
          interactionField.add(a);
      }
    }
  }
  timer = millis();
  println(vectorField.size());
}

void draw() {
//  camera(400*sin(mouseX*2*PI/width),400*cos(mouseX*2*PI/width)*sin(mouseY*2*PI/width),400*cos(mouseX*2*PI/width)*cos(mouseY*2*PI/width),
  float tim = millis()/1000*2*PI;
  camera(40*gridSize,mouseX,mouseY,
      //400*sin(mouseX*2*PI/width),400*cos(mouseX*2*PI/width)*sin(mouseY*2*PI/width),400*cos(mouseX*2*PI/width)*cos(mouseY*2*PI/width),
       0.0, 0.0, 0.0, // centerX, centerY, centerZ
       0.0, 1.0, 0.0); // upX, upY, upZ
  lights();
  //stroke(255);
  background(0);
  emulateMouse();
  if (keyPressed) {
    if (key == ' ') {
      int K = int(random(4096));
      vectorField.get(K).Spark = true;
      println(vectorField.get(K).ax);
    }
  }
  for (Lines l : vectorField) {
    l.update();
    //l.display();
  }
  for (Interaction I : interactionField) {
    I.update();
    I.display();
  }
  

  
  /*
  // Checking if the particles still interact once every 0.1 sec
  if (timer > 100) {
    interactionField = new ArrayList<Interaction>();
    for (Lines l : vectorField) {
      for (Lines k : vectorField) {
        if (l.ax <= k.ax + interactDist && l.ax >= k.ax - interactDist && 
            l.ay <= k.ay + interactDist && l.ay >= k.ay - interactDist && 
            l.az <= k.az + interactDist && l.az >= k.az - interactDist) {
            Interaction a = new Interaction(l,k);    
            interactionField.add(a);
        }
      }
    }
    timer = millis();
  }
  */
  
  //saveFrame("interaction_universe_collapse_oscillate_colours-####.png");
}

class Lines {
  float ax,ay,az;
  float dx,dy;
  float arotspeedX,arotspeedY, arotspeedZ;
  color colorStroke = 255;
  float speedCoeff = 0.45;
  boolean Spark;
  
  Lines(float x1, float y1, float z1) {
    ax = x1;
    ay = y1;
    az = z1;
  }
  
  void update() {
    
    if (mousePressedBool) {
      if (emulateMouseX < ax + gridSize/2 && emulateMouseX > ax - gridSize/2 && 
          emulateMouseY < ay + gridSize/2 && emulateMouseY > ay - gridSize/2) {        
          arotspeedX = speedCoeff*((emulateMouseX - pemulateMouseX));  
          arotspeedY = speedCoeff*((emulateMouseY - pemulateMouseY));
          //arot = speedCoeff*(abs(emulateMouseX - pemulateMouseX)) +  
          //       speedCoeff*(abs(emulateMouseY - pemulateMouseY));
          
      }
    }
    
    if (ax < -width + gridSize || ax > width - gridSize || 
        ay < -width + gridSize || ay > width - gridSize || 
        az < -width + gridSize || az > width - gridSize) {
    } else {
      arotspeedX -= arotspeedX*viscosity;
      arotspeedY -= arotspeedY*viscosity;
      arotspeedZ -= arotspeedZ*viscosity;
      //arot -= arot*viscosity;
      ax += arotspeedX;
      ay += arotspeedY;
      az += arotspeedZ;    
      //dx +=arot;
      }
  }
  
  void display() {
    fill(155,100,255);
    //stroke(255);
    pushMatrix();
    translate(ax,ay,az);
    rotateX(arotspeedX);    
    rotateY(arotspeedY);
    // translate(ax,ay,dx);
    // translate(dx,dy,dz);
    box(gridSize*boxFraction);
    //sphere(gridSize*boxFraction);
    //rect(0,0,0.8*gridSize,0.8*gridSize);
    popMatrix();
  }
}



class Interaction {
  Lines l1;
  Lines l2;
  float distX;
  float distY;
  float distZ;
  float Cdist;
  boolean Spark1;

  float maxNoInteraction = gridSize*boxFraction/2;
  
  Interaction(Lines Line1, Lines Line2) {
    l1 = Line1;
    l2 = Line2;
  }
  
  void update() {
    distX = (l1.ax - l2.ax);
    distY = (l1.ay - l2.ay);
    distZ = (l1.az - l2.az);
    Cdist = abs(distX)+abs(distY)+abs(distZ);
    if (abs(distX) > maxNoInteraction || abs(distY) > maxNoInteraction ||
        abs(distY) > maxNoInteraction) {  
      l1.arotspeedX += -IntCoeff*distX;
      l2.arotspeedX += IntCoeff*distX;
      l1.arotspeedY += -IntCoeff*distY;
      l2.arotspeedY += IntCoeff*distY;
      l1.arotspeedZ += -IntCoeff*distZ;
      l2.arotspeedZ += IntCoeff*distZ;
      //l1.arot += IntCoeff*(l2.dx - l1.dx);
      //l2.arot += IntCoeff*(l1.dx - l2.dx);
      } else {
        l1.arotspeedX += repulsCoeff*Cdist;
        l2.arotspeedX += -repulsCoeff*Cdist;
        l1.arotspeedY += repulsCoeff*Cdist;
        l2.arotspeedY += -repulsCoeff*Cdist;
        l1.arotspeedZ += repulsCoeff*Cdist;
        l2.arotspeedZ += -repulsCoeff*Cdist;
      }
      
      if (l1.Spark || l2.Spark) {
        Spark1 = true;
      }
      
  }
  
  void display() {
    float col = map(Cdist,0,300,1,0);
    //col = 0.5;
    if (Spark1) {
      stroke(255,0,0);
    } else {
      stroke(col*255,col*255,col*255);
    }strokeWeight(2);
    line(l1.ax,l1.ay,l1.az,l2.ax,l2.ay,l2.az);
  }
}

void emulateMouse() {

  emulateMouseX = map(mouseX,0,width,0,w);
  emulateMouseY = map(mouseY,0,height,0,h);
  pemulateMouseX = map(pmouseX,0,width,0,w);
  pemulateMouseY = map(pmouseY,0,height,0,h);
  if (mousePressed) {
    mousePressedBool = true;
  } else {
    mousePressedBool = false;
  }

}