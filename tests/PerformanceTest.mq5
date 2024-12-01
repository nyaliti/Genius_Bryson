//+------------------------------------------------------------------+
//|                                               PerformanceTest.mq5 |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"

#include "TestInit.mqh"
#include "../src/GeniusBryson.mq5"

// Performance Test Parameters
input group "Performance Test Settings"
input int    InpTestDuration = 3600;    // Test Duration (seconds)
input int    InpSampleInterval = 60;     // Sampling Interval (seconds)
input int    InpDataPoints = 1000;       // Number of Price Data Points
input bool   InpTestMemory = true;       // Test Memory Usage
input bool   InpTestCPU = true;          // Test CPU Usage
input bool   InpTestSpeed = true;        // Test Processing Speed

// Performance Metrics Structure
struct PerformanceMetrics {
    // Memory Usage
    double peak_memory;
    double avg_memory;
    double memory_samples[];
    
    // CPU Usage
    double peak_cpu;
    double avg_cpu;
    double cpu_samples[];
    
    // Processing Speed
    double avg_processing_time;
    double min_processing_time;
    double max_processing_time;
    double processing_samples[];
    
    // Pattern Detection Performance
    int patterns_detected;
    double pattern_detection_time;
    
    // Zone Detection Performance
    int zones_detected;
    double zone_detection_time;
    
    // Signal Generation Performance
    int signals_generated;
    double signal_generation_time;
};

// Global Variables
PerformanceMetrics metrics;
datetime start_time;
datetime end_time;

//+------------------------------------------------------------------+
//| Script program start function                                      |
//+------------------------------------------------------------------+
void OnStart() {
    // Initialize test environment
    if(!InitializeTestEnvironment()) {
        Print("Failed to initialize test environment");
        return;
    }
    
    // Run performance tests
    RunPerformanceTests();
    
    // Generate performance report
    GeneratePerformanceReport();
    
    // Clean up
    CleanupTestEnvironment();
}

//+------------------------------------------------------------------+
//| Performance Test Functions                                         |
//+------------------------------------------------------------------+

// Run all performance tests
void RunPerformanceTests() {
    LogInfo("Starting performance tests");
    start_time = TimeCurrent();
    
    // Initialize metrics arrays
    if(InpTestMemory) ArrayResize(metrics.memory_samples, InpTestDuration/InpSampleInterval);
    if(InpTestCPU) ArrayResize(metrics.cpu_samples, InpTestDuration/InpSampleInterval);
    if(InpTestSpeed) ArrayResize(metrics.processing_samples, InpTestDuration/InpSampleInterval);
    
    // Generate test data
    MqlRates rates[];
    GenerateTestData(rates);
    
    // Run continuous performance monitoring
    int sample_index = 0;
    datetime next_sample = TimeCurrent() + InpSampleInterval;
    
    while(TimeCurrent() - start_time < InpTestDuration) {
        // Run pattern detection test
        if(InpTestSpeed) {
            TestPatternDetectionPerformance(rates);
        }
        
        // Sample metrics
        if(TimeCurrent() >= next_sample) {
            if(InpTestMemory) {
                metrics.memory_samples[sample_index] = GetMemoryUsage();
                metrics.peak_memory = MathMax(metrics.peak_memory, 
                                           metrics.memory_samples[sample_index]);
            }
            
            if(InpTestCPU) {
                metrics.cpu_samples[sample_index] = GetCPUUsage();
                metrics.peak_cpu = MathMax(metrics.peak_cpu, 
                                        metrics.cpu_samples[sample_index]);
            }
            
            sample_index++;
            next_sample = TimeCurrent() + InpSampleInterval;
        }
    }
    
    end_time = TimeCurrent();
    
    // Calculate averages
    CalculateAverages();
}

// Generate test data
void GenerateTestData(MqlRates &rates[]) {
    ArrayResize(rates, InpDataPoints);
    datetime current_time = TimeCurrent();
    
    for(int i = 0; i < InpDataPoints; i++) {
        rates[i].time = current_time - (InpDataPoints - i) * PeriodSeconds();
        rates[i].open = 1.2000 + MathRand()/32768.0 * 0.0100;
        rates[i].high = rates[i].open + MathRand()/32768.0 * 0.0050;
        rates[i].low = rates[i].open - MathRand()/32768.0 * 0.0050;
        rates[i].close = rates[i].open + MathRand()/32768.0 * 0.0100 - 0.0050;
        rates[i].tick_volume = 1000 + MathRand() % 9000;
        rates[i].real_volume = rates[i].tick_volume;
        rates[i].spread = 1;
    }
}

// Test pattern detection performance
void TestPatternDetectionPerformance(const MqlRates &rates[]) {
    uint start_time = GetTickCount();
    
    // Test flag pattern detection
    bool is_bullish;
    if(DetectFlag(0, ArraySize(rates), rates[0].high, rates[0].low, 
                 rates[0].close, is_bullish)) {
        metrics.patterns_detected++;
    }
    
    // Test channel pattern detection
    ENUM_PATTERN_TYPE channel_type;
    if(DetectChannel(0, ArraySize(rates), rates[0].high, rates[0].low, 
                    rates[0].close, channel_type)) {
        metrics.patterns_detected++;
    }
    
    uint end_time = GetTickCount();
    double processing_time = (end_time - start_time) / 1000.0;
    
    metrics.pattern_detection_time += processing_time;
    metrics.processing_samples[metrics.patterns_detected] = processing_time;
    
    metrics.min_processing_time = (metrics.min_processing_time == 0) ? 
                                 processing_time : 
                                 MathMin(metrics.min_processing_time, processing_time);
    
    metrics.max_processing_time = MathMax(metrics.max_processing_time, processing_time);
}

