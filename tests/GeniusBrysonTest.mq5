//+------------------------------------------------------------------+
//|                                               GeniusBrysonTest.mq5 |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"

// Include necessary files
#include "../src/GeniusBryson.mq5"
#include "../src/Patterns/PatternRecognition.mqh"
#include "../src/Zones/SupplyDemand.mqh"
#include "../src/Analysis/Fibonacci.mqh"
#include "../src/Signals/SignalGenerator.mqh"
#include "../src/Utils/Helpers.mqh"
#include "../src/Utils/Logger.mqh"

// Test result structure
struct TestResult {
    string test_name;
    bool passed;
    string message;
};

// Global variables
TestResult results[];
int total_tests = 0;
int passed_tests = 0;

//+------------------------------------------------------------------+
//| Test Framework Functions                                           |
//+------------------------------------------------------------------+

//--- Initialize Test
void InitTest() {
    Print("Starting Genius_Bryson Tests...");
    ArrayResize(results, 0);
}

//--- Add Test Result
void AddTestResult(const string test_name,
                  const bool passed,
                  const string message = "") {
    int size = ArraySize(results);
    ArrayResize(results, size + 1);
    
    results[size].test_name = test_name;
    results[size].passed = passed;
    results[size].message = message;
    
    total_tests++;
    if(passed) passed_tests++;
}

//--- Print Test Results
void PrintTestResults() {
    Print("\nTest Results Summary:");
    Print("--------------------");
    Print(StringFormat("Total Tests: %d", total_tests));
    Print(StringFormat("Passed: %d", passed_tests));
    Print(StringFormat("Failed: %d", total_tests - passed_tests));
    Print(StringFormat("Success Rate: %.2f%%", (passed_tests * 100.0) / total_tests));
    Print("\nDetailed Results:");
    Print("----------------");
    
    for(int i = 0; i < ArraySize(results); i++) {
        string status = results[i].passed ? "PASSED" : "FAILED";
        Print(StringFormat("[%s] %s %s",
                          status,
                          results[i].test_name,
                          results[i].message != "" ? "- " + results[i].message : ""));
    }
}

//+------------------------------------------------------------------+
//| Pattern Recognition Tests                                          |
//+------------------------------------------------------------------+

//--- Test Flag Pattern Detection
void TestFlagPattern() {
    // Prepare test data
    double high[] = {1.2000, 1.2100, 1.2200, 1.2150, 1.2100};
    double low[]  = {1.1900, 1.2000, 1.2100, 1.2050, 1.2000};
    double close[]= {1.1950, 1.2050, 1.2150, 1.2100, 1.2050};
    bool is_bullish;
    
    // Test bullish flag detection
    bool result = DetectFlag(0, ArraySize(high), high, low, close, is_bullish);
    AddTestResult("Bullish Flag Detection",
                 result && is_bullish,
                 result ? "Successfully detected bullish flag" : "Failed to detect bullish flag");
}

//--- Test Channel Pattern Detection
void TestChannelPattern() {
    // Prepare test data
    double high[] = {1.2000, 1.2100, 1.2200, 1.2300, 1.2400};
    double low[]  = {1.1900, 1.2000, 1.2100, 1.2200, 1.2300};
    double close[]= {1.1950, 1.2050, 1.2150, 1.2250, 1.2350};
    ENUM_PATTERN_TYPE channel_type;
    
    // Test ascending channel detection
    bool result = DetectChannel(0, ArraySize(high), high, low, close, channel_type);
    AddTestResult("Ascending Channel Detection",
                 result && channel_type == PATTERN_CHANNEL_ASC,
                 result ? "Successfully detected ascending channel" : "Failed to detect ascending channel");
}

//+------------------------------------------------------------------+
//| Supply/Demand Zone Tests                                          |
//+------------------------------------------------------------------+

