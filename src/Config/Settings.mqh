//+------------------------------------------------------------------+
//|                                                      Settings.mqh |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"

//+------------------------------------------------------------------+
//| Visual Settings                                                    |
//+------------------------------------------------------------------+

// Color Scheme
struct ColorScheme {
    // Background Colors
    color Background;            // Chart background
    color ForegroundText;        // Text color
    
    // Pattern Colors
    color PatternLines;          // Pattern drawing lines
    color PatternFill;           // Pattern fill color
    color PatternText;           // Pattern labels
    
    // Zone Colors
    color SupplyZone;           // Supply zone color
    color DemandZone;           // Demand zone color
    color ZoneText;             // Zone labels
    
    // Fibonacci Colors
    color FibLines;             // Fibonacci lines
    color FibZone;              // Fibonacci zone highlight
    color FibText;              // Fibonacci labels
    
    // Signal Colors
    color StrongBuy;            // Strong buy signals
    color ModerateBuy;          // Moderate buy signals
    color Neutral;              // Neutral signals
    color ModerateSell;         // Moderate sell signals
    color StrongSell;           // Strong sell signals
    
    // Trade Level Colors
    color EntryLine;            // Entry level line
    color StopLoss;             // Stop loss line
    color TakeProfit;           // Take profit line
};

// Default Color Scheme
ColorScheme DefaultColors = {
    clrWhite,       // Background
    clrBlack,       // ForegroundText
    
    clrBlue,        // PatternLines
    clrAliceBlue,   // PatternFill
    clrNavy,        // PatternText
    
    clrPink,        // SupplyZone
    clrLightGreen,  // DemandZone
    clrDarkGray,    // ZoneText
    
    clrGold,        // FibLines
    clrKhaki,       // FibZone
    clrGoldenrod,   // FibText
    
    clrLime,        // StrongBuy
    clrGreen,       // ModerateBuy
    clrGray,        // Neutral
    clrCrimson,     // ModerateSell
    clrRed,         // StrongSell
    
    clrBlue,        // EntryLine
    clrRed,         // StopLoss
    clrGreen        // TakeProfit
};

//+------------------------------------------------------------------+
//| Pattern Recognition Settings                                       |
//+------------------------------------------------------------------+

struct PatternSettings {
    // General Settings
    int     MinPatternBars;      // Minimum bars for pattern
    int     MaxPatternBars;      // Maximum bars for pattern
    double  MinPatternSize;      // Minimum pattern size in pips
    double  ConfidenceThreshold; // Minimum pattern confidence
    
    // Pattern Types to Detect
    bool    DetectFlags;         // Flag patterns
    bool    DetectPennants;      // Pennant patterns
    bool    DetectChannels;      // Channel patterns
    bool    DetectTriangles;     // Triangle patterns
    bool    DetectHS;            // Head & Shoulders
    bool    DetectDBTB;          // Double/Triple Top/Bottom
    bool    DetectRounding;      // Rounding Bottom
    bool    DetectCupHandle;     // Cup and Handle
    
    // Validation Settings
    bool    RequireVolume;       // Require volume confirmation
    bool    RequireTrend;        // Require trend alignment
    int     MinimumTouchPoints;  // Minimum touch points
};

// Default Pattern Settings
PatternSettings DefaultPatternSettings = {
    10,     // MinPatternBars
    100,    // MaxPatternBars
    50.0,   // MinPatternSize
    75.0,   // ConfidenceThreshold
    
    true,   // DetectFlags
    true,   // DetectPennants
    true,   // DetectChannels
    true,   // DetectTriangles
    true,   // DetectHS
    true,   // DetectDBTB
    true,   // DetectRounding
    true,   // DetectCupHandle
    
    true,   // RequireVolume
    true,   // RequireTrend
    3       // MinimumTouchPoints
};

//+------------------------------------------------------------------+
//| Zone Detection Settings                                           |
//+------------------------------------------------------------------+

struct ZoneSettings {
    // Zone Detection
    int     MinZoneBars;        // Minimum bars for zone
    double  ZoneStrength;       // Minimum zone strength
    double  ZoneDepthFactor;    // Zone depth calculation factor
    
    // Zone Display
    double  ZoneOpacity;        // Zone fill opacity
    bool    ShowLabels;         // Show zone labels
    bool    ShowStrength;       // Show zone strength
    
    // Zone Management
    int     MaxZoneAge;         // Maximum age in bars
    double  MergeDistance;      // Distance to merge zones
    bool    DeleteInactive;     // Delete inactive zones
};

// Default Zone Settings
ZoneSettings DefaultZoneSettings = {
    5,      // MinZoneBars
    70.0,   // ZoneStrength
    2.0,    // ZoneDepthFactor
    
    0.3,    // ZoneOpacity
    true,   // ShowLabels
    true,   // ShowStrength
    
    500,    // MaxZoneAge
    0.0010, // MergeDistance
    true    // DeleteInactive
};

