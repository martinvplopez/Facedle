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
import processing.sound.*;

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
PImage config = new PImage();
PImage help = new PImage();
PImage x = new PImage();
PImage tick = new PImage();
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

Element rightEye, leftEye, mouth;

int tryNum;
int possibleTries;
int [] actualTry;
int selectedGesture;
int numSelected;

boolean isCalibrated = false;


PImage[] faceImages = new PImage[9];
PImage validatedFace;
int contImages = 0;

SoundFile music;
int musicAmp = 5;
SinOsc osc;
Env env;

void setup() {
  size(1080, 700);
  secuencial = 1;
  newSelection = true;
  for (int i=1; i<9; i++) {
    images[i-1] = loadImage("images/"+i+".png");
  }
  config = loadImage("images/config.png");
  help = loadImage("images/help.png");
  x = loadImage("images/x.png");
  tick = loadImage("images/tick.png");

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
  int[] data1 = { 4, 4, 3 };
  int[] data2 = { 3, 2, 3 };
  dailyGesture = gesture.setGestures(data1, data2);
  //dailyGesture = gesture.getDailyGesture();
  for (int i=0; i<3; i++) {
    println(dailyGesture[i]+" ");
  }
  actualTry= new int[3];
  tryNum=0;
  possibleTries=gesture.getTries();
  selectedGesture=-1;
  numSelected=0;

  //sonido
  music = new SoundFile(this, "sounds/music.mp3");
  //establezco el volumen por defecto
  music.amp(map(musicAmp, 0, 15, 0, 1));
  music.play();
  osc = new SinOsc(this);
  env  = new Env(this);
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
    game_settings();
    break;
  case CALIBRATE:
    calibrate();
    break;
  }
}

void principal() {
  textSize(70);
  fill(0);
  textAlign(CENTER);
  text("Facedle!", width/2, 150);
  textSize(35);
  text("¿Serás capaz de acertar el gesto del día?", width/2, 230 );

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
  textAlign(LEFT);
  stroke(0);
  fill(80);
  textSize(50);
  text("Facedle!", 30, 60);
  textAlign(CENTER);
  fill(0);
  textSize(50);
  text("Reglas", width/2, 125);

  // List of the rules of the game
  textSize(35);
  text("- Tienes que adivinar 3 gestos", width/2, 200);
  text("- Los gestos pueden repetirse", width/2, 250);
  text("- Los gestos contiguos solo tienen UNA diferencia", width/2, 300);
  image(images[7], width/2 - 340, 350);
  image(images[6], width/2 - 240, 350);
  image(tick, width/2 - 140, 350);
  image(images[7], width/2 + 60, 350);
  image(images[4], width/2 + 160, 350);
  image(x, width/2 + 260, 350);
  text("- Tienes 3 intentos, ¡buena suerte!", width/2, 500);

  //boton empezar
  if (mouseX>=width/2-75 && mouseX<=width/2+75 && mouseY>=height/2+205 && mouseY<=height/2+250) {
    fill(80, 200, 120);
  } else {
    noFill();
  }
  strokeWeight(1.5);
  rect(width/2-75, height/2+205, 150, 70, 45);
  textSize(28);
  fill(0);
  text("Empezar", width/2, height/2+250);
}

