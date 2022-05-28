import processing.video.*;
import java.lang.*;
import cvimage.*;
import org.opencv.core.*;
//Detectores
import org.opencv.objdetect.CascadeClassifier;
//Máscara del rostro
import org.opencv.face.Face;
import org.opencv.face.Facemark;

import java.util.Arrays;

int mode;
int secuencial;

boolean newSelection;

final int PRINCIPAL_MENU=1;
final int REGLAS_MENU=2;
final int GAME_UI=3;
final int GAME_SETTINGS=4;
final int CALIBRATE=5;

final int CAPW = 400;
final int CAPH = 300;

Capture cam;
CVImage img;

PImage[] images = new PImage[8];
boolean[] buttonAct = new boolean[8];


//Detectores
CascadeClassifier face;
//Máscara del rostro
Facemark fm;
//Nombres
String faceFile, modelFile;

int mouthOpen, mouthClose, eyesOpen, eyesClose;

Player calibration;
Gesture gesture;
int[] dailyGesture;

int tryNum;
int possibleTries;
int [] actualTry;
int selectedGesture;
int numSelected;


void setup() {
  size(1080, 700);
  secuencial = 1;
  newSelection = true;
  for (int i=1; i<9; i++) {
    images[i-1] = loadImage("images/"+i+".png");
  }

  cam = new Capture(this, CAPW, CAPH);
  cam.start();

  //OpenCV
  //Carga biblioteca core de OpenCV
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION);
  img = new CVImage(cam.width, cam.height);

  //Detectores
  faceFile = "haarcascade_frontalface_default.xml";
  //Modelo de máscara
  modelFile = "face_landmark_model.dat";
  fm = Face.createFacemarkKazemi();
  fm.loadModel(dataPath(modelFile));

  mode=PRINCIPAL_MENU;

  gesture = new Gesture(1);
  dailyGesture = gesture.getDailyGesture();
  for (int i=0; i<3; i++) {
    println(dailyGesture[i]+" ");
  }
  actualTry= new int[3];
  tryNum=0;
  possibleTries=gesture.getTries();
  selectedGesture=-1;
  numSelected=0;
}

void draw() {
  background(255);
  switch(mode) {
  case PRINCIPAL_MENU:
    principal();
    break;
  case REGLAS_MENU:
    reglas();
    break;
  case GAME_UI:
    game();
    break;
  case GAME_SETTINGS:
    break;
  case CALIBRATE:
    calibrate();
    break;
  }
}

void principal() {
  textSize(50);
  fill(0);
  textAlign(CENTER);
  text("Facedle!", width/2, 50);
  textSize(35);
  text("¿Serás capaz de acertar el gesto del día?", width/2, 130 );

  textSize(28);
  strokeWeight(1.5);
  
  //boton jugar
  if (mouseX>=width/2-200 && mouseX<=width/2-50 && mouseY>=height/2 && mouseY<=height/2+70) {
    fill(80, 200, 120);
  } else {
    noFill();
  }
  rect(width/2-200, height/2, 150, 70, 45);
  fill(0);
  text("Jugar", width/2-125, height/2+45);
  
  //boton reglas
  if (mouseX>=width/2+50 && mouseX<=width/2+200 && mouseY>=height/2 && mouseY<=height/2+70) {
    fill(80, 200, 120);
  } else {
    noFill();
  }
  rect(width/2+50, height/2, 150, 70, 45);
  fill(0);
  text("Reglas", width/2+125, height/2+45);
}

void reglas() {
  textSize(50);
  fill(0);
  textAlign(CENTER);
  text("Facedle!", width/2, 50);
  textSize(35);
  text("¿Serás capaz de acertar el gesto del día?", width/2, 105);
  
  //boton empezar
  if (mouseX>=width/2+150 && mouseX<=width/2+300 && mouseY>=height/2 && mouseY<=height/2+70) {
    fill(80, 200, 120);
  } else {
    noFill();
  }
  strokeWeight(1.5);
  rect(width/2+150, height/2, 150, 70, 45);
  textSize(28);
  fill(0);
  text("Empezar", width/2+225, height/2+45);
}

