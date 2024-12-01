//+------------------------------------------------------------------+
//|                                          BacktestOptimization.mq5 |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"

// Include necessary files
#include "../src/GeniusBryson.mq5"

// Optimization inputs
input group "Pattern Recognition Parameters"
input int    InpPatternBars = 100;              // Pattern Detection Bars
input double InpConfidenceMin = 65.0;           // Min Pattern Confidence
input double InpConfidenceMax = 85.0;           // Max Pattern Confidence
input double InpConfidenceStep = 5.0;           // Confidence Step

input group "Zone Detection Parameters"
input double InpZoneStrengthMin = 60.0;         // Min Zone Strength
input double InpZoneStrengthMax = 80.0;         // Max Zone Strength
input double InpZoneStrengthStep = 5.0;         // Zone Strength Step

input group "Signal Generation Parameters"
input double InpMinRRRatio = 1.5;               // Minimum Risk:Reward Ratio
input int    InpMinConfluence = 3;              // Minimum Confluence Factors

input group "Backtest Settings"
input datetime InpStartDate = D'2023.01.01';    // Backtest Start Date
input datetime InpEndDate = D'2023.12.31';      // Backtest End Date

// Statistics structure
struct BacktestStats {
    int    total_signals;
    int    winning_trades;
    int    losing_trades;
    double win_rate;
    double profit_factor;
    double max_drawdown;
    double average_win;
    double average_loss;
    double largest_win;
    double largest_loss;
    double total_profit;
    
    void Calculate() {
        if(total_signals > 0) {
            win_rate = (double)winning_trades / total_signals * 100;
            profit_factor = average_loss != 0 ? (average_win * winning_trades) / (MathAbs(average_loss) * losing_trades) : 0;
        }
    }
    
    void Reset() {
        total_signals = 0;
        winning_trades = 0;
        losing_trades = 0;
        win_rate = 0;
        profit_factor = 0;
        max_drawdown = 0;
        average_win = 0;
        average_loss = 0;
        largest_win = 0;
        largest_loss = 0;
        total_profit = 0;
    }
};

