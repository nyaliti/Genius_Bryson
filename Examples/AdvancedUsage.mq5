//+------------------------------------------------------------------+
//|                                                  AdvancedUsage.mq5 |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"

// Include necessary files
#include "../src/GeniusBryson.mq5"

// Custom Enums
enum ENUM_TRADING_MODE {
    MODE_CONSERVATIVE,    // Conservative
    MODE_MODERATE,        // Moderate
    MODE_AGGRESSIVE      // Aggressive
};

// Input Parameters
input group "Trading Parameters"
input ENUM_TRADING_MODE InpTradingMode = MODE_MODERATE;    // Trading Mode
input double InpRiskPercent = 1.0;                         // Risk Per Trade (%)
input int    InpMaxPositions = 3;                          // Maximum Open Positions

input group "Pattern Recognition"
input int    InpPatternBars = 100;                        // Pattern Detection Bars
input double InpConfidenceThreshold = 75.0;                // Pattern Confidence (%)
input bool   InpRequireVolume = true;                      // Require Volume Confirmation

input group "Zone Detection"
input double InpZoneStrength = 70.0;                       // Zone Strength Threshold
input int    InpZoneHistory = 500;                         // Zone History (bars)
input double InpZoneOpacity = 0.3;                         // Zone Opacity

input group "Fibonacci Settings"
input bool   InpShowFibZone = true;                        // Show 0.5-0.618 Zone
input color  InpFibColor = clrGold;                        // Fibonacci Line Color
input double InpFibZoneOpacity = 0.2;                      // Fibonacci Zone Opacity

input group "Alert Settings"
input bool   InpEnableAlerts = true;                       // Enable Alerts
input bool   InpEnableEmail = false;                       // Enable Email Alerts
input bool   InpEnablePush = false;                        // Enable Push Notifications

// Global Variables
GlobalSettings settings;
int positions_total = 0;
datetime last_signal_time = 0;
bool initialization_complete = false;

//+------------------------------------------------------------------+
//| Custom Trade Management Structure                                  |
//+------------------------------------------------------------------+
struct TradeManager {
    double account_balance;
    double available_margin;
    int    open_positions;
    double total_risk;
    
    void Update() {
        account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
        available_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
        open_positions = PositionsTotal();
        CalculateTotalRisk();
    }
    
    private:
    void CalculateTotalRisk() {
        total_risk = 0;
        for(int i = 0; i < PositionsTotal(); i++) {
            if(PositionSelectByTicket(PositionGetTicket(i))) {
                double position_risk = PositionGetDouble(POSITION_SL);
                if(position_risk > 0) {
                    total_risk += position_risk;
                }
            }
        }
    }
};

