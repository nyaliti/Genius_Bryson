//+------------------------------------------------------------------+
//|                                                     GeniusBryson.mq5 |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"
#property description "Genius_Bryson - Advanced Forex Chart Analysis Assistant"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8

// Enums
enum ENUM_PATTERN_TYPE {
    PATTERN_FLAG,
    PATTERN_PENNANT,
    PATTERN_CHANNEL_ASC,
    PATTERN_CHANNEL_DESC,
    PATTERN_CHANNEL_HORZ,
    PATTERN_TRIANGLE_ASC,
    PATTERN_TRIANGLE_DESC,
    PATTERN_TRIANGLE_SYM,
    PATTERN_HEAD_SHOULDERS,
    PATTERN_HEAD_SHOULDERS_INV,
    PATTERN_DOUBLE_TOP,
    PATTERN_DOUBLE_BOTTOM,
    PATTERN_TRIPLE_TOP,
    PATTERN_TRIPLE_BOTTOM,
    PATTERN_ROUNDING_BOTTOM,
    PATTERN_CUP_HANDLE
};

enum ENUM_CANDLESTICK_PATTERN {
    CANDLE_DOJI,
    CANDLE_HAMMER,
    CANDLE_SHOOTING_STAR,
    CANDLE_ENGULFING
};

// Global Variables
input int      InpPatternBars = 100;       // Pattern Detection Bars
input double   InpConfidenceThreshold = 75; // Pattern Confidence Threshold
input bool     InpShowSupplyDemand = true;  // Show Supply/Demand Zones
input bool     InpShowFibLevels = true;     // Show Fibonacci Levels
input color    InpSupplyZoneColor = clrPink;    // Supply Zone Color
input color    InpDemandZoneColor = clrLightGreen; // Demand Zone Color
input color    InpPatternColor = clrBlue;    // Pattern Lines Color
input color    InpFibColor = clrGold;        // Fibonacci Lines Color

