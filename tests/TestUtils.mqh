
//+------------------------------------------------------------------+
//|                                                      TestUtils.mqh |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"

// Test Result Structure
struct TestResult {
    string test_name;
    string test_category;
    bool passed;
    double duration;
    string details;
    datetime time;
};

// Test Data Structure
struct TestData {
    datetime time[];
    double open[];
    double high[];
    double low[];
    double close[];
    long volume[];
};

//+------------------------------------------------------------------+
//| Test Assertion Functions                                           |
//+------------------------------------------------------------------+

// Assert Equal for double values
bool AssertEqual(const string test_name,
                const double actual,
                const double expected,
                const double tolerance = 0.0001) {
    bool result = MathAbs(actual - expected) <= tolerance;
    if(!result) {
        string message = StringFormat("%s: Expected %.5f but got %.5f",
                                    test_name, expected, actual);
        LogTestFailure(test_name, message);
    }
    return result;
}

// Assert Equal for integer values
bool AssertEqual(const string test_name,
                const int actual,
                const int expected) {
    bool result = actual == expected;
    if(!result) {
        string message = StringFormat("%s: Expected %d but got %d",
                                    test_name, expected, actual);
        LogTestFailure(test_name, message);
    }
    return result;
}

// Assert Equal for boolean values
bool AssertEqual(const string test_name,
                const bool actual,
                const bool expected) {
    bool result = actual == expected;
    if(!result) {
        string message = StringFormat("%s: Expected %s but got %s",
                                    test_name,
                                    expected ? "true" : "false",
                                    actual ? "true" : "false");
        LogTestFailure(test_name, message);
    }
    return result;
}

// Assert Greater Than
bool AssertGreaterThan(const string test_name,
                      const double actual,
                      const double threshold) {
    bool result = actual > threshold;
    if(!result) {
        string message = StringFormat("%s: Expected > %.5f but got %.5f",
                                    test_name, threshold, actual);
        LogTestFailure(test_name, message);
    }
    return result;
}

// Assert Less Than
bool AssertLessThan(const string test_name,
                   const double actual,
                   const double threshold) {
    bool result = actual < threshold;
    if(!result) {
        string message = StringFormat("%s: Expected < %.5f but got %.5f",
                                    test_name, threshold, actual);
        LogTestFailure(test_name, message);
    }
    return result;
}

// Assert In Range
bool AssertInRange(const string test_name,
                  const double actual,
                  const double min_value,
                  const double max_value) {
    bool result = actual >= min_value && actual <= max_value;
    if(!result) {
        string message = StringFormat("%s: Expected value between %.5f and %.5f but got %.5f",
                                    test_name, min_value, max_value, actual);
        LogTestFailure(test_name, message);
    }
    return result;
}

//+------------------------------------------------------------------+
//| Test Data Loading Functions                                        |
//+------------------------------------------------------------------+

