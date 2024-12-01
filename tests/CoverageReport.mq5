//+------------------------------------------------------------------+
//|                                               CoverageReport.mq5 |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"

#include "TestInit.mqh"

// Coverage Metrics Structure
struct CoverageMetrics {
    // File Coverage
    struct FileCoverage {
        string file_name;
        int total_lines;
        int covered_lines;
        int uncovered_lines;
        double coverage_percent;
        string uncovered_sections[];
    };
    
    // Function Coverage
    struct FunctionCoverage {
        string function_name;
        int total_calls;
        bool is_covered;
        double coverage_percent;
        string test_cases[];
    };
    
    // Branch Coverage
    struct BranchCoverage {
        string location;
        int total_branches;
        int covered_branches;
        double coverage_percent;
        bool conditions[];
    };
    
    FileCoverage files[];
    FunctionCoverage functions[];
    BranchCoverage branches[];
    
    // Overall Metrics
    double total_coverage;
    double function_coverage;
    double branch_coverage;
    int total_test_cases;
};

// Global Variables
CoverageMetrics coverage;
string source_files[];

//+------------------------------------------------------------------+
//| Script program start function                                      |
//+------------------------------------------------------------------+
void OnStart() {
    // Initialize coverage tracking
    if(!InitializeCoverageTracking()) {
        Print("Failed to initialize coverage tracking");
        return;
    }
    
    // Analyze source files
    AnalyzeSourceFiles();
    
    // Generate coverage report
    GenerateCoverageReport();
    
    // Clean up
    CleanupCoverageTracking();
}

//+------------------------------------------------------------------+
//| Coverage Tracking Functions                                        |
//+------------------------------------------------------------------+

// Initialize coverage tracking
bool InitializeCoverageTracking() {
    LogInfo("Initializing coverage tracking");
    
    // Get list of source files
    if(!GetSourceFiles()) {
        LogError("Failed to get source files");
        return false;
    }
    
    // Initialize coverage metrics
    InitializeCoverageMetrics();
    
    return true;
}

// Get list of source files
bool GetSourceFiles() {
    string src_dir = "src";
    long handle = FileFindFirst(src_dir + "/*.mq*", 0);
    
    if(handle != INVALID_HANDLE) {
        string filename;
        int file_count = 0;
        
        do {
            filename = FileFindNext(handle);
            if(filename == "") break;
            
            ArrayResize(source_files, file_count + 1);
            source_files[file_count++] = src_dir + "/" + filename;
        } while(true);
        
        FileFindClose(handle);
        return true;
    }
    
    return false;
}

// Initialize coverage metrics
void InitializeCoverageMetrics() {
    // Initialize file coverage
    ArrayResize(coverage.files, ArraySize(source_files));
    
    for(int i = 0; i < ArraySize(source_files); i++) {
        coverage.files[i].file_name = source_files[i];
        AnalyzeFile(coverage.files[i]);
    }
}

//+------------------------------------------------------------------+
//| Source Analysis Functions                                          |
//+------------------------------------------------------------------+

// Analyze source files
void AnalyzeSourceFiles() {
    LogInfo("Analyzing source files for coverage");
    
    for(int i = 0; i < ArraySize(source_files); i++) {
        AnalyzeSourceFile(source_files[i]);
    }
    
    // Calculate overall metrics
    CalculateOverallMetrics();
}

// Analyze single source file
void AnalyzeSourceFile(const string filename) {
    int handle = FileOpen(filename, FILE_READ|FILE_TXT|FILE_ANSI);
    
    if(handle != INVALID_HANDLE) {
        string line;
        int line_count = 0;
        int function_count = 0;
        int branch_count = 0;
        
        while(!FileIsEnding(handle)) {
            line = FileReadString(handle);
            line_count++;
            
            // Analyze line content
            if(IsFunctionDeclaration(line)) {
                TrackFunction(line, function_count++);
            }
            
            if(IsBranchStatement(line)) {
                TrackBranch(line, branch_count++);
            }
        }
        
        FileClose(handle);
        
        // Update file metrics
        for(int i = 0; i < ArraySize(coverage.files); i++) {
            if(coverage.files[i].file_name == filename) {
                coverage.files[i].total_lines = line_count;
                break;
            }
        }
    }
}

