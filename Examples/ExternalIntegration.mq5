//+------------------------------------------------------------------+
//|                                           ExternalIntegration.mq5 |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"

// Include necessary files
#include "../src/GeniusBryson.mq5"
#include <Tools/JSONParser.mqh>
#include <Tools/HTTPClient.mqh>

// External API Settings
#define API_BASE_URL     "https://api.example.com/v1/"
#define API_KEY          "YOUR_API_KEY"  // Replace with actual API key
#define REQUEST_TIMEOUT  5000            // Timeout in milliseconds

// Data Source Types
enum ENUM_DATA_SOURCE {
    SOURCE_ECONOMIC_CALENDAR,  // Economic Calendar
    SOURCE_MARKET_SENTIMENT,   // Market Sentiment
    SOURCE_NEWS_FEED,         // News Feed
    SOURCE_TECHNICAL_SIGNALS  // External Technical Signals
};

// Input Parameters
input group "External Data Settings"
input bool   InpUseEconomicCalendar = true;   // Use Economic Calendar
input bool   InpUseMarketSentiment = true;    // Use Market Sentiment
input bool   InpUseNewsFeed = true;           // Use News Feed
input bool   InpUseTechnicalSignals = true;   // Use External Technical Signals
input int    InpUpdateInterval = 300;         // Update Interval (seconds)

// External Data Structure
struct ExternalData {
    // Economic Calendar Data
    struct EconomicEvent {
        datetime time;
        string   currency;
        string   event;
        string   impact;
        double   forecast;
        double   previous;
    } economic_events[];
    
    // Market Sentiment Data
    struct SentimentData {
        string   symbol;
        double   long_percentage;
        double   short_percentage;
        int      total_traders;
        datetime last_update;
    } sentiment;
    
    // News Data
    struct NewsItem {
        datetime time;
        string   headline;
        string   body;
        string   impact;
        string   source;
    } news_items[];
    
    // Technical Signals
    struct TechnicalSignal {
        string   timeframe;
        string   indicator;
        string   signal;
        double   strength;
        datetime time;
    } technical_signals[];
};

