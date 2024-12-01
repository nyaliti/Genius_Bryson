//+------------------------------------------------------------------+
//|                                              TestDataGenerator.mq5 |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"

#include <Tools/JSONParser.mqh>

// Pattern Generation Parameters
struct PatternParams {
    double trend_angle;      // Angle of trend line
    double volatility;       // Price volatility
    double noise_level;      // Random noise level
    int    pattern_bars;     // Number of bars in pattern
    bool   is_bullish;       // Pattern direction
};

// Test Data Types
enum ENUM_TEST_DATA_TYPE {
    TEST_PATTERN_FLAG,
    TEST_PATTERN_PENNANT,
    TEST_PATTERN_CHANNEL,
    TEST_PATTERN_TRIANGLE,
    TEST_PATTERN_HEAD_SHOULDERS,
    TEST_PATTERN_DOUBLE_TOP,
    TEST_ZONE_SUPPLY,
    TEST_ZONE_DEMAND,
    TEST_FIBONACCI_TREND,
    TEST_SIGNAL_BUY,
    TEST_SIGNAL_SELL
};

// Input Parameters
input group "Data Generation Settings"
input string InpOutputDir = "test_data";     // Output Directory
input int    InpDataPoints = 1000;           // Number of Data Points
input double InpVolatility = 0.001;          // Price Volatility
input double InpNoiseLevel = 0.2;            // Noise Level (0-1)

//+------------------------------------------------------------------+
//| Script program start function                                      |
//+------------------------------------------------------------------+
void OnStart() {
    // Create output directory if it doesn't exist
    if(!CreateDirectory(InpOutputDir, 0)) {
        if(GetLastError() != ERR_DIRECTORY_EXISTS) {
            Print("Failed to create output directory: ", GetLastError());
            return;
        }
    }
    
    // Generate test data for each type
    GeneratePatternData();
    GenerateZoneData();
    GenerateFibonacciData();
    GenerateSignalData();
    
    Print("Test data generation completed");
}

//+------------------------------------------------------------------+
//| Pattern Data Generation Functions                                  |
//+------------------------------------------------------------------+

// Generate pattern test data
void GeneratePatternData() {
    // Generate Flag Pattern Data
    PatternParams flag_params;
    flag_params.trend_angle = 45;
    flag_params.volatility = InpVolatility;
    flag_params.noise_level = InpNoiseLevel;
    flag_params.pattern_bars = 50;
    flag_params.is_bullish = true;
    
    GeneratePattern(TEST_PATTERN_FLAG, flag_params);
    
    // Generate Channel Pattern Data
    PatternParams channel_params;
    channel_params.trend_angle = 30;
    channel_params.volatility = InpVolatility;
    channel_params.noise_level = InpNoiseLevel;
    channel_params.pattern_bars = 100;
    channel_params.is_bullish = true;
    
    GeneratePattern(TEST_PATTERN_CHANNEL, channel_params);
    
    // Add more pattern generations as needed
}

// Generate specific pattern
void GeneratePattern(ENUM_TEST_DATA_TYPE pattern_type,
                    const PatternParams &params) {
    // Initialize arrays for price data
    double open[], high[], low[], close[];
    datetime time[];
    ArrayResize(open, params.pattern_bars);
    ArrayResize(high, params.pattern_bars);
    ArrayResize(low, params.pattern_bars);
    ArrayResize(close, params.pattern_bars);
    ArrayResize(time, params.pattern_bars);
    
    // Generate base trend
    double trend_step = MathTan(params.trend_angle * M_PI / 180.0) * 0.0001;
    double base_price = 1.2000; // Starting price
    
    for(int i = 0; i < params.pattern_bars; i++) {
        // Calculate base trend price
        double trend_price = base_price + trend_step * i;
        
        // Add pattern-specific modifications
        switch(pattern_type) {
            case TEST_PATTERN_FLAG:
                GenerateFlagPrices(i, trend_price, params, open[i], high[i], low[i], close[i]);
                break;
                
            case TEST_PATTERN_CHANNEL:
                GenerateChannelPrices(i, trend_price, params, open[i], high[i], low[i], close[i]);
                break;
                
            // Add more pattern cases
        }
        
        time[i] = TimeCurrent() + i * PeriodSeconds();
    }
    
    // Save generated data
    SaveTestData(pattern_type, time, open, high, low, close);
}

