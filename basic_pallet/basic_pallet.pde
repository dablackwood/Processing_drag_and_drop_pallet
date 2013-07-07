/*
Basic code for a simple pallet.
Drag and drop icons from that pallet.

*/

final int SIZE = 18; // icon fits in square this size

int iconCount = 0;
ArrayList myIcons; // all icons
Pallet myPallet;

boolean dragging = false;
boolean adding = false;
int onButton = 0;

char[] iMatrix;


void setup() {
  size(800,400);
  background(200);
  smooth();
  
  myIcons = new ArrayList();
  
  myPallet = new Pallet(width - 100, 40);  
  
  iMatrix = new char[myPallet.NUM_BUTTONS];
  iMatrix[0] = 'C';
  if (myPallet.NUM_BUTTONS > 1){ iMatrix[1] = 'S'; }
  if (myPallet.NUM_BUTTONS > 2){ iMatrix[2] = 'T'; }
  // Add additonal icon types here.
}


void draw() {
  background(200);

  if( myPallet.onPallet() && !dragging ) {
    myPallet.highlight();
  }
  for (int i=0; i<iconCount; i++) {
    Icon thisIcon = (Icon) myIcons.get(i);
    thisIcon.display();
  }
  myPallet.display();
}


void mousePressed() {
  if (mouseButton == LEFT) {
    if (myPallet.onPallet() ) {
      if (myPallet.onBar() ) {
        myPallet.grabbed = true;
        myPallet.offX = mouseX - myPallet.x;
        myPallet.offY = mouseY - myPallet.y;
      } else { // Adding a new Icon
        myPallet.grabbed = false;
        // Drag and drop an icon
        adding = true;
        dragging = true;
        addIcon();
        int last = myIcons.size() - 1;
        Icon thisIcon = (Icon) myIcons.get(last);
        thisIcon.grabbed = true;
        thisIcon.offX = mouseX - thisIcon.x;
        thisIcon.offY = mouseY - thisIcon.y;
      }
    } 
    else { // mouse NOT clicked over menu pallet
      for (int i=0; i<iconCount; i++) {
        Icon thisIcon = (Icon) myIcons.get(i);
        if ( thisIcon.onIcon() ) {
          dragging = true;
          thisIcon.grabbed = true;
          thisIcon.offX = mouseX - thisIcon.x;
          thisIcon.offY = mouseY - thisIcon.y;
        } else {
          thisIcon.grabbed = false;        
        }
      }
    }
  }
}


void mouseDragged() {
  for (int i=0; i<iconCount; i++) {
    Icon thisIcon = (Icon) myIcons.get(i);
    if (thisIcon.grabbed) {
      thisIcon.move(); 
    }
  }
  if (myPallet.grabbed) {
    myPallet.move(); 
  }
}


void mouseReleased() {
  dragging = false;
  adding = false;
  for (int i=0; i<iconCount; i++) {
    Icon thisIcon = (Icon) myIcons.get(i);
    thisIcon.grabbed = false;
  }
  myPallet.grabbed = false;
}


void addIcon() {
  iconCount += 1;
  print("Button: " + onButton);
  char g = iMatrix[ onButton ];
  print(", new " + g);
  Icon newIcon = new Icon(mouseX - SIZE/2, mouseY - SIZE/2, g);
  myIcons.add(newIcon);
  println(". Total icons: " + myIcons.size() + "." );
}


class Icon {
  char iconType; // C, S, T maps to Circle, Square, Triangle
  int x, y; // upper left corner of icon square
  color c = color(20);
  boolean grabbed = false;
  int offX = 0;
  int offY = 0;
  
  Icon(int tempX, int tempY, char tempType) {
    iconType = tempType;
    x = tempX;
    y = tempY;
  }
  
