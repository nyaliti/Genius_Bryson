//+------------------------------------------------------------------+
//|                                                       Helpers.mqh |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"

//+------------------------------------------------------------------+
//| Price Calculation Functions                                        |
//+------------------------------------------------------------------+

//--- Calculate Average Price
double CalculateAveragePrice(const double &high[], const double &low[], const int pos) {
    return (high[pos] + low[pos]) / 2.0;
}

//--- Calculate Typical Price
double CalculateTypicalPrice(const double &high[], const double &low[], const double &close[], const int pos) {
    return (high[pos] + low[pos] + close[pos]) / 3.0;
}

//--- Calculate Weighted Close Price
double CalculateWeightedClose(const double &high[], const double &low[], const double &close[], const int pos) {
    return (high[pos] + low[pos] + (close[pos] * 2)) / 4.0;
}

//--- Calculate Price Range
double CalculatePriceRange(const double &high[], const double &low[], const int pos) {
    return high[pos] - low[pos];
}

//+------------------------------------------------------------------+
//| Statistical Functions                                              |
//+------------------------------------------------------------------+

//--- Calculate Standard Deviation
double CalculateStdDev(const double &data[], const int start, const int count) {
    if(count <= 1) return 0.0;
    
    double sum = 0.0;
    double sum_sq = 0.0;
    
    for(int i = start; i < start + count; i++) {
        sum += data[i];
        sum_sq += data[i] * data[i];
    }
    
    double variance = (sum_sq - (sum * sum / count)) / (count - 1);
    return MathSqrt(variance);
}

//--- Calculate Moving Average
double CalculateMA(const double &data[], const int start, const int period) {
    if(period <= 0) return 0.0;
    
    double sum = 0.0;
    for(int i = start; i < start + period; i++) {
        sum += data[i];
    }
    
    return sum / period;
}

//--- Calculate Correlation
double CalculateCorrelation(const double &data1[], const double &data2[], const int start, const int count) {
    if(count <= 1) return 0.0;
    
    double sum1 = 0.0, sum2 = 0.0;
    double sum1_sq = 0.0, sum2_sq = 0.0;
    double sum_prod = 0.0;
    
    for(int i = start; i < start + count; i++) {
        sum1 += data1[i];
        sum2 += data2[i];
        sum1_sq += data1[i] * data1[i];
        sum2_sq += data2[i] * data2[i];
        sum_prod += data1[i] * data2[i];
    }
    
    double num = count * sum_prod - sum1 * sum2;
    double den = MathSqrt((count * sum1_sq - sum1 * sum1) * (count * sum2_sq - sum2 * sum2));
    
    return den != 0 ? num / den : 0;
}

//+------------------------------------------------------------------+
//| Trend Analysis Functions                                           |
//+------------------------------------------------------------------+

//--- Determine Trend Direction
ENUM_TREND_DIRECTION GetTrendDirection(const double &close[], const int start, const int period) {
    if(period <= 1) return TREND_NEUTRAL;
    
    double first = close[start + period - 1];
    double last = close[start];
    
    if(last > first * 1.001) return TREND_UP;
    if(last < first * 0.999) return TREND_DOWN;
    return TREND_NEUTRAL;
}

//--- Calculate Trend Strength
double CalculateTrendStrength(const double &close[], const int start, const int period) {
    if(period <= 1) return 0.0;
    
    double direction = 0;
    double strength = 0;
    
    for(int i = start; i < start + period - 1; i++) {
        double change = close[i] - close[i + 1];
        direction += change > 0 ? 1 : (change < 0 ? -1 : 0);
        strength += MathAbs(change);
    }
    
    return MathAbs(direction) / period * (strength / period);
}

//+------------------------------------------------------------------+
//| Time Functions                                                     |
//+------------------------------------------------------------------+

