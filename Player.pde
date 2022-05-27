public class Player {
  float mouthOpened;
  float mouthClosed;
  float eyeOpened;
  float eyeClosed;
  
  float mouthThreshold, eyesThreshold;

  public Player(float mouthOpen, float mouthClose, float eyesOpen, float eyesClose) {
    mouthOpened = mouthOpen;
    mouthClosed = mouthClose;
    eyeOpened = eyesOpen;
    eyeClosed = eyesClose;
    
    mouthThreshold = mouthOpened - mouthClosed;
    eyesThreshold = eyeOpened - eyeClosed;
  }
  /**
   public float getMouthThreshold() {
   
   }
   
   public float getEyesThreshold() {
   
   }*/
   
   public boolean isEyeOpen(int eye) {
     if(eyeOpened - eye <= eyesThreshold){
       
     }
     return false;  //Eye is CLOSED
   
   }
   
  /* public boolean isMouthOpen(int mouth) {
     mouthThreshold
     return false;  //Mouth is CLOSED
   }*/

  public boolean checkGesture(int gesture, int rightEye, int leftEye, int mouth) {
    switch(gesture) {
    case 0:  // Both eyes CLOSE and mouth CLOSE
      //if(){
        
      //}
      break;
      
    case 1:  // left eye OPEN, right eye CLOSE and mouth CLOSE
      break;

    case 2:  // left eye CLOSE, right eye OPEN and mouth CLOSE
      break;

    case 3:  // Both eyes OPEN and mouth CLOSE
      break;

    case 4:  // Both eyes CLOSE and mouth OPEN
      break;

    case 5:  // left eye OPEN, right eye CLOSE and mouth OPEN
      break;

    case 6:  // left eye CLOSE, right eye OPEN and mouth OPEN
      break;

    case 7:  // Both eyes OPEN and mouth OPEN
      break;
    }
    return false;
  }
}
