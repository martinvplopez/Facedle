public class Gesture {
  int diff;
  HashMap<Integer, int[]> gestures;
  int dailyGesture[];

  public Gesture(int diff) {
    this.diff = diff;
    gestures = new HashMap<Integer, int[]>();

    gestures.put(1, new int[]{ 1, 2, 3, 5});
    gestures.put(2, new int[]{ 1, 2, 4, 5});
    gestures.put(3, new int[]{ 1, 3, 4, 5});
    gestures.put(4, new int[]{ 2, 3, 4, 8});
    gestures.put(5, new int[]{ 1, 5, 6, 7});
    gestures.put(6, new int[]{ 2, 5, 6, 8});
    gestures.put(7, new int[]{ 3, 5, 7, 8});
    gestures.put(8, new int[]{ 4, 6, 7, 8});
    dailyGesture=new int[3];
  }
  // Function which returns random daily gesture
  public int[] getDailyGesture() {
    int start = (int) random(1, 9);
    dailyGesture[0] = start;
    for (int i = 0; i < 2; i++) {
      int ran = (int) random(0, 4);
      dailyGesture[i+1] = gestures.get(start)[ran];
      start = dailyGesture[i+1];
    }
    return dailyGesture;
  }

  // Based on gesture´s difficulty there will be different number of tries: easy (1): 3 tries, hard(2): 2 tries
  public int getTries() {
    if (diff==2) return 2;
    return 3;
  }

  public int[] setGestures(int[] answer, int[] attempt) {
    dailyGesture = answer;
    return checkGesture(attempt);
  }

  // Function which evaluates a try, if an action is in correct position(1), in another position(2) or incorrect action(0)
  public int[] checkGesture(int[] gestureTry) {
    int[] res=new int[3];
    int[] dailyGestureCopy = new int[3];

    for (int i=0; i<3; i++) {
      dailyGestureCopy[i] = dailyGesture[i];
    }
    
    // Loop that checks corrects
    for (int i=0; i<3; i++) {
      if (gestureTry[i]==dailyGestureCopy[i]) {
        res[i] = 1;
        dailyGestureCopy[i] = -1;
        gestureTry[i] = -1;
      }
    }
    
    for (int i=0; i<3; i++) {
      for (int j=0; j<3; j++) {
        if (gestureTry[i] == dailyGestureCopy[j] && j!=i && gestureTry[i] != -1) {
          res[i] = 2;
          dailyGestureCopy[j] = -1;
          gestureTry[i] = -1;
        }
      }
    }
    return res;
  }
}
