//+------------------------------------------------------------------+
//|                                                       TestInit.mqh |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"

#include "TestUtils.mqh"

// Test Configuration Structure
struct TestConfig {
    // General Settings
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    datetime start_date;
    datetime end_date;
    double initial_deposit;
    string currency;
    
    // Pattern Recognition Settings
    int min_pattern_bars;
    int max_pattern_bars;
    double confidence_threshold;
    bool require_volume;
    
    // Zone Detection Settings
    double zone_strength;
    double zone_depth_factor;
    int max_zone_age;
    double merge_distance;
    
    // Fibonacci Settings
    bool show_negative_618;
    bool highlight_zone;
    double zone_opacity;
    int swing_lookback;
    
    // Signal Generation Settings
    double min_signal_strength;
    int min_confluence;
    double min_rr_ratio;
    double max_risk_percent;
};

// Global Test Variables
TestConfig config;
bool test_environment_initialized = false;
string test_log_file = "test_results/logs/test_execution.log";
int total_tests = 0;
int passed_tests = 0;

//+------------------------------------------------------------------+
//| Test Environment Initialization                                    |
//+------------------------------------------------------------------+

// Initialize test environment
bool InitializeTestEnvironment() {
    if(test_environment_initialized) return true;
    
    // Load test configuration
    if(!LoadTestConfig()) {
        LogError("Failed to load test configuration");
        return false;
    }
    
    // Create necessary directories
    CreateTestDirectories();
    
    // Initialize logging
    InitializeLogging();
    
    // Clean old test results
    CleanOldTestResults();
    
    // Set up test data
    if(!SetupTestData()) {
        LogError("Failed to set up test data");
        return false;
    }
    
    test_environment_initialized = true;
    LogInfo("Test environment initialized successfully");
    return true;
}

// Load test configuration from JSON
bool LoadTestConfig() {
    string config_file = "config.json";
    string content = "";
    
    int handle = FileOpen(config_file, FILE_READ|FILE_TXT);
    if(handle != INVALID_HANDLE) {
        while(!FileIsEnding(handle)) {
            content += FileReadString(handle);
        }
        FileClose(handle);
        
        // Parse JSON and set configuration
        JSONParser parser;
        if(parser.Parse(content)) {
            JSONValue *settings = parser.GetObjectValue("test_settings");
            if(settings != NULL && settings.IsObject()) {
                // Set default settings
                config.symbol = settings.GetString("symbol", "EURUSD");
                config.timeframe = StringToTimeframe(settings.GetString("timeframe", "PERIOD_H1"));
                config.start_date = StringToTime(settings.GetString("start_date", "2023.01.01"));
                config.end_date = StringToTime(settings.GetString("end_date", "2023.12.31"));
                config.initial_deposit = settings.GetDouble("initial_deposit", 10000);
                config.currency = settings.GetString("currency", "USD");
                
                // Pattern recognition settings
                JSONValue *pattern_settings = settings.GetObjectValue("pattern_recognition");
                if(pattern_settings != NULL && pattern_settings.IsObject()) {
                    config.min_pattern_bars = (int)pattern_settings.GetNumber("min_pattern_bars", 10);
                    config.max_pattern_bars = (int)pattern_settings.GetNumber("max_pattern_bars", 100);
                    config.confidence_threshold = pattern_settings.GetDouble("confidence_threshold", 75.0);
                    config.require_volume = pattern_settings.GetBool("require_volume", true);
                }
                
                // Zone detection settings
                JSONValue *zone_settings = settings.GetObjectValue("zone_detection");
                if(zone_settings != NULL && zone_settings.IsObject()) {
                    config.zone_strength = zone_settings.GetDouble("zone_strength", 70.0);
                    config.zone_depth_factor = zone_settings.GetDouble("zone_depth_factor", 2.0);
                    config.max_zone_age = (int)zone_settings.GetNumber("max_zone_age", 500);
                    config.merge_distance = zone_settings.GetDouble("merge_distance", 0.0010);
                }
                
                return true;
            }
        }
    }
    
    return false;
}

