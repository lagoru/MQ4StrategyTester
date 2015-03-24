//+------------------------------------------------------------------+
//|                                      PriceFormationStrategy2.mq4 |
//|                                                    Adrian Ziemek |
//|                                                         BlaBlBla |
//+------------------------------------------------------------------+
#property library
#property copyright "Adrian Ziemek"
#property link      "BlaBlBla"
#property version   "1.00"
#property strict
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

#include "Strategy.mq4"

struct Point{
   double x;
   double y;
   
   Point operator=(const Point &sourcePoint){
      x=sourcePoint.x;
      y=sourcePoint.y;
      return(this);
   }
};

class PriceFormationStrategy2 : public Strategy{

   Point pointsUpperLine[];
   Point pointsLowerLine[];
   double mPi;
   
   /*wspolczynniki funkcji ograniczajacych od do³u*/
   double mAlower, mBlower;
   /*wspolczynniki funkcji ograniczajacych od góry*/
   double mAupper, mBupper;
   
   private:
   
   
   /*zwraca punkty charakterystyczne dla ograniczaj¹cej górnej linii
   argument to sta³e typy PERIOD np. PERIOD_H4, timeframe - jakie przedzia³y czasowe s³upków
   ,interval - jakie przedzia³y szukania punktów (ile s³ópków)*/
   void getCharacteristicPointsOfTheUpperLine(string symbol,int timeframe, int period, int interval){
      int i,j;
      ArrayResize(pointsUpperLine,period/interval);
      for(i=0; i < period/interval; i++){
         pointsUpperLine[i].y=0;
         for(j =0; j < interval;j++){
            if(pointsUpperLine[i].y < iHigh(symbol,timeframe,interval*i+j)){
               pointsUpperLine[i].x = interval*i+j;
               pointsUpperLine[i].y = iHigh(symbol,timeframe,interval*i+j);
            }
         }
      }
   }
   
   /*zwraca punkty charakterystyczne dla ograniczaj¹cej górnej linii
   argument to sta³e typy PERIOD np. PERIOD_H4, timeframe - jakie przedzia³y czasowe s³upków
   ,interval - jakie przedzia³y szukania punktów (ile s³ópków)*/
   void getCharacteristicPointsOfTheLowerLine(string symbol,int timeframe, int period, int interval){
      int i,j;
      ArrayResize(pointsLowerLine,period/interval);
      for(i=0; i < period/interval; i++){
         pointsLowerLine[i].y=1000; // chyba nic nie ma wiêkszego kursu ?
         for(j =0; j < interval;j++){
            if(pointsLowerLine[i].y > iLow(symbol,timeframe,interval*i+j)){
               pointsLowerLine[i].x = interval*i+j;
               pointsLowerLine[i].y = iLow(symbol,timeframe,interval*i+j);
            }
         }
      }
   }
   
   /*pojedyñczy punkt*/
   Point getCharacteristicPointOfTheUpperLine(string symbol,int timeframe, int offsite, int interval){
      Point to_return;
      to_return.y=0;
      for(int j =0; j < interval;j++){
          if(to_return.y < iHigh(symbol,timeframe,offsite+j)){
              to_return.x = offsite+j;
              to_return.y = iHigh(symbol,timeframe,offsite+j);
          }
      }
      
      return to_return;
   }
   
   /*pojedyñczy punkt*/
   Point getCharacteristicPointOfTheLowerLine(string symbol,int timeframe, int offsite, int interval){
      Point to_return;
      to_return.y=1000; // chyba nic nie ma wiêkszego kursu ?
      for(int j =0; j < interval;j++){
        if(to_return.y > iLow(symbol,timeframe,offsite+j)){
           to_return.x = offsite+j;
           to_return.y = iLow(symbol,timeframe,offsite+j);
        }
      }
      return to_return;
   }
   
