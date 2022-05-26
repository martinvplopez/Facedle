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
final int PRINCIPAL_MENU=1;
final int REGLAS_MENU=2;
final int GAME_UI=3;
final int GAME_SETTINGS=4;

final int CAPW = 400;
final int CAPH = 300;

Capture cam;
CVImage img;

PrintWriter output;

//Detectores
CascadeClassifier face;
//Máscara del rostro
Facemark fm;
//Nombres
String faceFile, modelFile;

void setup() {
  size(1080, 700);

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

  output= createWriter("points.txt");
}

void principal() {
  textSize(50);
  fill(0);
  textAlign(CENTER);
  text("Facedle!", width/2, 50);
  textSize(35);
  text("¿Serás capaz de acertar el gesto del día?", width/2, 130 );
  noFill();
  strokeWeight(1.5);
  rect(width/2-200, height/2, 150, 70, 45);
  textSize(28);
  text("Jugar", width/2-125, height/2+40);
  rect(width/2+50, height/2, 150, 70, 45);
  text("Reglas", width/2+125, height/2+40);
}

void reglas() {
  textSize(50);
  fill(0);
  textAlign(CENTER);
  text("Facedle!", width/2, 50);
  textSize(35);
  text("¿Serás capaz de acertar el gesto del día?", width/2, 105);
  noFill();
  strokeWeight(1.5);
  rect(width/2+150, height/2, 150, 70, 45);
  textSize(28);
  text("Empezar", width/2+220, height/2+40);
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
  rect(450, 90, 600, 350);
  rect(90, 530, 900, 100);


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
    Point [] leftEyePts = Arrays.copyOfRange(face, 43, 49);
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
    println("Mouths EAR: " + mouth.getEAR());
    fill(255, 0, 0);
    textSize(30);
    text("Right EAR " + rightEye.getEAR(), 500,150 );    
    text("Left EAR " + leftEye.getEAR(), 500,200 );
    text("Mouth EAR " + mouth.getEAR(), 500,250 );
    if (keyPressed && key==ENTER) {
    }
  }
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
  }
}

void mouseClicked() {
  if (mode==PRINCIPAL_MENU&&mouseX>=width/2-200 && mouseX<=width/2-50 && mouseY>=height/2 && mouseY<=height/2+70) {
    mode=GAME_UI;
  }
  if (mode==PRINCIPAL_MENU&&mouseX>=width/2+50 && mouseX<=width/2+200 && mouseY>=height/2 && mouseY<=height/2+70) {
    mode=REGLAS_MENU;
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
