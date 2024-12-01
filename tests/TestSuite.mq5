//+------------------------------------------------------------------+
//|                                                      TestSuite.mq5 |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"

#include "TestInit.mqh"
#include "../src/GeniusBryson.mq5"

// Test Categories
#define TEST_PATTERNS    0x0001
#define TEST_ZONES       0x0002
#define TEST_FIBONACCI   0x0004
#define TEST_SIGNALS     0x0008
#define TEST_ALL        0xFFFF

// Input Parameters
input group "Test Configuration"
input int    InpTestCategories = TEST_ALL;     // Test Categories (Flags)
input bool   InpGenerateReport = true;         // Generate HTML Report
input bool   InpSaveCharts = true;             // Save Test Charts
input bool   InpDetailedLogs = true;           // Enable Detailed Logging

//+------------------------------------------------------------------+
//| Script program start function                                      |
//+------------------------------------------------------------------+
void OnStart() {
    // Initialize test environment
    if(!InitializeTestEnvironment()) {
        Print("Failed to initialize test environment");
        return;
    }
    
    // Run selected test categories
    RunTestSuite();
    
    // Generate test report
    if(InpGenerateReport) {
        GenerateTestReport();
    }
    
    // Clean up
    CleanupTestEnvironment();
}

//+------------------------------------------------------------------+
//| Test Suite Functions                                               |
//+------------------------------------------------------------------+

// Run complete test suite
void RunTestSuite() {
    LogInfo("Starting test suite execution");
    datetime start_time = TimeCurrent();
    
    // Pattern Recognition Tests
    if(InpTestCategories & TEST_PATTERNS) {
        RunPatternTests();
    }
    
    // Zone Detection Tests
    if(InpTestCategories & TEST_ZONES) {
        RunZoneTests();
    }
    
    // Fibonacci Analysis Tests
    if(InpTestCategories & TEST_FIBONACCI) {
        RunFibonacciTests();
    }
    
    // Signal Generation Tests
    if(InpTestCategories & TEST_SIGNALS) {
        RunSignalTests();
    }
    
    datetime end_time = TimeCurrent();
    LogInfo(StringFormat("Test suite completed in %d seconds", 
            end_time - start_time));
}

//+------------------------------------------------------------------+
//| Pattern Recognition Tests                                          |
//+------------------------------------------------------------------+

void RunPatternTests() {
    LogInfo("Running Pattern Recognition Tests");
    
    // Load test data
    TestData data;
    if(!LoadTestData("patterns/flag_pattern.csv", data)) {
        LogError("Failed to load flag pattern test data");
        return;
    }
    
    // Test Flag Pattern Detection
    TestResult result;
    result.test_name = "Flag Pattern Detection";
    result.test_category = "pattern";
    result.time = TimeCurrent();
    
    bool is_bullish;
    result.passed = DetectFlag(0, ArraySize(data.close), data.high, data.low, 
                             data.close, is_bullish);
    
    if(result.passed) {
        result.details = StringFormat("Successfully detected %s flag pattern",
                                    is_bullish ? "bullish" : "bearish");
    }
    else {
        result.details = "Failed to detect flag pattern";
    }
    
    SaveTestResult(result);
    UpdateTestStatistics(result.passed);
    
    if(InpSaveCharts) {
        SaveChartScreenshot("FlagPattern");
    }
    
    // Add more pattern tests here
}

//+------------------------------------------------------------------+
//| Zone Detection Tests                                               |
//+------------------------------------------------------------------+

