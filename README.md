# Algorithmic-Skeleton-Trading-Templates
Template programming pattern (Skeleton) to be used to build fully customizable trading strategies with configurable open-close trade conditions.

These are fully functional, complete Expert Advisors. You just need to modify/enlarge a few functions - those that specify under which conditions should the buy/sell positions be opened. Here you can add your own trading logic, indicators, position-open strategies.

## 1. Introduction
<strong>Motivation. </strong> <p>I have a new trading strategy idea every day, and I want to implement on the fly as soon as possible. This is why I created these <em>"skeleton" trading bots</em>. These templates just require you to fill in the position-open functions with your own personal strategies. </p>


## 2. Table of Contents
1. [Introduction](#1-introduction)
2. [Table of Contents](#2-table-of-contents)
3. [Project Description](#3-project-description)
4. [Code Specs](#4-code-specs)
5. [How to Tweak and Configure the Scanner Script Functionality](#5-how-to-tweak-and-configure-the-scanner-script-functionality)
6. [How to Use the Project](#6-how-to-use-the-project)
7. [Credits](#7-credits)
8. [License](#8-license)


## 3. Project Description
<p>Let's see what are these skeleton trading bots capable of? Here is a short list of steps, capabilities and "hard-coded" actions that the bots can undertake: </p>
<ul>
   <li>Peridically activated function <em>void update_On_New_Bar()</em> - which runs everytime a new candle/bar is created, based on chart timeframe. </li>
   <li>Periodical function is usefull for lagging indicators (Moving Average, EMA, MACD, Ichimoku Cloud, RSI). As you know these indicator are updated based on chart timeframe.</li>
   <li>Use this function to update your indicators, sample new values, use last closed-bar to register new values.</li>
   <li>The only functions you need to worry about are: <strong><em>validateOpenBuy(), validateOpenSell()</em></strong>. This is where you insert and fill in your trading strategy.</li>
   <li>These functions are used inside the main trading function: <strong><em>void algorithm_UniBar_Fixed_TakeProfit()</em></strong>. So you should not modify this trading main-algo method.</li>
   <li>Actions performed by the main trading algorithm <strong><em>void algorithm_UniBar_Fixed_TakeProfit()</em></strong>:
      <ul>
         <li>Optionally (based on input parameters), the trading strategy allows you to configure your bot to wait a certain number of candles after a losing trade.</li>
         <li>Compute stop-loss and take-proffit, based on input stop-loss pips and take-proffit multiplier. </li>
         <li>Automatically deduce volume for each trade, based on stop-loss and input risk - to accomodate desired risk percentage for each position. </li>
         <li>Upon closing a position, either in loss or profit - there is an option to draw colored rectangles on the chart, to highlight those trade stop-loss and take-profit levels. And get a clearer picture about how well your bot is performing.</li>
      </ul>
   </li>
   <li>There are five skeleton-algorithmic bots, which have different ways of opening / advancing / closing trades. To note, opening trades always requires you to input custom conditional code which resolves to true/false. This is where you can use custom indicators and your own strategy.</li>
      <ul>
         <li><em>Skeleton Algo v1.0 Uni-Periodical Conditional OP </em></li>
         <li><em>Skeleton Algo v1.1 Uni-Periodical Conditional OP-CL </em></li>         
         <li><em>Skeleton Algo v2.0 Dual-Periodical Conditional OP </em></li>
         <li><em>Skeleton Algo v2.0 Dual-Periodical Conditional OP-CL </em></li>
         <li><em>Skeleton Algo v3.0 PP </em></li>
         <li><em>TradeRectVisualizer.mqh</em> and <em>UtilitaryTradingFunctions.mqh</em> (simple utilitay classes, aiding my trading bots.</li>
      </ul>
</ul>



## 4. Code Specs
Following explanation is targeted to <em>Skeleton Algo v1.0 Uni-Periodical Conditional OP</em>.

Entry-method. On every tick, <strong><em>void update_On_New_Bar()</em></strong> is called. 

This function runs time/periodicity checks to ensure that its contents are executed once in M15, H1, D1 (etc) (based on chart).

Main-algo executes peridocally (based on chart timeframe): <em> algorithm_UniBar_Fixed_TakeProfit()</em>

For debugging purposes, we print a new blanked line (as delimiter) on every frech candle/period: <em>alertBLANKlineForNewBarOrTick()</em>
```MQL5
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
```

Custom-functions. These are the functions that you need to modify by insert your own custom logic / trading strategy code. There are even global, static variables that hold the output for these functions, which are later deployd in the main algo:
```MQL5
static bool conditionForBuying, conditionForSelling;
bool validateOpenBuy(){
   // custom logic
   return true;
}
bool validateOpenSell(){
   // custom logic
   return true;
}
```

Main trading algorithm. There are a lot of actions performed by this function, into which I will delve further.
```MQL5
void algorithm_UniBar_Fixed_TakeProfit(){
   // ....
}
```

Part of main-algo. Checking if the most recent trade has been closed (wheter in profit or loss). In this case, we could draw rectangles to outline the trade levels
```MQL5
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
```

Part of main-algo. Checking if enough candles/bars have passed since the last losing trade has closed, with an unfortunate outcome for our portofolio:
```MQL5
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
```

Part of main-algo. Customizable functions are finally used inside the main-algo. You don't need to change the following lines, where these functions are used. But you do need to fill in these functions where they are defined (see above).
```MQL5
if(areWaitCandlesCondtionsSatisfied == true){
   conditionForBuying  = validateOpenBuy();
   conditionForSelling = validateOpenSell();
} else {
   conditionForBuying  = false;
   conditionForSelling = false;
}
```


Part of main-algo. Only open long/short positions if the custom functions previously returned true. And if enough candles have passed since the last losing trade (in case you enabled you this behaviour).

Here, we also compute volume (based on % risk), stop-loss and take-proffit levels. Example: <em>Inputing a 2% risk will result in calculating a trading volume, so that taking stop-loss into consideration as potentional loss - you won't risk losing more than 2% of your account balance.</em>

Optinally, for debugging purposes, you can enable the main-algo to draw vertical lines to easily visualize when the custom functions return true, and a new position is opened.
```MQL5
// OPEN BUY
if( conditionForBuying == true   &&   areWaitCandlesCondtionsSatisfied == true){
   double volume = computeTradeVolume(percentageRisk, stopLossPips);
   double orderStopLoss   = Ask - calcStopLossLevelInPoints;
   double orderTakeProfit = Ask + (calcStopLossLevelInPoints * takeProffitMultiplier);
   currentOrderTicket = OrderSend(Symbol(), OP_BUY, volume, Bid, 10, orderStopLoss, orderTakeProfit, "by UniBar", magicNumber, clrTurquoise);
   if(OrderSelect(currentOrderTicket, SELECT_BY_TICKET) == true){
      isThereAnOpenTrade = true;
         hasDrawnArrRect = false;
            if(doDrawOnOpen)
               draw3ForTime(TimeCurrent(), clrSeaGreen, 1);
   }
}
// OPEN SELL
else if( conditionForSelling == true   &&   areWaitCandlesCondtionsSatisfied == true){
   double volume = computeTradeVolume(percentageRisk, stopLossPips);
   double orderStopLoss   = Bid + calcStopLossLevelInPoints;
   double orderTakeProfit = Bid - (calcStopLossLevelInPoints * takeProffitMultiplier);
   currentOrderTicket = OrderSend(Symbol(), OP_SELL, volume, Bid, 10, orderStopLoss, orderTakeProfit, "by UniBar", magicNumber, clrCrimson);
   if(OrderSelect(currentOrderTicket, SELECT_BY_TICKET) == true){
      isThereAnOpenTrade = true;
         hasDrawnArrRect = false;
            if(doDrawOnOpen)
               draw3ForTime(TimeCurrent(), clrOrangeRed, 1);
   }
}
```

Part of main-algo. Compute a randomly generated magic number for this EA to use.
Get account balance to use for initial draw-down calculations.
Initialize the class/object which will outline and draw custom rectangles, highlightinh your trade on the chart.
```MQL5
int OnInit(){
   magicNumber = magicNumberGenerator();
   calcStopLossLevelInPoints = convertIntLevelToPricePoints( stopLossPips, true);
   startingAccountBalance = AccountBalance();
   
   rectVisualizer = new TradeRectVisualizer();
   rectVisualizer.setWhatToDraw (true, true);
   rectVisualizer.setTradeArrowProperties (clrRed, clrRoyalBlue, 3);
   rectVisualizer.setTradeRectProperties (clrTomato, clrDeepSkyBlue, true, true, 2);
   return(INIT_SUCCEEDED);
}
```






