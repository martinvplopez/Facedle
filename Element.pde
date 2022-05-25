public class Element{
  Point [] points;
  float ear;
  public Element(Point [] pts){
    points=pts;
  }
  
  
  public float getEAR(){
    ear= abs(dist((float)points[1].x,(float)points[1].y,(float)points[5].x,(float)points[5].y)+abs(dist((float)points[2].x,(float)points[2].y,(float)points[4].x,(float)points[4].y)))/2*abs(dist((float)points[0].x,(float)points[0].y,(float)points[3].x,(float)points[3].y));
    return ear;
  
  }

}
