//+------------------------------------------------------------------+
//|                                                        Alerts.mqh |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"

// Alert Types
enum ENUM_ALERT_TYPE {
    ALERT_PATTERN,       // Pattern Detection
    ALERT_ZONE,         // Supply/Demand Zone
    ALERT_FIBONACCI,    // Fibonacci Level
    ALERT_SIGNAL,       // Trading Signal
    ALERT_BREAKOUT,     // Pattern Breakout
    ALERT_REJECTION     // Level Rejection
};

// Alert Structure
struct AlertMessage {
    ENUM_ALERT_TYPE type;       // Alert type
    string          message;     // Alert message
    datetime        time;        // Alert time
    string          symbol;      // Trading symbol
    ENUM_TIMEFRAMES timeframe;   // Chart timeframe
    double          price;       // Current price
    string          details;     // Additional details
};

//+------------------------------------------------------------------+
//| Alert Generation Functions                                         |
//+------------------------------------------------------------------+

//--- Create Pattern Alert
void CreatePatternAlert(AlertMessage &alert,
                       const string pattern_name,
                       const string pattern_type,
                       const double confidence,
                       const bool is_complete) {
    alert.type = ALERT_PATTERN;
    alert.time = TimeCurrent();
    alert.symbol = Symbol();
    alert.timeframe = Period();
    alert.price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    
    // Format message
    alert.message = StringFormat("Pattern Alert: %s\n", pattern_name);
    alert.message += StringFormat("Symbol: %s\n", alert.symbol);
    alert.message += StringFormat("Timeframe: %s\n", EnumToString(alert.timeframe));
    alert.message += StringFormat("Pattern Type: %s\n", pattern_type);
    alert.message += StringFormat("Confidence: %.2f%%\n", confidence);
    alert.message += StringFormat("Status: %s\n", is_complete ? "Complete" : "Forming");
    alert.message += StringFormat("Price: %s\n", DoubleToString(alert.price, _Digits));
    alert.message += StringFormat("Time: %s", TimeToString(alert.time, TIME_DATE|TIME_MINUTES));
    
    alert.details = StringFormat("Pattern: %s, Type: %s, Confidence: %.2f%%",
                               pattern_name, pattern_type, confidence);
}

//--- Create Zone Alert
void CreateZoneAlert(AlertMessage &alert,
                    const bool is_supply,
                    const double zone_price,
                    const double zone_strength,
                    const string zone_status) {
    alert.type = ALERT_ZONE;
    alert.time = TimeCurrent();
    alert.symbol = Symbol();
    alert.timeframe = Period();
    alert.price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    
    string zone_type = is_supply ? "Supply" : "Demand";
    
    // Format message
    alert.message = StringFormat("%s Zone Alert\n", zone_type);
    alert.message += StringFormat("Symbol: %s\n", alert.symbol);
    alert.message += StringFormat("Timeframe: %s\n", EnumToString(alert.timeframe));
    alert.message += StringFormat("Zone Price: %s\n", DoubleToString(zone_price, _Digits));
    alert.message += StringFormat("Current Price: %s\n", DoubleToString(alert.price, _Digits));
    alert.message += StringFormat("Zone Strength: %.2f%%\n", zone_strength);
    alert.message += StringFormat("Status: %s\n", zone_status);
    alert.message += StringFormat("Time: %s", TimeToString(alert.time, TIME_DATE|TIME_MINUTES));
    
    alert.details = StringFormat("%s Zone, Price: %s, Strength: %.2f%%",
                               zone_type, DoubleToString(zone_price, _Digits), zone_strength);
}

//--- Create Fibonacci Alert
void CreateFibonacciAlert(AlertMessage &alert,
                         const double fib_level,
                         const double fib_price,
                         const string reaction_type) {
    alert.type = ALERT_FIBONACCI;
    alert.time = TimeCurrent();
    alert.symbol = Symbol();
    alert.timeframe = Period();
    alert.price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    
    // Format message
    alert.message = StringFormat("Fibonacci Level Alert\n");
    alert.message += StringFormat("Symbol: %s\n", alert.symbol);
    alert.message += StringFormat("Timeframe: %s\n", EnumToString(alert.timeframe));
    alert.message += StringFormat("Fibonacci Level: %.3f\n", fib_level);
    alert.message += StringFormat("Level Price: %s\n", DoubleToString(fib_price, _Digits));
    alert.message += StringFormat("Current Price: %s\n", DoubleToString(alert.price, _Digits));
    alert.message += StringFormat("Reaction: %s\n", reaction_type);
    alert.message += StringFormat("Time: %s", TimeToString(alert.time, TIME_DATE|TIME_MINUTES));
    
    alert.details = StringFormat("Fib %.3f, Price: %s, Reaction: %s",
                               fib_level, DoubleToString(fib_price, _Digits), reaction_type);
}