// Load test data from CSV file
bool LoadTestData(const string filename, TestData &data) {
    string full_path = "test_data/" + filename;
    int handle = FileOpen(full_path, FILE_READ|FILE_CSV);
    
    if(handle != INVALID_HANDLE) {
        // Skip header
        FileReadString(handle);
        
        // Count lines
        int lines = 0;
        while(!FileIsEnding(handle)) {
            FileReadString(handle);
            lines++;
        }
        
        // Reset file position
        FileSeek(handle, 0, SEEK_SET);
        FileReadString(handle); // Skip header again
        
        // Resize arrays
        ArrayResize(data.time, lines);
        ArrayResize(data.open, lines);
        ArrayResize(data.high, lines);
        ArrayResize(data.low, lines);
        ArrayResize(data.close, lines);
        ArrayResize(data.volume, lines);
        
        // Read data
        for(int i = 0; i < lines; i++) {
            data.time[i] = StringToTime(FileReadString(handle));
            data.open[i] = StringToDouble(FileReadString(handle));
            data.high[i] = StringToDouble(FileReadString(handle));
            data.low[i] = StringToDouble(FileReadString(handle));
            data.close[i] = StringToDouble(FileReadString(handle));
            data.volume[i] = StringToInteger(FileReadString(handle));
        }
        
        FileClose(handle);
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Test Result Management Functions                                   |
//+------------------------------------------------------------------+

// Save test result
void SaveTestResult(const TestResult &result) {
    string filename = StringFormat("test_results/logs/%s_%s.log",
                                 TimeToString(result.time, TIME_DATE),
                                 result.test_name);
    
    int handle = FileOpen(filename, FILE_WRITE|FILE_TXT);
    if(handle != INVALID_HANDLE) {
        FileWrite(handle, "Test Name: " + result.test_name);
        FileWrite(handle, "Category: " + result.test_category);
        FileWrite(handle, "Status: " + (result.passed ? "PASSED" : "FAILED"));
        FileWrite(handle, "Duration: " + DoubleToString(result.duration, 3) + "ms");
        FileWrite(handle, "Details: " + result.details);
        FileWrite(handle, "Time: " + TimeToString(result.time));
        FileClose(handle);
    }
}

// Log test failure
void LogTestFailure(const string test_name, const string message) {
    string filename = "test_results/logs/failures.log";
    int handle = FileOpen(filename, FILE_WRITE|FILE_TXT|FILE_ANSI);
    
    if(handle != INVALID_HANDLE) {
        FileSeek(handle, 0, SEEK_END);
        FileWrite(handle, StringFormat("[%s] %s: %s",
                                     TimeToString(TimeCurrent()),
                                     test_name,
                                     message));
        FileClose(handle);
    }
}

//+------------------------------------------------------------------+
//| Performance Measurement Functions                                  |
//+------------------------------------------------------------------+

// Measure execution time
double MeasureExecutionTime(const string test_name, void (*test_function)()) {
    uint start_time = GetTickCount();
    test_function();
    uint end_time = GetTickCount();
    
    return (end_time - start_time) / 1000.0; // Convert to seconds
}

// Measure memory usage
double MeasureMemoryUsage(const string test_name, void (*test_function)()) {
    double start_memory = TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL);
    test_function();
    double end_memory = TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL);
    
    return end_memory - start_memory; // Memory difference in bytes
}

//+------------------------------------------------------------------+
//| Test Environment Setup Functions                                   |
//+------------------------------------------------------------------+

// Initialize test environment
void InitializeTestEnvironment() {
    // Create necessary directories
    CreateDirectory("test_results/reports", 0);
    CreateDirectory("test_results/charts", 0);
    CreateDirectory("test_results/logs", 0);
    
    // Clear old test results
    CleanOldTestResults();
}

// Clean old test results
void CleanOldTestResults() {
    DeleteOldFiles("test_results/reports/", 30); // Keep last 30 days
    DeleteOldFiles("test_results/charts/", 30);
    DeleteOldFiles("test_results/logs/", 30);
}

// Delete old files
void DeleteOldFiles(const string directory, const int days) {
    string search_pattern = directory + "*.*";
    long handle = FileFindFirst(search_pattern, 0);
    
    if(handle != INVALID_HANDLE) {
        datetime cutoff_time = TimeCurrent() - days * 24 * 60 * 60;
        
        do {
            string filename = FileFindNext(handle);
            if(filename == "") break;
            
            if(FileGetInteger(directory + filename, FILE_CREATE_DATE) < cutoff_time) {
                FileDelete(directory + filename);
            }
        } while(true);
        
        FileFindClose(handle);
    }
}

//+------------------------------------------------------------------+
//| Chart Visualization Functions                                      |
//+------------------------------------------------------------------+

// Save chart screenshot
void SaveChartScreenshot(const string test_name) {
    string filename = StringFormat("test_results/charts/%s_%s.png",
                                 TimeToString(TimeCurrent(), TIME_DATE),
                                 test_name);
    ChartScreenShot(0, filename, 1024, 768, ALIGN_RIGHT);
}

// Clear chart objects
void ClearChartObjects() {
    ObjectsDeleteAll(0);
}

//+------------------------------------------------------------------+
//| Utility Functions                                                  |
//+------------------------------------------------------------------+

// Format test name
string FormatTestName(const string category, const string name) {
    return StringFormat("%s_%s", category, name);
}

// Generate random price data
void GenerateRandomPriceData(double &price[], const int size,
                           const double base_price = 1.2000,
                           const double volatility = 0.0010) {
    ArrayResize(price, size);
    price[0] = base_price;
    
    for(int i = 1; i < size; i++) {
        double random = (MathRand() / 32768.0) * 2 - 1; // Random between -1 and 1
        price[i] = price[i-1] + random * volatility;
    }
}

// Calculate percentage difference
double CalculatePercentageDiff(const double value1, const double value2) {
    if(value2 == 0) return 0;
    return (value1 - value2) / value2 * 100;
}
