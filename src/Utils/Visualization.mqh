//+------------------------------------------------------------------+
//|                                                 Visualization.mqh |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"

// Visualization Constants
#define PATTERN_PREFIX    "GB_Pattern_"
#define ZONE_PREFIX       "GB_Zone_"
#define FIB_PREFIX        "GB_Fib_"
#define SIGNAL_PREFIX     "GB_Signal_"
#define LABEL_PREFIX      "GB_Label_"

//+------------------------------------------------------------------+
//| Pattern Visualization Functions                                    |
//+------------------------------------------------------------------+

//--- Draw Flag Pattern
void DrawFlagPattern(const string name,
                    const datetime &time[],
                    const double &price[],
                    const int start_pos,
                    const int end_pos,
                    const bool is_bullish,
                    const color pattern_color) {
    string obj_name = PATTERN_PREFIX + name;
    
    // Draw flag pole
    ObjectCreate(0, obj_name + "_Pole", OBJ_TREND, 0,
                time[start_pos], price[start_pos],
                time[end_pos], price[end_pos]);
    ObjectSetInteger(0, obj_name + "_Pole", OBJPROP_COLOR, pattern_color);
    ObjectSetInteger(0, obj_name + "_Pole", OBJPROP_WIDTH, 2);
    
    // Draw parallel channel lines
    // ... Channel drawing logic here
    
    // Add label
    string label = is_bullish ? "Bullish Flag" : "Bearish Flag";
    CreatePatternLabel(obj_name + "_Label", label,
                      time[end_pos], price[end_pos], pattern_color);
}

//--- Draw Channel Pattern
void DrawChannelPattern(const string name,
                       const datetime start_time,
                       const datetime end_time,
                       const double upper_price,
                       const double lower_price,
                       const color pattern_color,
                       const double opacity = 0.2) {
    string obj_name = PATTERN_PREFIX + name;
    
    // Draw upper line
    ObjectCreate(0, obj_name + "_Upper", OBJ_TREND, 0,
                start_time, upper_price,
                end_time, upper_price);
    ObjectSetInteger(0, obj_name + "_Upper", OBJPROP_COLOR, pattern_color);
    ObjectSetInteger(0, obj_name + "_Upper", OBJPROP_STYLE, STYLE_SOLID);
    
    // Draw lower line
    ObjectCreate(0, obj_name + "_Lower", OBJ_TREND, 0,
                start_time, lower_price,
                end_time, lower_price);
    ObjectSetInteger(0, obj_name + "_Lower", OBJPROP_COLOR, pattern_color);
    ObjectSetInteger(0, obj_name + "_Lower", OBJPROP_STYLE, STYLE_SOLID);
    
    // Draw filled area
    ObjectCreate(0, obj_name + "_Fill", OBJ_RECTANGLE, 0,
                start_time, upper_price,
                end_time, lower_price);
    ObjectSetInteger(0, obj_name + "_Fill", OBJPROP_COLOR, pattern_color);
    ObjectSetInteger(0, obj_name + "_Fill", OBJPROP_FILL, true);
    ObjectSetInteger(0, obj_name + "_Fill", OBJPROP_BACK, true);
    ObjectSetDouble(0, obj_name + "_Fill", OBJPROP_TRANSPARENCY, opacity * 100);
}

//--- Draw Triangle Pattern
void DrawTrianglePattern(const string name,
                        const datetime &time[],
                        const double &price[],
                        const int points[],
                        const ENUM_PATTERN_TYPE type,
                        const color pattern_color) {
    string obj_name = PATTERN_PREFIX + name;
    
    // Draw triangle lines
    for(int i = 0; i < ArraySize(points) - 1; i++) {
        ObjectCreate(0, obj_name + "_Line" + IntegerToString(i), OBJ_TREND, 0,
                    time[points[i]], price[points[i]],
                    time[points[i+1]], price[points[i+1]]);
        ObjectSetInteger(0, obj_name + "_Line" + IntegerToString(i),
                        OBJPROP_COLOR, pattern_color);
    }
    
    // Add label
    string label = "";
    switch(type) {
        case PATTERN_TRIANGLE_ASC:  label = "Ascending Triangle";  break;
        case PATTERN_TRIANGLE_DESC: label = "Descending Triangle"; break;
        case PATTERN_TRIANGLE_SYM:  label = "Symmetrical Triangle"; break;
    }
    
    CreatePatternLabel(obj_name + "_Label", label,
                      time[points[0]], price[points[0]], pattern_color);
}