// Global Variables
GlobalSettings settings;
ExternalData ext_data;
datetime last_update_time = 0;
HTTPClient http_client;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit() {
    // Initialize settings
    settings.Version = "1.0.0";
    
    // Initialize HTTP client
    http_client.SetTimeout(REQUEST_TIMEOUT);
    
    // Initial data fetch
    if(!UpdateExternalData()) {
        Logger.Error("Initialization", "Failed to fetch initial external data");
        return(INIT_FAILED);
    }
    
    Logger.Info("Initialization", "External integration example started");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Logger.Info("Deinitialization", "External integration example stopped");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick() {
    // Update external data if needed
    if(TimeCurrent() - last_update_time >= InpUpdateInterval) {
        if(UpdateExternalData()) {
            last_update_time = TimeCurrent();
        }
    }
    
    // Analyze market with external data
    AnalyzeMarketWithExternalData();
}

//+------------------------------------------------------------------+
//| External Data Functions                                           |
//+------------------------------------------------------------------+

// Update all external data
bool UpdateExternalData() {
    bool success = true;
    
    if(InpUseEconomicCalendar) {
        success &= UpdateEconomicCalendar();
    }
    
    if(InpUseMarketSentiment) {
        success &= UpdateMarketSentiment();
    }
    
    if(InpUseNewsFeed) {
        success &= UpdateNewsFeed();
    }
    
    if(InpUseTechnicalSignals) {
        success &= UpdateTechnicalSignals();
    }
    
    return success;
}

// Update Economic Calendar
bool UpdateEconomicCalendar() {
    string url = API_BASE_URL + "economic-calendar";
    string params = StringFormat("currency=%s&days=7", Symbol());
    
    string response = "";
    if(!MakeAPIRequest(url, params, response)) {
        return false;
    }
    
    return ParseEconomicCalendarData(response);
}

// Update Market Sentiment
bool UpdateMarketSentiment() {
    string url = API_BASE_URL + "market-sentiment";
    string params = StringFormat("symbol=%s", Symbol());
    
    string response = "";
    if(!MakeAPIRequest(url, params, response)) {
        return false;
    }
    
    return ParseMarketSentimentData(response);
}

// Update News Feed
bool UpdateNewsFeed() {
    string url = API_BASE_URL + "news";
    string params = StringFormat("symbol=%s&hours=24", Symbol());
    
    string response = "";
    if(!MakeAPIRequest(url, params, response)) {
        return false;
    }
    
    return ParseNewsData(response);
}

// Update Technical Signals
bool UpdateTechnicalSignals() {
    string url = API_BASE_URL + "technical-signals";
    string params = StringFormat("symbol=%s&timeframe=%s",
                               Symbol(), EnumToString(Period()));
    
    string response = "";
    if(!MakeAPIRequest(url, params, response)) {
        return false;
    }
    
    return ParseTechnicalSignalsData(response);
}

//+------------------------------------------------------------------+
//| API Communication Functions                                        |
//+------------------------------------------------------------------+

// Make API Request
bool MakeAPIRequest(const string url,
                   const string params,
                   string &response) {
    // Add API key to headers
    http_client.SetHeader("Authorization", "Bearer " + API_KEY);
    
    // Make request
    int status = http_client.Get(url + "?" + params, response);
    
    if(status != 200) {
        Logger.Error("API", StringFormat("Request failed with status %d: %s",
                    status, response));
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Data Parsing Functions                                            |
//+------------------------------------------------------------------+

// Parse Economic Calendar Data
bool ParseEconomicCalendarData(const string &json) {
    JSONParser parser;
    if(!parser.Parse(json)) {
        Logger.Error("Parser", "Failed to parse economic calendar data");
        return false;
    }
    
    // Clear existing data
    ArrayResize(ext_data.economic_events, 0);
    
    // Parse events
    JSONValue *events = parser.GetObjectValue("events");
    if(events != NULL && events.IsArray()) {
        int size = events.Size();
        ArrayResize(ext_data.economic_events, size);
        
        for(int i = 0; i < size; i++) {
            JSONValue *event = events.GetArrayItem(i);
            if(event != NULL && event.IsObject()) {
                ext_data.economic_events[i].time = 
                    StringToTime(event.GetString("time"));
                ext_data.economic_events[i].currency = 
                    event.GetString("currency");
                ext_data.economic_events[i].event = 
                    event.GetString("event");
                ext_data.economic_events[i].impact = 
                    event.GetString("impact");
                ext_data.economic_events[i].forecast = 
                    event.GetDouble("forecast");
                ext_data.economic_events[i].previous = 
                    event.GetDouble("previous");
            }
        }
    }
    
    return true;
}

// Parse Market Sentiment Data
bool ParseMarketSentimentData(const string &json) {
    JSONParser parser;
    if(!parser.Parse(json)) {
        Logger.Error("Parser", "Failed to parse market sentiment data");
        return false;
    }
    
    JSONValue *sentiment = parser.GetObjectValue("sentiment");
    if(sentiment != NULL && sentiment.IsObject()) {
        ext_data.sentiment.symbol = sentiment.GetString("symbol");
        ext_data.sentiment.long_percentage = sentiment.GetDouble("long_percentage");
        ext_data.sentiment.short_percentage = sentiment.GetDouble("short_percentage");
        ext_data.sentiment.total_traders = (int)sentiment.GetNumber("total_traders");
        ext_data.sentiment.last_update = 
            StringToTime(sentiment.GetString("last_update"));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Market Analysis Functions                                         |
//+------------------------------------------------------------------+

// Analyze market with external data
void AnalyzeMarketWithExternalData() {
    // Get current market data
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(Symbol(), Period(), 0, 100, rates);
    
    if(copied <= 0) {
        Logger.Error("Data", "Failed to copy price data");
        return;
    }
    
    // Check for high-impact events
    if(HasHighImpactEvents()) {
        Logger.Warning("Analysis", "High impact events detected - Use caution");
    }
    
    // Analyze with sentiment data
    if(InpUseMarketSentiment) {
        AnalyzeWithSentiment(rates);
    }
    
    // Generate combined signals
    GenerateCombinedSignals(rates);
}

// Check for high-impact events
bool HasHighImpactEvents() {
    datetime current_time = TimeCurrent();
    
    for(int i = 0; i < ArraySize(ext_data.economic_events); i++) {
        if(ext_data.economic_events[i].impact == "High" &&
           MathAbs(ext_data.economic_events[i].time - current_time) < 3600) { // 1 hour
            return true;
        }
    }
    
    return false;
}

// Analyze with sentiment data
void AnalyzeWithSentiment(const MqlRates &rates[]) {
    if(ext_data.sentiment.total_traders > 0) {
        // Check for extreme sentiment
        if(ext_data.sentiment.long_percentage > 80) {
            Logger.Info("Sentiment", "Extreme bullish sentiment detected");
        }
        else if(ext_data.sentiment.short_percentage > 80) {
            Logger.Info("Sentiment", "Extreme bearish sentiment detected");
        }
    }
}

// Generate combined signals
void GenerateCombinedSignals(const MqlRates &rates[]) {
    TradeSignal signal;
    if(GenerateSignal(0, rates[0].close, rates[0].time, signal)) {
        // Modify signal based on external data
        ModifySignalWithExternalData(signal);
        
        // Process modified signal
        if(ValidateSignal(signal)) {
            ProcessTradeSignal(signal);
        }
    }
}

// Modify signal with external data
void ModifySignalWithExternalData(TradeSignal &signal) {
    // Adjust signal strength based on sentiment
    if(signal.type <= SIGNAL_NEUTRAL && ext_data.sentiment.long_percentage > 70) {
        signal.strength *= 1.2; // Increase bullish signal strength
    }
    else if(signal.type > SIGNAL_NEUTRAL && ext_data.sentiment.short_percentage > 70) {
        signal.strength *= 1.2; // Increase bearish signal strength
    }
    
    // Add external factors to rationale
    signal.rationale += "\nExternal Factors:";
    signal.rationale += StringFormat("\nMarket Sentiment: %.1f%% Long, %.1f%% Short",
                                   ext_data.sentiment.long_percentage,
                                   ext_data.sentiment.short_percentage);
    
    // Add relevant news
    AddNewsToRationale(signal);
}

// Add news to signal rationale
void AddNewsToRationale(TradeSignal &signal) {
    string news = "\nRecent News:";
    int news_count = 0;
    
    for(int i = 0; i < ArraySize(ext_data.news_items); i++) {
        if(news_count >= 3) break; // Limit to 3 news items
        
        if(ext_data.news_items[i].impact == "High") {
            news += "\n- " + ext_data.news_items[i].headline;
            news_count++;
        }
    }
    
    if(news_count > 0) {
        signal.rationale += news;
    }
}

//+------------------------------------------------------------------+
//| Signal Processing Functions                                        |
//+------------------------------------------------------------------+

// Validate signal
bool ValidateSignal(const TradeSignal &signal) {
    // Check for high-impact events
    if(HasHighImpactEvents()) {
        return false;
    }
    
    // Check signal strength
    if(signal.strength < settings.Signals.MinSignalStrength) {
        return false;
    }
    
    return true;
}

// Process trade signal
void ProcessTradeSignal(const TradeSignal &signal) {
    // Draw signal visualization
    DrawSignal(StringFormat("Signal_%s", TimeToString(signal.time)),
               signal.time,
               signal.entry_price,
               signal.stop_loss,
               signal.take_profit,
               signal.type,
               settings.Colors.StrongBuy);
    
    // Send alert
    AlertMessage alert;
    CreateSignalAlert(alert, signal.type,
                     signal.entry_price,
                     signal.stop_loss,
                     signal.take_profit,
                     signal.rationale);
    SendAlert(alert, settings.Alerts);
}
