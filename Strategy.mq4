//+------------------------------------------------------------------+
//|                                                     Strategy.mq4 |
//|                                                    Adrian Ziemek |
//|                                                         BlaBlBla |
//+------------------------------------------------------------------+
#property library
#property copyright "Adrian Ziemek"
#property link      "BlaBlBla"
#property version   "1.00"
#property strict

//Klasa do przetrzymywania zleceñ - otwartych i tych zamknietych
class Order{
   public:
   int ORDER_TICKET;
   string PAIR;
   double LOT;
   double INCOME;
   datetime OPEN_DATE;
   datetime CLOSE_DATE; 
};

class Strategy{

private:
   Order mOpenedOrder;
   Order lClosedOrders [];
   int mNumberOfClosedOrders;
   int mNumberOfWins;
   double mOverallProfit;
   
protected:
   string mNameOfStrategy;
    
public:
   Strategy(): mNumberOfWins(0), mNumberOfClosedOrders(0), mOverallProfit(0){
      ArrayResize(lClosedOrders,5);
      mOpenedOrder.ORDER_TICKET = -1;
   }
   
   //zwraca zero jezeli nie ma bledu
   int closeActiveOrder(){
      bool result;
      if(mOpenedOrder.ORDER_TICKET == -1){
         return -1;
      }
      if(!OrderSelect(mOpenedOrder.ORDER_TICKET, SELECT_BY_TICKET)){
         Alert("Error during order closing, error code : " + IntegerToString(GetLastError()));
         return -3;
      }
      if(ArrayRange(lClosedOrders,0) <= mNumberOfClosedOrders + 1){
         if(ArrayResize(lClosedOrders, mNumberOfClosedOrders + 10) == -1){
            Alert("Error during order closing, no sufficient amount of memory for closed orders");
            return -2;
         }
      }
      
      lClosedOrders[mNumberOfClosedOrders-1].CLOSE_DATE = TimeCurrent();
      lClosedOrders[mNumberOfClosedOrders-1].INCOME = OrderProfit()-OrderSwap();
      lClosedOrders[mNumberOfClosedOrders-1].OPEN_DATE = mOpenedOrder.OPEN_DATE;
      lClosedOrders[mNumberOfClosedOrders-1].LOT = mOpenedOrder.LOT;
      lClosedOrders[mNumberOfClosedOrders-1].ORDER_TICKET = 1;
      lClosedOrders[mNumberOfClosedOrders-1].PAIR = mOpenedOrder.PAIR;
      
      if(OrderType() == OP_BUY){
         result = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
         if(!result){
            Alert("Error during order closing, error code : " + IntegerToString(GetLastError()));
            return result;
         }
      }
      if(OrderType() == OP_SELL){
         result = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
         if(!result){
            Alert("Error during order closing, error code : " + IntegerToString(GetLastError()));
            return result;
         }
      }
      if(OrderType()== OP_BUYSTOP){
         result = OrderDelete(OrderTicket());
         if(!result){
            Alert("Error during order closing, error code : " + IntegerToString(GetLastError()));
            return result;
         }
      }
      if(OrderType()== OP_SELLSTOP){
         result = OrderDelete(OrderTicket());
         if(!result){
            Alert("Error during order closing, error code : " + IntegerToString(GetLastError()));
            return result;
         }
      }
      
      mOverallProfit += lClosedOrders[mNumberOfClosedOrders-1].INCOME;
      if(lClosedOrders[mNumberOfClosedOrders-1].INCOME > 0){
         mNumberOfWins++;
      }
      mNumberOfClosedOrders++;
      return 0;
   }
   
   //Pobiera zarobek (stratê) aktualnego zlecenia
   //Zwraca -1 je¿eli jest problem z pobraniem informacji
   double getActualOrderProfit(){
      if(mOpenedOrder.ORDER_TICKET == -1){
         return -1;
      }
      
      if(!OrderSelect(mOpenedOrder.ORDER_TICKET, SELECT_BY_TICKET)){
         Alert("Error during order closing, error code : " + IntegerToString(GetLastError()));
         return -1;
      }
      
      return OrderProfit()-OrderSwap();
   }
   
   //procentowe ratio wygranych
   double getRatioOfWins(){
      return (double)mNumberOfWins/(double)mNumberOfClosedOrders*100.0;
   }
   
   double getOverallProfit(){
      return mOverallProfit;
   }
   
   /*kolejny krok algorytmu*/
   virtual void step(){
   
   }
   /*robi analizê op³acalnoœci w tym momencie od -10* do 10 (- sprzeda¿, + kupno)*/
   virtual int doAnalyze(string ){
      return 0;
   }
};