//+------------------------------------------------------------------+
//| Zone Visualization Functions                                       |
//+------------------------------------------------------------------+

//--- Draw Supply/Demand Zone
void DrawZone(const string name,
             const datetime start_time,
             const datetime end_time,
             const double upper_price,
             const double lower_price,
             const bool is_supply,
             const color zone_color,
             const double opacity = 0.3) {
    string obj_name = ZONE_PREFIX + name;
    
    // Draw zone rectangle
    ObjectCreate(0, obj_name + "_Zone", OBJ_RECTANGLE, 0,
                start_time, upper_price,
                end_time, lower_price);
    ObjectSetInteger(0, obj_name + "_Zone", OBJPROP_COLOR, zone_color);
    ObjectSetInteger(0, obj_name + "_Zone", OBJPROP_FILL, true);
    ObjectSetInteger(0, obj_name + "_Zone", OBJPROP_BACK, true);
    ObjectSetDouble(0, obj_name + "_Zone", OBJPROP_TRANSPARENCY, opacity * 100);
    
    // Add label
    string label = is_supply ? "Supply Zone" : "Demand Zone";
    CreateZoneLabel(obj_name + "_Label", label,
                   end_time, (upper_price + lower_price) / 2, zone_color);
}

//+------------------------------------------------------------------+
//| Fibonacci Visualization Functions                                  |
//+------------------------------------------------------------------+

//--- Draw Fibonacci Levels
void DrawFibonacciLevels(const string name,
                        const datetime start_time,
                        const datetime end_time,
                        const double &levels[],
                        const color fib_color,
                        const bool highlight_zone = true) {
    string obj_name = FIB_PREFIX + name;
    
    // Draw Fibonacci lines
    for(int i = 0; i < ArraySize(levels); i++) {
        ObjectCreate(0, obj_name + "_Level" + IntegerToString(i),
                    OBJ_TREND, 0,
                    start_time, levels[i],
                    end_time, levels[i]);
        ObjectSetInteger(0, obj_name + "_Level" + IntegerToString(i),
                        OBJPROP_COLOR, fib_color);
        ObjectSetInteger(0, obj_name + "_Level" + IntegerToString(i),
                        OBJPROP_STYLE, STYLE_DOT);
        
        // Add level labels
        string level_text = DoubleToString(levels[i], _Digits);
        CreateFibLabel(obj_name + "_Label" + IntegerToString(i),
                      level_text, end_time, levels[i], fib_color);
    }
    
    // Highlight 0.5-0.618 zone if requested
    if(highlight_zone) {
        int level_50 = ArraySize(levels) / 2;
        int level_618 = level_50 + 1;
        
        ObjectCreate(0, obj_name + "_Zone", OBJ_RECTANGLE, 0,
                    start_time, levels[level_50],
                    end_time, levels[level_618]);
        ObjectSetInteger(0, obj_name + "_Zone", OBJPROP_COLOR, fib_color);
        ObjectSetInteger(0, obj_name + "_Zone", OBJPROP_FILL, true);
        ObjectSetInteger(0, obj_name + "_Zone", OBJPROP_BACK, true);
        ObjectSetDouble(0, obj_name + "_Zone", OBJPROP_TRANSPARENCY, 80);
    }
}

//+------------------------------------------------------------------+
//| Signal Visualization Functions                                     |
//+------------------------------------------------------------------+

