//+------------------------------------------------------------------+
//|                                                 CustomPatterns.mq5 |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"

// Include necessary files
#include "../src/GeniusBryson.mq5"

// Custom Pattern Types
enum ENUM_CUSTOM_PATTERN {
    PATTERN_HARMONIC_BAT,        // Harmonic Bat Pattern
    PATTERN_HARMONIC_BUTTERFLY,  // Harmonic Butterfly Pattern
    PATTERN_HARMONIC_GARTLEY,    // Harmonic Gartley Pattern
    PATTERN_THREE_DRIVES,        // Three Drives Pattern
    PATTERN_ABCD                 // ABCD Pattern
};

// Custom Pattern Structure
struct CustomPattern {
    ENUM_CUSTOM_PATTERN type;     // Pattern type
    datetime           time[];    // Time points
    double            price[];    // Price points
    double            ratios[];   // Fibonacci ratios
    bool              is_bullish; // Pattern direction
    double            confidence; // Pattern confidence
    string            name;       // Pattern name
};

// Input Parameters
input group "Custom Pattern Settings"
input bool   InpEnableHarmonic = true;         // Enable Harmonic Patterns
input bool   InpEnableThreeDrives = true;      // Enable Three Drives Pattern
input bool   InpEnableABCD = true;             // Enable ABCD Pattern
input double InpRatioTolerance = 0.02;         // Ratio Tolerance
input int    InpLookbackBars = 100;            // Pattern Lookback Bars

