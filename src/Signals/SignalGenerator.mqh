//+------------------------------------------------------------------+
//|                                                SignalGenerator.mqh |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"

// Signal Constants
#define MIN_SIGNAL_STRENGTH    70.0    // Minimum strength for valid signals
#define MIN_RR_RATIO          1.5     // Minimum risk-reward ratio
#define MAX_RISK_PERCENT      2.0     // Maximum risk per trade (%)
#define CONFLUENCE_THRESHOLD   3       // Minimum number of confirming factors

// Signal Types
enum ENUM_SIGNAL_TYPE {
    SIGNAL_STRONG_BUY,
    SIGNAL_MODERATE_BUY,
    SIGNAL_NEUTRAL,
    SIGNAL_MODERATE_SELL,
    SIGNAL_STRONG_SELL
};

// Confluence Factor Structure
struct ConfluenceFactor {
    string name;          // Factor name
    double weight;        // Factor weight (0-1)
    bool   confirmed;     // Whether factor is confirmed
    string description;   // Description of confirmation
};

// Trading Signal Structure
struct TradeSignal {
    ENUM_SIGNAL_TYPE type;        // Signal type
    datetime time;                // Signal time
    double entry_price;           // Suggested entry price
    double stop_loss;            // Suggested stop loss
    double take_profit;          // Suggested take profit
    double strength;             // Signal strength (0-100)
    string rationale;            // Trading rationale
    ConfluenceFactor factors[];  // Contributing factors
};

//+------------------------------------------------------------------+
//| Signal Generation Functions                                        |
//+------------------------------------------------------------------+

//--- Generate Trading Signal
bool GenerateSignal(const int pos,
                   const double &close[],
                   const datetime &time[],
                   TradeSignal &signal) {
    // Initialize confluence factors
    InitializeConfluenceFactors(signal.factors);
    
    // Analyze all confluence factors
    if(!AnalyzeConfluenceFactors(pos, close, signal.factors)) {
        return false;
    }
    
    // Calculate signal strength and type
    CalculateSignalStrength(signal);
    
    // Generate entry, stop loss, and take profit levels
    if(!CalculateTradeLevels(pos, close, signal)) {
        return false;
    }
    
    // Generate trading rationale
    GenerateRationale(signal);
    
    // Set signal time
    signal.time = time[pos];
    
    return (signal.strength >= MIN_SIGNAL_STRENGTH);
}

//--- Initialize Confluence Factors
void InitializeConfluenceFactors(ConfluenceFactor &factors[]) {
    ArrayResize(factors, 5);
    
    // Pattern Recognition Factor
    factors[0].name = "Pattern";
    factors[0].weight = 0.3;
    factors[0].confirmed = false;
    
    // Supply/Demand Zone Factor
    factors[1].name = "Zone";
    factors[1].weight = 0.25;
    factors[1].confirmed = false;
    
    // Fibonacci Factor
    factors[2].name = "Fibonacci";
    factors[2].weight = 0.2;
    factors[2].confirmed = false;
    
    // Candlestick Pattern Factor
    factors[3].name = "Candlestick";
    factors[3].weight = 0.15;
    factors[3].confirmed = false;
    
    // Volume Factor
    factors[4].name = "Volume";
    factors[4].weight = 0.1;
    factors[4].confirmed = false;
}

//--- Analyze Confluence Factors
bool AnalyzeConfluenceFactors(const int pos,
                            const double &close[],
                            ConfluenceFactor &factors[]) {
    int confirmed_count = 0;
    
    // Analyze each factor
    for(int i = 0; i < ArraySize(factors); i++) {
        switch(i) {
            case 0: // Pattern Recognition
                factors[i].confirmed = AnalyzePatternFactor(pos, close, factors[i].description);
                break;
                
            case 1: // Supply/Demand Zone
                factors[i].confirmed = AnalyzeZoneFactor(pos, close, factors[i].description);
                break;
                
            case 2: // Fibonacci
                factors[i].confirmed = AnalyzeFibonacciFactor(pos, close, factors[i].description);
                break;
                
            case 3: // Candlestick Pattern
                factors[i].confirmed = AnalyzeCandlestickFactor(pos, close, factors[i].description);
                break;
                
            case 4: // Volume
                factors[i].confirmed = AnalyzeVolumeFactor(pos, close, factors[i].description);
                break;
        }
        
        if(factors[i].confirmed) confirmed_count++;
    }
    
    return (confirmed_count >= CONFLUENCE_THRESHOLD);
}

//--- Calculate Signal Strength
void CalculateSignalStrength(TradeSignal &signal) {
    double total_strength = 0;
    double total_weight = 0;
    bool is_bullish = false;
    int bullish_count = 0;
    int bearish_count = 0;
    
    // Calculate weighted strength
    for(int i = 0; i < ArraySize(signal.factors); i++) {
        if(signal.factors[i].confirmed) {
            total_strength += signal.factors[i].weight * 100;
            total_weight += signal.factors[i].weight;
            
            // Count bullish/bearish factors
            if(StringFind(signal.factors[i].description, "bullish") >= 0) {
                bullish_count++;
            }
            else if(StringFind(signal.factors[i].description, "bearish") >= 0) {
                bearish_count++;
            }
        }
    }
    
    // Calculate final strength
    signal.strength = total_weight > 0 ? total_strength / total_weight : 0;
    
    // Determine signal type
    is_bullish = (bullish_count > bearish_count);
    
    if(signal.strength >= 90) {
        signal.type = is_bullish ? SIGNAL_STRONG_BUY : SIGNAL_STRONG_SELL;
    }
    else if(signal.strength >= 70) {
        signal.type = is_bullish ? SIGNAL_MODERATE_BUY : SIGNAL_MODERATE_SELL;
    }
    else {
        signal.type = SIGNAL_NEUTRAL;
    }
}