//--- Draw Trading Signal
void DrawSignal(const string name,
               const datetime signal_time,
               const double entry_price,
               const double stop_loss,
               const double take_profit,
               const ENUM_SIGNAL_TYPE signal_type,
               const color signal_color) {
    string obj_name = SIGNAL_PREFIX + name;
    
    // Draw entry arrow
    ObjectCreate(0, obj_name + "_Entry", OBJ_ARROW,0,
                signal_time, entry_price);
    ObjectSetInteger(0, obj_name + "_Entry", OBJPROP_ARROWCODE,
                    signal_type <= SIGNAL_NEUTRAL ? 233 : 234);
    ObjectSetInteger(0, obj_name + "_Entry", OBJPROP_COLOR, signal_color);
    
    // Draw stop loss line
    ObjectCreate(0, obj_name + "_SL", OBJ_TREND, 0,
                signal_time, stop_loss,
                signal_time + PeriodSeconds() * 20, stop_loss);
    ObjectSetInteger(0, obj_name + "_SL", OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, obj_name + "_SL", OBJPROP_STYLE, STYLE_DOT);
    
    // Draw take profit line
    ObjectCreate(0, obj_name + "_TP", OBJ_TREND, 0,
                signal_time, take_profit,
                signal_time + PeriodSeconds() * 20, take_profit);
    ObjectSetInteger(0, obj_name + "_TP", OBJPROP_COLOR, clrGreen);
    ObjectSetInteger(0, obj_name + "_TP", OBJPROP_STYLE, STYLE_DOT);
    
    // Add signal label
    string signal_text = "";
    switch(signal_type) {
        case SIGNAL_STRONG_BUY:    signal_text = "Strong Buy";     break;
        case SIGNAL_MODERATE_BUY:  signal_text = "Moderate Buy";   break;
        case SIGNAL_NEUTRAL:       signal_text = "Neutral";        break;
        case SIGNAL_MODERATE_SELL: signal_text = "Moderate Sell";  break;
        case SIGNAL_STRONG_SELL:   signal_text = "Strong Sell";    break;
    }
    
    CreateSignalLabel(obj_name + "_Label", signal_text,
                     signal_time, entry_price, signal_color);
}

//+------------------------------------------------------------------+
//| Label Creation Functions                                          |
//+------------------------------------------------------------------+

//--- Create Pattern Label
void CreatePatternLabel(const string name,
                       const string text,
                       const datetime time,
                       const double price,
                       const color text_color) {
    ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
}

//--- Create Zone Label
void CreateZoneLabel(const string name,
                    const string text,
                    const datetime time,
                    const double price,
                    const color text_color) {
    ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_CENTER);
}

//--- Create Fibonacci Label
void CreateFibLabel(const string name,
                   const string text,
                   const datetime time,
                   const double price,
                   const color text_color) {
    ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_CENTER);
}

//--- Create Signal Label
void CreateSignalLabel(const string name,
                      const string text,
                      const datetime time,
                      const double price,
                      const color text_color) {
    ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
}

//+------------------------------------------------------------------+
//| Object Management Functions                                        |
//+------------------------------------------------------------------+

//--- Remove Pattern Objects
void RemovePatternObjects(const string pattern_name = "") {
    if(pattern_name == "")
        ObjectsDeleteAll(0, PATTERN_PREFIX);
    else
        ObjectsDeleteAll(0, PATTERN_PREFIX + pattern_name);
}

//--- Remove Zone Objects
void RemoveZoneObjects(const string zone_name = "") {
    if(zone_name == "")
        ObjectsDeleteAll(0, ZONE_PREFIX);
    else
        ObjectsDeleteAll(0, ZONE_PREFIX + zone_name);
}

//--- Remove Fibonacci Objects
void RemoveFibObjects(const string fib_name = "") {
    if(fib_name == "")
        ObjectsDeleteAll(0, FIB_PREFIX);
    else
        ObjectsDeleteAll(0, FIB_PREFIX + fib_name);
}

//--- Remove Signal Objects
void RemoveSignalObjects(const string signal_name = "") {
    if(signal_name == "")
        ObjectsDeleteAll(0, SIGNAL_PREFIX);
    else
        ObjectsDeleteAll(0, SIGNAL_PREFIX + signal_name);
}

//--- Remove All Objects
void RemoveAllObjects() {
    RemovePatternObjects();
    RemoveZoneObjects();
    RemoveFibObjects();
    RemoveSignalObjects();
}
