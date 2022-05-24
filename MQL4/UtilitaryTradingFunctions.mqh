//+------------------------------------------------------------------+
//|                                    UtilitaryTradingFunctions.mqh |
//|                                               Svetozar Pasulschi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Svetozar Pasulschi"
#property link      "https://www.mql5.com"
#property strict


// --------------------------------------------------------- MAGIC NUMBER / RANDOM GENERATION  -------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------------
// @TESTED OK
/* Return a randomly generated, unique MAGIC NUMBER for your EA - 8 digits.*/
int magicNumberGenerator(){
   return (int) generateUniqueLongIntOfSize(8);
}

/* @TESTED
Generates a random long number of a given length:
int numDigits=3   will generate  152
int numDigits=9   will generate  934576309
*/
long generateUniqueLongIntOfSize (int numDigitsForInt){
   long digit=0, random;
   for(int i=0; i < numDigitsForInt; i++){
      random = generateRandomNumber_0_9();
      digit += (random * (int) MathPow(10, i));
   }
   return digit;
}

/* @TESTED
Generates a random cipher between 0-9.
*/
int generateRandomNumber_0_9(){
   return (int)(MathRand()/3276.7);
}
// ---------------------------------------------------------------------------------------------------------------------------------------------------


// --------------------------------------------------------- CONVERSION ------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------------
// @TESTED OK
/* Returns a price in POINTS, converted from price in PIPS (int). Ex: 20 -> 0.00020 */
double convertIntLevelToPricePoints (double level, bool isUsing5DigitBroker){
   // On a 4 digit broker a point == pip.
   // On a 5 digit broker a point is 1/10 pip.
   // Either you must adjust all your pip values when you move from a 4 to a 5 broker or the EA must adjust.
   int onePipInPoints = 1;
   if(isUsing5DigitBroker == true)    onePipInPoints = 10;
   if(isUsing5DigitBroker == false)   onePipInPoints = 1;
   return (level * Point * onePipInPoints);
}


// --------------------------------------------------------- NAKED DISPLAY ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------------
// @TESTED OK
/* Display a bunch of lines to see prints output more clearly. */
void alertBLANKlineForNewBarOrTick(){   
   Alert(" -------------------------------------------- NEW BAR -------------------------------------------- ");
   Alert("                                                                                                   ");
}
// ---------------------------------------------------------------------------------------------------------------------------------------------------



// --------------------------------------------------------- ENABLING & DISABLING TRADES EA ----------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------------
// @TESTED OK
/* Disable trading and remove EA if losses are above a certain unacceptable percentage of the overall account. */
bool disableTrading_AccountBalance_TooSmall (double startingBalance, double minPercentageBalance, bool doRemoveExpert){
   bool doDisable = disableTradingWhenAccountPercentageDropsTo( startingBalance, minPercentageBalance);
   if( doDisable == true){
      Alert(" STOP EA --- Current Balance = ", NormalizeDouble(AccountBalance(), 2),"  from Initial Account = ", startingBalance);
      if( doRemoveExpert == true){
         Alert(" REMOVE EA --- Account balance droped below minimum percentage/fraction ", minPercentageBalance ,"%  !!! ");
         ExpertRemove();
      }
   }
   return doDisable;
}

// @TESTED OK
/* Check actual account size verses starting account size, before trading. */
bool disableTradingWhenAccountPercentageDropsTo (double startingBalance, double percentageMin){
   double currentBalance = AccountBalance();
   bool doDisable = false;
   double startVal = percentageMin;
   // Percentage correction
   double percentage = standardizePercentageToFormat_Point001( percentageMin );
   
   if( currentBalance <= (startingBalance * percentage) )
      doDisable = true;
   return doDisable;
}

// @TESTED OK
/* Make sure that whatever percentage format user puts it, it will be used correctly:
   0.1   is    10%
   10    is    10%   */
double standardizePercentageToFormat_Point001(double percentageInitial){      // @TESTED OK
   double finalPercentage = 0.10;
        if(percentageInitial < 0.10)                                finalPercentage = 0.10;
   else if(0.10 <= percentageInitial && percentageInitial < 0.95)   finalPercentage = percentageInitial;
   else if(0.95 <= percentageInitial && percentageInitial <  1.0)   finalPercentage = 0.95;
   else if(1.0  <= percentageInitial && percentageInitial < 10.0)   finalPercentage = 0.10;
   else if(10.0 <= percentageInitial && percentageInitial < 95.0)   finalPercentage = percentageInitial /100;
   else if(95.0 <= percentageInitial)                               finalPercentage = 0.95;
   return finalPercentage;
}
// ---------------------------------------------------------------------------------------------------------------------------------------------------


