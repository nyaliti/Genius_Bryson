//+------------------------------------------------------------------+
//|                                                     Fibonacci.mqh |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"

// Fibonacci Constants
#define FIB_LEVELS_COUNT   6       // Number of Fibonacci levels
#define FIB_SWING_DEPTH    20      // Bars to check for swing points
#define FIB_ZONE_OPACITY   0.2     // Opacity for highlighted zones

// Fibonacci Level Structure
struct FibLevel {
    double ratio;      // Fibonacci ratio
    double price;      // Price level
    color  clr;        // Level color
    string label;      // Level label
};

// Fibonacci Analysis Structure
struct FibAnalysis {
    datetime start_time;   // Analysis start time
    datetime end_time;     // Analysis end time
    double   swing_high;   // Swing high price
    double   swing_low;    // Swing low price
    bool     is_uptrend;   // Trend direction
    FibLevel levels[];     // Fibonacci levels
};

//+------------------------------------------------------------------+
//| Fibonacci Level Initialization                                     |
//+------------------------------------------------------------------+
void InitializeFibLevels(FibLevel &levels[]) {
    ArrayResize(levels, FIB_LEVELS_COUNT);
    
    // Initialize standard Fibonacci levels
    levels[0].ratio = -0.618;  levels[0].label = "-0.618";
    levels[1].ratio = 0.0;     levels[1].label = "0.0";
    levels[2].ratio = 0.5;     levels[2].label = "0.5";
    levels[3].ratio = 0.618;   levels[3].label = "0.618";
    levels[4].ratio = 1.0;     levels[4].label = "1.0";
    levels[5].ratio = 1.618;   levels[5].label = "1.618";
    
    // Set colors for each level
    levels[0].clr = clrCrimson;
    levels[1].clr = clrGold;
    levels[2].clr = clrDodgerBlue;
    levels[3].clr = clrGold;
    levels[4].clr = clrGold;
    levels[5].clr = clrForestGreen;
}

//+------------------------------------------------------------------+
//| Fibonacci Analysis Functions                                       |
//+------------------------------------------------------------------+

//--- Calculate Fibonacci Levels
void CalculateFibLevels(const double swing_high,
                       const double swing_low,
                       const bool is_uptrend,
                       FibLevel &levels[]) {
    double range = swing_high - swing_low;
    
    for(int i = 0; i < FIB_LEVELS_COUNT; i++) {
        if(is_uptrend) {
            levels[i].price = swing_low + range * levels[i].ratio;
        } else {
            levels[i].price = swing_high - range * levels[i].ratio;
        }
    }
}

//--- Find Swing Points
bool FindSwingPoints(const int start_pos,
                    const int rates_total,
                    const double &high[],
                    const double &low[],
                    double &swing_high,
                    double &swing_low,
                    bool &is_uptrend) {
    if(start_pos < FIB_SWING_DEPTH || start_pos >= rates_total) return false;
    
    swing_high = high[start_pos];
    swing_low = low[start_pos];
    int high_pos = start_pos;
    int low_pos = start_pos;
    
    // Find significant swing points
    for(int i = start_pos; i > start_pos - FIB_SWING_DEPTH; i--) {
        if(high[i] > swing_high) {
            swing_high = high[i];
            high_pos = i;
        }
        if(low[i] < swing_low) {
            swing_low = low[i];
            low_pos = i;
        }
    }
    
    // Determine trend direction
    is_uptrend = (high_pos < low_pos);
    
    return (swing_high > swing_low);
}

//--- Analyze Fibonacci Retracement
bool AnalyzeFibonacci(const int start_pos,
                     const int rates_total,
                     const double &high[],
                     const double &low[],
                     const datetime &time[],
                     FibAnalysis &analysis) {
    // Find swing points
    if(!FindSwingPoints(start_pos, rates_total, high, low,
                       analysis.swing_high, analysis.swing_low,
                       analysis.is_uptrend)) {
        return false;
    }
    
    // Set time range
    analysis.start_time = time[start_pos];
    analysis.end_time = time[start_pos - FIB_SWING_DEPTH];
    
    // Calculate Fibonacci levels
    CalculateFibLevels(analysis.swing_high, analysis.swing_low,
                      analysis.is_uptrend, analysis.levels);
    
    return true;
}

