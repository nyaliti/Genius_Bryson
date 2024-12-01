//+------------------------------------------------------------------+
//|                                              AutomatedTrading.mq5 |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"
#property version   "1.0"

// Include necessary files
#include "../src/GeniusBryson.mq5"
#include <Trade/Trade.mqh>

// Trading Parameters
input group "Trading Settings"
input double InpRiskPercent = 1.0;          // Risk Per Trade (%)
input int    InpMaxPositions = 3;           // Maximum Open Positions
input double InpMinRRRatio = 1.5;           // Minimum Risk:Reward Ratio
input bool   InpUseBreakeven = true;        // Use Breakeven
input double InpBreakevenPips = 20;         // Breakeven Pips
input bool   InpUseTrailing = true;         // Use Trailing Stop
input double InpTrailingPips = 30;          // Trailing Stop Pips

input group "Risk Management"
input double InpMaxDailyLoss = 3.0;         // Maximum Daily Loss (%)
input double InpMaxWeeklyLoss = 7.0;        // Maximum Weekly Loss (%)
input bool   InpCloseOnMaxLoss = true;      // Close Positions on Max Loss

input group "Time Filters"
input bool   InpUseTimeFilter = true;       // Use Time Filter
input string InpTradingHoursStart = "08:00"; // Trading Hours Start
input string InpTradingHoursEnd = "16:00";   // Trading Hours End
input bool   InpAvoidNews = true;           // Avoid Trading During News

// Trade Management Structure
struct TradeManager {
    int    total_positions;
    double daily_profit;
    double weekly_profit;
    double account_balance;
    double max_position_size;
    
    void Update() {
        UpdatePositions();
        UpdateProfits();
        UpdateLimits();
    }
    
private:
    void UpdatePositions() {
        total_positions = PositionsTotal();
        account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
        max_position_size = account_balance * InpRiskPercent / 100.0;
    }
    
    void UpdateProfits() {
        daily_profit = CalculateDailyProfit();
        weekly_profit = CalculateWeeklyProfit();
    }
    
    void UpdateLimits() {
        if(InpCloseOnMaxLoss) {
            if(daily_profit <= -(InpMaxDailyLoss * account_balance / 100.0) ||
               weekly_profit <= -(InpMaxWeeklyLoss * account_balance / 100.0)) {
                CloseAllPositions();
            }
        }
    }
    
    double CalculateDailyProfit() {
        double profit = 0.0;
        datetime today_start = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
        
        HistorySelect(today_start, TimeCurrent());
        for(int i = 0; i < HistoryDealsTotal(); i++) {
            ulong ticket = HistoryDealGetTicket(i);
            if(ticket > 0) {
                profit += HistoryDealGetDouble(ticket, DEAL_PROFIT);
            }
        }
        
        return profit;
    }
    
    double CalculateWeeklyProfit() {
        double profit = 0.0;
        datetime week_start = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
        while(TimeDayOfWeek(week_start) != 1) {
            week_start -= PeriodSeconds(PERIOD_D1);
        }
        
        HistorySelect(week_start, TimeCurrent());
        for(int i = 0; i < HistoryDealsTotal(); i++) {
            ulong ticket = HistoryDealGetTicket(i);
            if(ticket > 0) {
                profit += HistoryDealGetDouble(ticket, DEAL_PROFIT);
            }
        }
        
        return profit;
    }
};

