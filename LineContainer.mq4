//+------------------------------------------------------------------+
//|                                                LineContainer.mq4 |
//|                                                    Adrian Ziemek |
//|                                                         BlaBlBla |
//+------------------------------------------------------------------+
#property library
#property copyright "Adrian Ziemek"
#property link      "BlaBlBla"
#property version   "1.00"
#property strict

class Line{
   public:
   int length; //w d³ugoœci linii wzgledem x
   double a,b;
      
   Line(){
   }
    
   Line(Line &t){
      length = t.length;
      a = t.a;
      b = t.b;
   }
   
   Line(int _a, double _b, double _length){
      length = _length;
      a = _a;
      b = _b;
   }
   
   Line operator=(Line &t){
      length = t.length;
      a = t.a;
      b = t.b;
    
      return this;
   }
};
   
/*Klasa bêd¹ca kontenerem dla linii*/
class LineContainer{
   Line lines[];
   double spreads[];
   int number;
   
   public:
      
   LineContainer(){
      ArrayResize(lines,100,1000);
      number =0;
   }
     
   void addLine(Line &line){
      if(ArraySize(lines) - 2 < number){
          ArrayResize(lines,ArraySize(lines)+100);
      } 
      lines[number++] =line;
   }
      
   int getNumberOfLines(){
       return number;
   }
};