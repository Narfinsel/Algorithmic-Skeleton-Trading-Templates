//+------------------------------------------------------------------+
//|                                          TradeRectVisualizer.mqh |
//|                                               Svetozar Pasulschi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "SimonG"
#property link      "https://www.mql5.com"
#property strict

#define VIZ_TRADE_SL1 "SL1"
#define VIZ_TRADE_SL  "SL"
#define VIZ_TRADE_TP  "TP"

#define WINDOW_MAIN 0
#define CHART_ID 0

class TradeRectVisualizer{
   protected:
      color colorArrowSL;
      color colorArrowTP;
      color colorRectSL;
      color colorRectTP;
      bool canDrawArrow;
      bool canDrawRectangle;
      bool isSelectable;
      int thicknessArrow;
      int thicknessRect;
      bool shouldFillRect;
      bool shouldUseBackColRect;

      //string drawRectTrade_IfNonePresent(string nameRect, string rectTradeType, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doFill, bool withBackCol, bool doShowAlert);    doSelect missing
      //string drawRectTrade(string nameRect, string rectTradeType, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doFill, bool withBackCol, bool doShowAlert);  doSelect missing
      //string drawRectTrade( int magicNumer, int ticketNumer, string rectTradeType, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doFill, bool withBackCol, bool doShowAlert);  doSelect missing
      void vizFullyColored (int tradeMagicNum, int tradeTicketNum, bool doDrawArrows, int thiccArrow, bool doDrawRectangleSlTp, bool doFill, bool withBackCol, bool doSelect, int thiccRect);
      void vizHalfHallow (int tradeMagicNum, int tradeTicketNum, bool doDrawArrows, int thiccArrow, bool doDrawRectangleSlTp, bool doFill, bool withBackCol, bool doSelect, int thiccRect);
      string drawArrowTrade_IfNonePresent(string nameArrow, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doSelect, bool doShowAlert);
      string drawRectTrade_IfNonePresent(string nameRect, string rectTradeType, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doFill, bool withBackCol, bool doSelect, bool doShowAlert);
      string drawRectTrade(string nameRect, string rectTradeType, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doFill, bool withBackCol, bool doSelect, bool doShowAlert);
      string drawArrowTrade(string nameArrow, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doSelect, bool doShowAlert);      
      string drawArrowTrade( int magicNumer, int ticketNumer, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doSelect, bool doShowAlert);