// Generate Flag Pattern Prices
void GenerateFlagPrices(const int index,
                       const double trend_price,
                       const PatternParams &params,
                       double &open,
                       double &high,
                       double &low,
                       double &close) {
    // Calculate flag channel boundaries
    double channel_height = 0.0020;
    double channel_angle = 15; // degrees
    double channel_step = MathTan(channel_angle * M_PI / 180.0) * 0.0001;
    
    // Calculate price range
    double range = params.volatility * (1.0 + RandomNoise(params.noise_level));
    
    // Calculate channel prices
    double channel_mid = trend_price - channel_step * index;
    double channel_top = channel_mid + channel_height/2;
    double channel_bottom = channel_mid - channel_height/2;
    
    // Generate OHLC prices within channel
    open = channel_mid + RandomNoise(params.noise_level) * channel_height;
    high = MathMin(channel_top, open + range);
    low = MathMax(channel_bottom, open - range);
    close = channel_mid + RandomNoise(params.noise_level) * channel_height;
}

// Generate Channel Pattern Prices
void GenerateChannelPrices(const int index,
                          const double trend_price,
                          const PatternParams &params,
                          double &open,
                          double &high,
                          double &low,
                          double &close) {
    // Calculate channel boundaries
    double channel_height = 0.0030;
    double upper_boundary = trend_price + channel_height/2;
    double lower_boundary = trend_price - channel_height/2;
    
    // Calculate price range
    double range = params.volatility * (1.0 + RandomNoise(params.noise_level));
    
    // Generate OHLC prices within channel
    open = trend_price + RandomNoise(params.noise_level) * channel_height;
    high = MathMin(upper_boundary, open + range);
    low = MathMax(lower_boundary, open - range);
    close = trend_price + RandomNoise(params.noise_level) * channel_height;
}

//+------------------------------------------------------------------+
//| Zone Data Generation Functions                                     |
//+------------------------------------------------------------------+

// Generate zone test data
void GenerateZoneData() {
    // Generate Supply Zone Data
    GenerateSupplyZoneData();
    
    // Generate Demand Zone Data
    GenerateDemandZoneData();
}

// Generate Supply Zone Data
void GenerateSupplyZoneData() {
    int bars = 200;
    double open[], high[], low[], close[];
    datetime time[];
    ArrayResize(open, bars);
    ArrayResize(high, bars);
    ArrayResize(low, bars);
    ArrayResize(close, bars);
    ArrayResize(time, bars);
    
    double base_price = 1.2000;
    double zone_height = 0.0050;
    
    for(int i = 0; i < bars; i++) {
        time[i] = TimeCurrent() + i * PeriodSeconds();
        
        if(i < 50) { // Pre-zone price action
            open[i] = base_price + RandomNoise(InpNoiseLevel) * 0.0020;
            high[i] = open[i] + InpVolatility;
            low[i] = open[i] - InpVolatility;
            close[i] = open[i] + RandomNoise(InpNoiseLevel) * 0.0020;
        }
        else if(i < 70) { // Supply zone formation
            open[i] = base_price + zone_height + RandomNoise(InpNoiseLevel) * 0.0020;
            high[i] = open[i] + InpVolatility;
            low[i] = open[i] - InpVolatility;
            close[i] = open[i] + RandomNoise(InpNoiseLevel) * 0.0020;
        }
        else { // Post-zone price action
            open[i] = base_price - zone_height/2 + RandomNoise(InpNoiseLevel) * 0.0020;
            high[i] = open[i] + InpVolatility;
            low[i] = open[i] - InpVolatility;
            close[i] = open[i] + RandomNoise(InpNoiseLevel) * 0.0020;
        }
    }
    
    SaveTestData(TEST_ZONE_SUPPLY, time, open, high, low, close);
}

//+------------------------------------------------------------------+
//| Fibonacci Data Generation Functions                                |
//+------------------------------------------------------------------+

