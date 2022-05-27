public class Player {
  int mouthOpened, mouthClosed;
  int eyeOpened, eyeClosed;

  int mouthThreshold, eyesThreshold;

  public Player(int mouthOpen, int mouthClose, int eyesOpen, int eyesClose) {
    mouthOpened = mouthOpen;
    mouthClosed = mouthClose;
    eyeOpened = eyesOpen;
    eyeClosed = eyesClose;

    mouthThreshold = (int)((mouthOpened - mouthClosed)*0.2);
    eyesThreshold = (int)((eyeOpened - eyeClosed)*0.1); //Error of 50%
  }

  private boolean isOpen(float value, float openValue, float threshold) {
    //Checks if the value its within the expected error
    if (value < openValue + threshold && value > openValue - threshold) {
      return true; //OPEN
    }
    //println("Value:"+value+" Open:"+openValue+" Threshold:"+threshold);
    return false;  //CLOSED
  }

  public boolean isEyeOpen(float eye) {
    return isOpen(eye, eyeOpened, eyesThreshold);
  }

  public boolean isMouthOpen(float mouth) {
    return isOpen(mouth, mouthOpened, mouthThreshold);
  }

  public boolean checkMatchingGesture(int gesture, int rightEye, int leftEye, int mouth) {
    switch(gesture) {
    case 1:  // Both eyes CLOSED and mouth CLOSED
      if (!isEyeOpen(leftEye) && !isEyeOpen(rightEye)&& !isMouthOpen(mouth)) {
        return true;
      }
      break;

    case 2:  // left eye OPEN, right eye CLOSED and mouth CLOSED
      if (isEyeOpen(leftEye) && !isEyeOpen(rightEye)&& !isMouthOpen(mouth)) {
        return true;
      }
      break;

    case 3:  // left eye CLOSED, right eye OPEN and mouth CLOSED
      if (!isEyeOpen(leftEye) && isEyeOpen(rightEye)&& !isMouthOpen(mouth)) {
        return true;
      }
      break;

    case 4:  // Both eyes OPEN and mouth CLOSED
      if (isEyeOpen(leftEye) && isEyeOpen(rightEye)&& !isMouthOpen(mouth)) {
        return true;
      }
      break;

    case 5:  // Both eyes CLOSED and mouth OPEN
      if (!isEyeOpen(leftEye) && !isEyeOpen(rightEye)&& isMouthOpen(mouth)) {
        return true;
      }
      break;

    case 6:  // left eye OPEN, right eye CLOSED and mouth OPEN
      if (isEyeOpen(leftEye) && !isEyeOpen(rightEye)&& isMouthOpen(mouth)) {
        return true;
      }
      break;

    case 7:  // left eye CLOSED, right eye OPEN and mouth OPEN
      if (!isEyeOpen(leftEye) && isEyeOpen(rightEye)&& isMouthOpen(mouth)) {
        return true;
      }
      break;

    case 8:  // Both eyes OPEN and mouth OPEN
      if (isEyeOpen(leftEye) && isEyeOpen(rightEye)&& isMouthOpen(mouth)) {
        return true;
      }
      break;
    }
    //println("Right:"+isEyeOpen(rightEye)+" Left:"+isEyeOpen(leftEye)+" Mouth:"+isMouthOpen(mouth));
    return false; // The gesture didn't match
  }
}
