//+------------------------------------------------------------------+
//|                                                  Shaolin Quantum |
//|                                      Copyright 2015, Alex Lewis  |
//+------------------------------------------------------------------+ 
#property strict
input int magic_num=2015; //Magic Number
input string time_open_str="07:00"; // Trading Window Start Time (GMT)
input string time_close_str="13:00"; // Trading Window End Time (GMT)
input int max_trades=0;//Max Trades per Trading Slot (0 unlimited)
input int max_cycles=0;//Max Cycles per Trading Slot (0 unlimited)
input int qde=325;//Quantum eintDepth3 for Entry
input int qdc=325;//Quantum eintDepth3 for Close
input int slip=50;//Order Slippage
input double lots1=0.01; //Lots Trades 1-12
input double lots2=0.02; //Lots Trades 13-21
input double lots3=0.05; //Lots Trades 22-29
input double lots4=0.13; //Lots Trades 30-36
input double lots5=0.34; //Lots Trades 37-39
input double lots6=0.89; //Lots Trade 40 & >
input double sl_pct=0;//% Equity Stop Loss (positive number Eg 2.5)
input double tp_pct=0;//% Equity Take Profit (positive number Eg 2.5)
input double sl_dollar=0;//$ Equity Stop Loss (positive number Eg 100.00)
input double tp_dollar=0;//$ Equity Take Profit (positive number Eg 100.00)

int cycles = 0;
int trades = 0;
int trade_side = -1;
datetime day_curr;
datetime day_prev; 
int bars = Bars;

int init()
{
   return 0;
}

int deinit()
{
   return 0;
}

int start()
{
   datetime currTime = TimeGMT();
   datetime time_open = StrToTime(time_open_str);
   datetime time_close = StrToTime(time_close_str);
   bool barNext = false;
   
   day_curr=iTime(Symbol(),PERIOD_D1,0);

   if(day_curr > day_prev)
   {
      cycles=0;
      day_prev=iTime(Symbol(),PERIOD_D1,0);
   }

   checkCloseTrades();
   
   if (Bars > bars) {
      bars = Bars;
      barNext = true;
   }

   if ((cycles < max_cycles || max_cycles == 0) && (trades < max_trades || max_trades == 0) && currTime >= time_open && currTime < time_close && barNext)
   {
      int nextTicket = -1;
      bool trade = false;
      double price = 0;
      //buy
      if (iCustom(Symbol(),0,"Quantum",qde,0,1) > 0 && (trade_side == -1 || trade_side == OP_BUY)) 
      {
         trade_side = OP_BUY;
         trade = true;
         price = Ask;
      }
      else
      //sell
      if (iCustom(Symbol(),0,"Quantum",qde,1,1) > 0 && (trade_side == -1 || trade_side == OP_SELL)) 
      {
         trade_side = OP_SELL;
         trade = true;
         price = Bid;
      }
      //trade
      if (trade) 
      {
         nextTicket = OrderSend(Symbol(), trade_side, getLots(), price, slip, 0, 0, "SHAOLIN", magic_num, 0, 0);
         
         if(nextTicket <= -1) 
         {
            Print("OrderSend Error: ",GetLastError());
         } 
         else 
         {
            trades++;
         }
      }
   }
   
   return 0;
}

double getLots()
{
   double retlots = 0.01;

   if(trades>=0 && trades<12)
      retlots=lots1;
   if(trades>=12 && trades<21)
      retlots=lots2;
   if(trades>=21 && trades<29)
      retlots=lots3;
   if(trades>=29 && trades<36)
      retlots=lots4;
   if(trades>=36 && trades<39)
      retlots=lots5;
   if(trades>=39)
      retlots=lots6;

   return retlots;
}

void checkCloseTrades()
{
   bool close = false;

   if (trades > 0)
   {
      if((sl_pct > 0 && AccountEquity() <= (AccountBalance() - (AccountBalance() * (sl_pct/100)))) ||
         (sl_dollar > 0 && AccountEquity() <= (AccountBalance() - sl_dollar)))
      {
         close = true;
         Print("Stoploss Triggered");
      }
      else if((tp_pct > 0 && AccountEquity() >= (AccountBalance() + (AccountBalance() * (tp_pct/100)))) ||
         (tp_dollar > 0 && AccountEquity() >= (AccountBalance() + tp_dollar)))
      {
         close = true;
         Print("Take Profit Triggered");
      }
      else
      {
         close = (iCustom(Symbol(),0,"Quantum",qdc,1,1) > 0 && trade_side == OP_BUY) || (iCustom(Symbol(),0,"Quantum",qdc,0,1) > 0 && trade_side == OP_SELL); 
      }
      
      if (close)
      {
         while (trades > 0)
         {          
            int tradeList[][2];  
            int size = 0;
            
            for(int h = OrdersTotal()-1; h >= 0; h--)
            {
               if(!OrderSelect(h,SELECT_BY_POS,MODE_TRADES))
                  continue;
               if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic_num)
               {
                  size++;
                  ArrayResize(tradeList, size);
                  tradeList[size-1][0]=OrderOpenTime();
                  tradeList[size-1][1]=OrderTicket();
               }
            }
            
            if (size > 0)
            {
               ArraySort(tradeList);
               
               for(int i=0; i < size; i++)
               {
                  if (!OrderSelect(tradeList[i][1],SELECT_BY_TICKET))
                     continue;
                  if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,0))
                  {
                     trades--;
                  }
                  else
                  {
                     Print("OrderClose Error: ",GetLastError());
                  }
               }
            }
            else
            {
               trades = 0;
            }
         }
         cycles++;
         trade_side = -1;
      }
   }
}