void RunZoneTests() {
    LogInfo("Running Zone Detection Tests");
    
    // Load test data
    TestData data;
    if(!LoadTestData("zones/supply_zone.csv", data)) {
        LogError("Failed to load supply zone test data");
        return;
    }
    
    // Test Supply Zone Detection
    TestResult result;
    result.test_name = "Supply Zone Detection";
    result.test_category = "zone";
    result.time = TimeCurrent();
    
    Zone zone;
    result.passed = DetectSupplyZone(0, ArraySize(data.close), data.high, 
                                   data.low, data.close, data.time, zone);
    
    if(result.passed) {
        result.details = StringFormat("Supply zone detected with strength: %.2f",
                                    zone.strength);
    }
    else {
        result.details = "Failed to detect supply zone";
    }
    
    SaveTestResult(result);
    UpdateTestStatistics(result.passed);
    
    if(InpSaveCharts) {
        SaveChartScreenshot("SupplyZone");
    }
    
    // Add more zone tests here
}

//+------------------------------------------------------------------+
//| Fibonacci Analysis Tests                                           |
//+------------------------------------------------------------------+

void RunFibonacciTests() {
    LogInfo("Running Fibonacci Analysis Tests");
    
    // Load test data
    TestData data;
    if(!LoadTestData("fibonacci/fibonacci_trend.csv", data)) {
        LogError("Failed to load Fibonacci test data");
        return;
    }
    
    // Test Fibonacci Level Calculation
    TestResult result;
    result.test_name = "Fibonacci Level Calculation";
    result.test_category = "fibonacci";
    result.time = TimeCurrent();
    
    FibAnalysis fib;
    result.passed = AnalyzeFibonacci(0, ArraySize(data.close), data.high,
                                   data.low, data.time, fib);
    
    if(result.passed) {
        result.details = StringFormat("Fibonacci levels calculated successfully. Swing High: %.5f, Swing Low: %.5f",
                                    fib.swing_high, fib.swing_low);
    }
    else {
        result.details = "Failed to calculate Fibonacci levels";
    }
    
    SaveTestResult(result);
    UpdateTestStatistics(result.passed);
    
    if(InpSaveCharts) {
        SaveChartScreenshot("FibonacciLevels");
    }
    
    // Add more Fibonacci tests here
}

//+------------------------------------------------------------------+
//| Signal Generation Tests                                            |
//+------------------------------------------------------------------+

void RunSignalTests() {
    LogInfo("Running Signal Generation Tests");
    
    // Test Buy Signal Generation
    TestData data;
    if(!LoadTestData("signals/buy_signal.csv", data)) {
        LogError("Failed to load buy signal test data");
        return;
    }
    
    TestResult result;
    result.test_name = "Buy Signal Generation";
    result.test_category = "signal";
    result.time = TimeCurrent();
    
    TradeSignal signal;
    result.passed = GenerateSignal(0, data.close, data.time, signal);
    
    if(result.passed) {
        result.details = StringFormat("Buy signal generated with strength: %.2f",
                                    signal.strength);
    }
    else {
        result.details = "Failed to generate buy signal";
    }
    
    SaveTestResult(result);
    UpdateTestStatistics(result.passed);
    
    if(InpSaveCharts) {
        SaveChartScreenshot("BuySignal");
    }
    
    // Add more signal tests here
}

//+------------------------------------------------------------------+
//| Report Generation Functions                                        |
//+------------------------------------------------------------------+

// Generate HTML test report
void GenerateTestReport() {
    LogInfo("Generating test report");
    
    // Create test results processor
    TestResultsProcessor processor;
    if(processor.GenerateReport()) {
        LogInfo("Test report generated successfully");
    }
    else {
        LogError("Failed to generate test report");
    }
}

//+------------------------------------------------------------------+
//| Error Handling Functions                                           |
//+------------------------------------------------------------------+

// Handle test errors
void HandleTestError(const string test_name, const string error_message) {
    string full_message = StringFormat("Test Error in %s: %s", 
                                     test_name, error_message);
    LogError(full_message);
    
    TestResult result;
    result.test_name = test_name;
    result.passed = false;
    result.details = error_message;
    result.time = TimeCurrent();
    
    SaveTestResult(result);
    UpdateTestStatistics(false);
}