// Create test directories
void CreateTestDirectories() {
    string directories[] = {
        "test_results/reports",
        "test_results/charts",
        "test_results/logs"
    };
    
    for(int i = 0; i < ArraySize(directories); i++) {
        CreateDirectory(directories[i], 0);
    }
}

// Initialize logging
void InitializeLogging() {
    int handle = FileOpen(test_log_file, FILE_WRITE|FILE_TXT);
    if(handle != INVALID_HANDLE) {
        FileWrite(handle, "Test Execution Log");
        FileWrite(handle, "Started: " + TimeToString(TimeCurrent()));
        FileWrite(handle, "Configuration:");
        FileWrite(handle, "Symbol: " + config.symbol);
        FileWrite(handle, "Timeframe: " + EnumToString(config.timeframe));
        FileWrite(handle, "Period: " + TimeToString(config.start_date) + 
                 " to " + TimeToString(config.end_date));
        FileClose(handle);
    }
}

// Set up test data
bool SetupTestData() {
    // Verify test data files exist
    string required_files[] = {
        "patterns/flag_pattern.csv",
        "zones/supply_zone.csv",
        "fibonacci/fibonacci_trend.csv",
        "signals/buy_signal.csv",
        "signals/sell_signal.csv"
    };
    
    for(int i = 0; i < ArraySize(required_files); i++) {
        if(!FileIsExist("test_data/" + required_files[i])) {
            LogError("Missing test data file: " + required_files[i]);
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Logging Functions                                                  |
//+------------------------------------------------------------------+

// Log information message
void LogInfo(const string message) {
    LogMessage("INFO", message);
}

// Log error message
void LogError(const string message) {
    LogMessage("ERROR", message);
}

// Log warning message
void LogWarning(const string message) {
    LogMessage("WARNING", message);
}

// Log debug message
void LogDebug(const string message) {
    LogMessage("DEBUG", message);
}

// Log message with level
void LogMessage(const string level, const string message) {
    string log_entry = StringFormat("[%s] [%s] %s",
                                  TimeToString(TimeCurrent()),
                                  level,
                                  message);
    
    int handle = FileOpen(test_log_file, FILE_WRITE|FILE_TXT|FILE_ANSI);
    if(handle != INVALID_HANDLE) {
        FileSeek(handle, 0, SEEK_END);
        FileWrite(handle, log_entry);
        FileClose(handle);
    }
    
    if(level == "ERROR") {
        Print("ERROR: " + message);
    }
}

//+------------------------------------------------------------------+
//| Utility Functions                                                  |
//+------------------------------------------------------------------+

// Convert string to timeframe
ENUM_TIMEFRAMES StringToTimeframe(const string timeframe_str) {
    if(timeframe_str == "PERIOD_M1")  return PERIOD_M1;
    if(timeframe_str == "PERIOD_M5")  return PERIOD_M5;
    if(timeframe_str == "PERIOD_M15") return PERIOD_M15;
    if(timeframe_str == "PERIOD_M30") return PERIOD_M30;
    if(timeframe_str == "PERIOD_H1")  return PERIOD_H1;
    if(timeframe_str == "PERIOD_H4")  return PERIOD_H4;
    if(timeframe_str == "PERIOD_D1")  return PERIOD_D1;
    if(timeframe_str == "PERIOD_W1")  return PERIOD_W1;
    if(timeframe_str == "PERIOD_MN1") return PERIOD_MN1;
    
    return PERIOD_H1; // Default
}

// Update test statistics
void UpdateTestStatistics(const bool test_passed) {
    total_tests++;
    if(test_passed) passed_tests++;
}

// Get test success rate
double GetTestSuccessRate() {
    return total_tests > 0 ? (double)passed_tests / total_tests * 100 : 0;
}

// Clean up test environment
void CleanupTestEnvironment() {
    if(!test_environment_initialized) return;
    
    // Log final statistics
    LogInfo(StringFormat("Test execution completed. Success rate: %.2f%% (%d/%d)",
                        GetTestSuccessRate(), passed_tests, total_tests));
    
    test_environment_initialized = false;
}
