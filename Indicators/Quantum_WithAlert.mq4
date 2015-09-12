//+------------------------------------------------------------------+
//|                                                      Quantum.mq4 |
//+------------------------------------------------------------------+
//2012Jan27 mod for mer071898

#property copyright "Copyright © 2010, zznbrm"
                          
//---- indicator settings
#property indicator_chart_window
#property  indicator_buffers 2 
#property  indicator_color1 Blue
#property  indicator_color2 Red
#property  indicator_width1 5
#property  indicator_width2 5
//----added for alerting

//---- input parameters
extern int eintDepth3 = 325;
input bool PopupAlert = true;
input bool NotifyAlert = false;
input bool SoundAlert = true;
input bool BuyAlert = true;
input bool SellAlert = true;
//---- indicator buffers
double gadblUp3[];
double gadblDn3[];
//---- parameters for alerting
int thisBar, alertedBar;

 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   SetIndexBuffer( 0, gadblUp3 );
   SetIndexEmptyValue( 0, 0.0 );
   SetIndexStyle( 0, DRAW_ARROW );
   SetIndexArrow( 0, 250 ); 
   SetIndexLabel( 0, NULL );
   
   SetIndexBuffer( 1, gadblDn3 );
   SetIndexEmptyValue( 1, 0.0 );
   SetIndexStyle( 1, DRAW_ARROW );
   SetIndexArrow( 1, 250 ); 
   SetIndexLabel( 1, NULL ); 
   
   IndicatorDigits( 5 );
 
   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName( "Quantum(" + eintDepth3 + ")" );
   
   return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int intLimit = Bars - counted_bars;
   int intLow3, intHigh3;




   for( int inx = intLimit; inx >= 0; inx-- )
   {          
      gadblUp3[inx] = 0.0;
      gadblDn3[inx] = 0.0;
      
      intLow3 = iLowest( Symbol(), Period(), MODE_LOW, eintDepth3, inx );
      
      if ( intLow3 == inx )
      {
         gadblUp3[inx] = Low[inx];
         thisBar = Bars;

      }

      intHigh3 = iHighest( Symbol(), Period(), MODE_HIGH, eintDepth3, inx );
      
      if ( intHigh3 == inx )
      {
         gadblDn3[inx] = High[inx];
         thisBar = Bars;

      }
   }
   
   if (alertedBar != thisBar) {
      if (PopupAlert && BuyAlert) {
         Alert(Symbol() + " " + TFToStr(Period()) + ": New Blue Box appears - Buy Signal"); 
      }
      if (NotifyAlert && BuyAlert) {
         SendNotification(Symbol() + " " + TFToStr(Period()) + ": New Blue Box appears - Buy Signal"); 
      }
      if (SoundAlert && BuyAlert) {
         PlaySound("alert2.wav"); 
      }
      alertedBar = thisBar;
   }
   if (alertedBar != thisBar) {
      if (PopupAlert && SellAlert) {
         Alert(Symbol() + " " + TFToStr(Period()) + ": New Red Box appears - Sell Signal"); 
      }
      if (NotifyAlert && SellAlert) {
         SendNotification(Symbol() + " " + TFToStr(Period()) + ": New Red Box appears - Sell Signal"); 
      }
      if (SoundAlert && SellAlert) {
         PlaySound("alert2.wav"); 
      }
      alertedBar = thisBar;
   }
   
   return( 0 );
}

//+------------------------------------------------------------------+                                                                          //
string TFToStr(int tf)   {                                                                                                                      //
//+------------------------------------------------------------------+                                                                          //
  if (tf == 0)        tf = Period();                                                                                                            //
  if (tf >= 43200)    return("MN");                                                                                                             //
  if (tf >= 10080)    return("W1");                                                                                                             //
  if (tf >=  1440)    return("D1");                                                                                                             //
  if (tf >=   240)    return("H4");                                                                                                             //
  if (tf >=    60)    return("H1");                                                                                                             //
  if (tf >=    30)    return("M30");                                                                                                            //
  if (tf >=    15)    return("M15");                                                                                                            //
  if (tf >=     5)    return("M5");                                                                                                             //
  if (tf >=     1)    return("M1");                                                                                                             //
  return("");                                                                                                                                   //
}                                                                                                                                               //
// ===========================================================================================