//--- Test Supply Zone Detection
void TestSupplyZone() {
    // Prepare test data
    double high[] = {1.2000, 1.2100, 1.2200, 1.2150, 1.2100};
    double low[]  = {1.1900, 1.2000, 1.2100, 1.2050, 1.2000};
    double close[]= {1.1950, 1.2050, 1.2150, 1.2100, 1.2050};
    datetime time[]= {1,2,3,4,5}; // Dummy time values
    Zone zone;
    
    // Test supply zone detection
    bool result = DetectSupplyZone(0, ArraySize(high), high, low, close, time, zone);
    AddTestResult("Supply Zone Detection",
                 result && zone.is_supply,
                 result ? "Successfully detected supply zone" : "Failed to detect supply zone");
}

//--- Test Demand Zone Detection
void TestDemandZone() {
    // Prepare test data
    double high[] = {1.2000, 1.1900, 1.1800, 1.1850, 1.1900};
    double low[]  = {1.1900, 1.1800, 1.1700, 1.1750, 1.1800};
    double close[]= {1.1950, 1.1850, 1.1750, 1.1800, 1.1850};
    datetime time[]= {1,2,3,4,5}; // Dummy time values
    Zone zone;
    
    // Test demand zone detection
    bool result = DetectDemandZone(0, ArraySize(high), high, low, close, time, zone);
    AddTestResult("Demand Zone Detection",
                 result && !zone.is_supply,
                 result ? "Successfully detected demand zone" : "Failed to detect demand zone");
}

//+------------------------------------------------------------------+
//| Fibonacci Analysis Tests                                          |
//+------------------------------------------------------------------+

//--- Test Fibonacci Level Calculation
void TestFibonacciLevels() {
    // Prepare test data
    double high[] = {1.2000, 1.2100, 1.2200, 1.2150, 1.2100};
    double low[]  = {1.1900, 1.2000, 1.2100, 1.2050, 1.2000};
    double swing_high, swing_low;
    bool is_uptrend;
    
    // Test swing point detection
    bool result = FindSwingPoints(0, ArraySize(high), high, low, swing_high, swing_low, is_uptrend);
    AddTestResult("Fibonacci Swing Points",
                 result,
                 result ? "Successfully identified swing points" : "Failed to identify swing points");
}

//+------------------------------------------------------------------+
//| Signal Generation Tests                                           |
//+------------------------------------------------------------------+

//--- Test Signal Generation
void TestSignalGeneration() {
    // Prepare test data
    double close[] = {1.1950, 1.2050, 1.2150, 1.2100, 1.2050};
    datetime time[]= {1,2,3,4,5}; // Dummy time values
    TradeSignal signal;
    
    // Test signal generation
    bool result = GenerateSignal(0, close, time, signal);
    AddTestResult("Signal Generation",
                 result && signal.strength >= MIN_SIGNAL_STRENGTH,
                 result ? "Successfully generated trading signal" : "Failed to generate trading signal");
}

//+------------------------------------------------------------------+
//| Helper Function Tests                                             |
//+------------------------------------------------------------------+

//--- Test Price Calculations
void TestPriceCalculations() {
    // Prepare test data
    double high[] = {1.2000, 1.2100, 1.2200, 1.2150, 1.2100};
    double low[]  = {1.1900, 1.2000, 1.2100, 1.2050, 1.2000};
    double close[]= {1.1950, 1.2050, 1.2150, 1.2100, 1.2050};
    
    // Test average price calculation
    double avg_price = CalculateAveragePrice(high, low, 0);
    AddTestResult("Average Price Calculation",
                 MathAbs(avg_price - (high[0] + low[0])/2) < 0.0001,
                 "Average price calculation accuracy check");
}

//+------------------------------------------------------------------+
//| Main Test Function                                                |
//+------------------------------------------------------------------+
void OnStart() {
    InitTest();
    
    // Run pattern recognition tests
    TestFlagPattern();
    TestChannelPattern();
    
    // Run zone detection tests
    TestSupplyZone();
    TestDemandZone();
    
    // Run Fibonacci analysis tests
    TestFibonacciLevels();
    
    // Run signal generation tests
    TestSignalGeneration();
    
    // Run helper function tests
    TestPriceCalculations();
    
    // Print test results
    PrintTestResults();
}
