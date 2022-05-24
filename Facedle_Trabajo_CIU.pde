int mode;
final int PRINCIPAL_MENU=1;
final int REGLAS_MENU=2;
final int GAME_UI=3;
final int GAME_SETTINGS=4;

void setup(){
  mode=PRINCIPAL_MENU;
  size(800,700);
}


void principal(){
  textSize(50);
  fill(0);
  textAlign(CENTER);
  text("Facedle!",width/2,50);
  textSize(35);
  text("¿Serás capaz de acertar el gesto del día?",width/2,130 );
  noFill();
  strokeWeight(1.5);
  rect(width/2-200, height/2, 150, 70, 45);
  textSize(28);
  text("Jugar",width/2-125,height/2+40);
  rect(width/2+50, height/2, 150, 70, 45);
  text("Reglas",width/2+125,height/2+40);

}

void reglas(){
  textSize(50);
  fill(0);
  textAlign(CENTER);
  text("Facedle!",width/2,50);
  textSize(35);
  text("¿Serás capaz de acertar el gesto del día?",width/2,105);
  noFill();
  strokeWeight(1.5);
  rect(width/2+150, height/2, 150, 70, 45);
  textSize(28);
  text("Empezar",width/2+220,height/2+40);
}



void game(){
  textAlign(LEFT);
  text("Facedle!",30,30);



}

void draw(){
  background(255);
  switch(mode){
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

void mouseClicked(){
  if(mouseX>=width/2-200 && mouseX<=width/2-50 && mouseY>=height/2 && mouseY<=height/2+70){
    mode=GAME_UI;
  }
  if(mouseX>=width/2+50 && mouseX<=width/2+200 && mouseY>=height/2 && mouseY<=height/2+70){
    mode=REGLAS_MENU;
  }
  
}