// Generate Fibonacci test data
void GenerateFibonacciData() {
    int bars = 200;
    double open[], high[], low[], close[];
    datetime time[];
    ArrayResize(open, bars);
    ArrayResize(high, bars);
    ArrayResize(low, bars);
    ArrayResize(close, bars);
    ArrayResize(time, bars);
    
    double base_price = 1.2000;
    double trend_range = 0.0200;
    
    for(int i = 0; i < bars; i++) {
        time[i] = TimeCurrent() + i * PeriodSeconds();
        
        if(i < 50) { // Uptrend
            double trend_progress = (double)i / 50;
            open[i] = base_price + trend_range * trend_progress + RandomNoise(InpNoiseLevel) * 0.0020;
            high[i] = open[i] + InpVolatility;
            low[i] = open[i] - InpVolatility;
            close[i] = open[i] + RandomNoise(InpNoiseLevel) * 0.0020;
        }
        else { // Retracement
            double retrace_progress = (double)(i - 50) / 150;
            open[i] = base_price + trend_range - trend_range * 0.618 * retrace_progress + RandomNoise(InpNoiseLevel) * 0.0020;
            high[i] = open[i] + InpVolatility;
            low[i] = open[i] - InpVolatility;
            close[i] = open[i] + RandomNoise(InpNoiseLevel) * 0.0020;
        }
    }
    
    SaveTestData(TEST_FIBONACCI_TREND, time, open, high, low, close);
}

//+------------------------------------------------------------------+
//| Signal Data Generation Functions                                   |
//+------------------------------------------------------------------+

// Generate signal test data
void GenerateSignalData() {
    // Generate Buy Signal Data
    GenerateBuySignalData();
    
    // Generate Sell Signal Data
    GenerateSellSignalData();
}

//+------------------------------------------------------------------+
//| Utility Functions                                                 |
//+------------------------------------------------------------------+

// Generate random noise
double RandomNoise(const double level) {
    return (2.0 * MathRand() / 32768.0 - 1.0) * level;
}

// Save test data to file
void SaveTestData(const ENUM_TEST_DATA_TYPE data_type,
                 const datetime &time[],
                 const double &open[],
                 const double &high[],
                 const double &low[],
                 const double &close[]) {
    string filename = GetDataTypeString(data_type) + ".csv";
    string filepath = InpOutputDir + "//" + filename;
    
    int handle = FileOpen(filepath, FILE_WRITE|FILE_CSV);
    if(handle != INVALID_HANDLE) {
        // Write header
        FileWrite(handle, "datetime,open,high,low,close");
        
        // Write data
        for(int i = 0; i < ArraySize(time); i++) {
            FileWrite(handle,
                     TimeToString(time[i]),
                     DoubleToString(open[i], 5),
                     DoubleToString(high[i], 5),
                     DoubleToString(low[i], 5),
                     DoubleToString(close[i], 5));
        }
        
        FileClose(handle);
        Print("Generated ", filename);
    }
    else {
        Print("Failed to create file: ", filepath, " Error: ", GetLastError());
    }
}

// Get string representation of data type
string GetDataTypeString(const ENUM_TEST_DATA_TYPE data_type) {
    switch(data_type) {
        case TEST_PATTERN_FLAG:         return "flag_pattern";
        case TEST_PATTERN_PENNANT:      return "pennant_pattern";
        case TEST_PATTERN_CHANNEL:      return "channel_pattern";
        case TEST_PATTERN_TRIANGLE:     return "triangle_pattern";
        case TEST_PATTERN_HEAD_SHOULDERS: return "head_shoulders_pattern";
        case TEST_PATTERN_DOUBLE_TOP:   return "double_top_pattern";
        case TEST_ZONE_SUPPLY:          return "supply_zone";
        case TEST_ZONE_DEMAND:          return "demand_zone";
        case TEST_FIBONACCI_TREND:      return "fibonacci_trend";
        case TEST_SIGNAL_BUY:           return "buy_signal";
        case TEST_SIGNAL_SELL:          return "sell_signal";
        default:                        return "unknown";
    }
}