      string drawRectTrade( int magicNumer, int ticketNumer, string rectTradeType, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doFill, bool withBackCol, bool doSelect, bool doShowAlert);
      bool createArrow(string nameArrow, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doSelect, bool doShowAlert=false);
      bool createRentangle(string nameRect, datetime time1, double price1, datetime time2, double price2, color clr, ENUM_LINE_STYLE style=STYLE_SOLID, 
                     int width=1, bool fill=true, bool back=false, bool selectionMove=false, bool hidden=true, long z_order=0, bool doShowAlert=false);
      bool modifyRentangle(string nameRect, datetime newTime2, double newPrice2, bool doShowAlert=false);
      bool modifyRectTrade (int magicNumer, int ticketNumer, string rectTradeType, datetime newTime2, double newPrice2, bool doShowAlert=false);
      string composeArrowObjectName (int magicNumer, int ticketNumer);
      string composeRectObjectName (int magicNumer, int ticketNumer, string rectTradeType);
      
      
   public:
      ~TradeRectVisualizer();
      TradeRectVisualizer();
      void vizualizeHalfHollowTradeRect (int tradeMagicNum, int tradeTicketNum);
      void vizualizeFullyColoredTradeRect (int tradeMagicNum, int tradeTicketNum);
      void setTradeRectAndArrowColors (color slArrowColor, color slRectColor, color tpArrowColor, color tpRectColor);
      void setTradeArrowProperties (color slArrowColor, color tpArrowColor, int arrowThickness);
      void setTradeRectProperties (color slRectColor, color tpRectColor, bool doFillRect, bool doUseBackColRect, int rectThickness);
      void setWhatToDraw (bool doDrawArrow, bool doDrawRectangle);
      void setSelectable (bool doSelect);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeRectVisualizer :: ~TradeRectVisualizer(){}
TradeRectVisualizer :: TradeRectVisualizer(){
   this.colorArrowSL = clrRed;
   this.colorRectSL = clrLightPink;
   this.colorArrowTP = clrForestGreen;
   this.colorRectTP = clrPaleTurquoise;
   this.canDrawArrow = true;
   this.isSelectable = true;
   this.thicknessArrow = 2;
   this.thicknessRect = 1;
   this.canDrawRectangle = true;
   this.shouldFillRect = true;
   this.shouldUseBackColRect = true;
}

void TradeRectVisualizer :: setTradeRectAndArrowColors (color slArrowColor, color slRectColor, color tpArrowColor, color tpRectColor){
   this.colorArrowSL = slArrowColor;
   this.colorRectSL = slRectColor;
   this.colorArrowTP = tpArrowColor;
   this.colorRectTP = tpRectColor;
}

void TradeRectVisualizer :: setTradeArrowProperties (color slArrowColor, color tpArrowColor, int arrowThickness){
   this.colorArrowSL = slArrowColor;
   this.colorArrowTP = tpArrowColor;
   this.thicknessArrow = arrowThickness;
}

void TradeRectVisualizer :: setTradeRectProperties (color slRectColor, color tpRectColor, bool doFillRect, bool doUseBackColRect, int rectThickness){
   this.colorRectSL = slRectColor;
   this.colorRectTP = tpRectColor;
   this.shouldFillRect = doFillRect;
   this.shouldUseBackColRect = doUseBackColRect;
   this.thicknessRect = rectThickness;
}

void TradeRectVisualizer :: setWhatToDraw (bool doDrawArrow, bool doDrawRectangle){
   this.canDrawArrow = doDrawArrow;
   this.canDrawRectangle = doDrawRectangle;
}
void TradeRectVisualizer :: setSelectable (bool doSelect){
   this.isSelectable = doSelect;
}


//+------------------------------------------------------------------------------------------------------------------------------+


// -------------------------------------------------- VISUALIZE RECT AND ARROW --------------------------------------------------+
// ------------------------------------------------------------------------------------------------------------------------------+
// @TESTED OK
void TradeRectVisualizer :: vizualizeHalfHollowTradeRect (int tradeMagicNum, int tradeTicketNum){
   this.vizHalfHallow (tradeMagicNum, tradeTicketNum, this.canDrawArrow, this.thicknessArrow, this.canDrawRectangle, this.shouldFillRect, this.shouldUseBackColRect, this.isSelectable, this.thicknessRect);
}

// @TESTED OK
void TradeRectVisualizer :: vizualizeFullyColoredTradeRect (int tradeMagicNum, int tradeTicketNum){
   this.vizFullyColored (tradeMagicNum, tradeTicketNum, this.canDrawArrow, this.thicknessArrow, this.canDrawRectangle, this.shouldFillRect, this.shouldUseBackColRect, this.isSelectable, this.thicknessRect);
}

// @TESTED OK
void TradeRectVisualizer :: vizFullyColored (int tradeMagicNum, int tradeTicketNum, bool doDrawArrows, int thiccArrow, bool doDrawRectangleSlTp, bool doFill, bool withBackCol, bool doSelect, int thiccRect){
   bool doAlert = false;
   if(OrderMagicNumber() == tradeMagicNum){
      if(OrderSelect(tradeTicketNum, SELECT_BY_TICKET) == true){  // Order was selected
         if(OrderCloseTime() > 0){                             // Order was closed
            string nameLine = StringConcatenate( tradeMagicNum, "_",tradeTicketNum);
            if(doDrawArrows == true){
               if(OrderProfit() < 0.0)          // Loss
                  drawArrowTrade( tradeMagicNum, tradeTicketNum, OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderClosePrice(), colorArrowSL, thiccArrow, doSelect, doAlert);
               else if(OrderProfit() >= 0.0)    // Profit
                  drawArrowTrade( tradeMagicNum, tradeTicketNum, OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderClosePrice(), colorArrowTP, thiccArrow, doSelect, doAlert);
            }
            if(doDrawRectangleSlTp == true){
               if(OrderProfit() < 0.0){         // Loss
                  drawRectTrade( tradeMagicNum, tradeTicketNum, VIZ_TRADE_SL, OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderStopLoss(), colorRectSL, thiccRect, doFill, withBackCol, doSelect, doAlert);
                  if(OrderTakeProfit() != 0.0)
                     drawRectTrade( tradeMagicNum, tradeTicketNum, (VIZ_TRADE_TP +"a"), OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderTakeProfit(), colorRectTP, thiccRect, doFill, withBackCol, doSelect, doAlert);
               }
               else if(OrderProfit() >= 0.0){   // Profit
                  drawRectTrade( tradeMagicNum, tradeTicketNum, VIZ_TRADE_SL, OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderStopLoss(), colorRectSL, thiccRect, doFill, withBackCol, doSelect, doAlert);
                  drawRectTrade( tradeMagicNum, tradeTicketNum, (VIZ_TRADE_TP +"a"), OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderClosePrice(), colorRectTP, thiccRect, doFill, withBackCol, doSelect, doAlert);
               }
            }
         }  else  Alert(" Cannot visualize trade 3 - NOT CLOSED YET!!");
      } else  Alert(" Cannot visualize trade 2 - FAILED TO SELECT TICKET!!");
   } else  Alert(" Cannot visualize trade 1 - MISMATCHING MAGIC NUMBER!! -   ", OrderMagicNumber(), " vs ", tradeMagicNum);
}


// @TESTED OK
void TradeRectVisualizer :: vizHalfHallow (int tradeMagicNum, int tradeTicketNum, bool doDrawArrows, int thiccArrow, bool doDrawRectangleSlTp, bool doFill, bool withBackCol, bool doSelect, int thiccRect){
   bool doAlert = false;
   if(OrderSelect(tradeTicketNum, SELECT_BY_TICKET) == true){  // Order was selected
      if(OrderMagicNumber() == tradeMagicNum){
         if(OrderCloseTime() > 0){                             // Order was closed
            string nameLine = StringConcatenate( tradeMagicNum, "_",tradeTicketNum);
            if(OrderProfit() < 0.0){         // Loss
               if(doDrawArrows == true)
                  drawArrowTrade( tradeMagicNum, tradeTicketNum, OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderClosePrice(), colorArrowSL, thiccArrow, doSelect, doAlert);
                  
               if(doDrawRectangleSlTp == true){
                  drawRectTrade( tradeMagicNum, tradeTicketNum, (VIZ_TRADE_SL +"a"), OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderStopLoss(), colorRectSL, thiccRect, doFill, withBackCol, doSelect, false);
                  if(OrderTakeProfit() > 0)
                     drawRectTrade( tradeMagicNum, tradeTicketNum, (VIZ_TRADE_TP +"b"), OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderTakeProfit(), colorRectTP, thiccRect, false, false, doSelect, false);
               }
            }
            else if(OrderProfit() >= 0.0){   // Profit
               if(doDrawArrows == true)
                  drawArrowTrade( tradeMagicNum, tradeTicketNum, OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderClosePrice(), colorArrowTP, thiccArrow, doSelect, doAlert);
               if(doDrawRectangleSlTp == true){
                  drawRectTrade( tradeMagicNum, tradeTicketNum, (VIZ_TRADE_SL +"b"), OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderStopLoss(), colorRectSL, thiccRect, false, false, doSelect, false);
                  drawRectTrade( tradeMagicNum, tradeTicketNum, (VIZ_TRADE_TP +"b"), OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderClosePrice(), colorRectTP, thiccRect, doFill, withBackCol, doSelect, false);
               }
            }
         } else  Alert(" Cannot visualize trade 3 - NOT CLOSED YET!!");
      } else  Alert(" Cannot visualize trade 2 - FAILED TO SELECT TICKET!!");
   } else  Alert(" Cannot visualize trade 1 - MISMATCHING MAGIC NUMBER!! -   ", OrderMagicNumber(), " vs ", tradeMagicNum);
}


// ------------------------------------------------------- DRAW FUNCTIONS -------------------------------------------------------+
// ------------------------------------------------------------------------------------------------------------------------------+
string TradeRectVisualizer :: drawArrowTrade_IfNonePresent(string nameArrow, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doSelect, bool doShowAlert){
   if(ObjectFind(0, nameArrow) < 0)
      return drawArrowTrade( nameArrow, T0, P0, T1, P1, clr, thickness, doSelect, doShowAlert);
   return NULL;
}

string TradeRectVisualizer :: drawRectTrade_IfNonePresent(string nameRect, string rectTradeType, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doFill, bool withBackCol, bool doSelect, bool doShowAlert){
   if(ObjectFind(0, nameRect) < 0)
      return drawRectTrade( nameRect, rectTradeType, T0, P0, T1, P1, clr, thickness, doFill, withBackCol, doSelect, doShowAlert);
   return NULL;
}


string TradeRectVisualizer :: drawArrowTrade(string nameArrow, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doSelect, bool doShowAlert){
   if( !createArrow( nameArrow, T0, P0, T1, P1, clr, thickness, doSelect, doShowAlert) ){
      Alert("Did not create arrow named - ", nameArrow);
      return NULL;
   }
   else return nameArrow;
}


string TradeRectVisualizer :: drawRectTrade(string nameRect, string rectTradeType, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doFill, bool withBackCol, bool doSelect, bool doShowAlert){
   if(doShowAlert)
      Alert(" D R A W --------- RECT   Type=", rectTradeType," is     :     ", nameRect);
   if( !createRentangle( nameRect, T0, P0, T1, P1, clr, STYLE_SOLID, thickness, doFill, withBackCol, doSelect, false, 0, doShowAlert) ){
      Alert("Did not create rectangle named - ", nameRect);
      return NULL;
   }
   else return nameRect;
}



// @TESTED OK
string TradeRectVisualizer :: drawArrowTrade(int magicNumer, int ticketNumer, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doSelect, bool doShowAlert){
   string nameArrow = composeArrowObjectName( magicNumer, ticketNumer);
   return drawArrowTrade( nameArrow, T0, P0, T1, P1, clr, thickness, doSelect, doShowAlert);
}

// @TESTED OK
string TradeRectVisualizer :: drawRectTrade(int magicNumer, int ticketNumer, string rectTradeType, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doFill, bool withBackCol, bool doSelect, bool doShowAlert){
   string nameRect = composeRectObjectName( magicNumer, ticketNumer, rectTradeType);
   return drawRectTrade( nameRect, rectTradeType, T0, P0, T1, P1, clr, thickness, doFill, withBackCol, doSelect, doShowAlert);
}



string TradeRectVisualizer :: composeArrowObjectName (int magicNumer, int ticketNumer){
   return StringConcatenate( "ARROW", "__", "MN", magicNumer, "__", "TRADE", ticketNumer);
}
string TradeRectVisualizer :: composeRectObjectName (int magicNumer, int ticketNumer, string rectTradeType){
   return StringConcatenate( "RECT", "__", "MN", magicNumer, "__", "TRADE", ticketNumer, "__", rectTradeType);
}

bool TradeRectVisualizer :: modifyRectTrade (int magicNumer, int ticketNumer, string rectTradeType, datetime newTime2, double newPrice2, bool doShowAlert=false){
   string nameRect = composeRectObjectName( magicNumer, ticketNumer, rectTradeType);
   if(doShowAlert)
      Alert(" M O D I F Y --------- RECT   Ticket=", ticketNumer,"   Type=", rectTradeType," is     :     ", nameRect);
   if( !modifyRentangle( nameRect, newTime2, newPrice2, doShowAlert=false) )
      return false;
   return true;
}


// @TESTED OK
bool TradeRectVisualizer :: createArrow (string nameArrow, datetime T0, double P0, datetime T1, double P1, color clr, int thickness, bool doSelect, bool doShowAlert=false){
   bool ray = false;
   if(ObjectMove(nameArrow, 0, T0, P0))
      ObjectMove(nameArrow, 1, T1, P1);
   else if( !ObjectCreate(nameArrow, OBJ_TREND, WINDOW_MAIN, T0, P0, T1, P1) && doShowAlert==true){
      if(doShowAlert==true)         Alert("ObjectCreate(",nameArrow,",TREND) failed: ", GetLastError() );
      return(false);
   }
   ObjectSet(nameArrow, OBJPROP_RAY, ray);
   ObjectSet(nameArrow, OBJPROP_WIDTH, thickness);
   ObjectSet(nameArrow, OBJPROP_COLOR, clr);
   ObjectSet(nameArrow, OBJPROP_SELECTABLE, doSelect);
   ObjectSet(nameArrow, OBJPROP_SELECTED, false);
   string label = StringConcatenate(DoubleToStr(P0, Digits), " to ", DoubleToStr(P1, Digits));
   ObjectSetText(nameArrow, label, 10);
   return(true); 
}

// @TESTED OK
bool TradeRectVisualizer :: createRentangle (string nameRect, datetime time1, double price1, datetime time2, double price2, color clr, ENUM_LINE_STYLE style=STYLE_SOLID, 
                                             int width=1, bool fill=true, bool back=false, bool selectionMove=false, bool hidden=true, long z_order=0, bool doShowAlert=false){
   ResetLastError();    //--- reset the error value
   if( !ObjectCreate( nameRect, OBJ_RECTANGLE, WINDOW_MAIN, time1, price1, time2, price2) ){       //--- create a rectangle by the given coordinates
         if(doShowAlert==true)  Alert(__FUNCTION__, ": failed to create a rectangle! Error code = ", GetLastError()); 
         return(false); 
   }
   ObjectSetInteger(CHART_ID, nameRect, OBJPROP_COLOR, clr);      //--- set rectangle color
   ObjectSetInteger(CHART_ID, nameRect, OBJPROP_STYLE, style);    //--- set the style of rectangle lines
   ObjectSetInteger(CHART_ID, nameRect, OBJPROP_WIDTH, width);    //--- set width of the rectangle lines
   ObjectSetInteger(CHART_ID, nameRect, OBJPROP_FILL, fill);      //--- enable (true) or disable (false) the mode of filling the rectangle
   ObjectSetInteger(CHART_ID, nameRect, OBJPROP_BACK, back);      //--- display in the foreground (false) or background (true)
   //--- enable (true) or disable (false) the mode of highlighting the rectangle for moving 
   //--- when creating a graphical object using ObjectCreate function, the object cannot be 
   //--- highlighted and moved by default. Inside this method, selection parameter 
   //--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(CHART_ID, nameRect, OBJPROP_SELECTABLE, selectionMove);
   ObjectSetInteger(CHART_ID, nameRect, OBJPROP_SELECTED, false);
   ObjectSetInteger(CHART_ID, nameRect, OBJPROP_HIDDEN, hidden);  //--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(CHART_ID, nameRect, OBJPROP_ZORDER, z_order); //--- set the priority for receiving the event of a mouse click in the chart
   return(true);                                                  //--- successful execution 
} 

bool TradeRectVisualizer :: modifyRentangle (string nameRect, datetime newTime2, double newPrice2, bool doShowAlert=false){    
   ResetLastError();    //--- reset the error value
   if( ObjectFind( CHART_ID, nameRect) < 0){                      //--- check if rectangle exists
      if(doShowAlert==true)  Alert(__FUNCTION__, ": failed to find a rectangle! Error code = ", GetLastError()); 
      return(false);    
   }
   ObjectMove(CHART_ID, nameRect, 1, newTime2, newPrice2);
   return(true);                                                  //--- successful execution 
} 


// ---------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------



/*+------------------------------------------------------------------+
//|                            HOW TO                                |
//+------------------------------------------------------------------+

1. Include in file:
      #include <__SimonG\Helpers\TradeRectVisualizer.mqh>

2. Create a public EA variable of type TradeRectVisualizer:
      TradeRectVisualizer * rectVisualizer;

3. Instantiante and customize in OnInit():
      rectVisualizer = new TradeRectVisualizer();
      rectVisualizer.setWhatToDraw (true, true);
      rectVisualizer.setTradeArrowProperties (clrDeepPink, clrDarkTurquoise, 3);
      rectVisualizer.setTradeRectProperties (clrLightPink, clrPaleTurquoise, true, true, 2);

4. In your onTick() or any function :
         if(OrderSelect(currentOrderTicket, SELECT_BY_TICKET) == true)
            if(OrderCloseTime() > 0){
               isThereAnOpenTrade = false;
               if(doGraphTradesArrRect == true && hasDrawnArrRect == false){
                  rectVisualizer.vizualizeHalfHollowTradeRect ( magicNumber, currentOrderTicket);
                  // rectVisualizer.vizualizeFullyColoredTradeRect ( magicNumber, currentOrderTicket);
                  hasDrawnArrRect = true;
               }
            }else isThereAnOpenTrade = true;
      ...
      And then, when you open a new trade:
         OrderSend(..........);
         hasDrawnArrRect = false;
*/