//+------------------------------------------------------------------+
//| Fibonacci Settings                                                |
//+------------------------------------------------------------------+

struct FibSettings {
    // Fibonacci Levels
    bool    ShowNegative618;    // Show -0.618 level
    bool    Show000;            // Show 0.0 level
    bool    Show050;            // Show 0.5 level
    bool    Show618;            // Show 0.618 level
    bool    Show100;            // Show 1.0 level
    bool    Show1618;           // Show 1.618 level
    
    // Display Settings
    bool    ShowLabels;         // Show level labels
    bool    ShowPrices;         // Show price values
    bool    HighlightZone;      // Highlight 0.5-0.618 zone
    double  ZoneOpacity;        // Zone highlight opacity
    
    // Analysis Settings
    int     SwingLookback;      // Bars to find swing points
    double  LevelTolerance;     // Price tolerance at levels
};

// Default Fibonacci Settings
FibSettings DefaultFibSettings = {
    true,   // ShowNegative618
    true,   // Show000
    true,   // Show050
    true,   // Show618
    true,   // Show100
    true,   // Show1618
    
    true,   // ShowLabels
    true,   // ShowPrices
    true,   // HighlightZone
    0.2,    // ZoneOpacity
    
    20,     // SwingLookback
    0.0010  // LevelTolerance
};

//+------------------------------------------------------------------+
//| Signal Generation Settings                                        |
//+------------------------------------------------------------------+

struct SignalSettings {
    // Signal Requirements
    double  MinSignalStrength;  // Minimum signal strength
    int     MinConfluence;      // Minimum confluence factors
    double  MinRRRatio;         // Minimum risk-reward ratio
    
    // Risk Management
    double  MaxRiskPercent;     // Maximum risk per trade
    double  ATRMultiplierSL;    // ATR multiplier for stop loss
    double  ATRMultiplierTP;    // ATR multiplier for take profit
    
    // Display Settings
    bool    ShowSignalArrows;   // Show signal arrows
    bool    ShowTradeLevels;    // Show entry/SL/TP levels
    bool    ShowRationale;      // Show trading rationale
};

// Default Signal Settings
SignalSettings DefaultSignalSettings = {
    70.0,   // MinSignalStrength
    3,      // MinConfluence
    1.5,    // MinRRRatio
    
    2.0,    // MaxRiskPercent
    2.0,    // ATRMultiplierSL
    3.0,    // ATRMultiplierTP
    
    true,   // ShowSignalArrows
    true,   // ShowTradeLevels
    true    // ShowRationale
};

//+------------------------------------------------------------------+
//| Alert Settings                                                    |
//+------------------------------------------------------------------+

struct AlertSettings {
    // Alert Types
    bool    EnablePopup;        // Enable popup alerts
    bool    EnableSound;        // Enable sound alerts
    bool    EnableEmail;        // Enable email alerts
    bool    EnablePush;         // Enable push notifications
    
    // Alert Conditions
    bool    AlertOnPattern;     // Alert on pattern detection
    bool    AlertOnZone;        // Alert on zone touch
    bool    AlertOnFib;         // Alert on Fibonacci level
    bool    AlertOnSignal;      // Alert on trading signal
    
    // Sound Settings
    string  PatternSound;       // Pattern alert sound
    string  ZoneSound;          // Zone alert sound
    string  FibSound;           // Fibonacci alert sound
    string  SignalSound;        // Signal alert sound
};

// Default Alert Settings
AlertSettings DefaultAlertSettings = {
    true,   // EnablePopup
    true,   // EnableSound
    false,  // EnableEmail
    false,  // EnablePush
    
    true,   // AlertOnPattern
    true,   // AlertOnZone
    true,   // AlertOnFib
    true,   // AlertOnSignal
    
    "alert.wav",    // PatternSound
    "alert2.wav",   // ZoneSound
    "alert3.wav",   // FibSound
    "alert4.wav"    // SignalSound
};

//+------------------------------------------------------------------+
//| Global Settings Structure                                         |
//+------------------------------------------------------------------+

struct GlobalSettings {
    string          Version;            // Indicator version
    ColorScheme     Colors;             // Color settings
    PatternSettings Patterns;           // Pattern settings
    ZoneSettings    Zones;              // Zone settings
    FibSettings     Fibonacci;          // Fibonacci settings
    SignalSettings  Signals;            // Signal settings
    AlertSettings   Alerts;             // Alert settings
};

// Initialize Global Settings
GlobalSettings Settings = {
    "1.0.0",               // Version
    DefaultColors,         // Colors
    DefaultPatternSettings,// Patterns
    DefaultZoneSettings,   // Zones
    DefaultFibSettings,    // Fibonacci
    DefaultSignalSettings, // Signals
    DefaultAlertSettings  // Alerts
};
