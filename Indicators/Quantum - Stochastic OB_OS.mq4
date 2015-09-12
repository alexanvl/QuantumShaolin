//+------------------------------------------------------------------+
//|                                                      Quantum.mq4 |
//+------------------------------------------------------------------+
//2012Jan27 mod for mer071898

#property copyright "Copyright © 2010, zznbrm"
                          
//---- indicator settings
#property indicator_separate_window
#property  indicator_buffers 3 
#property  indicator_color1 Blue
#property  indicator_color2 Red
#property  indicator_color3 Gray
#property  indicator_width1 5
#property  indicator_width2 5
#property  indicator_width3 2

#property  indicator_maximum 100
#property  indicator_minimum 0

//---- input parameters
extern int eintDepth3 = 300;
extern int K = 5;
extern int D = 3;
extern int S = 3; 
extern int OS = 20;
extern int OB = 80;

//---- indicator buffers
double gadblUp3[];
double gadblDn3[];
double sto[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   SetIndexBuffer( 0, gadblUp3 );
   SetIndexEmptyValue( 0, 0.0 );
   SetIndexStyle( 0, DRAW_ARROW );
   SetIndexArrow( 0, 250 ); 
   SetIndexLabel( 0, "High" );
   
   SetIndexBuffer( 1, gadblDn3 );
   SetIndexEmptyValue( 1, 0.0 );
   SetIndexStyle( 1, DRAW_ARROW );
   SetIndexArrow( 1, 250 ); 
   SetIndexLabel( 1, "Low" ); 
   
   SetIndexBuffer( 2, sto );
   SetIndexStyle( 2, DRAW_LINE );
    
   IndicatorDigits( 5 );
     
   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName( "Quantum Stoch (" + eintDepth3+"," + K+"," + D+"," + S +")" );
   
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
      
      sto[inx]=iStochastic(NULL,0,K,D,S,MODE_SMA,0,MODE_MAIN,inx);
      
      intLow3 = iLowest( Symbol(), Period(), MODE_LOW, eintDepth3, inx );
      
      if ( intLow3 == inx && sto [inx] <= OS )
      {
         gadblUp3[inx] = sto[inx];
      }

      intHigh3 = iHighest( Symbol(), Period(), MODE_HIGH, eintDepth3, inx );
      
      if ( intHigh3 == inx && sto[inx] >= OB)
      {
         gadblDn3[inx] = sto[inx];
      }
   }
   
   return( 0 );
}