TradeManager trade_manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit() {
    // Initialize settings based on trading mode
    InitializeSettings();
    
    // Initialize trade manager
    trade_manager.Update();
    
    // Initialize logger with debug level for advanced monitoring
    Logger.SetLogLevel(LOG_DEBUG);
    Logger.EnableFileOutput(true);
    
    Logger.Info("Initialization", StringFormat("Advanced usage example started - Mode: %s",
               EnumToString(InpTradingMode)));
    
    initialization_complete = true;
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    RemoveAllObjects();
    Logger.Info("Deinitialization", "Advanced usage example stopped");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick() {
    if(!initialization_complete) return;
    
    // Update trade manager
    trade_manager.Update();
    
    // Check if we can take new positions
    if(trade_manager.open_positions >= InpMaxPositions) {
        return;
    }
    
    // Get current chart data
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(Symbol(), Period(), 0, InpPatternBars, rates);
    
    if(copied <= 0) {
        Logger.Error("Data", "Failed to copy price data");
        return;
    }
    
    // Advanced pattern analysis with multiple confirmations
    AnalyzeMarketConditions(rates);
}

//+------------------------------------------------------------------+
//| Market Analysis Functions                                         |
//+------------------------------------------------------------------+

// Comprehensive market analysis
void AnalyzeMarketConditions(const MqlRates &rates[]) {
    // Pattern Recognition with multiple timeframe confirmation
    if(AnalyzePatterns(rates)) {
        // Zone Analysis
        if(AnalyzeZones(rates)) {
            // Fibonacci Analysis
            if(AnalyzeFibLevels(rates)) {
                // Generate and validate signals
                GenerateTradeSignals(rates);
            }
        }
    }
}

// Pattern analysis across multiple timeframes
bool AnalyzePatterns(const MqlRates &rates[]) {
    bool patterns_found = false;
    
    // Check patterns on current timeframe
    bool is_bullish;
    if(DetectFlag(0, ArraySize(rates), rates[0].high, rates[0].low, rates[0].close, is_bullish)) {
        patterns_found = true;
        Logger.Debug("Pattern", StringFormat("Flag pattern detected on %s",
                    EnumToString(Period())));
        
        // Verify pattern on higher timeframe
        if(VerifyPatternHigherTimeframe(is_bullish)) {
            DrawAdvancedPattern("Flag", rates[0].time, rates[0].high,
                              is_bullish, settings.Colors.PatternLines);
        }
    }
    
    return patterns_found;
}

// Zone analysis with strength validation
bool AnalyzeZones(const MqlRates &rates[]) {
    bool zones_found = false;
    
    Zone zone;
    if(DetectSupplyZone(0, ArraySize(rates), rates[0].high, rates[0].low,
                        rates[0].close, rates[0].time, zone)) {
        if(zone.strength >= InpZoneStrength) {
            zones_found = true;
            Logger.Debug("Zone", StringFormat("Strong %s zone detected, Strength: %.2f",
                        zone.is_supply ? "Supply" : "Demand", zone.strength));
            
            DrawAdvancedZone(zone);
        }
    }
    
    return zones_found;
}

// Advanced Fibonacci analysis
bool AnalyzeFibLevels(const MqlRates &rates[]) {
    bool fib_valid = false;
    
    FibAnalysis fib;
    if(AnalyzeFibonacci(0, ArraySize(rates), rates[0].high, rates[0].low,
                        rates[0].time, fib)) {
        if(ValidateFibonacciLevels(fib)) {
            fib_valid = true;
            Logger.Debug("Fibonacci", "Valid Fibonacci levels detected");
            
            DrawAdvancedFibonacci(fib);
        }
    }
    
    return fib_valid;
}

// Generate and validate trade signals
void GenerateTradeSignals(const MqlRates &rates[]) {
    TradeSignal signal;
    if(GenerateSignal(0, rates[0].close, rates[0].time, signal)) {
        if(ValidateSignal(signal)) {
            Logger.Info("Signal", StringFormat("Valid %s signal generated",
                       EnumToString(signal.type)));
            
            ProcessTradeSignal(signal);
        }
    }
}

//+------------------------------------------------------------------+
//| Helper Functions                                                   |
//+------------------------------------------------------------------+

// Initialize settings based on trading mode
void InitializeSettings() {
    switch(InpTradingMode) {
        case MODE_CONSERVATIVE:
            settings.Patterns.ConfidenceThreshold = 85.0;
            settings.Signals.MinSignalStrength = 80.0;
            settings.Signals.MinRRRatio = 2.0;
            break;
            
        case MODE_AGGRESSIVE:
            settings.Patterns.ConfidenceThreshold = 65.0;
            settings.Signals.MinSignalStrength = 60.0;
            settings.Signals.MinRRRatio = 1.2;
            break;
            
        default: // MODE_MODERATE
            settings.Patterns.ConfidenceThreshold = InpConfidenceThreshold;
            settings.Signals.MinSignalStrength = 70.0;
            settings.Signals.MinRRRatio = 1.5;
    }
    
    // Common settings
    settings.Patterns.MinPatternBars = InpPatternBars;
    settings.Patterns.RequireVolume = InpRequireVolume;
    settings.Zones.ZoneStrength = InpZoneStrength;
    settings.Zones.MaxZoneAge = InpZoneHistory;
    settings.Fibonacci.HighlightZone = InpShowFibZone;
    
    // Alert settings
    settings.Alerts.EnablePopup = InpEnableAlerts;
    settings.Alerts.EnableEmail = InpEnableEmail;
    settings.Alerts.EnablePush = InpEnablePush;
}

// Verify pattern on higher timeframe
bool VerifyPatternHigherTimeframe(const bool is_bullish) {
    // Implementation for higher timeframe confirmation
    return true; // Placeholder
}

// Validate Fibonacci levels
bool ValidateFibonacciLevels(const FibAnalysis &fib) {
    // Implementation for Fibonacci validation
    return true; // Placeholder
}

// Validate trading signal
bool ValidateSignal(const TradeSignal &signal) {
    // Check signal strength
    if(signal.strength < settings.Signals.MinSignalStrength) {
        return false;
    }
    
    // Check risk/reward ratio
    double rr_ratio = CalculateRiskRewardRatio(signal.entry_price,
                                             signal.stop_loss,
                                             signal.take_profit);
    if(rr_ratio < settings.Signals.MinRRRatio) {
        return false;
    }
    
    // Check time between signals
    if(TimeCurrent() - last_signal_time < PeriodSeconds() * 10) {
        return false;
    }
    
    return true;
}

// Process valid trade signal
void ProcessTradeSignal(const TradeSignal &signal) {
    // Update last signal time
    last_signal_time = TimeCurrent();
    
    // Draw signal visualization
    DrawAdvancedSignal(signal);
    
    // Send alerts
    if(InpEnableAlerts) {
        AlertMessage alert;
        CreateSignalAlert(alert, signal.type, signal.entry_price,
                         signal.stop_loss, signal.take_profit,
                         signal.rationale);
        SendAlert(alert, settings.Alerts);
    }
    
    // Log signal details
    Logger.Info("Signal", StringFormat("Signal processed - Type: %s, Entry: %.5f, SL: %.5f, TP: %.5f",
               EnumToString(signal.type), signal.entry_price,
               signal.stop_loss, signal.take_profit));
}

//+------------------------------------------------------------------+
//| Advanced Drawing Functions                                         |
//+------------------------------------------------------------------+

// Draw advanced pattern visualization
void DrawAdvancedPattern(const string name,
                        const datetime time,
                        const double price,
                        const bool is_bullish,
                        const color pattern_color) {
    // Implementation for advanced pattern visualization
}

// Draw advanced zone visualization
void DrawAdvancedZone(const Zone &zone) {
    // Implementation for advanced zone visualization
}

// Draw advanced Fibonacci visualization
void DrawAdvancedFibonacci(const FibAnalysis &fib) {
    // Implementation for advanced Fibonacci visualization
}

// Draw advanced signal visualization
void DrawAdvancedSignal(const TradeSignal &signal) {
    // Implementation for advanced signal visualization
}