void game() {
  if (cam.available()) {
    //background(255);
    cam.read();
  }

  textAlign(LEFT);
  stroke(0);
  fill(80);
  textSize(50);
  text("Facedle!", 30, 60);

  //Rectangles
  rect(450, 90, 600, 400);

  for (int i=0; i<3; i++) {
    for (int j=0; j<3; j++) {
      rect(510+i*180, 100+j*130, 120, 120);
    }
  }

  rect(90, 540, 900, 100);

  for (int i=0; i<8; i++) {
    image(images[i], 115+i*110, 550);
    if (buttonAct[i]) {
    }
  }

  //Get image from cam
  img.copy(cam, 0, 0, cam.width, cam.height, 
    0, 0, img.width, img.height);
  img.copyTo();

  //Imagen de entrada
  image(img, 30, 90);
  //Detección de puntos fiduciales
  ArrayList<MatOfPoint2f> shapes = detectFacemarks(cam);

  if (shapes.size() > 0) {
    Point [] face = shapes.get(0).toArray();

    PVector origin = new PVector(0, 0);
    for (MatOfPoint2f sh : shapes) {
      Point [] pts = sh.toArray();
      drawFacemarks(pts, origin);
      break;
    }
    //background(255);
    //PImage newImage = cam.get();
    //newImage.save("outputImage.jpg");
    Point [] rightEyePts = Arrays.copyOfRange(face, 36, 42);
    Element rightEye = new Element(rightEyePts);
    //println(rightEye.getEAR());
    Point [] leftEyePts = Arrays.copyOfRange(face, 42, 48);
    Element leftEye = new Element(leftEyePts);
    Point [] mouthPts = new Point [6];
    int c=0;
    for (int i=0; i<8; i++) {
      if (i!=2 && i!=6) {
        mouthPts[c]=face[i];
        c++;
      }
    }
    Element mouth = new Element(mouthPts);
    fill(255, 0, 0);
    textSize(20);
    text("Right EAR " + rightEye.getEAR(), 30, 420 );
    text("Left EAR " + leftEye.getEAR(), 30, 450 );
    text("Mouth EAR " + mouth.getEAR(), 30, 480 );
    if (tryNum==3) {
      println("HAN terminado tus intentos...");
    } else {
      if (keyPressed && key==' ') {
        // If there has gesture been clicked and there are max clicks, get the try and evaluate it
        if (selectedGesture!=-1&&numSelected<3 && newSelection) {
          println("Inserting gesture");
          actualTry[numSelected]=selectedGesture;
          selectedGesture=-1;
          numSelected++;
          newSelection = false;
        }
      }
      if (numSelected==3) {
        tryNum++;
        print("Actual try:");
        for (int i=0; i<3; i++) {
          print(actualTry[i]+" ");
        }
        print("Results:");
        int []test=gesture.checkGesture(actualTry);
        int count=0;
        for (int i=0; i<3; i++) {
          if (test[i]==1) {
            count++;
          }
          print(test[i]+" ");
        }
        if (count==3) {
          println("RESPUESTA CORRECTA!");
        }
        numSelected=0;
      }
    }
    //println(calibration.checkMatchingGesture(selectedGesture, leftEye.getEAR(), rightEye.getEAR(), mouth.getEAR()));
    if (!newSelection) {
      if (selectedGesture != -1 && calibration.checkMatchingGesture(selectedGesture, leftEye.getEAR(), rightEye.getEAR(), mouth.getEAR())) {
        newSelection = true;
        println("Validated");
      }
    }
  }
}