// Check if line is function declaration
bool IsFunctionDeclaration(const string line) {
    return StringFind(line, "void") >= 0 || 
           StringFind(line, "double") >= 0 || 
           StringFind(line, "int") >= 0 || 
           StringFind(line, "bool") >= 0;
}

// Check if line contains branch statement
bool IsBranchStatement(const string line) {
    return StringFind(line, "if") >= 0 || 
           StringFind(line, "else") >= 0 || 
           StringFind(line, "switch") >= 0 || 
           StringFind(line, "case") >= 0;
}

//+------------------------------------------------------------------+
//| Coverage Tracking Functions                                        |
//+------------------------------------------------------------------+

// Track function coverage
void TrackFunction(const string line, const int index) {
    string function_name = ExtractFunctionName(line);
    
    ArrayResize(coverage.functions, index + 1);
    coverage.functions[index].function_name = function_name;
    coverage.functions[index].is_covered = false;
    coverage.functions[index].total_calls = 0;
}

// Track branch coverage
void TrackBranch(const string line, const int index) {
    ArrayResize(coverage.branches, index + 1);
    coverage.branches[index].location = line;
    coverage.branches[index].total_branches = CountBranches(line);
    coverage.branches[index].covered_branches = 0;
}

// Extract function name from declaration
string ExtractFunctionName(const string line) {
    int start = StringFind(line, " ", 0) + 1;
    while(StringGetCharacter(line, start) == ' ') start++;
    
    int end = StringFind(line, "(", start);
    if(end < 0) end = StringLen(line);
    
    return StringSubstr(line, start, end - start);
}

// Count branches in statement
int CountBranches(const string line) {
    if(StringFind(line, "if") >= 0) return 2;
    if(StringFind(line, "switch") >= 0) {
        // Count case statements
        return StringSplit(line, 'case', NULL);
    }
    return 1;
}

//+------------------------------------------------------------------+
//| Metric Calculation Functions                                       |
//+------------------------------------------------------------------+

// Calculate overall metrics
void CalculateOverallMetrics() {
    // Calculate file coverage
    double total_lines = 0;
    double covered_lines = 0;
    
    for(int i = 0; i < ArraySize(coverage.files); i++) {
        total_lines += coverage.files[i].total_lines;
        covered_lines += coverage.files[i].covered_lines;
    }
    
    coverage.total_coverage = total_lines > 0 ? 
                            (covered_lines / total_lines) * 100 : 0;
    
    // Calculate function coverage
    int covered_functions = 0;
    for(int i = 0; i < ArraySize(coverage.functions); i++) {
        if(coverage.functions[i].is_covered) covered_functions++;
    }
    
    coverage.function_coverage = ArraySize(coverage.functions) > 0 ?
                               (double)covered_functions / ArraySize(coverage.functions) * 100 : 0;
    
    // Calculate branch coverage
    int total_branches = 0;
    int covered_branches = 0;
    
    for(int i = 0; i < ArraySize(coverage.branches); i++) {
        total_branches += coverage.branches[i].total_branches;
        covered_branches += coverage.branches[i].covered_branches;
    }
    
    coverage.branch_coverage = total_branches > 0 ?
                             (double)covered_branches / total_branches * 100 : 0;
}

//+------------------------------------------------------------------+
//| Report Generation Functions                                        |
//+------------------------------------------------------------------+

// Generate coverage report
void GenerateCoverageReport() {
    string report_file = "test_results/reports/coverage_report_" + 
                        TimeToString(TimeCurrent()) + ".html";
    
    int handle = FileOpen(report_file, FILE_WRITE|FILE_TXT);
    if(handle != INVALID_HANDLE) {
        // Write report content
        WriteCoverageReport(handle);
        FileClose(handle);
        
        LogInfo("Coverage report generated: " + report_file);
    }
    else {
        LogError("Failed to create coverage report");
    }
}