// --------------------------------------------------------- DRAWING & HIGHLIGHTING ------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------------
void draw3ForTime (datetime timeDate, int lineColor, int lineThickness){
   string name = TimeToStr(timeDate, TIME_DATE|TIME_MINUTES);
   if(lineThickness < 1)    lineThickness= 1;
   if(lineThickness > 5)    lineThickness= 5;
   ObjectCreate(name, OBJ_VLINE, 0, timeDate, 0);
   ObjectSet(name, OBJPROP_WIDTH, lineThickness);
   ObjectSet(name, OBJPROP_COLOR, lineColor);
   ObjectSet(name, OBJPROP_BACK, true);
}



// --------------------------------------------------------- VOLUME RISK COMPUTATION FOR FOREX -------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------------
double computeTradeVolume (double risk, double stopLossInPips){
   double myBalance = AccountBalance();
   string currencyAccount = AccountCurrency();
   double finalLotSize;
   
   if(0.1 < risk && risk < 10.0){
      double riskAccCurrency = myBalance *risk /100;
      
      string currencyPair = Symbol();
      string quoteCurrency = getQuoteCurrency (Symbol());
      string conversionPair = StringTrimLeft( StringTrimRight( StringConcatenate(currencyAccount, quoteCurrency)));
      double rateForAccountConversion = MarketInfo(conversionPair, MODE_BID);
      
      if(rateForAccountConversion == 0.0){
         string first  = StringSubstr(conversionPair, 0, 3);
         string second = StringSubstr(conversionPair, 3, -1);
         string inverted = second + first;
         rateForAccountConversion = MarketInfo(inverted, MODE_BID);
      }
      if(currencyAccount == quoteCurrency){
         rateForAccountConversion = 1.0;
      }
      double riskQuoteCurrency = riskAccCurrency * rateForAccountConversion;
      
      double pipValue = riskQuoteCurrency /stopLossInPips;
      int multiplier = (int)MathPow(10, MarketInfo(Symbol(),MODE_DIGITS)-1);
      
      long units = (long) (pipValue * multiplier);
      double lotsize = units / MarketInfo(Symbol(), MODE_LOTSIZE);
      
      int normalizedLotSize = (int) (lotsize *100);
      double min = (double)(normalizedLotSize) /100;
      double max = (double)(normalizedLotSize +1) /100;
      
      double distanceFromMin = lotsize - min;
      double distanceFromMax = max - lotsize;
      
      if(distanceFromMin < distanceFromMax)     finalLotSize = min;
      else                                      finalLotSize = max;
      
   if(finalLotSize < 0.01)
      finalLotSize = 0.01;
   }else{
      finalLotSize = -1.0;
   }
   return finalLotSize;
}

string getBaseCurrency (string chartSymbol){
   return StringSubstr(chartSymbol, 0, 3);
}

string getQuoteCurrency (string chartSymbol){
   return StringSubstr(chartSymbol, 3, -1);
}

// ---------------------------------------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------------



// --------------------------------------------------------- PAUSE TRADING IF TOO MANY LOSSES --------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------------
bool checkIfLastOrderClosedWithLoss (int lastOrderTicket){
   bool didCloseWithLOSS = false;
   bool wasOrderClosed = true;
   if(OrderSelect(lastOrderTicket, SELECT_BY_TICKET) == true)
      if(OrderCloseTime() > 0)   wasOrderClosed = true;
      else                       wasOrderClosed = false;
   if(wasOrderClosed == true){
      if(OrderProfit() < 0.0)
         didCloseWithLOSS = true;
   }
   return didCloseWithLOSS;
}

// @TESTED OK
bool didWaitForXbars(int period, datetime startDateTime, int waitForXBars){
   if(waitForXBars < 1)    waitForXBars = 1;
   datetime NotBefore = startDateTime + waitForXBars *period *60; // to wait x bars
   //Alert(" didWaitForXbars() ---    startDateTime= ", startDateTime, "     TimeCurrent()= ", TimeCurrent(), "     NotBefore= ", NotBefore );
   if (TimeCurrent() < NotBefore)
      return false;
   else{
      //Alert(" didWaitForXbars() ---    Enough candles PASSED... ");
      return true;
   }
}

// @TESTED OK
bool didWaitForXminutes(datetime startDateTime, int waitForXMinutes){
   if(waitForXMinutes < 1)    waitForXMinutes = 1;
   datetime NotBefore = startDateTime + waitForXMinutes *60; // to wait x bars
   Alert(" waitForXMinutes() ---    startDateTime= ", startDateTime, "     TimeCurrent()= ", TimeCurrent(), "     NotBefore= ", NotBefore );
   if (TimeCurrent() < NotBefore)
      return false;
   else{
      Alert(" waitForXMinutes() ---    Enough candles PASSED... ");
      return true;
   }
}
// ---------------------------------------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------------