//--- Calculate Trade Levels
bool CalculateTradeLevels(const int pos,
                         const double &close[],
                         TradeSignal &signal) {
    double atr = iATR(NULL, 0, 14, pos);
    if(atr == 0) return false;
    
    // Set entry price
    signal.entry_price = close[pos];
    
    // Calculate stop loss and take profit based on signal type
    switch(signal.type) {
        case SIGNAL_STRONG_BUY:
        case SIGNAL_MODERATE_BUY:
            signal.stop_loss = signal.entry_price - (2 * atr);
            signal.take_profit = signal.entry_price + (3 * atr);
            break;
            
        case SIGNAL_STRONG_SELL:
        case SIGNAL_MODERATE_SELL:
            signal.stop_loss = signal.entry_price + (2 * atr);
            signal.take_profit = signal.entry_price - (3 * atr);
            break;
            
        default:
            return false;
    }
    
    // Validate risk-reward ratio
    double risk = MathAbs(signal.entry_price - signal.stop_loss);
    double reward = MathAbs(signal.entry_price - signal.take_profit);
    
    return (reward / risk >= MIN_RR_RATIO);
}

//--- Generate Trading Rationale
void GenerateRationale(TradeSignal &signal) {
    string rationale = "";
    
    // Add signal type
    switch(signal.type) {
        case SIGNAL_STRONG_BUY:
            rationale = "Strong Buy Signal\n";
            break;
        case SIGNAL_MODERATE_BUY:
            rationale = "Moderate Buy Signal\n";
            break;
        case SIGNAL_STRONG_SELL:
            rationale = "Strong Sell Signal\n";
            break;
        case SIGNAL_MODERATE_SELL:
            rationale = "Moderate Sell Signal\n";
            break;
        default:
            rationale = "Neutral Signal\n";
    }
    
    // Add confluence factors
    rationale += "\nConfluence Factors:\n";
    for(int i = 0; i < ArraySize(signal.factors); i++) {
        if(signal.factors[i].confirmed) {
            rationale += "- " + signal.factors[i].name + ": " +
                        signal.factors[i].description + "\n";
        }
    }
    
    // Add trade levels
    rationale += StringFormat("\nTrade Levels:\nEntry: %.5f\nStop Loss: %.5f\nTake Profit: %.5f",
                            signal.entry_price, signal.stop_loss, signal.take_profit);
    
    // Add risk-reward ratio
    double risk = MathAbs(signal.entry_price - signal.stop_loss);
    double reward = MathAbs(signal.entry_price - signal.take_profit);
    rationale += StringFormat("\nRisk:Reward Ratio: 1:%.2f", reward/risk);
    
    signal.rationale = rationale;
}

//+------------------------------------------------------------------+
//| Factor Analysis Functions                                          |
//+------------------------------------------------------------------+

//--- Analyze Pattern Factor
bool AnalyzePatternFactor(const int pos,
                         const double &close[],
                         string &description) {
    // Pattern analysis logic here
    return false;
}

//--- Analyze Zone Factor
bool AnalyzeZoneFactor(const int pos,
                      const double &close[],
                      string &description) {
    // Zone analysis logic here
    return false;
}

//--- Analyze Fibonacci Factor
bool AnalyzeFibonacciFactor(const int pos,
                           const double &close[],
                           string &description) {
    // Fibonacci analysis logic here
    return false;
}

//--- Analyze Candlestick Factor
bool AnalyzeCandlestickFactor(const int pos,
                             const double &close[],
                             string &description) {
    // Candlestick analysis logic here
    return false;
}

//--- Analyze Volume Factor
bool AnalyzeVolumeFactor(const int pos,
                        const double &close[],
                        string &description) {
    // Volume analysis logic here
    return false;
}

//+------------------------------------------------------------------+
//| Signal Visualization Functions                                     |
//+------------------------------------------------------------------+

//--- Draw Signal on Chart
void DrawSignal(const TradeSignal &signal) {
    string base_name = "Signal_" + TimeToString(signal.time);
    color signal_color;
    
    // Set color based on signal type
    switch(signal.type) {
        case SIGNAL_STRONG_BUY:
            signal_color = clrLime;
            break;
        case SIGNAL_MODERATE_BUY:
            signal_color = clrGreen;
            break;
        case SIGNAL_STRONG_SELL:
            signal_color = clrRed;
            break;
        case SIGNAL_MODERATE_SELL:
            signal_color = clrCrimson;
            break;
        default:
            signal_color = clrGray;
    }
    
    // Draw entry arrow
    string arrow_name = base_name + "_Arrow";
    ObjectCreate(0, arrow_name, OBJ_ARROW,0, signal.time, signal.entry_price);
    ObjectSetInteger(0, arrow_name, OBJPROP_ARROWCODE,
                    (signal.type <= SIGNAL_NEUTRAL) ? 233 : 234);
    ObjectSetInteger(0, arrow_name, OBJPROP_COLOR, signal_color);
    
    // Draw stop loss and take profit lines
    string sl_name = base_name + "_SL";
    string tp_name = base_name + "_TP";
    
    ObjectCreate(0, sl_name, OBJ_HLINE, 0, signal.time, signal.stop_loss);
    ObjectCreate(0, tp_name, OBJ_HLINE, 0, signal.time, signal.take_profit);
    
    ObjectSetInteger(0, sl_name, OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, tp_name, OBJPROP_COLOR, clrGreen);
    ObjectSetInteger(0, sl_name, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, tp_name, OBJPROP_STYLE, STYLE_DOT);
}

//--- Remove Signal Objects
void RemoveSignalObjects(const datetime time) {
    string base_name = "Signal_" + TimeToString(time);
    ObjectsDeleteAll(0, base_name);
}