// Global Variables
GlobalSettings settings;
CustomPattern custom_patterns[];

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit() {
    // Initialize settings
    settings.Version = "1.0.0";
    settings.Patterns.MinPatternBars = InpLookbackBars;
    
    Logger.Info("Initialization", "Custom patterns example started");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    RemoveAllPatternObjects();
    Logger.Info("Deinitialization", "Custom patterns example stopped");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick() {
    // Get historical data
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(Symbol(), Period(), 0, InpLookbackBars, rates);
    
    if(copied <= 0) {
        Logger.Error("Data", "Failed to copy price data");
        return;
    }
    
    // Detect custom patterns
    DetectCustomPatterns(rates);
}

//+------------------------------------------------------------------+
//| Custom Pattern Detection Functions                                 |
//+------------------------------------------------------------------+

// Main pattern detection function
void DetectCustomPatterns(const MqlRates &rates[]) {
    // Clear previous patterns
    ArrayResize(custom_patterns, 0);
    
    // Detect Harmonic patterns
    if(InpEnableHarmonic) {
        DetectHarmonicPatterns(rates);
    }
    
    // Detect Three Drives pattern
    if(InpEnableThreeDrives) {
        DetectThreeDrivesPattern(rates);
    }
    
    // Detect ABCD pattern
    if(InpEnableABCD) {
        DetectABCDPattern(rates);
    }
    
    // Process detected patterns
    ProcessDetectedPatterns();
}

// Harmonic pattern detection
void DetectHarmonicPatterns(const MqlRates &rates[]) {
    // Detect Bat Pattern
    DetectBatPattern(rates);
    
    // Detect Butterfly Pattern
    DetectButterflyPattern(rates);
    
    // Detect Gartley Pattern
    DetectGartleyPattern(rates);
}

// Bat Pattern Detection
void DetectBatPattern(const MqlRates &rates[]) {
    int size = ArraySize(rates);
    
    for(int i = 0; i < size - 4; i++) {
        // Find potential XABCD points
        double xPoint = rates[i].high;
        double aPoint = rates[i+1].low;
        double bPoint = rates[i+2].high;
        double cPoint = rates[i+3].low;
        double dPoint = rates[i+4].high;
        
        // Calculate ratios
        double ab = MathAbs(bPoint - aPoint);
        double bc = MathAbs(cPoint - bPoint);
        double cd = MathAbs(dPoint - cPoint);
        double xb = MathAbs(bPoint - xPoint);
        
        // Check Bat pattern ratios
        if(IsWithinTolerance(bc/ab, 0.382, InpRatioTolerance) &&
           IsWithinTolerance(cd/bc, 1.618, InpRatioTolerance) &&
           IsWithinTolerance(xb/ab, 0.886, InpRatioTolerance)) {
            
            // Create pattern
            CustomPattern pattern;
            pattern.type = PATTERN_HARMONIC_BAT;
            pattern.name = "Bat Pattern";
            pattern.is_bullish = dPoint > xPoint;
            
            // Store points
            ArrayResize(pattern.time, 5);
            ArrayResize(pattern.price, 5);
            
            pattern.time[0] = rates[i].time;   // X
            pattern.time[1] = rates[i+1].time; // A
            pattern.time[2] = rates[i+2].time; // B
            pattern.time[3] = rates[i+3].time; // C
            pattern.time[4] = rates[i+4].time; // D
            
            pattern.price[0] = xPoint;
            pattern.price[1] = aPoint;
            pattern.price[2] = bPoint;
            pattern.price[3] = cPoint;
            pattern.price[4] = dPoint;
            
            // Store ratios
            ArrayResize(pattern.ratios, 3);
            pattern.ratios[0] = bc/ab;  // B-C / A-B
            pattern.ratios[1] = cd/bc;  // C-D / B-C
            pattern.ratios[2] = xb/ab;  // X-B / A-B
            
            // Calculate confidence
            pattern.confidence = CalculatePatternConfidence(pattern);
            
            // Add pattern to array
            int patterns_count = ArraySize(custom_patterns);
            ArrayResize(custom_patterns, patterns_count + 1);
            custom_patterns[patterns_count] = pattern;
            
            Logger.Debug("Pattern", StringFormat("Bat pattern detected at %s",
                       TimeToString(rates[i].time)));
        }
    }
}

// Three Drives Pattern Detection
void DetectThreeDrivesPattern(const MqlRates &rates[]) {
    int size = ArraySize(rates);
    
    for(int i = 0; i < size - 6; i++) {
        // Find potential drive points
        double drive1 = rates[i].high;
        double pullback1 = rates[i+1].low;
        double drive2 = rates[i+2].high;
        double pullback2 = rates[i+3].low;
        double drive3 = rates[i+4].high;
        
        // Calculate ratios between drives
        double drive_ratio1 = MathAbs(drive2 - drive1) / MathAbs(drive1 - pullback1);
        double drive_ratio2 = MathAbs(drive3 - drive2) / MathAbs(drive2 - pullback2);
        
        // Check Three Drives pattern criteria
        if(IsWithinTolerance(drive_ratio1, 1.27, InpRatioTolerance) &&
           IsWithinTolerance(drive_ratio2, 1.27, InpRatioTolerance)) {
            
            CustomPattern pattern;
            pattern.type = PATTERN_THREE_DRIVES;
            pattern.name = "Three Drives Pattern";
            pattern.is_bullish = drive3 < drive1;
            
            // Store points
            ArrayResize(pattern.time, 6);
            ArrayResize(pattern.price, 6);
            
            pattern.time[0] = rates[i].time;   // Drive 1
            pattern.time[1] = rates[i+1].time; // Pullback 1
            pattern.time[2] = rates[i+2].time; // Drive 2
            pattern.time[3] = rates[i+3].time; // Pullback 2
            pattern.time[4] = rates[i+4].time; // Drive 3
            
            pattern.price[0] = drive1;
            pattern.price[1] = pullback1;
            pattern.price[2] = drive2;
            pattern.price[3] = pullback2;
            pattern.price[4] = drive3;
            
            // Calculate confidence
            pattern.confidence = CalculatePatternConfidence(pattern);
            
            // Add pattern
            int patterns_count = ArraySize(custom_patterns);
            ArrayResize(custom_patterns, patterns_count + 1);
            custom_patterns[patterns_count] = pattern;
            
            Logger.Debug("Pattern", StringFormat("Three Drives pattern detected at %s",
                       TimeToString(rates[i].time)));
        }
    }
}

//+------------------------------------------------------------------+
//| Pattern Analysis Functions                                         |
//+------------------------------------------------------------------+

// Calculate pattern confidence
double CalculatePatternConfidence(const CustomPattern &pattern) {
    double confidence = 100.0;
    
    // Check ratio precision
    for(int i = 0; i < ArraySize(pattern.ratios); i++) {
        double ratio_error = MathAbs(pattern.ratios[i] - GetIdealRatio(pattern.type, i));
        confidence *= (1.0 - ratio_error);
    }
    
    // Check pattern symmetry
    confidence *= CalculatePatternSymmetry(pattern);
    
    // Check volume confirmation
    confidence *= GetVolumeConfirmation(pattern);
    
    return MathMin(confidence, 100.0);
}

// Get ideal ratio for pattern type
double GetIdealRatio(ENUM_CUSTOM_PATTERN pattern_type, int ratio_index) {
    switch(pattern_type) {
        case PATTERN_HARMONIC_BAT:
            switch(ratio_index) {
                case 0: return 0.382; // B-C / A-B
                case 1: return 1.618; // C-D / B-C
                case 2: return 0.886; // X-B / A-B
            }
            break;
            
        case PATTERN_THREE_DRIVES:
            return 1.27; // All ratios should be 1.27
    }
    
    return 0.0;
}

// Calculate pattern symmetry
double CalculatePatternSymmetry(const CustomPattern &pattern) {
    double symmetry = 1.0;
    
    // Check time symmetry
    datetime time_diffs[];
    ArrayResize(time_diffs, ArraySize(pattern.time) - 1);
    
    for(int i = 0; i < ArraySize(time_diffs); i++) {
        time_diffs[i] = pattern.time[i+1] - pattern.time[i];
    }
    
    double time_std_dev = CalculateStdDev(time_diffs, 0, ArraySize(time_diffs));
    double time_mean = CalculateMA(time_diffs, 0, ArraySize(time_diffs));
    
    symmetry *= 1.0 - (time_std_dev / time_mean);
    
    return symmetry;
}

//+------------------------------------------------------------------+
//| Pattern Visualization Functions                                    |
//+------------------------------------------------------------------+

// Draw custom pattern
void DrawCustomPattern(const CustomPattern &pattern) {
    string name = StringFormat("CustomPattern_%s_%s",
                             EnumToString(pattern.type),
                             TimeToString(pattern.time[0]));
    
    // Draw pattern lines
    for(int i = 0; i < ArraySize(pattern.price) - 1; i++) {
        string line_name = name + "_Line" + IntegerToString(i);
        ObjectCreate(0, line_name, OBJ_TREND, 0,
                    pattern.time[i], pattern.price[i],
                    pattern.time[i+1], pattern.price[i+1]);
        ObjectSetInteger(0, line_name, OBJPROP_COLOR, settings.Colors.PatternLines);
        ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 1);
    }
    
    // Add pattern label
    string label = StringFormat("%s (%.1f%%)",
                              pattern.name,
                              pattern.confidence);
    CreatePatternLabel(name + "_Label", label,
                      pattern.time[ArraySize(pattern.time)-1],
                      pattern.price[ArraySize(pattern.price)-1],
                      settings.Colors.PatternText);
}