void calibrate() {
  if (cam.available()) {
    //background(255);
    cam.read();
  }

  textAlign(LEFT);
  stroke(0);
  fill(80);
  textSize(50);
  text("Facedle!", 30, 60);

  //Get image from cam
  img.copy(cam, 0, 0, cam.width, cam.height, 
    0, 0, img.width, img.height);
  img.copyTo();

  //Imagen de entrada
  image(img, 30, 90);
  //Detección de puntos fiduciales
  ArrayList<MatOfPoint2f> shapes = detectFacemarks(cam);

  if (shapes.size() > 0) {
    Point [] face = shapes.get(0).toArray();

    PVector origin = new PVector(0, 0);
    for (MatOfPoint2f sh : shapes) {
      Point [] pts = sh.toArray();
      drawFacemarks(pts, origin);
      break;
    }
    //background(255);
    //PImage newImage = cam.get();
    //newImage.save("outputImage.jpg");
    Point [] rightEyePts = Arrays.copyOfRange(face, 36, 42);
    Element rightEye = new Element(rightEyePts);
    //println(rightEye.getEAR());
    Point [] leftEyePts = Arrays.copyOfRange(face, 42, 48);
    Element leftEye = new Element(leftEyePts);
    Point [] mouthPts = new Point [6];
    int c=0;
    for (int i=0; i<8; i++) {
      if (i!=2 && i!=6) {
        mouthPts[c]=face[i];
        c++;
      }
    }
    Element mouth = new Element(mouthPts);
    fill(255, 0, 0);
    textSize(20);
    text("Right EAR " + rightEye.getEAR(), 30, 420 );
    text("Left EAR " + leftEye.getEAR(), 30, 450 );
    text("Mouth EAR " + mouth.getEAR(), 30, 480 );

    //progress bar
    noFill();
    strokeWeight(1.5);
    rect(390, 550, 250, 30, 50);
    switch(secuencial) {
    case 1:
      break;
    case 2:
      fill(80, 200, 120);
      rect(390, 550, 125, 30, 50);
      break;
    case 3:
      fill(80, 200, 120);
      rect(390, 550, 250, 30, 50);
      break;
    }


    switch(secuencial) {
    case 1:
      fill(80, 200, 120);
      textSize(30);
      text("TO PERFORM THE CALIBRATION PLEASE FOLLOW THE NEXT STEPS", 450, 100 );
      textSize(20);
      text("- OPEN both your eyes and mouth and then PRESS the SPACEBAR ", 450, 150 );
      break;
    case 2:
      fill(80, 200, 120);
      textSize(30);
      text("GREAT! NOW CONTINUE WITH THE NEXT STEP", 500, 100 );
      textSize(20);
      text("- CLOSE both your eyes and mouth and then PRESS the SPACEBAR ", 500, 150 );
      break;
    case 3:
      fill(80, 200, 120);
      textSize(30);
      text("AWESOME! ARE YOU READY TO START?", 500, 100 );
      text("- PRESS SPACEBAR to START the game", 500, 150 );
      break;
    }
    if (keyPressed && key==' ') {
      switch(secuencial) {
      case 1:
        int rightEyeOpen = rightEye.getEAR();
        int leftEyeOpen = leftEye.getEAR();
        eyesOpen = (rightEyeOpen + leftEyeOpen) / 2;

        mouthOpen = mouth.getEAR();
        secuencial++;
        break;
      case 2:
        int rightEyeClose = rightEye.getEAR();
        int leftEyeClose = leftEye.getEAR();
        eyesClose = (rightEyeClose + leftEyeClose) / 2;

        mouthClose = mouth.getEAR();
        secuencial++;
        break;
      case 3:
        calibration = new Player(mouthOpen, mouthClose, eyesOpen, eyesClose);
        mode=GAME_UI;
        break;
      }
    }
  }
}

void mouseClicked() {
  if (mode==PRINCIPAL_MENU&&mouseX>=width/2-200 && mouseX<=width/2-50 && mouseY>=height/2 && mouseY<=height/2+70) {
    mode = CALIBRATE;
  }
  if (mode==PRINCIPAL_MENU&&mouseX>=width/2+50 && mouseX<=width/2+200 && mouseY>=height/2 && mouseY<=height/2+70) {
    mode = REGLAS_MENU;
  }
  if (mode==GAME_UI) {
    for (int i=0; i<8; i++) {
      if (mouseX>=115+i*110 && mouseX<=115+i*110+80 && mouseY>=550 && mouseY<=630) {
        selectedGesture = i+1;
        println("Selected:"+selectedGesture);
        newSelection = false;
      }
    }
  }
  if (mode==REGLAS_MENU&&mouseX>=width/2+150 && mouseX<=width/2+300 && mouseY>=height/2 && mouseY<=height/2+70) {
    mode = CALIBRATE;
  }
}

private ArrayList<MatOfPoint2f> detectFacemarks(PImage i) {
  ArrayList<MatOfPoint2f> shapes = new ArrayList<MatOfPoint2f>();
  CVImage im = new CVImage(i.width, i.height);
  im.copyTo(i);
  MatOfRect faces = new MatOfRect();
  Face.getFacesHAAR(im.getBGR(), faces, dataPath(faceFile));
  if (!faces.empty()) {
    fm.fit(im.getBGR(), faces, shapes);
  }
  return shapes;
}

private void drawFacemarks(Point [] p, PVector o) {
  pushStyle();
  noStroke();
  fill(255);
  for (Point pt : p) {
    ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
  }
  popStyle();
}