// Global variables
GlobalSettings settings;
BacktestStats stats;
double initial_deposit;
datetime current_time;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit() {
    // Initialize settings and statistics
    InitializeSettings();
    stats.Reset();
    initial_deposit = AccountInfoDouble(ACCOUNT_BALANCE);
    
    // Enable detailed logging for backtest analysis
    Logger.SetLogLevel(LOG_DEBUG);
    Logger.EnableFileOutput(true);
    
    Logger.Info("Backtest", "Starting backtest optimization");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    // Save backtest results
    SaveBacktestResults();
    Logger.Info("Backtest", "Backtest optimization completed");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick() {
    current_time = TimeCurrent();
    
    // Check if within backtest period
    if(current_time < InpStartDate || current_time > InpEndDate) {
        return;
    }
    
    // Get historical data
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(Symbol(), Period(), 0, InpPatternBars, rates);
    
    if(copied <= 0) {
        Logger.Error("Data", "Failed to copy price data");
        return;
    }
    
    // Analyze market and generate signals
    AnalyzeMarket(rates);
}

//+------------------------------------------------------------------+
//| Market Analysis Functions                                         |
//+------------------------------------------------------------------+

// Comprehensive market analysis
void AnalyzeMarket(const MqlRates &rates[]) {
    // Pattern Recognition
    if(AnalyzePatterns(rates)) {
        // Zone Analysis
        if(AnalyzeZones(rates)) {
            // Signal Generation and Evaluation
            GenerateAndEvaluateSignals(rates);
        }
    }
}

// Pattern analysis with optimization
bool AnalyzePatterns(const MqlRates &rates[]) {
    bool patterns_found = false;
    
    // Test different confidence thresholds
    for(double confidence = InpConfidenceMin;
        confidence <= InpConfidenceMax;
        confidence += InpConfidenceStep) {
        
        settings.Patterns.ConfidenceThreshold = confidence;
        
        bool is_bullish;
        if(DetectFlag(0, ArraySize(rates), rates[0].high, rates[0].low, rates[0].close, is_bullish)) {
            patterns_found = true;
            Logger.Debug("Pattern", StringFormat("Pattern detected at confidence: %.2f", confidence));
            break;
        }
    }
    
    return patterns_found;
}

// Zone analysis with optimization
bool AnalyzeZones(const MqlRates &rates[]) {
    bool zones_found = false;
    
    // Test different zone strength thresholds
    for(double strength = InpZoneStrengthMin;
        strength <= InpZoneStrengthMax;
        strength += InpZoneStrengthStep) {
        
        settings.Zones.ZoneStrength = strength;
        
        Zone zone;
        if(DetectSupplyZone(0, ArraySize(rates), rates[0].high, rates[0].low,
                           rates[0].close, rates[0].time, zone)) {
            if(zone.strength >= strength) {
                zones_found = true;
                Logger.Debug("Zone", StringFormat("Zone detected at strength: %.2f", strength));
                break;
            }
        }
    }
    
    return zones_found;
}

// Signal generation and evaluation
void GenerateAndEvaluateSignals(const MqlRates &rates[]) {
    TradeSignal signal;
    if(GenerateSignal(0, rates[0].close, rates[0].time, signal)) {
        if(ValidateSignal(signal)) {
            // Record signal for backtesting
            RecordSignal(signal, rates);
        }
    }
}

//+------------------------------------------------------------------+
//| Backtesting Functions                                             |
//+------------------------------------------------------------------+

// Record and evaluate signal
void RecordSignal(const TradeSignal &signal, const MqlRates &rates[]) {
    stats.total_signals++;
    
    // Simulate trade outcome
    double outcome = SimulateTradeOutcome(signal, rates);
    
    // Update statistics
    if(outcome > 0) {
        stats.winning_trades++;
        stats.average_win = (stats.average_win * (stats.winning_trades - 1) + outcome) / stats.winning_trades;
        stats.largest_win = MathMax(stats.largest_win, outcome);
    }
    else if(outcome < 0) {
        stats.losing_trades++;
        stats.average_loss = (stats.average_loss * (stats.losing_trades - 1) + outcome) / stats.losing_trades;
        stats.largest_loss = MathMin(stats.largest_loss, outcome);
    }
    
    stats.total_profit += outcome;
    
    // Update maximum drawdown
    double current_drawdown = CalculateDrawdown();
    stats.max_drawdown = MathMax(stats.max_drawdown, current_drawdown);
    
    // Calculate overall statistics
    stats.Calculate();
}

// Simulate trade outcome
double SimulateTradeOutcome(const TradeSignal &signal, const MqlRates &rates[]) {
    double entry = signal.entry_price;
    double stop_loss = signal.stop_loss;
    double take_profit = signal.take_profit;
    
    // Simulate future price movement
    for(int i = 1; i < ArraySize(rates); i++) {
        if(signal.type <= SIGNAL_NEUTRAL) { // Buy signal
            if(rates[i].low <= stop_loss) return -(entry - stop_loss);
            if(rates[i].high >= take_profit) return take_profit - entry;
        }
        else { // Sell signal
            if(rates[i].high >= stop_loss) return -(stop_loss - entry);
            if(rates[i].low <= take_profit) return entry - take_profit;
        }
    }
    
    return 0; // Trade still open
}

// Calculate current drawdown
double CalculateDrawdown() {
    double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double peak_balance = MathMax(initial_deposit, current_balance);
    
    return (peak_balance - current_balance) / peak_balance * 100;
}

//+------------------------------------------------------------------+
//| Results Management Functions                                      |
//+------------------------------------------------------------------+

// Save backtest results
void SaveBacktestResults() {
    string filename = "Backtest_Results_" + TimeToString(TimeCurrent()) + ".csv";
    int handle = FileOpen(filename, FILE_WRITE|FILE_CSV);
    
    if(handle != INVALID_HANDLE) {
        // Write header
        FileWrite(handle, "Parameter", "Value");
        
        // Write settings
        FileWrite(handle, "Pattern Confidence", settings.Patterns.ConfidenceThreshold);
        FileWrite(handle, "Zone Strength", settings.Zones.ZoneStrength);
        FileWrite(handle, "Minimum RR Ratio", InpMinRRRatio);
        FileWrite(handle, "Minimum Confluence", InpMinConfluence);
        
        // Write statistics
        FileWrite(handle, "Total Signals", stats.total_signals);
        FileWrite(handle, "Winning Trades", stats.winning_trades);
        FileWrite(handle, "Losing Trades", stats.losing_trades);
        FileWrite(handle, "Win Rate (%)", stats.win_rate);
        FileWrite(handle, "Profit Factor", stats.profit_factor);
        FileWrite(handle, "Maximum Drawdown (%)", stats.max_drawdown);
        FileWrite(handle, "Average Win", stats.average_win);
        FileWrite(handle, "Average Loss", stats.average_loss);
        FileWrite(handle, "Largest Win", stats.largest_win);
        FileWrite(handle, "Largest Loss", stats.largest_loss);
        FileWrite(handle, "Total Profit", stats.total_profit);
        
        FileClose(handle);
        
        Logger.Info("Results", StringFormat("Backtest results saved to %s", filename));
    }
    else {
        Logger.Error("Results", "Failed to save backtest results");
    }
}

//+------------------------------------------------------------------+
//| Helper Functions                                                   |
//+------------------------------------------------------------------+

// Initialize settings
void InitializeSettings() {
    settings.Patterns.MinPatternBars = InpPatternBars;
    settings.Patterns.ConfidenceThreshold = InpConfidenceMin;
    settings.Zones.ZoneStrength = InpZoneStrengthMin;
    settings.Signals.MinRRRatio = InpMinRRRatio;
    settings.Signals.MinConfluence = InpMinConfluence;
}

// Validate trading signal
bool ValidateSignal(const TradeSignal &signal) {
    // Check risk/reward ratio
    double rr_ratio = CalculateRiskRewardRatio(signal.entry_price,
                                             signal.stop_loss,
                                             signal.take_profit);
    if(rr_ratio < InpMinRRRatio) return false;
    
    // Check confluence factors
    int confluence_count = 0;
    for(int i = 0; i < ArraySize(signal.factors); i++) {
        if(signal.factors[i].confirmed) confluence_count++;
    }
    
    return confluence_count >= InpMinConfluence;
}
