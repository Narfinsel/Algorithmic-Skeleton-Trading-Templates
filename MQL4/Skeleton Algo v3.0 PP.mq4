//+------------------------------------------------------------------+
//|                                          Skeleton3 onTick-PP.mq4 |
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
bool doDrawVertOnOpen = true;
TradeRectVisualizer * rectVisualizer;

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   update_On_New_Bar();
   algorithm_Advance_onTick();
}

static datetime lastTime = 0;
void update_On_New_Bar(){
   // METHOD - Returns true if a new bar has appeared for a symbol/period pair  |
   //--- memorize the time of opening of the last bar in the static variable
   datetime lastBarTime = (datetime) SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);  //--- current time
   if(lastTime == 0){               //--- if it is the first call of the function
      lastTime = lastBarTime;       //--- set the time and exit
      // INITIATE INDICATOR -----------------------------------------------
      algorithm_Open_onNewBar();
      alertBLANKlineForNewBarOrTick();
   }
   if(lastTime != lastBarTime){     //--- if the time differs
      lastTime = lastBarTime;       //--- memorize the time and return true
      // REFRESH INDICATOR ------------------------------------------------
      algorithm_Open_onNewBar();
      alertBLANKlineForNewBarOrTick();
   }
}


// ---------------------------------------------------------------------------------
// -------------------------- MODIFY JUST THESE FUNCITONS --------------------------
static bool conditionsBUY, conditionsSELL;
bool validateBuyOpen(){
   return true;
}
bool validateSellOpen(){
   return true;
}
// ---------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------

static double orderNewVirtualTP = 0.0;
void algorithm_Open_onNewBar(){
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
            conditionsBUY  = validateBuyOpen();
            conditionsSELL = validateSellOpen();
           } else {
            conditionsBUY  = false;
            conditionsSELL = false;
         }
         
         // OPEN BUY
         if( conditionsBUY == true   &&   areWaitCandlesCondtionsSatisfied == true){
            double volume = computeTradeVolume(percentageRisk, stopLossPips);
            currentOrderTicket = OrderSend(Symbol(), OP_BUY, volume, Bid, 10*10, Ask -calcStopLossLevelInPoints, 0.0, "by Covidma", magicNumber, clrTurquoise);
            if(OrderSelect(currentOrderTicket, SELECT_BY_TICKET) == true){
               orderNewVirtualTP = OrderOpenPrice() + calcStopLossLevelInPoints;
               hasDrawnArrRect = false;
               if(doDrawVertOnOpen)
                  draw3ForTime(TimeCurrent(), clrLightSkyBlue, 1);
            }
         }
         // OPEN SELL
         if( conditionsSELL == true   &&   areWaitCandlesCondtionsSatisfied == true){
            double volume = computeTradeVolume(percentageRisk, stopLossPips);
            currentOrderTicket = OrderSend(Symbol(), OP_SELL, volume, Bid, 10*10, Bid +calcStopLossLevelInPoints, 0.0, "by Covidma", magicNumber, clrCrimson);
            if(OrderSelect(currentOrderTicket, SELECT_BY_TICKET) == true){
               orderNewVirtualTP = OrderOpenPrice() - calcStopLossLevelInPoints;
               hasDrawnArrRect = false;
               if(doDrawVertOnOpen)
                  draw3ForTime(TimeCurrent(), clrLightCoral, 1);
            }
         }
      }
   }
}


void algorithm_Advance_onTick(){
   double orderNewSL;
  
   // Check if there is an open trade, or if it was closed as a result of hitting Stop Loss
   if(OrderSelect(currentOrderTicket, SELECT_BY_TICKET) == true)
      if(OrderCloseTime() > 0)   isThereAnOpenTrade = false;
      else                       isThereAnOpenTrade = true;
      
   if(isThereAnOpenTrade == true){
      bool wasCurrentSelected, wasCurrentModified;
      
      if(OrderType() == OP_BUY){
         if(Bid >= orderNewVirtualTP){
            wasCurrentSelected = OrderSelect(currentOrderTicket, SELECT_BY_TICKET);
            
            if(wasCurrentSelected){
               orderNewSL         = OrderStopLoss() + calcStopLossLevelInPoints;
               orderNewVirtualTP  = OrderStopLoss() + (3* calcStopLossLevelInPoints);
               wasCurrentModified = OrderModify(currentOrderTicket, 0, orderNewSL, 0, 0);
            }
         }
      }
      else if(OrderType() == OP_SELL){
         if(Ask <= orderNewVirtualTP){
            wasCurrentSelected = OrderSelect(currentOrderTicket, SELECT_BY_TICKET);
            
            if(wasCurrentSelected){
               orderNewSL         = OrderStopLoss() - calcStopLossLevelInPoints;
               orderNewVirtualTP  = OrderStopLoss() - (3* calcStopLossLevelInPoints);
               wasCurrentModified = OrderModify(currentOrderTicket, 0, orderNewSL, 0, 0);
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
   calcStopLossLevelInPoints = convertIntLevelToPricePoints( stopLossPips, is5DigitBroker);
   startingAccountBalance = AccountBalance();

   rectVisualizer = new TradeRectVisualizer();
   rectVisualizer.setWhatToDraw (true, true);
   rectVisualizer.setTradeArrowProperties (clrRed, clrRoyalBlue, 3);
   rectVisualizer.setTradeRectProperties (clrTomato, clrDeepSkyBlue, true, true, 2);
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){}