   /*wyszukuje najbardziej wysuniête punkty dolnej i górnej linii które nie przekraczaj¹ siebie nazwzajem*/
   void getLongestCharacteristicPointsOfBothLines(string symbol,int timeframe,int interval){
      Point lower, upper;
      int offsite = 0;
      upper = getCharacteristicPointOfTheUpperLine(symbol, timeframe,offsite,interval);
      lower = getCharacteristicPointOfTheLowerLine(symbol, timeframe,offsite,interval);
      ArrayResize(pointsUpperLine,2,100);
      ArrayResize(pointsLowerLine,2,100);
      pointsUpperLine[0] = upper;
      pointsLowerLine[0] = lower;
      upper = getCharacteristicPointOfTheUpperLine(symbol, timeframe,offsite,interval);
      lower = getCharacteristicPointOfTheLowerLine(symbol, timeframe,offsite,interval);
      pointsUpperLine[1] = upper;
      pointsLowerLine[1] = lower;
      leastSquaresMethod(mAlower,mBlower,pointsLowerLine);
      leastSquaresMethod(mAupper,mBupper,pointsUpperLine);
      offsite += interval;
      
      while(true){
           upper = getCharacteristicPointOfTheUpperLine(symbol, timeframe,offsite,interval);
           lower = getCharacteristicPointOfTheLowerLine(symbol, timeframe,offsite,interval);
           
           if(upper.y < (mAlower*upper.x + mBlower) || lower.y > (mAupper*lower.x + mBupper)){
               break;
           }
           
           ArrayResize(pointsUpperLine,ArraySize(pointsUpperLine)+1,100);
           ArrayResize(pointsLowerLine,ArraySize(pointsLowerLine)+1,100);
           offsite += interval;
           leastSquaresMethod(mAlower,mBlower,pointsLowerLine);
           leastSquaresMethod(mAupper,mBupper,pointsUpperLine);
      }
   }
   
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
   
   public:
   
   PriceFormationStrategy2(){
      mPi=0.0;
      for(double i=0; i<11; i++) mPi+= 1/MathPow(16,i)*(4/(8*i+1)-2/(8*i+4)-1/(8*i+5)-1/(8*i+6));
   }
   
   
   class Tester{
      public:
      datetime time;
      int length;
      double angle_between, angle1, angle2;
      
      Tester(){
      }
       
      Tester(Tester &t){
         time = t.time;
         length = t.length;
         angle_between = t.angle_between;
         angle1 = t.angle1;
         angle2 = t.angle2;
      }
      
      Tester(datetime _time, int _length, double _angle_between, double _angle1, double _angle2){
         time = _time;
         length = _length;
         angle_between = _angle_between;
         angle1 = _angle1;
         angle2 = _angle2;
      }
      
      Tester operator=(Tester &t){
         time = t.time;
         length = t.length;
         angle_between = t.angle_between;
         angle1 = t.angle1;
         angle2 = t.angle2;
         
         return this;
      }
   };
   
   class TesterContainer{
      Tester lines[];
      double spreads[];
      int number;
      bool used_once;
      
      public:
      
      TesterContainer(){
         ArrayResize(lines,100,1000);
         ArrayResize(spreads,100,1000);
         number =0;
         used_once = false;
      }
      
      void addTest(Tester &test){
         if(ArraySize(lines) - 2 < number){
            ArrayResize(lines,ArraySize(lines)+100);
            ArrayResize(spreads,ArraySize(lines)+100);
         } 
         if(!used_once){
            used_once = true;
            lines[number] = test;
            spreads[number] = Close[0];
            return;
         }
         
         if(lines[number].time - Period()*60*2 <= test.time){ //jezeli dwie minuty to uznajemy ze ta sama lina
            lines[number] = test;
         }else{
            spreads[number]= Close[0] - spreads[number];
            number++;
            lines[number] = test;
            spreads[number]= Close[0];
         }
      }
      
      int getNumberOfLines(){
          return number;
      }
   };
   
   TesterContainer tester;
   /*robi analizê op³acalnoœci w tym momencie od -10* do 10 (- sprzeda¿, + kupno)*/
   int doAnalyze(string pair= NULL){
      
      getLongestCharacteristicPointsOfBothLines(pair,Period(),PERIOD_M5);
      
      if(ArraySize(pointsLowerLine) > 4){
         Tester to_add(TimeCurrent(),getCommonPointOfLines(),calculateAngleBetweenLines(mBlower,mBupper)
            ,calculateAngleBetweenLines(mBlower,mBupper),calculateAngleBetweenLines(mBlower,mBupper));
         tester.addTest(to_add);      
      }
      
      return 0;
   }
   
   
}; 
