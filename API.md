# Genius_Bryson API Documentation

## Overview

This document provides detailed information about integrating and using the Genius_Bryson indicator in your MetaTrader 5 trading system.

## Table of Contents

1. [Installation](#installation)
2. [Core Components](#core-components)
3. [Pattern Recognition API](#pattern-recognition-api)
4. [Zone Detection API](#zone-detection-api)
5. [Fibonacci Analysis API](#fibonacci-analysis-api)
6. [Signal Generation API](#signal-generation-api)
7. [Utility Functions](#utility-functions)
8. [Event Handling](#event-handling)
9. [Integration Examples](#integration-examples)

## Installation

```mql5
// Include the main indicator
#include <Indicators\GeniusBryson.mq5>

// Include specific components
#include <Indicators\GeniusBryson\PatternRecognition.mqh>
#include <Indicators\GeniusBryson\SupplyDemand.mqh>
#include <Indicators\GeniusBryson\Fibonacci.mqh>
#include <Indicators\GeniusBryson\SignalGenerator.mqh>
```

## Core Components

### Settings Structure

```mql5
struct GlobalSettings {
    string          Version;
    ColorScheme     Colors;
    PatternSettings Patterns;
    ZoneSettings    Zones;
    FibSettings     Fibonacci;
    SignalSettings  Signals;
    AlertSettings   Alerts;
};
```

### Initialization

```mql5
// Initialize with default settings
GlobalSettings settings;
InitializeSettings(settings);

// Custom initialization
settings.Patterns.MinPatternBars = 15;
settings.Zones.ZoneStrength = 80.0;
```

## Pattern Recognition API

### Pattern Detection

```mql5
// Flag Pattern Detection
bool DetectFlag(const int start_pos,
               const int rates_total,
               const double &high[],
               const double &low[],
               const double &close[],
               bool &is_bullish);

// Channel Pattern Detection
bool DetectChannel(const int start_pos,
                  const int rates_total,
                  const double &high[],
                  const double &low[],
                  const double &close[],
                  ENUM_PATTERN_TYPE &channel_type);

// Triangle Pattern Detection
bool DetectTriangle(const int start_pos,
                   const int rates_total,
                   const double &high[],
                   const double &low[],
                   const double &close[],
                   ENUM_PATTERN_TYPE &triangle_type);
```

### Usage Example

```mql5
bool is_bullish;
if(DetectFlag(0, rates_total, High, Low, Close, is_bullish)) {
    Print("Flag pattern detected: ", is_bullish ? "Bullish" : "Bearish");
}
```

## Zone Detection API

### Zone Structure

```mql5
struct Zone {
    datetime    start_time;
    datetime    end_time;
    double      upper_price;
    double      lower_price;
    double      strength;
    bool        is_supply;
    int         touches;
    bool        active;
};
```

### Zone Detection Methods

```mql5
// Supply Zone Detection
bool DetectSupplyZone(const int start_pos,
                     const int rates_total,
                     const double &high[],
                     const double &low[],
                     const double &close[],
                     const datetime &time[],
                     Zone &zone);

// Demand Zone Detection
bool DetectDemandZone(const int start_pos,
                     const int rates_total,
                     const double &high[],
                     const double &low[],
                     const double &close[],
                     const datetime &time[],
                     Zone &zone);
```

### Usage Example

```mql5
Zone zone;
if(DetectSupplyZone(0, rates_total, High, Low, Close, Time, zone)) {
    Print("Supply zone detected with strength: ", zone.strength);
}
```

## Fibonacci Analysis API

### Fibonacci Structure

```mql5
struct FibAnalysis {
    datetime start_time;
    datetime end_time;
    double   swing_high;
    double   swing_low;
    bool     is_uptrend;
    FibLevel levels[];
};
```

### Fibonacci Methods

```mql5
// Calculate Fibonacci Levels
void CalculateFibLevels(const double swing_high,
                       const double swing_low,
                       const bool is_uptrend,
                       FibLevel &levels[]);

// Analyze Fibonacci Retracement
bool AnalyzeFibonacci(const int start_pos,
                     const int rates_total,
                     const double &high[],
                     const double &low[],
                     const datetime &time[],
                     FibAnalysis &analysis);
```

## Signal Generation API

### Signal Structure

```mql5
struct TradeSignal {
    ENUM_SIGNAL_TYPE type;
    datetime time;
    double entry_price;
    double stop_loss;
    double take_profit;
    double strength;
    string rationale;
    ConfluenceFactor factors[];
};
```

### Signal Generation Methods

```mql5
// Generate Trading Signal
bool GenerateSignal(const int pos,
                   const double &close[],
                   const datetime &time[],
                   TradeSignal &signal);
```

## Utility Functions

### Visualization

```mql5
// Draw Pattern
void DrawPattern(const string name,
                const datetime &time[],
                const double &price[],
                const ENUM_PATTERN_TYPE pattern_type,
                const color pattern_color);

// Draw Zone
void DrawZone(const string name,
             const datetime start_time,
             const datetime end_time,
             const double upper_price,
             const double lower_price,
             const bool is_supply,
             const color zone_color);
```

### Alerts

```mql5
// Send Alert
void SendAlert(const string message,
              const bool enable_popup,
              const bool enable_sound,
              const bool enable_email,
              const bool enable_push,
              const string sound_file = "alert.wav");
```

## Event Handling

### Custom Events

```mql5
// Pattern Detection Event
void OnPatternDetected(const string pattern_name,
                      const ENUM_PATTERN_TYPE pattern_type,
                      const double confidence);

// Zone Detection Event
void OnZoneDetected(const Zone &zone);

// Signal Generation Event
void OnSignalGenerated(const TradeSignal &signal);
```

## Integration Examples

### Basic Integration

```mql5
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"

#include <Indicators\GeniusBryson.mq5>

input int      InpPatternBars = 100;
input double   InpConfidenceThreshold = 75;

int OnInit() {
    // Initialize settings
    GlobalSettings settings;
    InitializeSettings(settings);
    
    // Customize settings
    settings.Patterns.MinPatternBars = InpPatternBars;
    settings.Patterns.ConfidenceThreshold = InpConfidenceThreshold;
    
    return(INIT_SUCCEEDED);
}

void OnTick() {
    // Pattern Recognition
    bool is_bullish;
    if(DetectFlag(0, Bars, High, Low, Close, is_bullish)) {
        Print("Flag pattern detected");
    }
    
    // Zone Detection
    Zone zone;
    if(DetectSupplyZone(0, Bars, High, Low, Close, Time, zone)) {
        Print("Supply zone detected");
    }
    
    // Signal Generation
    TradeSignal signal;
    if(GenerateSignal(0, Close, Time, signal)) {
        Print("Trading signal generated: ", EnumToString(signal.type));
    }
}
```

### Advanced Integration

```mql5
// Example of advanced integration with custom event handling
// and multiple pattern detection
void OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[]) {
    
    // Initialize analysis components
    if(prev_calculated == 0) {
        InitializeComponents();
    }
    
    // Analyze patterns
    AnalyzePatterns(rates_total, prev_calculated,
                   time, open, high, low, close);
    
    // Analyze zones
    AnalyzeZones(rates_total, prev_calculated,
                 time, open, high, low, close);
    
    // Generate signals
    GenerateSignals(rates_total, prev_calculated,
                   time, open, high, low, close);
    
    return(rates_total);
}
```

## Support

For technical support or custom integration assistance, contact:
- Email: bnyaliti@gmail.com
- Phone: +254745959794

## Version History

See [CHANGELOG.md](CHANGELOG.md) for version history and updates.