void game() {
  visualizeGame();

  detectFaces(30, 420, 35, 90);

  fill(255, 0, 0);
  textSize(20);
  text("Right EAR " + rightEye.getEAR(), 30, 420 );
  text("Left EAR " + leftEye.getEAR(), 30, 450 );
  text("Mouth EAR " + mouth.getEAR(), 30, 480 );

  //Muestra las fotos de las caras
  for (int i=0; i<3; i++) {
    if (faceImages[i]!=null) {
      image(faceImages[i], 510, 100+130*i);
    }
  }

  for (int i=0; i<3; i++) {
    if (faceImages[i+3]!=null) {
      image(faceImages[i+3], 690, 100+130*i);
    }
  }

  for (int i=0; i<3; i++) {
    if (faceImages[i+6]!=null) {
      image(faceImages[i+6], 870, 100+130*i);
    }
  }

  if (tryNum==3) {
    println("HAN terminado tus intentos...");
  } else {
    if (keyPressed && key==' ') {
      // If there has gesture been clicked and there are max clicks, get the try and evaluate it
      if (selectedGesture!=-1&&numSelected<3 && newSelection) {
        println("Inserting gesture");
        faceImages[contImages] = validatedFace;
        faceImages[contImages].resize(120, 120);
        contImages++;
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
      validatedFace = cam.get();
      println("Validated");
    }
  }
}

void game_settings() {
  visualizeGame();
  //menú de ayuda
  fill(255);
  rect(width/2-250, 150, 500, 370);
  fill(50);
  textSize(28);
  text("AJUSTES", width/2-60, 195);


  if (mouseX>=width/2-180 && mouseX<=width/2-55 && mouseY>=250 && mouseY<=330) fill(51, 173, 189);
  else noFill();
  rect(width/2-180, 250, 125, 80);
  if (mouseX>=width/2+25 && mouseX<=width/2+195 && mouseY>=250 && mouseY<=330) fill(255, 0, 0);
  else noFill();
  rect(width/2+25, 250, 170, 80);
  fill(100);
  textSize(23);
  text("Resetear", width/2-161, 300);
  //text("You will get another face!\nOnly possible on demo!", width/2-155, 350);
  textSize(23);
  text("Volver al MENU", width/2+40, 300);

  text("Volumen:", width/2-200, 450);
  //dibuja el volumen
  noStroke();
  for (int i = 0; i < musicAmp; i++) {
    rect(width/2-70+i*8, 430, 4, 20);
  }
  stroke(0);
  noFill();
  rect(width/2-75, 425, 126, 30);

  //sale de la configuración
  if (mousePressed &&(mouseX<=width/2-250 || mouseX>=width/2+250 || mouseY<=150 || mouseY>=520)) {
    mode = GAME_UI;
  }
}

void calibrationHelp() {
  fill(51, 173, 189);
  textSize(30);
  text("CALIBRACIÓN:", 25, 450 );
  textSize(25);
  text("IMITA LAS SIGUIENTES CARAS", 25, 490 );
  textSize(18);
  text("PULSA ESPACIO PARA CONFIRMAR", width/2-125, 415);
  noFill();
  rect(width/2-95, 460, 86, 86);
  rect(width/2, 460, 86, 86);
}

void calibrate() {
  if (cam.available()) {
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
  image(img, width/2-cam.width/2, 90);

  detectFaces(width/2+cam.width/2, cam.height, width/2-cam.width/2, 90);
  //progress bar
  noFill();
  strokeWeight(1.5);
  rect(410, 600, 250, 30, 50);
  switch(secuencial) {
  case 1:
    break;
  case 2:
    fill(80, 200, 120);
    rect(410, 600, 125, 30, 50);
    break;
  case 3:
    fill(80, 200, 120);
    rect(410, 600, 250, 30, 50);
    break;
  }

  switch(secuencial) {
  case 1:
    calibrationHelp();
    image(images[7], width/2-92, 463);
    tint(255, 80);
    image(images[0], width/2+3, 463);
    tint(255, 255);
    break;
  case 2:
    calibrationHelp();
    tint(255, 80);
    image(images[7], width/2-92, 463);
    tint(255, 255);
    image(images[0], width/2+3, 463);
    break;
  case 3:
    fill(80, 200, 120);
    textSize(30);
    text("¡INCREÍBLE, ESTÁS PREPARADO!", width/2-200, 463 );
    textSize(20);
    text("PULSA ESPACIO PARA EMPEZAR", width/2-125, 415);
    break;
  }
  if (keyPressed && key==' ') {
    switch(secuencial) {
    case 1:
      osc.play((pow(2, ((61-69)/12.0))) * 440, 0.5);
      env.play(osc, 0.001, 0.004, 0.5, 0.4);

      int rightEyeOpen = rightEye.getEAR();
      int leftEyeOpen = leftEye.getEAR();
      eyesOpen = (rightEyeOpen + leftEyeOpen) / 2;

      mouthOpen = mouth.getEAR();
      secuencial++;
      break;
    case 2:
      osc.play((pow(2, ((61-69)/12.0))) * 440, 0.5);
      env.play(osc, 0.001, 0.004, 0.5, 0.4);

      int rightEyeClose = rightEye.getEAR();
      int leftEyeClose = leftEye.getEAR();
      eyesClose = (rightEyeClose + leftEyeClose) / 2;

      mouthClose = mouth.getEAR();
      secuencial++;
      break;
    case 3:
      osc.play((pow(2, ((61-69)/12.0))) * 440, 0.5);
      env.play(osc, 0.001, 0.004, 0.5, 0.4);

      calibration = new Player(mouthOpen, mouthClose, eyesOpen, eyesClose);
      isCalibrated = true;
      mode=GAME_UI;

      break;
    }
  }
}

void mouseClicked() {
  if (mode==PRINCIPAL_MENU&&mouseX>=width/2-200 && mouseX<=width/2-50 && mouseY>=height/2 && mouseY<=height/2+70) {
    clickSound();
    mode = CALIBRATE;
  }
  if (mode==PRINCIPAL_MENU&&mouseX>=width/2+50 && mouseX<=width/2+200 && mouseY>=height/2 && mouseY<=height/2+70) {
    clickSound();
    mode = REGLAS_MENU;
  }
  //activa la configuracion
  if (mode==GAME_UI&&mouseX>=935 && mouseX<=975 && mouseY>=25 && mouseY<=65) {
    clickSound();
    mode = GAME_SETTINGS;
  }

  if (mode==GAME_UI&&mouseX>=1000 && mouseX<=1040 && mouseY>=25 && mouseY<=65) {
    clickSound();
    mode = REGLAS_MENU;
  }

  if (mode==REGLAS_MENU&&mouseX>=width/2-75 && mouseX<=width/2+75 && mouseY>=height/2+205 && mouseY<=height/2+250) {
    clickSound();
    if (!isCalibrated) {
      mode = CALIBRATE;
    } else {
      mode = GAME_UI;
    }
  }

  if (mode==GAME_UI) {
    for (int i=0; i<8; i++) {
      if (mouseX>=115+i*110 && mouseX<=115+i*110+80 && mouseY>=550 && mouseY<=630) {
        clickSound();
        selectedGesture = i+1;
        println("Selected:"+selectedGesture);
        newSelection = false;
      }
    }
  }
}

private void detectFaces(int xEar, int yEar, int posOriginX, int posOriginY) {
  //Detección de puntos fiduciales
  ArrayList<MatOfPoint2f> shapes = detectFacemarks(cam);
  int maxFaceValue = -1;
  int maxFaceIndex = -1;
  int currentFaceValue;
  int index = 0;
  if (shapes.size() > 0) {
    PVector origin = new PVector(posOriginX, posOriginY);
    for (MatOfPoint2f sh : shapes) {
      Point [] pts = sh.toArray();
      currentFaceValue = (int)dist((float)pts[0].x, (float)pts[0].y, (float)pts[16].x, (float)pts[16].y);
      if (currentFaceValue > maxFaceValue) {
        maxFaceValue = currentFaceValue;
        maxFaceIndex = index;
      }
      index++;
    }
    Point [] face = shapes.get(maxFaceIndex).toArray();
    drawFacemarks(face, origin);
    //background(255);
    //PImage newImage = cam.get();
    //newImage.save("outputImage.jpg");
    Point [] rightEyePts = Arrays.copyOfRange(face, 36, 42);
    rightEye = new Element(rightEyePts);
    Point [] leftEyePts = Arrays.copyOfRange(face, 42, 48);
    leftEye = new Element(leftEyePts);
    Point [] mouthPts = new Point [6];
    int c=0;
    for (int i=0; i<8; i++) {
      if (i!=2 && i!=6) {
        mouthPts[c]=face[i];
        c++;
      }
    }
    mouth = new Element(mouthPts);
    fill(255, 0, 0);
    textSize(20);
    text("Right EAR " + rightEye.getEAR(), xEar, yEar );
    text("Left EAR " + leftEye.getEAR(), xEar, yEar+30 );
    text("Mouth EAR " + mouth.getEAR(), xEar, yEar+60 );
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
    // change the flat values with the position of the cam
    ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
  }
  popStyle();
}

public void visualizeGame() {
  if (cam.available()) {
    cam.read();
  }

  textAlign(LEFT);
  stroke(0);
  fill(80);
  textSize(50);
  text("Facedle!", 30, 60);

  //Rectangles
  fill(200);
  rect(450, 90, 600, 400);

  fill(250);

  //boton configuración
  image(config, 935, 25);

  //boton ayuda
  image(help, 1000, 25);

  for (int i=0; i<3; i++) {
    for (int j=0; j<3; j++) {
      rect(510+i*180, 100+j*130, 120, 120);
    }
  }

  rect(90, 540, 900, 100);

  for (int i=0; i<8; i++) {
    // hover of the faces
    if (mouseX>=115+i*110 && mouseX<=115+80+i*110 && mouseY>=550 && mouseY<=550+80) {
      if (mode == GAME_UI) {
        fill(200);
        rect(112+i*110, 547, 86, 86);
      }
    } else {
      noFill();
    }
    // Border of the selected gesture
    if (selectedGesture == i+1) {
      fill(0);
      rect(112+i*110, 547, 86, 86);
    }
    image(images[i], 115+i*110, 550);
    if (buttonAct[i]) {
    }
  }
  //Get image from cam
  img.copy(cam, 0, 0, cam.width, cam.height, 
    0, 0, img.width, img.height);
  img.copyTo();

  //Imagen de entrada
  fill(0);
  rect(30, 90, 410, 310);
  image(img, 35, 95);
}

void keyPressed() {
  if (key == '+') {
    //aumenta el volumen de la música
    if (musicAmp < 15)
      musicAmp++;
    music.amp(map(musicAmp, 0, 15, 0, 1));
  } else if (key == '-') {
    //disminuye el volumen de la música
    if (musicAmp > 0)
      musicAmp--;
    music.amp(map(musicAmp, 0, 15, 0, 1));
  }
}

void clickSound() {
  osc.play((pow(2, ((67-69)/12.0))) * 440, 0.5);
  env.play(osc, 0.001, 0.004, 0.5, 0.4);
}