  void display() {
    noFill();
    strokeWeight(2);
    stroke(c);
    
    pushMatrix();
    translate(x,y);
    
    if (iconType == 'C') {
      ellipseMode(CORNERS);
      ellipse(0,0, SIZE, SIZE);
      
    } else if (iconType == 'S') {
      rect(0,0, SIZE, SIZE);
      
    } else if (iconType == 'T') {
      triangle(0,SIZE, SIZE,SIZE, SIZE/2,0);
      
    } else {
      println("Type Error!"); // Define additional shapes!
    }
    
    popMatrix();
  }
  
  void move() {     
    x = mouseX - offX;
    y = mouseY - offY;
    
    if ( x < 0 ) {
      x = 0;
    } else if ( x > width-SIZE ) {
      x = width - SIZE;
    }
    if ( y < 0 ) {
      y = 0;
    } else if ( y > height-SIZE /**/ ) {
      y = height - SIZE /**/;
    }
  }
  
  boolean onIcon() {
    if ( (mouseX > x - 1) && (mouseX < x + SIZE + 1) &&
         (mouseY > y - 1) && (mouseY < y + SIZE + 1) ) {
           return true;
     } else {
       return false;
     }
  }
}


class Pallet {
  int x,y; // x,y position of upper left corner
  int h = 160; // height
  int w = 40; // width
  int bar = 15; // height of menu bar
  final int NUM_BUTTONS = 3; // Define additional types of icons if >3
  
  float buttonH = (h - bar) / float(NUM_BUTTONS); // Height of button
  boolean grabbed = false;
  int offX = 0;
  int offY = 0;
  
  Pallet(int tempX, int tempY) {
    x = tempX;
    y = tempY;
  }
  
  void display() {
    pushMatrix();
    translate(x,y);
    
    noStroke();
    fill(100,30);
    rect(0,0, w,h); // background
    
    fill(100,70);
    rect(0,0, w,bar); // menu bar
    
    noFill();
    stroke(20,200,20);
    strokeWeight(2);
    translate( (w-SIZE)/2.0, bar-1 + (buttonH-SIZE)/2.0);    
    ellipseMode(CORNERS);
    ellipse(0,0, SIZE, SIZE);
    
    if (NUM_BUTTONS > 1) {
    translate(0,buttonH);
    rect(0,0, SIZE, SIZE);
    }
    if (NUM_BUTTONS > 2) {
    translate(0,buttonH);
    triangle(0,SIZE, SIZE,SIZE, SIZE/2,0);
    }
    
    popMatrix();
  }
  
  void move() {
    x = mouseX - offX;
    y = mouseY - offY;
    if ( x < 0 ) {
      x = 0;
    } else if ( x > width-w ) {
      x = width - w;
    }
    if ( y < 0 ) {
      y = 0;
    } else if ( y > height-bar ) {
      y = height - bar;
    }
  }
  
  void highlight() {
    if ((relY() > 0) && (relY() < h-bar) ){
      // mouse NOT over menu bar
      pushMatrix();
      onButton = floor(relY() / buttonH);
      translate(x,y+bar + (buttonH * onButton ) );
      fill(255,120);
      noStroke();
      rect(0,0, w,buttonH);
      
      popMatrix();
    }
  }
  
  boolean onPallet() {
    // True if mouse over pallet
    if ( (mouseX > myPallet.x - 1) && (mouseX < myPallet.x + myPallet.w + 1) &&
       (mouseY > myPallet.y - 1) && (mouseY < myPallet.y + myPallet.h + 1) ) {
         return true;
       } else {
         return false;
       }
  }
  
  boolean onBar() {
    // True if mouse over pallet's bar
    if ( (mouseX > myPallet.x - 1) && (mouseX < myPallet.x + myPallet.w + 1) &&
       (mouseY > myPallet.y - 1) && (mouseY < myPallet.y + myPallet.bar + 1) ) {
         return true;
       } else {
         return false;
       }
  }

  int relY() {
    // Relative y position of the mouse.
    return mouseY - y - bar;
  }
  
}