//--- Check Trading Hours
bool IsWithinTradingHours(const datetime time) {
    MqlDateTime dt;
    TimeToStruct(time, dt);
    
    // Default trading hours: Monday-Friday, 00:00-23:59
    if(dt.day_of_week == 0 || dt.day_of_week == 6) return false;
    return true;
}

//--- Format Time String
string FormatTimeString(const datetime time) {
    return TimeToString(time, TIME_DATE|TIME_MINUTES);
}

//+------------------------------------------------------------------+
//| Drawing Functions                                                  |
//+------------------------------------------------------------------+

//--- Create Text Label
void CreateLabel(const string name, 
                const string text,
                const datetime time,
                const double price,
                const color clr,
                const int font_size = 8) {
    ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size);
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
}

//--- Create Trend Line
void CreateTrendLine(const string name,
                    const datetime time1,
                    const double price1,
                    const datetime time2,
                    const double price2,
                    const color clr,
                    const int width = 1,
                    const ENUM_LINE_STYLE style = STYLE_SOLID) {
    ObjectCreate(0, name, OBJ_TREND, 0, time1, price1, time2, price2);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
    ObjectSetInteger(0, name, OBJPROP_STYLE, style);
    ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
}

//--- Create Rectangle
void CreateRectangle(const string name,
                    const datetime time1,
                    const double price1,
                    const datetime time2,
                    const double price2,
                    const color clr,
                    const double opacity = 0.3) {
    ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FILL, true);
    ObjectSetInteger(0, name, OBJPROP_BACK, true);
    ObjectSetDouble(0, name, OBJPROP_TRANSPARENCY, opacity * 100);
}

//+------------------------------------------------------------------+
//| Alert Functions                                                    |
//+------------------------------------------------------------------+

//--- Send Alert
void SendAlert(const string message,
              const bool enable_popup,
              const bool enable_sound,
              const bool enable_email,
              const bool enable_push,
              const string sound_file = "alert.wav") {
    if(enable_popup) Alert(message);
    if(enable_sound) PlaySound(sound_file);
    if(enable_email) SendMail("Genius_Bryson Alert", message);
    if(enable_push) SendNotification(message);
}

//+------------------------------------------------------------------+
//| Validation Functions                                              |
//+------------------------------------------------------------------+

//--- Validate Price
bool IsValidPrice(const double price) {
    return (price > 0 && !MathIsValidNumber(price));
}

//--- Validate Array Size
bool ValidateArrays(const double &arr1[],
                   const double &arr2[],
                   const double &arr3[],
                   const int required_size) {
    return (ArraySize(arr1) >= required_size &&
            ArraySize(arr2) >= required_size &&
            ArraySize(arr3) >= required_size);
}

//+------------------------------------------------------------------+
//| Risk Management Functions                                          |
//+------------------------------------------------------------------+

//--- Calculate Position Size
double CalculatePositionSize(const double account_balance,
                           const double risk_percent,
                           const double stop_loss_pips) {
    if(stop_loss_pips <= 0 || risk_percent <= 0) return 0.0;
    
    double risk_amount = account_balance * risk_percent / 100.0;
    double pip_value = MarketInfo(Symbol(), MODE_TICKVALUE) * 10;
    
    return NormalizeDouble(risk_amount / (stop_loss_pips * pip_value), 2);
}

//--- Calculate Risk/Reward Ratio
double CalculateRiskRewardRatio(const double entry_price,
                              const double stop_loss,
                              const double take_profit) {
    double risk = MathAbs(entry_price - stop_loss);
    double reward = MathAbs(entry_price - take_profit);
    
    return risk != 0 ? reward / risk : 0;
}

//+------------------------------------------------------------------+
//| String Functions                                                   |
//+------------------------------------------------------------------+

//--- Format Double
string FormatDouble(const double value, const int digits = 5) {
    return DoubleToString(value, digits);
}

//--- Format Price
string FormatPrice(const double price) {
    return DoubleToString(price, _Digits);
}

//--- Format Percentage
string FormatPercent(const double value) {
    return DoubleToString(value, 2) + "%";
}
