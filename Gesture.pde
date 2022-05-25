public class Gesture{
  int diff;
  HashMap<Integer, int[]> gestures;
  
  public Gesture(int diff){
    this.diff = diff;
    gestures = new HashMap<Integer, int[]>();
    
    gestures.put(1, new int[]{ 1,2,3,5});
    gestures.put(2, new int[]{ 1,2,4,5});
    gestures.put(3, new int[]{ 1,3,4,5});
    gestures.put(4, new int[]{ 2,3,4,8});
    gestures.put(5, new int[]{ 1,5,6,7});
    gestures.put(6, new int[]{ 2,5,6,8});
    gestures.put(7, new int[]{ 3,5,7,8});
    gestures.put(8, new int[]{ 4,6,7,8});
  } 

  public int[] getDailyGesture(){
    int[] res = new int[3];
    int start = (int) random(1,9);
    println(start);
    res[0] = start;
    for(int i = 0; i < 2; i++){
      int ran = (int) random(0,4);
      res[i+1] = gestures.get(start)[ran];
      start = res[i+1];
    }
    return res;
  }
}
