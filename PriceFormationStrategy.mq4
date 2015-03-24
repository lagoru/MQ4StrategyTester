//+------------------------------------------------------------------+
//|                                      PriceFormationsStrategy.mq4 |
//|                                                    Adrian Ziemek |
//|                                                         BlaBlBla |
//+------------------------------------------------------------------+
#property library
#property copyright "Adrian Ziemek"
#property link      "BlaBlBla"
#property version   "1.00"
#property strict

#include "LineContainer.mq4"
#include  "PointsContainer.mq4"
#include "Strategy.mq4"
   
class PriceFormationStrategy : public Strategy{

   PointsContainer pointsUpperLine;
   PointsContainer pointsNormalLine;
   PointsContainer pointsLowerLine;
   
   double mPi;
   int mEpsilon;
   string mPair;
   
   /*metoda do znalezienia linii metod¹ najmniejszych kwadratów*/
   void leastSquaresMethod(double &a, double&b, Point & points[]){
      double delta = 0,s_x = 0,s_y = 0,s_xx = 0, s_xy=0;
      
      for(int i = 0;i < ArraySize(points); i++){
         s_x += points[i].x;
         s_y += points[i].y;
         s_xx += (MathPow(points[i].x,2));
         s_xy += (points[i].x*points[i].y);
      }
      delta = MathPow(s_x,2) - s_xx*ArraySize(points);
      a = (s_x*s_y - s_xy*ArraySize(points))/delta;
      b = (s_x*s_xy - s_xx*s_y)/delta;
   }
   
   int getCommonPointOfLines(){
      return (mBlower - mBupper)/(mAupper-mBlower);
   }
   
   double calculateAngleBetweenLines(double b1, double b2){
      if(b1 == b2){
         return 0;
      }
      double tangens = MathAbs((b1-b2)/(1+b1*b2));
      return 180.0 - 180.0/mPi*MathArctan(tangens);
   }
   
   Point getBiggestValuePoint(Point points[],int size){
      Point point(0,0);
      for(int i=0; i < size;i++){
         if(point.y < points[i].y){
            point.x = points[i].x;
            point.y = points[i].y;
         }
      }
      return point;
   }
   
   Point getLowestValuePoint(Point points[],int size){
      Point point(0,1000);
      for(int i=0; i < size;i++){
         if(point.y > points[i].y){
            point.x = points[i].x;
            point.y = points[i].y;
         }
      }
      return point;
   }
   
   bool checkIfPointOnLine(Point point, Line line){
   
   
   }
   void extractMiddleLines(PointsContainer &middle_points, LineContainer &medium_lines, int epsilon, int amount_of_lines){
      int i=0;
      Line actual_line;
      Point potint_tmp1;
      while(1){
         middle_points[i].
         
         i++;
      }
   }
   
   void extractLines(PointsContainer lower_points, PointsContainer medium_points, PointsContainer upper_points,
                      LineContainer &lower_lines, LineContainer &medium_lines, LineContainer &upper_lines, int epsilon){
   
      extractMiddleLines(medium_points,medium_lines,epsilon,10);
   
   
   }
   public:
   
   /*epsilon do zaokr¹glania linii (np. epsilon 2 mo¿e zignorowaæ jeden punkt pomiêdzy dwoma punktami)*/
   PriceFormationStrategy(int epsilon,string pair= NULL){
      mPi=0.0;
      for(double i=0; i<11; i++) mPi+= 1/MathPow(16,i)*(4/(8*i+1)-2/(8*i+4)-1/(8*i+5)-1/(8*i+6));
      mEpsilon = epsilon;
      mPair = pair;
      mSizePointsUpperLine = mSizePointsLowerLine = 0;
      mActualIndex=0;
      ArrayResize(lTmpPointsUpperLine,timespace);
      ArrayResize(lTmpPointsLowerLine,timespace);
      ArrayResize(lTmpPointsNormalLine,timespace);
      mTimespace=timespace;
   }
   
   
   /*robi pojedynczy krok - analizuje obecne ceny*/
   int step(){
      double tmp_a,tmp_b;
      int x = TimeCurrent();
      
      pointsNormalLine.addPoint(x,(iOpen(mSymbol,Period(),0) + iClose(mSymbol,Period(),0)) /2.0);
      pointsLowerLine.addPoint(x, iLow(mSymbol,Period(),0));
      pointsUpperLine.addPoint(x, iHigh(mSymbol,Period(),0));
   }
   
   LineContainer tester;
   /*robi analizê op³acalnoœci w tym momencie od -10* do 10 (- sprzeda¿, + kupno)*/
   int doAnalyze(string pair= NULL){
      
      extractLines(pointsLowerLine,pointsNormalLine, pointsUpperLine, mEpsilon);
      
      if(ArraySize(pointsLowerLine) > 4){
         Line to_add(TimeCurrent(),getCommonPointOfLines(),calculateAngleBetweenLines(mBlower,mBupper)
            ,calculateAngleBetweenLines(mBlower,mBupper),calculateAngleBetweenLines(mBlower,mBupper));
         tester.addTest(to_add);      
      }
      
      return 0;
   }
}; 
