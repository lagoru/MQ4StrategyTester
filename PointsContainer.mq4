//+------------------------------------------------------------------+
//|                                              PointsContainer.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

struct Point{
   double x;
   double y;
   
   Point(){
   }
   
   Point(Point &point){
      x = point.x;
      y = point.y;
   }
   
   Point(double _x, double _y){
      x=_x;
      y=_y;
   }
   Point operator=(const Point &sourcePoint){
      x=sourcePoint.x;
      y=sourcePoint.y;
      return(this);
   }
};

class PointsContainer{
   Point points[];
   int mNumber;
   
   public:
   PointsContainer(){
      ArrayResize(points,10,1000);
      mNumber =0;
   }
   
   void addPoint(double x, double y){
      if(ArraySize(points) < (++mNumber)){
         ArrayResize(points,ArraySize(points)+20);
      }
      Point point(x,y);
      points[mNumber-1] = point;
   }
   
   void addPoint(Point &_point){
      if(ArraySize(points) < (++mNumber)){
         ArrayResize(points,ArraySize(points)+20);
      }
      Point point(_point);
      points[mNumber-1] = point;
   }
   
   Point operator[](int pos){
      return points[pos];
   }
   
   int getSize(){
      return mNumber;
   }
   
   void clear(){
      mNumber =0;
      ArrayResize(points,10,1000);
   }
   ~PointsContainer(){
      ArrayFree(points);
   }
};