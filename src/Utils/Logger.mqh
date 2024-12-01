//+------------------------------------------------------------------+
//|                                                        Logger.mqh |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"

// Log Levels
enum ENUM_LOG_LEVEL {
    LOG_ERROR,      // Critical errors
    LOG_WARNING,    // Warning messages
    LOG_INFO,       // Information messages
    LOG_DEBUG,      // Debug information
    LOG_TRACE       // Detailed trace information
};

// Log Entry Structure
struct LogEntry {
    datetime        time;           // Log entry time
    ENUM_LOG_LEVEL  level;          // Log level
    string          category;       // Log category
    string          message;        // Log message
    string          details;        // Additional details
    string          function_name;  // Function name
    int             line_number;    // Line number
};

//+------------------------------------------------------------------+
//| Logger Class                                                       |
//+------------------------------------------------------------------+
class CLogger {
private:
    string          m_filename;         // Log file name
    ENUM_LOG_LEVEL  m_min_level;        // Minimum log level
    bool            m_console_output;    // Output to console
    bool            m_file_output;       // Output to file
    string          m_prefix;           // Log prefix
    
    // Format log entry
    string FormatLogEntry(const LogEntry &entry) {
        string level_str = "";
        switch(entry.level) {
            case LOG_ERROR:   level_str = "ERROR  "; break;
            case LOG_WARNING: level_str = "WARNING"; break;
            case LOG_INFO:    level_str = "INFO   "; break;
            case LOG_DEBUG:   level_str = "DEBUG  "; break;
            case LOG_TRACE:   level_str = "TRACE  "; break;
        }
        
        string time_str = TimeToString(entry.time, TIME_DATE|TIME_SECONDS);
        string location = StringFormat("%s:%d", entry.function_name, entry.line_number);
        
        return StringFormat("%s [%s] [%s] [%s] %s - %s",
                          time_str,
                          level_str,
                          entry.category,
                          location,
                          entry.message,
                          entry.details);
    }
    
    // Write to file
    void WriteToFile(const string &text) {
        int handle = FileOpen(m_filename, FILE_WRITE|FILE_READ|FILE_TXT);
        if(handle != INVALID_HANDLE) {
            FileSeek(handle, 0, SEEK_END);
            FileWriteString(handle, text + "\n");
            FileClose(handle);
        }
    }
    
    // Clean old logs
    void CleanOldLogs() {
        if(!FileIsExist(m_filename)) return;
        
        datetime file_time = (datetime)FileGetInteger(m_filename, FILE_CREATE_DATE);
        if(TimeCurrent() - file_time > 7 * 24 * 60 * 60) { // 7 days
            FileDelete(m_filename);
        }
    }

public:
    // Constructor
    CLogger(const string prefix = "GeniusBryson",
            const ENUM_LOG_LEVEL min_level = LOG_INFO,
            const bool console_output = true,
            const bool file_output = true) {
        m_prefix = prefix;
        m_min_level = min_level;
        m_console_output = console_output;
        m_file_output = file_output;
        m_filename = m_prefix + "_" + TimeToString(TimeCurrent(), TIME_DATE) + ".log";
        
        CleanOldLogs();
    }
    
    // Log message
    void Log(const ENUM_LOG_LEVEL level,
             const string category,
             const string message,
             const string details = "",
             const string function_name = __FUNCTION__,
             const int line_number = __LINE__) {
        
        if(level > m_min_level) return;
        
        LogEntry entry;
        entry.time = TimeCurrent();
        entry.level = level;
        entry.category = category;
        entry.message = message;
        entry.details = details;
        entry.function_name = function_name;
        entry.line_number = line_number;
        
        string formatted_entry = FormatLogEntry(entry);
        
        if(m_console_output) Print(formatted_entry);
        if(m_file_output) WriteToFile(formatted_entry);
    }
    
    // Convenience methods for different log levels
    void Error(const string category,
               const string message,
               const string details = "",
               const string function_name = __FUNCTION__,
               const int line_number = __LINE__) {
        Log(LOG_ERROR, category, message, details, function_name, line_number);
    }
    
    void Warning(const string category,
                const string message,
                const string details = "",
                const string function_name = __FUNCTION__,
                const int line_number = __LINE__) {
        Log(LOG_WARNING, category, message, details, function_name, line_number);
    }
    
    void Info(const string category,
              const string message,
              const string details = "",
              const string function_name = __FUNCTION__,
              const int line_number = __LINE__) {
        Log(LOG_INFO, category, message, details, function_name, line_number);
    }
    
    void Debug(const string category,
               const string message,
               const string details = "",
               const string function_name = __FUNCTION__,
               const int line_number = __LINE__) {
        Log(LOG_DEBUG, category, message, details, function_name, line_number);
    }
    
    void Trace(const string category,
               const string message,
               const string details = "",
               const string function_name = __FUNCTION__,
               const int line_number = __LINE__) {
        Log(LOG_TRACE, category, message, details, function_name, line_number);
    }
    
    // Pattern Detection Logging
    void LogPatternDetection(const string pattern_name,
                            const string pattern_type,
                            const double confidence,
                            const bool is_complete) {
        string details = StringFormat("Type: %s, Confidence: %.2f%%, Status: %s",
                                    pattern_type,
                                    confidence,
                                    is_complete ? "Complete" : "Forming");
        
        Info("Pattern", StringFormat("Detected %s pattern", pattern_name), details);
    }
    
    // Zone Detection Logging
    void LogZoneDetection(const bool is_supply,
                         const double zone_price,
                         const double zone_strength) {
        string zone_type = is_supply ? "Supply" : "Demand";
        string details = StringFormat("Price: %s, Strength: %.2f%%",
                                    DoubleToString(zone_price, _Digits),
                                    zone_strength);
        
        Info("Zone", StringFormat("Detected %s zone", zone_type), details);
    }
    
    // Signal Generation Logging
    void LogSignalGeneration(const ENUM_SIGNAL_TYPE signal_type,
                            const double entry_price,
                            const double stop_loss,
                            const double take_profit) {
        string signal_str = "";
        switch(signal_type) {
            case SIGNAL_STRONG_BUY:    signal_str = "Strong Buy";     break;
            case SIGNAL_MODERATE_BUY:  signal_str = "Moderate Buy";   break;
            case SIGNAL_NEUTRAL:       signal_str = "Neutral";        break;
            case SIGNAL_MODERATE_SELL: signal_str = "Moderate Sell";  break;
            case SIGNAL_STRONG_SELL:   signal_str = "Strong Sell";    break;
        }
        
        string details = StringFormat("Entry: %s, SL: %s, TP: %s",
                                    DoubleToString(entry_price, _Digits),
                                    DoubleToString(stop_loss, _Digits),
                                    DoubleToString(take_profit, _Digits));
        
        Info("Signal", StringFormat("Generated %s signal", signal_str), details);
    }
    
    // Performance Logging
    void LogPerformance(const string operation,
                       const double execution_time,
                       const string additional_info = "") {
        string details = StringFormat("Execution Time: %.2f ms%s%s",
                                    execution_time,
                                    additional_info != "" ? ", " : "",
                                    additional_info);
        
        Debug("Performance", operation, details);
    }
    
    // Error Logging with Stack Trace
    void LogErrorWithStack(const string category,
                          const string message,
                          const string stack_trace) {
        Error(category, message, "Stack Trace: " + stack_trace);
    }
};

// Global logger instance
CLogger Logger("GeniusBryson");