// Write coverage report
void WriteCoverageReport(const int handle) {
    // Write HTML header
    WriteReportHeader(handle);
    
    // Write overall metrics
    WriteOverallMetrics(handle);
    
    // Write file coverage
    WriteFileCoverage(handle);
    
    // Write function coverage
    WriteFunctionCoverage(handle);
    
    // Write branch coverage
    WriteBranchCoverage(handle);
    
    // Write HTML footer
    WriteReportFooter(handle);
}

// Write report header
void WriteReportHeader(const int handle) {
    FileWrite(handle, "<html>");
    FileWrite(handle, "<head>");
    FileWrite(handle, "<title>Code Coverage Report</title>");
    FileWrite(handle, "<style>");
    FileWrite(handle, "body { font-family: Arial, sans-serif; margin: 20px; }");
    FileWrite(handle, ".metric { margin: 10px 0; padding: 10px; border: 1px solid #ddd; }");
    FileWrite(handle, ".progress { width: 200px; height: 20px; background: #eee; }");
    FileWrite(handle, ".progress-bar { height: 100%; background: #4CAF50; }");
    FileWrite(handle, ".uncovered { color: #f44336; }");
    FileWrite(handle, "</style>");
    FileWrite(handle, "</head>");
    FileWrite(handle, "<body>");
}

// Write overall metrics
void WriteOverallMetrics(const int handle) {
    FileWrite(handle, "<h1>Code Coverage Report</h1>");
    FileWrite(handle, "<div class='metric'>");
    FileWrite(handle, "<h2>Overall Metrics</h2>");
    FileWrite(handle, StringFormat("Total Coverage: %.2f%%", coverage.total_coverage));
    FileWrite(handle, StringFormat("Function Coverage: %.2f%%", coverage.function_coverage));
    FileWrite(handle, StringFormat("Branch Coverage: %.2f%%", coverage.branch_coverage));
    FileWrite(handle, "</div>");
}

// Write file coverage
void WriteFileCoverage(const int handle) {
    FileWrite(handle, "<div class='metric'>");
    FileWrite(handle, "<h2>File Coverage</h2>");
    
    for(int i = 0; i < ArraySize(coverage.files); i++) {
        FileWrite(handle, "<h3>" + coverage.files[i].file_name + "</h3>");
        FileWrite(handle, StringFormat("Coverage: %.2f%%", coverage.files[i].coverage_percent));
        
        if(ArraySize(coverage.files[i].uncovered_sections) > 0) {
            FileWrite(handle, "<p class='uncovered'>Uncovered Sections:</p>");
            FileWrite(handle, "<ul>");
            for(int j = 0; j < ArraySize(coverage.files[i].uncovered_sections); j++) {
                FileWrite(handle, "<li>" + coverage.files[i].uncovered_sections[j] + "</li>");
            }
            FileWrite(handle, "</ul>");
        }
    }
    
    FileWrite(handle, "</div>");
}

// Write function coverage
void WriteFunctionCoverage(const int handle) {
    FileWrite(handle, "<div class='metric'>");
    FileWrite(handle, "<h2>Function Coverage</h2>");
    
    for(int i = 0; i < ArraySize(coverage.functions); i++) {
        string status = coverage.functions[i].is_covered ? "Covered" : "Not Covered";
        FileWrite(handle, StringFormat("<p>%s: %s (Calls: %d)</p>",
                                     coverage.functions[i].function_name,
                                     status,
                                     coverage.functions[i].total_calls));
    }
    
    FileWrite(handle, "</div>");
}

// Write branch coverage
void WriteBranchCoverage(const int handle) {
    FileWrite(handle, "<div class='metric'>");
    FileWrite(handle, "<h2>Branch Coverage</h2>");
    
    for(int i = 0; i < ArraySize(coverage.branches); i++) {
        FileWrite(handle, "<p>" + coverage.branches[i].location + "</p>");
        FileWrite(handle, StringFormat("Coverage: %.2f%% (%d/%d branches)",
                                     coverage.branches[i].coverage_percent,
                                     coverage.branches[i].covered_branches,
                                     coverage.branches[i].total_branches));
    }
    
    FileWrite(handle, "</div>");
}

// Write report footer
void WriteReportFooter(const int handle) {
    FileWrite(handle, "</body>");
    FileWrite(handle, "</html>");
}
