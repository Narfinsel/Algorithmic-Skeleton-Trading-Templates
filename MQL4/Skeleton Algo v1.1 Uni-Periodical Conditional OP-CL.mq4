//+------------------------------------------------------------------+
//|                    Skeleton1 UniPeriodBar TF-Indicator OP-CL.mq4 |
//|                                               Svetozar Pasulschi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "SimonG"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <UtilitaryTradingFunctions.mqh>
#include <TradeRectVisualizer.mqh>

extern int stopLossPips = 25;                            // Stop-Loss in Pips
extern bool doWaitXnumCandlesAfterLoss = true;           // Should wait X bars after lost trade
extern int waitXnumCandlesAfterLoss = 10;                // How many X bars to wait
extern bool doRemoveEAwhenMinBalanceReached = true;      // Should remove EA after High Capital Loss
extern double minimumBalancePercentage = 80.0;           // Drawdown Capital Loss, when EA removed
extern bool is5DigitBroker = true;                       // Is a 5-Digit Broker
extern bool doGraphTradesArrRect = true;                 // Should outline Trade Position with Rectangles
extern double percentageRisk = 1.0;                      // Percentage Risk


static double calcStopLossLevelInPoints;
static double startingAccountBalance;
static bool isThereAnOpenTrade = false;
static int currentOrderTicket = -1;
static int magicNumber;
bool doDrawOnOpen = true;
TradeRectVisualizer * rectVisualizer;


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   update_On_New_Bar();
}

static datetime lastTime = 0;
void update_On_New_Bar(){
   // METHOD - Returns true if a new bar has appeared for a symbol/period pair  |
   //--- memorize the time of opening of the last bar in the static variable
   datetime lastBarTime = (datetime) SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);  //--- current time
   if(lastTime == 0){               //--- if it is the first call of the function
      lastTime = lastBarTime;       //--- set the time and exit
      // --------------- INITIATE INDICATOR -----------------------------------------------
      algorithm_UniBar_Fixed_TakeProfit();
      alertBLANKlineForNewBarOrTick();
   }
   if(lastTime != lastBarTime){     //--- if the time differs
      lastTime = lastBarTime;       //--- memorize the time and return true
      // --------------- REFRESH INDICATOR ------------------------------------------------
      algorithm_UniBar_Fixed_TakeProfit();
      alertBLANKlineForNewBarOrTick();
   }
}

static bool openLongConditions, openShortConditions;
static bool closeLongConditions, closeShortConditions;

// ----------------------- LONG -----------------------
bool accept_Open_LONG(){
   return true;
}
bool confirm_Close_Long(){
   return true;
}

// ----------------------- SHORT -----------------------
bool accept_Open_SHORT(){
   return true;
}
bool confirm_Close_Short(){
   return true;
}