// Calculate average metrics
void CalculateAverages() {
    if(InpTestMemory) {
        metrics.avg_memory = CalculateArrayAverage(metrics.memory_samples);
    }
    
    if(InpTestCPU) {
        metrics.avg_cpu = CalculateArrayAverage(metrics.cpu_samples);
    }
    
    if(InpTestSpeed) {
        metrics.avg_processing_time = metrics.pattern_detection_time / 
                                    MathMax(1, metrics.patterns_detected);
    }
}

//+------------------------------------------------------------------+
//| Report Generation Functions                                        |
//+------------------------------------------------------------------+

// Generate performance report
void GeneratePerformanceReport() {
    string report_file = "test_results/reports/performance_report_" + 
                        TimeToString(TimeCurrent()) + ".html";
    
    int handle = FileOpen(report_file, FILE_WRITE|FILE_TXT);
    if(handle != INVALID_HANDLE) {
        // Write HTML header
        WriteReportHeader(handle);
        
        // Write performance metrics
        WritePerformanceMetrics(handle);
        
        // Write charts
        WritePerformanceCharts(handle);
        
        // Write HTML footer
        WriteReportFooter(handle);
        
        FileClose(handle);
        LogInfo("Performance report generated: " + report_file);
    }
    else {
        LogError("Failed to create performance report");
    }
}

// Write report header
void WriteReportHeader(const int handle) {
    FileWrite(handle, "<html>");
    FileWrite(handle, "<head>");
    FileWrite(handle, "<title>Genius_Bryson Performance Test Report</title>");
    FileWrite(handle, "<style>");
    FileWrite(handle, "body { font-family: Arial, sans-serif; margin: 20px; }");
    FileWrite(handle, ".metric { margin: 10px 0; padding: 10px; border: 1px solid #ddd; }");
    FileWrite(handle, ".chart { width: 100%; height: 300px; margin: 20px 0; }");
    FileWrite(handle, "</style>");
    FileWrite(handle, "</head>");
    FileWrite(handle, "<body>");
    FileWrite(handle, "<h1>Performance Test Report</h1>");
    FileWrite(handle, "<p>Test Duration: " + IntegerToString(InpTestDuration) + " seconds</p>");
    FileWrite(handle, "<p>Data Points: " + IntegerToString(InpDataPoints) + "</p>");
}

// Write performance metrics
void WritePerformanceMetrics(const int handle) {
    FileWrite(handle, "<h2>Performance Metrics</h2>");
    
    if(InpTestMemory) {
        FileWrite(handle, "<div class='metric'>");
        FileWrite(handle, "<h3>Memory Usage</h3>");
        FileWrite(handle, "<p>Peak: " + DoubleToString(metrics.peak_memory/1024/1024, 2) + " MB</p>");
        FileWrite(handle, "<p>Average: " + DoubleToString(metrics.avg_memory/1024/1024, 2) + " MB</p>");
        FileWrite(handle, "</div>");
    }
    
    if(InpTestCPU) {
        FileWrite(handle, "<div class='metric'>");
        FileWrite(handle, "<h3>CPU Usage</h3>");
        FileWrite(handle, "<p>Peak: " + DoubleToString(metrics.peak_cpu, 2) + "%</p>");
        FileWrite(handle, "<p>Average: " + DoubleToString(metrics.avg_cpu, 2) + "%</p>");
        FileWrite(handle, "</div>");
    }
    
    if(InpTestSpeed) {
        FileWrite(handle, "<div class='metric'>");
        FileWrite(handle, "<h3>Processing Speed</h3>");
        FileWrite(handle, "<p>Average Time: " + DoubleToString(metrics.avg_processing_time * 1000, 2) + " ms</p>");
        FileWrite(handle, "<p>Min Time: " + DoubleToString(metrics.min_processing_time * 1000, 2) + " ms</p>");
        FileWrite(handle, "<p>Max Time: " + DoubleToString(metrics.max_processing_time * 1000, 2) + " ms</p>");
        FileWrite(handle, "</div>");
        
        FileWrite(handle, "<div class='metric'>");
        FileWrite(handle, "<h3>Pattern Detection</h3>");
        FileWrite(handle, "<p>Patterns Detected: " + IntegerToString(metrics.patterns_detected) + "</p>");
        FileWrite(handle, "<p>Total Time: " + DoubleToString(metrics.pattern_detection_time, 2) + " seconds</p>");
        FileWrite(handle, "</div>");
    }
}

// Write performance charts
void WritePerformanceCharts(const int handle) {
    // Add chart generation code here
    // This would typically use a JavaScript charting library
}

// Write report footer
void WriteReportFooter(const int handle) {
    FileWrite(handle, "</body>");
    FileWrite(handle, "</html>");
}

//+------------------------------------------------------------------+
//| Utility Functions                                                  |
//+------------------------------------------------------------------+

// Calculate array average
double CalculateArrayAverage(const double &array[]) {
    double sum = 0;
    int count = 0;
    
    for(int i = 0; i < ArraySize(array); i++) {
        if(array[i] != 0) {
            sum += array[i];
            count++;
        }
    }
    
    return count > 0 ? sum / count : 0;
}

// Get memory usage in bytes
double GetMemoryUsage() {
    return (double)TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL);
}

// Get CPU usage percentage
double GetCPUUsage() {
    return (double)TerminalInfoInteger(TERMINAL_CPU_USAGE);
}
