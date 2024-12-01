//+------------------------------------------------------------------+
//|                                                     BasicUsage.mq5 |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"

// Include necessary files
#include "../src/GeniusBryson.mq5"

// Input parameters
input int      InpPatternBars = 100;       // Pattern Detection Bars
input double   InpConfidenceThreshold = 75; // Pattern Confidence Threshold
input bool     InpShowSupplyDemand = true;  // Show Supply/Demand Zones
input bool     InpShowFibLevels = true;     // Show Fibonacci Levels

// Global variables
GlobalSettings settings;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit() {
    // Initialize settings
    settings.Version = "1.0.0";
    settings.Patterns.MinPatternBars = InpPatternBars;
    settings.Patterns.ConfidenceThreshold = InpConfidenceThreshold;
    settings.Zones.ShowLabels = true;
    settings.Fibonacci.ShowLabels = true;
    
    // Initialize logger
    Logger.Info("Initialization", "Basic usage example started");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    // Cleanup
    RemoveAllObjects();
    Logger.Info("Deinitialization", "Basic usage example stopped");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick() {
    // Get current chart data
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(Symbol(), Period(), 0, InpPatternBars, rates);
    
    if(copied <= 0) {
        Logger.Error("Data", "Failed to copy price data");
        return;
    }
    
    // Pattern Recognition
    bool is_bullish;
    if(DetectFlag(0, copied, rates[0].high, rates[0].low, rates[0].close, is_bullish)) {
        string pattern_type = is_bullish ? "Bullish" : "Bearish";
        Logger.Info("Pattern", StringFormat("%s Flag pattern detected", pattern_type));
        
        // Draw pattern
        DrawFlagPattern("Flag_" + TimeToString(rates[0].time),
                       rates[0].time, rates[0].high,
                       is_bullish, settings.Colors.PatternLines);
    }
    
    // Supply/Demand Zone Detection
    if(InpShowSupplyDemand) {
        Zone zone;
        if(DetectSupplyZone(0, copied, rates[0].high, rates[0].low, rates[0].close,
                           rates[0].time, zone)) {
            Logger.Info("Zone", "Supply zone detected");
            
            // Draw zone
            DrawZone("Supply_" + TimeToString(rates[0].time),
                    zone.start_time, zone.end_time,
                    zone.upper_price, zone.lower_price,
                    true, settings.Colors.SupplyZone);
        }
    }
    
    // Fibonacci Analysis
    if(InpShowFibLevels) {
        FibAnalysis fib;
        if(AnalyzeFibonacci(0, copied, rates[0].high, rates[0].low,
                           rates[0].time, fib)) {
            Logger.Info("Fibonacci", "Fibonacci levels calculated");
            
            // Draw Fibonacci levels
            DrawFibonacciLevels("Fib_" + TimeToString(rates[0].time),
                               fib.start_time, fib.end_time,
                               fib.levels, settings.Colors.FibLines);
        }
    }
    
    // Signal Generation
    TradeSignal signal;
    if(GenerateSignal(0, rates[0].close, rates[0].time, signal)) {
        Logger.Info("Signal", StringFormat("Generated %s signal",
                   EnumToString(signal.type)));
        
        // Draw signal
        DrawSignal("Signal_" + TimeToString(rates[0].time),
                  signal.time, signal.entry_price,
                  signal.stop_loss, signal.take_profit,
                  signal.type, settings.Colors.StrongBuy);
        
        // Send alert
        AlertMessage alert;
        CreateSignalAlert(alert, signal.type, signal.entry_price,
                         signal.stop_loss, signal.take_profit,
                         signal.rationale);
        SendAlert(alert, settings.Alerts);
    }
}

//+------------------------------------------------------------------+
//| Custom functions                                                   |
//+------------------------------------------------------------------+

// Draw Flag Pattern
void DrawFlagPattern(const string name,
                    const datetime time,
                    const double price,
                    const bool is_bullish,
                    const color pattern_color) {
    // Implementation example
    string obj_name = PATTERN_PREFIX + name;
    
    // Draw arrow
    ObjectCreate(0, obj_name, OBJ_ARROW,0, time, price);
    ObjectSetInteger(0, obj_name, OBJPROP_ARROWCODE,
                    is_bullish ? 217 : 218);
    ObjectSetInteger(0, obj_name, OBJPROP_COLOR, pattern_color);
    
    // Add label
    string label = is_bullish ? "Bullish Flag" : "Bearish Flag";
    CreatePatternLabel(obj_name + "_Label", label,
                      time, price, pattern_color);
}

//+------------------------------------------------------------------+
//| Helper functions                                                   |
//+------------------------------------------------------------------+

// Remove all chart objects
void RemoveAllObjects() {
    ObjectsDeleteAll(0, PATTERN_PREFIX);
    ObjectsDeleteAll(0, ZONE_PREFIX);
    ObjectsDeleteAll(0, FIB_PREFIX);
    ObjectsDeleteAll(0, SIGNAL_PREFIX);
}