// Global Variables
CTrade trade;
TradeManager trade_manager;
GlobalSettings settings;
datetime last_signal_time = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit() {
    // Initialize settings
    settings.Version = "1.0.0";
    settings.Signals.MinRRRatio = InpMinRRRatio;
    
    // Initialize trade object
    trade.SetExpertMagicNumber(123456);
    trade.SetMarginMode();
    trade.SetTypeFillingBySymbol(Symbol());
    
    // Initialize trade manager
    trade_manager.Update();
    
    Logger.Info("Initialization", "Automated trading example started");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    if(reason == REASON_REMOVE) {
        CloseAllPositions();
    }
    Logger.Info("Deinitialization", "Automated trading example stopped");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick() {
    // Update trade manager
    trade_manager.Update();
    
    // Check trading conditions
    if(!CanTrade()) return;
    
    // Manage existing positions
    ManagePositions();
    
    // Check for new trading opportunities
    if(trade_manager.total_positions < InpMaxPositions) {
        AnalyzeMarket();
    }
}

//+------------------------------------------------------------------+
//| Trading Functions                                                 |
//+------------------------------------------------------------------+

// Check if trading is allowed
bool CanTrade() {
    // Check time filter
    if(InpUseTimeFilter && !IsWithinTradingHours()) {
        return false;
    }
    
    // Check news filter
    if(InpAvoidNews && IsNewsTime()) {
        return false;
    }
    
    // Check risk limits
    if(trade_manager.daily_profit <= -(InpMaxDailyLoss * trade_manager.account_balance / 100.0)) {
        Logger.Warning("Risk", "Daily loss limit reached");
        return false;
    }
    
    if(trade_manager.weekly_profit <= -(InpMaxWeeklyLoss * trade_manager.account_balance / 100.0)) {
        Logger.Warning("Risk", "Weekly loss limit reached");
        return false;
    }
    
    return true;
}

// Check trading hours
bool IsWithinTradingHours() {
    datetime current_time = TimeCurrent();
    
    MqlDateTime current_dt;
    TimeToStruct(current_time, current_dt);
    
    int current_minutes = current_dt.hour * 60 + current_dt.min;
    int start_minutes = StringToInteger(StringSubstr(InpTradingHoursStart, 0, 2)) * 60 +
                       StringToInteger(StringSubstr(InpTradingHoursStart, 3, 2));
    int end_minutes = StringToInteger(StringSubstr(InpTradingHoursEnd, 0, 2)) * 60 +
                     StringToInteger(StringSubstr(InpTradingHoursEnd, 3, 2));
    
    return (current_minutes >= start_minutes && current_minutes <= end_minutes);
}

// Check news time
bool IsNewsTime() {
    // Implementation for news time check
    return false; // Placeholder
}

// Analyze market for trading opportunities
void AnalyzeMarket() {
    // Get current market data
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(Symbol(), Period(), 0, 100, rates);
    
    if(copied <= 0) {
        Logger.Error("Data", "Failed to copy price data");
        return;
    }
    
    // Generate trading signal
    TradeSignal signal;
    if(GenerateSignal(0, rates[0].close, rates[0].time, signal)) {
        if(ValidateSignal(signal)) {
            ExecuteSignal(signal);
        }
    }
}

// Validate trading signal
bool ValidateSignal(const TradeSignal &signal) {
    // Check signal strength
    if(signal.strength < settings.Signals.MinSignalStrength) {
        return false;
    }
    
    // Check risk:reward ratio
    double rr_ratio = CalculateRiskRewardRatio(signal.entry_price,
                                             signal.stop_loss,
                                             signal.take_profit);
    if(rr_ratio < InpMinRRRatio) {
        return false;
    }
    
    // Check time between signals
    if(TimeCurrent() - last_signal_time < PeriodSeconds() * 10) {
        return false;
    }
    
    return true;
}

// Execute trading signal
void ExecuteSignal(const TradeSignal &signal) {
    // Calculate position size
    double position_size = CalculatePositionSize(signal);
    
    // Execute trade
    bool result = false;
    if(signal.type <= SIGNAL_NEUTRAL) {
        result = trade.Buy(position_size, Symbol(), signal.entry_price,
                          signal.stop_loss, signal.take_profit,
                          "GeniusBryson Signal");
    }
    else {
        result = trade.Sell(position_size, Symbol(), signal.entry_price,
                           signal.stop_loss, signal.take_profit,
                           "GeniusBryson Signal");
    }
    
    if(result) {
        last_signal_time = TimeCurrent();
        Logger.Info("Trade", StringFormat("Executed %s signal, Size: %.2f",
                   EnumToString(signal.type), position_size));
    }
    else {
        Logger.Error("Trade", StringFormat("Failed to execute signal: %d",
                    GetLastError()));
    }
}

// Calculate position size
double CalculatePositionSize(const TradeSignal &signal) {
    double risk_amount = trade_manager.account_balance * InpRiskPercent / 100.0;
    double stop_points = MathAbs(signal.entry_price - signal.stop_loss) / Point();
    double tick_value = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);
    double position_size = risk_amount / (stop_points * tick_value);
    
    // Normalize position size
    double min_lot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
    double max_lot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
    double lot_step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
    
    position_size = MathFloor(position_size / lot_step) * lot_step;
    position_size = MathMax(min_lot, MathMin(max_lot, position_size));
    
    return position_size;
}

//+------------------------------------------------------------------+
//| Position Management Functions                                      |
//+------------------------------------------------------------------+

// Manage open positions
void ManagePositions() {
    for(int i = 0; i < PositionsTotal(); i++) {
        if(PositionSelectByTicket(PositionGetTicket(i))) {
            // Check breakeven
            if(InpUseBreakeven) {
                CheckBreakeven();
            }
            
            // Check trailing stop
            if(InpUseTrailing) {
                UpdateTrailingStop();
            }
        }
    }
}

// Check and set breakeven
void CheckBreakeven() {
    double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
    double current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
    double stop_loss = PositionGetDouble(POSITION_SL);
    
    if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
        if(current_price >= open_price + InpBreakevenPips * Point() &&
           stop_loss < open_price) {
            trade.PositionModify(PositionGetTicket(0), open_price, 
                               PositionGetDouble(POSITION_TP));
        }
    }
    else {
        if(current_price <= open_price - InpBreakevenPips * Point() &&
           stop_loss > open_price) {
            trade.PositionModify(PositionGetTicket(0), open_price,
                               PositionGetDouble(POSITION_TP));
        }
    }
}

// Update trailing stop
void UpdateTrailingStop() {
    double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
    double current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
    double stop_loss = PositionGetDouble(POSITION_SL);
    
    if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
        double new_sl = current_price - InpTrailingPips * Point();
        if(new_sl > stop_loss && new_sl > open_price) {
            trade.PositionModify(PositionGetTicket(0), new_sl,
                               PositionGetDouble(POSITION_TP));
        }
    }
    else {
        double new_sl = current_price + InpTrailingPips * Point();
        if(new_sl < stop_loss && new_sl < open_price) {
            trade.PositionModify(PositionGetTicket(0), new_sl,
                               PositionGetDouble(POSITION_TP));
        }
    }
}

// Close all positions
void CloseAllPositions() {
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(PositionSelectByTicket(PositionGetTicket(i))) {
            trade.PositionClose(PositionGetTicket(i));
        }
    }
}