//+------------------------------------------------------------------+
//| Fibonacci Drawing Functions                                        |
//+------------------------------------------------------------------+

//--- Draw Fibonacci Levels
void DrawFibonacciLevels(const string name,
                        const FibAnalysis &analysis,
                        const color fib_color = clrGold) {
    string base_name = "Fib_" + name + "_";
    
    // Draw main Fibonacci lines
    for(int i = 0; i < FIB_LEVELS_COUNT; i++) {
        string obj_name = base_name + analysis.levels[i].label;
        
        // Create line object
        ObjectCreate(0, obj_name, OBJ_TREND, 0,
                    analysis.start_time, analysis.levels[i].price,
                    analysis.end_time, analysis.levels[i].price);
                    
        // Set line properties
        ObjectSetInteger(0, obj_name, OBJPROP_COLOR, analysis.levels[i].clr);
        ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_DOT);
        ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
        
        // Add price label
        string label_name = obj_name + "_Label";
        ObjectCreate(0, label_name, OBJ_TEXT, 0,
                    analysis.end_time, analysis.levels[i].price);
        ObjectSetString(0, label_name, OBJPROP_TEXT,
                       analysis.levels[i].label + " (" +
                       DoubleToString(analysis.levels[i].price, _Digits) + ")");
        ObjectSetInteger(0, label_name, OBJPROP_COLOR, analysis.levels[i].clr);
    }
    
    // Draw highlighted zone between 0.5 and 0.618
    string zone_name = base_name + "Zone";
    ObjectCreate(0, zone_name, OBJ_RECTANGLE, 0,
                analysis.start_time, analysis.levels[2].price,  // 0.5 level
                analysis.end_time, analysis.levels[3].price);   // 0.618 level
    ObjectSetInteger(0, zone_name, OBJPROP_COLOR, fib_color);
    ObjectSetInteger(0, zone_name, OBJPROP_FILL, true);
    ObjectSetInteger(0, zone_name, OBJPROP_BACK, true);
    ObjectSetDouble(0, zone_name, OBJPROP_TRANSPARENCY, FIB_ZONE_OPACITY * 100);
}

//--- Remove Fibonacci Objects
void RemoveFibonacciObjects(const string name) {
    string base_name = "Fib_" + name + "_";
    ObjectsDeleteAll(0, base_name);
}

//+------------------------------------------------------------------+
//| Fibonacci Analysis Helper Functions                                |
//+------------------------------------------------------------------+

//--- Check Price at Fibonacci Level
bool IsPriceAtFibLevel(const double price,
                      const FibLevel &level,
                      const double tolerance = 0.0010) {
    return (MathAbs(price - level.price) <= tolerance);
}

//--- Find Nearest Fibonacci Level
int FindNearestFibLevel(const double price,
                       const FibLevel &levels[],
                       double &distance) {
    int nearest = -1;
    distance = DBL_MAX;
    
    for(int i = 0; i < FIB_LEVELS_COUNT; i++) {
        double curr_distance = MathAbs(price - levels[i].price);
        if(curr_distance < distance) {
            distance = curr_distance;
            nearest = i;
        }
    }
    
    return nearest;
}

//--- Check Fibonacci Retracement Quality
double AssessFibonacciQuality(const FibAnalysis &analysis,
                             const double &close[],
                             const int bars_to_check) {
    int touches = 0;
    int total_bars = 0;
    
    // Count price touches of Fibonacci levels
    for(int i = 0; i < bars_to_check; i++) {
        for(int j = 0; j < FIB_LEVELS_COUNT; j++) {
            if(IsPriceAtFibLevel(close[i], analysis.levels[j])) {
                touches++;
                break;
            }
        }
        total_bars++;
    }
    
    return (touches * 100.0) / total_bars;
}