// Remove pattern objects
void RemoveAllPatternObjects() {
    ObjectsDeleteAll(0, "CustomPattern_");
}

//+------------------------------------------------------------------+
//| Helper Functions                                                   |
//+------------------------------------------------------------------+

// Check if value is within tolerance
bool IsWithinTolerance(const double value,
                      const double target,
                      const double tolerance) {
    return MathAbs(value - target) <= tolerance;
}

// Get volume confirmation
double GetVolumeConfirmation(const CustomPattern &pattern) {
    // Implementation for volume confirmation
    return 1.0; // Placeholder
}

// Process detected patterns
void ProcessDetectedPatterns() {
    for(int i = 0; i < ArraySize(custom_patterns); i++) {
        if(custom_patterns[i].confidence >= settings.Patterns.ConfidenceThreshold) {
            // Draw pattern
            DrawCustomPattern(custom_patterns[i]);
            
            // Generate signal if appropriate
            if(ShouldGenerateSignal(custom_patterns[i])) {
                GeneratePatternSignal(custom_patterns[i]);
            }
        }
    }
}

// Check if signal should be generated
bool ShouldGenerateSignal(const CustomPattern &pattern) {
    return pattern.confidence >= settings.Signals.MinSignalStrength;
}

// Generate signal from pattern
void GeneratePatternSignal(const CustomPattern &pattern) {
    TradeSignal signal;
    signal.time = pattern.time[ArraySize(pattern.time)-1];
    signal.type = pattern.is_bullish ? SIGNAL_STRONG_BUY : SIGNAL_STRONG_SELL;
    signal.strength = pattern.confidence;
    
    // Calculate entry, stop loss, and take profit
    CalculateTradePoints(pattern, signal);
    
    // Generate rationale
    signal.rationale = StringFormat("%s detected with %.1f%% confidence",
                                  pattern.name,
                                  pattern.confidence);
    
    // Process signal
    ProcessTradeSignal(signal);
}

// Calculate trade points
void CalculateTradePoints(const CustomPattern &pattern,
                         TradeSignal &signal) {
    // Implementation for calculating entry, SL, and TP levels
    // based on pattern type and structure
}

// Process trade signal
void ProcessTradeSignal(const TradeSignal &signal) {
    // Draw signal visualization
    DrawSignal(StringFormat("Signal_%s", TimeToString(signal.time)),
               signal.time,
               signal.entry_price,
               signal.stop_loss,
               signal.take_profit,
               signal.type,
               settings.Colors.StrongBuy);
    
    // Send alert
    AlertMessage alert;
    CreateSignalAlert(alert, signal.type,
                     signal.entry_price,
                     signal.stop_loss,
                     signal.take_profit,
                     signal.rationale);
    SendAlert(alert, settings.Alerts);
}