void algorithm_UniBar_Fixed_TakeProfit(){
   // Check if there is an open trade, or if it was closed as a result of hitting Stop Loss
   static bool hasDrawnArrRect = false;
   if(OrderSelect(currentOrderTicket, SELECT_BY_TICKET) == true)
      if(OrderCloseTime() > 0){
         isThereAnOpenTrade = false;
         if(doGraphTradesArrRect == true && hasDrawnArrRect == false){
            rectVisualizer.vizualizeHalfHollowTradeRect (magicNumber, currentOrderTicket);
            hasDrawnArrRect = true;
         }
      }
      else isThereAnOpenTrade = true;
   
   if(isThereAnOpenTrade == false){
      
      bool disableTradingExceedingLoses = disableTrading_AccountBalance_TooSmall(startingAccountBalance, minimumBalancePercentage, doRemoveEAwhenMinBalanceReached);
      if(disableTradingExceedingLoses == false){
      
         bool areWaitCandlesCondtionsSatisfied;
         if( doWaitXnumCandlesAfterLoss == true && OrdersHistoryTotal() >=1 ){
            if( checkIfLastOrderClosedWithLoss(currentOrderTicket) == true){
               if( didWaitForXbars( Period(), OrderCloseTime(), waitXnumCandlesAfterLoss) == true){
                  areWaitCandlesCondtionsSatisfied = true;
               }
               else areWaitCandlesCondtionsSatisfied = false;
            }
            else areWaitCandlesCondtionsSatisfied = true;
         }
         else areWaitCandlesCondtionsSatisfied = true;
         
         if(areWaitCandlesCondtionsSatisfied == true){
            openLongConditions  = accept_Open_LONG();
            openShortConditions = accept_Open_SHORT();
         } else {
            openLongConditions  = false;
            openShortConditions = false;
         }
         
         // OPEN BUY
         if( openLongConditions == true   &&   areWaitCandlesCondtionsSatisfied == true){
            double volume = computeTradeVolume(percentageRisk, stopLossPips);
            double orderStopLoss   = Ask - calcStopLossLevelInPoints;
            currentOrderTicket = OrderSend(Symbol(), OP_BUY, volume, Bid, 10, orderStopLoss, 0.0, "by UniBar", magicNumber, clrTurquoise);
            if(OrderSelect(currentOrderTicket, SELECT_BY_TICKET) == true){
               isThereAnOpenTrade = true;
               hasDrawnArrRect = false;
               if(doDrawOnOpen)
                  draw3ForTime(TimeCurrent(), clrSeaGreen, 1);
            }
         }
         // OPEN SELL
         else if( openShortConditions == true   &&   areWaitCandlesCondtionsSatisfied == true){
            double volume = computeTradeVolume(percentageRisk, stopLossPips);
            double orderStopLoss   = Bid + calcStopLossLevelInPoints;
            currentOrderTicket = OrderSend(Symbol(), OP_SELL, volume, Bid, 10, orderStopLoss, 0.0, "by UniBar", magicNumber, clrCrimson);
            if(OrderSelect(currentOrderTicket, SELECT_BY_TICKET) == true){
               isThereAnOpenTrade = true;
               hasDrawnArrRect = false;
               if(doDrawOnOpen)
                  draw3ForTime(TimeCurrent(), clrOrangeRed, 1);
            }
         }
      }
   }
   else if(isThereAnOpenTrade == true){
      bool didFindCurrentOrder = OrderSelect(currentOrderTicket, SELECT_BY_TICKET);
      bool wasOrderClosed;
      
      // Close BUY order
      if(OrderType() == OP_BUY){
         closeLongConditions = confirm_Close_Long();
         if(closeLongConditions == true){
            wasOrderClosed = OrderClose(currentOrderTicket, OrderLots(), Bid, 10, clrTurquoise);
            if(wasOrderClosed == true){
               isThereAnOpenTrade = false;
               //draw3(TimeCurrent(), clrGreen);
            }
         }
      }
      // Close SELL order
      else if(OrderType() == OP_SELL){
         closeShortConditions = confirm_Close_Short();
         if(closeShortConditions == true){
            wasOrderClosed = OrderClose(currentOrderTicket, OrderLots(), Bid, 10, clrCrimson);
            if(wasOrderClosed == true){
               isThereAnOpenTrade = false;
               //draw3(TimeCurrent(), clrFireBrick);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization & deinitialization function                |
//+------------------------------------------------------------------+
int OnInit(){
   magicNumber = magicNumberGenerator ();
   calcStopLossLevelInPoints = convertIntLevelToPricePoints( stopLossPips, true);
   startingAccountBalance = AccountBalance();
   
   rectVisualizer = new TradeRectVisualizer();
   rectVisualizer.setWhatToDraw (true, true);
   rectVisualizer.setTradeArrowProperties (clrRed, clrRoyalBlue, 3);
   rectVisualizer.setTradeRectProperties (clrTomato, clrDeepSkyBlue, true, true, 2);
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){}