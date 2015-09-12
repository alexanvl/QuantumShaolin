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

//---- input parameters
extern int eintDepth3 = 300;

//---- indicator buffers
double gadblUp3[];
double gadblDn3[];

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
      }

      intHigh3 = iHighest( Symbol(), Period(), MODE_HIGH, eintDepth3, inx );
      
      if ( intHigh3 == inx )
      {
         gadblDn3[inx] = High[inx];
      }
   }
   
   return( 0 );
}