// Buffers for indicators
double BufferSupplyZone[];
double BufferDemandZone[];
double BufferPatternHigh[];
double BufferPatternLow[];
double BufferFibLevels[];
double BufferSignalStrength[];
double BufferStopLoss[];
double BufferTakeProfit[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                           |
//+------------------------------------------------------------------+
int OnInit() {
    // Initialize buffers
    SetIndexBuffer(0, BufferSupplyZone, INDICATOR_DATA);
    SetIndexBuffer(1, BufferDemandZone, INDICATOR_DATA);
    SetIndexBuffer(2, BufferPatternHigh, INDICATOR_DATA);
    SetIndexBuffer(3, BufferPatternLow, INDICATOR_DATA);
    SetIndexBuffer(4, BufferFibLevels, INDICATOR_DATA);
    SetIndexBuffer(5, BufferSignalStrength, INDICATOR_DATA);
    SetIndexBuffer(6, BufferStopLoss, INDICATOR_DATA);
    SetIndexBuffer(7, BufferTakeProfit, INDICATOR_DATA);
    
    // Set indicator properties
    IndicatorSetString(INDICATOR_SHORTNAME, "Genius_Bryson");
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    
    // Initialize colors
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpSupplyZoneColor);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpDemandZoneColor);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, InpPatternColor);
    PlotIndexSetInteger(4, PLOT_LINE_COLOR, InpFibColor);
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                |
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
                const int &spread[]) {
    
    // Check for minimum required bars
    if(rates_total < InpPatternBars) return(0);
    
    // Calculate start position
    int start = prev_calculated == 0 ? InpPatternBars : prev_calculated - 1;
    
    // Main calculation loop
    for(int i = start; i < rates_total; i++) {
        // Reset buffers
        BufferSupplyZone[i] = EMPTY_VALUE;
        BufferDemandZone[i] = EMPTY_VALUE;
        BufferPatternHigh[i] = EMPTY_VALUE;
        BufferPatternLow[i] = EMPTY_VALUE;
        BufferFibLevels[i] = EMPTY_VALUE;
        BufferSignalStrength[i] = EMPTY_VALUE;
        BufferStopLoss[i] = EMPTY_VALUE;
        BufferTakeProfit[i] = EMPTY_VALUE;
        
        // Detect patterns
        if(DetectPatterns(i, rates_total, open, high, low, close)) {
            // Pattern detected, analyze and generate signals
            AnalyzePattern(i, rates_total, open, high, low, close);
        }
        
        // Detect supply/demand zones
        if(InpShowSupplyDemand) {
            DetectSupplyDemandZones(i, rates_total, high, low, close);
        }
        
        // Calculate Fibonacci levels
        if(InpShowFibLevels) {
            CalculateFibonacciLevels(i, rates_total, high, low);
        }
        
        // Generate trading signals
        GenerateSignals(i, rates_total, open, high, low, close);
    }
    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Pattern Detection Function                                         |
//+------------------------------------------------------------------+
bool DetectPatterns(const int index,
                   const int rates_total,
                   const double &open[],
                   const double &high[],
                   const double &low[],
                   const double &close[]) {
    bool pattern_found = false;
    
    // Check if we have enough bars for pattern detection
    if(index < InpPatternBars) return false;
    
    // Flag Pattern Detection
    bool is_bullish;
    if(DetectFlag(index, rates_total, high, low, close, is_bullish)) {
        pattern_found = true;
        DrawFlagPattern(index, is_bullish);
        BufferPatternHigh[index] = high[index];
        BufferPatternLow[index] = low[index];
    }
    
    // Channel Pattern Detection
    ENUM_PATTERN_TYPE channel_type;
    if(DetectChannel(index, rates_total, high, low, close, channel_type)) {
        pattern_found = true;
        DrawChannelPattern(index, channel_type);
        BufferPatternHigh[index] = high[index];
        BufferPatternLow[index] = low[index];
    }
    
    // Triangle Pattern Detection
    ENUM_PATTERN_TYPE triangle_type;
    if(DetectTriangle(index, rates_total, high, low, close, triangle_type)) {
        pattern_found = true;
        DrawTrianglePattern(index, triangle_type);
        BufferPatternHigh[index] = high[index];
        BufferPatternLow[index] = low[index];
    }
    
    // Head and Shoulders Pattern Detection
    bool is_inverse;
    if(DetectHeadAndShoulders(index, rates_total, high, low, close, is_inverse)) {
        pattern_found = true;
        DrawHeadAndShouldersPattern(index, is_inverse);
        BufferPatternHigh[index] = high[index];
        BufferPatternLow[index] = low[index];
    }
    
    // Double/Triple Top/Bottom Detection
    ENUM_PATTERN_TYPE top_bottom_type;
    if(DetectTopBottom(index, rates_total, high, low, close, top_bottom_type)) {
        pattern_found = true;
        DrawTopBottomPattern(index, top_bottom_type);
        BufferPatternHigh[index] = high[index];
        BufferPatternLow[index] = low[index];
    }
    
    return pattern_found;
}

// Pattern Drawing Functions
void DrawFlagPattern(const int index, const bool is_bullish) {
    string name = "GeniusBryson_Flag_" + TimeToString(Time[index]);
    color pattern_color = is_bullish ? clrGreen : clrRed;
    
    // Draw flag pole
    ObjectCreate(0, name + "_Pole", OBJ_TREND, 0,
                Time[index-20], Low[index-20],
                Time[index], High[index]);
    ObjectSetInteger(0, name + "_Pole", OBJPROP_COLOR, pattern_color);
    ObjectSetInteger(0, name + "_Pole", OBJPROP_WIDTH, 2);
    
    // Draw flag channel
    ObjectCreate(0, name + "_Upper", OBJ_TREND, 0,
                Time[index-10], High[index-10],
                Time[index], High[index]);
    ObjectCreate(0, name + "_Lower", OBJ_TREND, 0,
                Time[index-10], Low[index-10],
                Time[index], Low[index]);
    ObjectSetInteger(0, name + "_Upper", OBJPROP_COLOR, pattern_color);
    ObjectSetInteger(0, name + "_Lower", OBJPROP_COLOR, pattern_color);
}

void DrawChannelPattern(const int index, const ENUM_PATTERN_TYPE channel_type) {
    string name = "GeniusBryson_Channel_" + TimeToString(Time[index]);
    color pattern_color = InpPatternColor;
    
    // Draw channel lines
    ObjectCreate(0, name + "_Upper", OBJ_TREND, 0,
                Time[index-20], High[index-20],
                Time[index], High[index]);
    ObjectCreate(0, name + "_Lower", OBJ_TREND, 0,
                Time[index-20], Low[index-20],
                Time[index], Low[index]);
    ObjectSetInteger(0, name + "_Upper", OBJPROP_COLOR, pattern_color);
    ObjectSetInteger(0, name + "_Lower", OBJPROP_COLOR, pattern_color);
}

void DrawTrianglePattern(const int index, const ENUM_PATTERN_TYPE triangle_type) {
    string name = "GeniusBryson_Triangle_" + TimeToString(Time[index]);
    color pattern_color = InpPatternColor;
    
    // Draw triangle lines based on type
    switch(triangle_type) {
        case PATTERN_TRIANGLE_ASC:
            ObjectCreate(0, name + "_Lower", OBJ_TREND, 0,
                       Time[index-20], Low[index-20],
                       Time[index], Low[index]);
            ObjectCreate(0, name + "_Upper", OBJ_TREND, 0,
                       Time[index-20], High[index-20],
                       Time[index], High[index-20]);
            break;
            
        case PATTERN_TRIANGLE_DESC:
            ObjectCreate(0, name + "_Upper", OBJ_TREND, 0,
                       Time[index-20], High[index-20],
                       Time[index], High[index]);
            ObjectCreate(0, name + "_Lower", OBJ_TREND, 0,
                       Time[index-20], Low[index-20],
                       Time[index], Low[index-20]);
            break;
            
        case PATTERN_TRIANGLE_SYM:
            ObjectCreate(0, name + "_Upper", OBJ_TREND, 0,
                       Time[index-20], High[index-20],
                       Time[index], (High[index] + Low[index])/2);
            ObjectCreate(0, name + "_Lower", OBJ_TREND, 0,
                       Time[index-20], Low[index-20],
                       Time[index], (High[index] + Low[index])/2);
            break;
    }
    
    ObjectSetInteger(0, name + "_Upper", OBJPROP_COLOR, pattern_color);
    ObjectSetInteger(0, name + "_Lower", OBJPROP_COLOR, pattern_color);
}

void DrawHeadAndShouldersPattern(const int index, const bool is_inverse) {
    string name = "GeniusBryson_HS_" + TimeToString(Time[index]);
    color pattern_color = InpPatternColor;
    
    // Draw neckline
    ObjectCreate(0, name + "_Neckline", OBJ_TREND, 0,
                Time[index-20], is_inverse ? High[index-20] : Low[index-20],
                Time[index], is_inverse ? High[index] : Low[index]);
    ObjectSetInteger(0, name + "_Neckline", OBJPROP_COLOR, pattern_color);
    
    // Draw head and shoulders points
    for(int i = 0; i < 3; i++) {
        ObjectCreate(0, name + "_Point" + IntegerToString(i), OBJ_ARROW,
                    0, Time[index-15+i*5], 
                    is_inverse ? Low[index-15+i*5] : High[index-15+i*5]);
        ObjectSetInteger(0, name + "_Point" + IntegerToString(i),
                        OBJPROP_ARROWCODE, 159);
        ObjectSetInteger(0, name + "_Point" + IntegerToString(i),
                        OBJPROP_COLOR, pattern_color);
    }
}

void DrawTopBottomPattern(const int index, const ENUM_PATTERN_TYPE pattern_type) {
    string name = "GeniusBryson_TB_" + TimeToString(Time[index]);
    color pattern_color = InpPatternColor;
    
    bool is_top = (pattern_type == PATTERN_DOUBLE_TOP || 
                   pattern_type == PATTERN_TRIPLE_TOP);
    int points = (pattern_type == PATTERN_DOUBLE_TOP || 
                 pattern_type == PATTERN_DOUBLE_BOTTOM) ? 2 : 3;
    
    // Draw resistance/support line
    ObjectCreate(0, name + "_Line", OBJ_TREND, 0,
                Time[index-20], is_top ? High[index-20] : Low[index-20],
                Time[index], is_top ? High[index] : Low[index]);
    ObjectSetInteger(0, name + "_Line", OBJPROP_COLOR, pattern_color);
    
    // Draw pattern points
    for(int i = 0; i < points; i++) {
        ObjectCreate(0, name + "_Point" + IntegerToString(i), OBJ_ARROW,
                    0, Time[index-15+i*5],
                    is_top ? High[index-15+i*5] : Low[index-15+i*5]);
        ObjectSetInteger(0, name + "_Point" + IntegerToString(i),
                        OBJPROP_ARROWCODE, 159);
        ObjectSetInteger(0, name + "_Point" + IntegerToString(i),
                        OBJPROP_COLOR, pattern_color);
    }
}

//+------------------------------------------------------------------+
//| Pattern Analysis Function                                          |
//+------------------------------------------------------------------+
void AnalyzePattern(const int index,
                   const int rates_total,
                   const double &open[],
                   const double &high[],
                   const double &low[],
                   const double &close[]) {
    // Pattern analysis logic will be implemented here
}

//+------------------------------------------------------------------+
//| Supply/Demand Zone Detection                                       |
//+------------------------------------------------------------------+
void DetectSupplyDemandZones(const int index,
                            const int rates_total,
                            const double &high[],
                            const double &low[],
                            const double &close[]) {
    // Supply/Demand zone detection logic will be implemented here
}

//+------------------------------------------------------------------+
//| Fibonacci Level Calculation                                        |
//+------------------------------------------------------------------+
void CalculateFibonacciLevels(const int index,
                             const int rates_total,
                             const double &high[],
                             const double &low[]) {
    // Fibonacci calculation logic will be implemented here
}

//+------------------------------------------------------------------+
//| Signal Generation Function                                         |
//+------------------------------------------------------------------+
void GenerateSignals(const int index,
                    const int rates_total,
                    const double &open[],
                    const double &high[],
                    const double &low[],
                    const double &close[]) {
    // Signal generation logic will be implemented here
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    // Cleanup objects and resources
    ObjectsDeleteAll(0, "GeniusBryson_");
}
