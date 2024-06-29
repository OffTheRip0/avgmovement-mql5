//+------------------------------------------------------------------+
//|                                                    AvgMovement.mq5|
//|                                                          Harshal  |
//|                                                                   |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue

double AvgMovementBuffer[];

// Global variables
datetime currentCandleTime;
double totalTimeBullish = 0;
double totalTimeBearish = 0;
long lastTickTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, AvgMovementBuffer);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int start = 0;
   if (prev_calculated > 0) start = prev_calculated - 1;
   
   for (int i = start; i < rates_total - 1; i++)
     {
      // Check if it's a new candle
      if (time[i] != currentCandleTime)
        {
         // Calculate the average movement for the last candle
         double averageMovement = 0.5; // Default neutral value
         double totalTime = totalTimeBullish + totalTimeBearish;
         if (totalTime > 0)
           {
            averageMovement = totalTimeBullish / totalTime;
           }
         
         AvgMovementBuffer[i] = averageMovement;
         
         // Reset for the new candle
         currentCandleTime = time[i];
         totalTimeBullish = 0;
         totalTimeBearish = 0;
        }
     }
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom function to handle tick data                              |
//+------------------------------------------------------------------+
void OnTick()
  {
   MqlTick tick;
   if (SymbolInfoTick(_Symbol, tick))
     {
      // Only process if it's a new tick
      if (tick.time_msc != lastTickTime)
        {
         if (tick.bid > iOpen(_Symbol, PERIOD_M1, 0))
           {
            totalTimeBullish += (double)(tick.time_msc - lastTickTime);
           }
         else if (tick.bid < iOpen(_Symbol, PERIOD_M1, 0))
           {
            totalTimeBearish += (double)(tick.time_msc - lastTickTime);
           }
         
         lastTickTime = tick.time_msc;
        }
     }
  }