//--- Create Signal Alert
void CreateSignalAlert(AlertMessage &alert,
                      const ENUM_SIGNAL_TYPE signal_type,
                      const double entry_price,
                      const double stop_loss,
                      const double take_profit,
                      const string rationale) {
    alert.type = ALERT_SIGNAL;
    alert.time = TimeCurrent();
    alert.symbol = Symbol();
    alert.timeframe = Period();
    alert.price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    
    string signal_str = "";
    switch(signal_type) {
        case SIGNAL_STRONG_BUY:    signal_str = "Strong Buy";     break;
        case SIGNAL_MODERATE_BUY:  signal_str = "Moderate Buy";   break;
        case SIGNAL_NEUTRAL:       signal_str = "Neutral";        break;
        case SIGNAL_MODERATE_SELL: signal_str = "Moderate Sell";  break;
        case SIGNAL_STRONG_SELL:   signal_str = "Strong Sell";    break;
    }
    
    // Format message
    alert.message = StringFormat("Trading Signal Alert\n");
    alert.message += StringFormat("Symbol: %s\n", alert.symbol);
    alert.message += StringFormat("Timeframe: %s\n", EnumToString(alert.timeframe));
    alert.message += StringFormat("Signal: %s\n", signal_str);
    alert.message += StringFormat("Entry: %s\n", DoubleToString(entry_price, _Digits));
    alert.message += StringFormat("Stop Loss: %s\n", DoubleToString(stop_loss, _Digits));
    alert.message += StringFormat("Take Profit: %s\n", DoubleToString(take_profit, _Digits));
    alert.message += StringFormat("Rationale: %s\n", rationale);
    alert.message += StringFormat("Time: %s", TimeToString(alert.time, TIME_DATE|TIME_MINUTES));
    
    alert.details = StringFormat("%s Signal, Entry: %s, SL: %s, TP: %s",
                               signal_str, DoubleToString(entry_price, _Digits),
                               DoubleToString(stop_loss, _Digits),
                               DoubleToString(take_profit, _Digits));
}

//--- Create Breakout Alert
void CreateBreakoutAlert(AlertMessage &alert,
                        const string pattern_name,
                        const bool is_bullish,
                        const double breakout_price,
                        const double target_price) {
    alert.type = ALERT_BREAKOUT;
    alert.time = TimeCurrent();
    alert.symbol = Symbol();
    alert.timeframe = Period();
    alert.price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    
    // Format message
    alert.message = StringFormat("Pattern Breakout Alert\n");
    alert.message += StringFormat("Symbol: %s\n", alert.symbol);
    alert.message += StringFormat("Timeframe: %s\n", EnumToString(alert.timeframe));
    alert.message += StringFormat("Pattern: %s\n", pattern_name);
    alert.message += StringFormat("Direction: %s\n", is_bullish ? "Bullish" : "Bearish");
    alert.message += StringFormat("Breakout Price: %s\n", DoubleToString(breakout_price, _Digits));
    alert.message += StringFormat("Target Price: %s\n", DoubleToString(target_price, _Digits));
    alert.message += StringFormat("Time: %s", TimeToString(alert.time, TIME_DATE|TIME_MINUTES));
    
    alert.details = StringFormat("%s Breakout, Price: %s, Target: %s",
                               pattern_name, DoubleToString(breakout_price, _Digits),
                               DoubleToString(target_price, _Digits));
}

//--- Create Rejection Alert
void CreateRejectionAlert(AlertMessage &alert,
                         const string level_type,
                         const double level_price,
                         const bool is_bullish,
                         const string confirmation) {
    alert.type = ALERT_REJECTION;
    alert.time = TimeCurrent();
    alert.symbol = Symbol();
    alert.timeframe = Period();
    alert.price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    
    // Format message
    alert.message = StringFormat("Level Rejection Alert\n");
    alert.message += StringFormat("Symbol: %s\n", alert.symbol);
    alert.message += StringFormat("Timeframe: %s\n", EnumToString(alert.timeframe));
    alert.message += StringFormat("Level Type: %s\n", level_type);
    alert.message += StringFormat("Level Price: %s\n", DoubleToString(level_price, _Digits));
    alert.message += StringFormat("Direction: %s\n", is_bullish ? "Bullish" : "Bearish");
    alert.message += StringFormat("Confirmation: %s\n", confirmation);
    alert.message += StringFormat("Time: %s", TimeToString(alert.time, TIME_DATE|TIME_MINUTES));
    
    alert.details = StringFormat("%s Rejection, Price: %s, %s",
                               level_type, DoubleToString(level_price, _Digits),
                               is_bullish ? "Bullish" : "Bearish");
}

//+------------------------------------------------------------------+
//| Alert Sending Functions                                            |
//+------------------------------------------------------------------+

//--- Send Alert
void SendAlert(const AlertMessage &alert,
              const AlertSettings &settings) {
    // Check if alert type is enabled
    bool should_alert = false;
    switch(alert.type) {
        case ALERT_PATTERN:   should_alert = settings.AlertOnPattern; break;
        case ALERT_ZONE:      should_alert = settings.AlertOnZone;    break;
        case ALERT_FIBONACCI: should_alert = settings.AlertOnFib;     break;
        case ALERT_SIGNAL:    should_alert = settings.AlertOnSignal;  break;
        case ALERT_BREAKOUT:  should_alert = settings.AlertOnPattern; break;
        case ALERT_REJECTION: should_alert = settings.AlertOnZone;    break;
    }
    
    if(!should_alert) return;
    
    // Get appropriate sound file
    string sound_file = "";
    switch(alert.type) {
        case ALERT_PATTERN:   sound_file = settings.PatternSound; break;
        case ALERT_ZONE:      sound_file = settings.ZoneSound;    break;
        case ALERT_FIBONACCI: sound_file = settings.FibSound;     break;
        case ALERT_SIGNAL:    sound_file = settings.SignalSound;  break;
        case ALERT_BREAKOUT:  sound_file = settings.PatternSound; break;
        case ALERT_REJECTION: sound_file = settings.ZoneSound;    break;
    }
    
    // Send alerts based on settings
    if(settings.EnablePopup) Alert(alert.message);
    if(settings.EnableSound) PlaySound(sound_file);
    if(settings.EnableEmail) SendMail("Genius_Bryson Alert", alert.message);
    if(settings.EnablePush) SendNotification(alert.details);
}
