//+------------------------------------------------------------------+
//|                                                   SupplyDemand.mqh |
//|                                           Copyright 2024, Bryson Omullo |
//|                                           Email: bnyaliti@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Bryson Omullo"
#property link      "https://github.com/nyaliti/Genius_Bryson"

// Zone Detection Constants
#define ZONE_STRENGTH_THRESHOLD  70.0    // Minimum strength for valid zones
#define ZONE_DEPTH_FACTOR       2.0     // Multiplier for zone depth calculation
#define MIN_ZONE_SIZE           5       // Minimum candles for zone formation
#define MAX_ZONE_AGE            500     // Maximum age of zones in bars
#define ZONE_MERGE_DISTANCE     0.0010  // Distance to merge nearby zones

// Zone Structure
struct Zone {
    datetime    start_time;     // Zone formation start time
    datetime    end_time;       // Zone formation end time
    double      upper_price;    // Upper price level of zone
    double      lower_price;    // Lower price level of zone
    double      strength;       // Zone strength (0-100)
    bool        is_supply;      // true for supply, false for demand
    int         touches;        // Number of times price touched the zone
    bool        active;         // Whether zone is still active
};

//+------------------------------------------------------------------+
//| Zone Detection Functions                                           |
//+------------------------------------------------------------------+

//--- Detect Supply Zones
bool DetectSupplyZone(const int start_pos,
                     const int rates_total,
                     const double &high[],
                     const double &low[],
                     const double &close[],
                     const datetime &time[],
                     Zone &zone) {
    // Supply zone detection logic
    if(start_pos < MIN_ZONE_SIZE || start_pos >= rates_total) return false;
    
    // Look for strong bearish move
    double highest = high[start_pos];
    double lowest = low[start_pos];
    int highest_pos = start_pos;
    
    // Find local high
    for(int i = start_pos; i > start_pos - MIN_ZONE_SIZE; i--) {
        if(high[i] > highest) {
            highest = high[i];
            highest_pos = i;
        }
        lowest = MathMin(lowest, low[i]);
    }
    
    // Check for strong bearish move after high
    double move_size = highest - lowest;
    if(move_size > ZONE_DEPTH_FACTOR * iATR(NULL, 0, 14, highest_pos)) {
        // Zone found, populate structure
        zone.start_time = time[highest_pos];
        zone.end_time = time[start_pos];
        zone.upper_price = highest;
        zone.lower_price = highest - move_size/3; // Upper third of the move
        zone.strength = CalculateZoneStrength(highest_pos, start_pos, high, low, close, true);
        zone.is_supply = true;
        zone.touches = CountZoneTouches(zone, start_pos, rates_total, high, low);
        zone.active = true;
        
        return true;
    }
    
    return false;
}

//--- Detect Demand Zones
bool DetectDemandZone(const int start_pos,
                     const int rates_total,
                     const double &high[],
                     const double &low[],
                     const double &close[],
                     const datetime &time[],
                     Zone &zone) {
    // Demand zone detection logic
    if(start_pos < MIN_ZONE_SIZE || start_pos >= rates_total) return false;
    
    // Look for strong bullish move
    double highest = high[start_pos];
    double lowest = low[start_pos];
    int lowest_pos = start_pos;
    
    // Find local low
    for(int i = start_pos; i > start_pos - MIN_ZONE_SIZE; i--) {
        if(low[i] < lowest) {
            lowest = low[i];
            lowest_pos = i;
        }
        highest = MathMax(highest, high[i]);
    }
    
    // Check for strong bullish move after low
    double move_size = highest - lowest;
    if(move_size > ZONE_DEPTH_FACTOR * iATR(NULL, 0, 14, lowest_pos)) {
        // Zone found, populate structure
        zone.start_time = time[lowest_pos];
        zone.end_time = time[start_pos];
        zone.upper_price = lowest + move_size/3; // Lower third of the move
        zone.lower_price = lowest;
        zone.strength = CalculateZoneStrength(lowest_pos, start_pos, high, low, close, false);
        zone.is_supply = false;
        zone.touches = CountZoneTouches(zone, start_pos, rates_total, high, low);
        zone.active = true;
        
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Zone Analysis Functions                                            |
//+------------------------------------------------------------------+

//--- Calculate Zone Strength
double CalculateZoneStrength(const int start_pos,
                           const int end_pos,
                           const double &high[],
                           const double &low[],
                           const double &close[],
                           const bool is_supply) {
    double strength = 100.0;
    
    // Factors affecting strength:
    // 1. Age of zone
    strength *= MathExp(-0.001 * (end_pos - start_pos));
    
    // 2. Price action within zone
    int touches = 0;
    int breaks = 0;
    
    for(int i = start_pos; i >= end_pos; i--) {
        if(is_supply) {
            if(high[i] > high[start_pos]) breaks++;
            if(high[i] >= high[start_pos] * 0.99) touches++;
        } else {
            if(low[i] < low[start_pos]) breaks++;
            if(low[i] <= low[start_pos] * 1.01) touches++;
        }
    }
    
    // Reduce strength for breaks
    strength *= MathExp(-0.5 * breaks);
    
    // Increase strength for touches without breaks
    strength *= (1.0 + 0.1 * touches);
    
    return MathMin(100.0, strength);
}

//--- Count Zone Touches
int CountZoneTouches(const Zone &zone,
                    const int start_pos,
                    const int rates_total,
                    const double &high[],
                    const double &low[]) {
    int touches = 0;
    bool in_zone = false;
    
    for(int i = start_pos; i < rates_total; i++) {
        bool price_in_zone = (high[i] >= zone.lower_price && low[i] <= zone.upper_price);
        
        if(price_in_zone && !in_zone) {
            touches++;
        }
        
        in_zone = price_in_zone;
    }
    
    return touches;
}

//--- Check Zone Validity
bool IsZoneValid(const Zone &zone, const datetime current_time) {
    // Check zone age
    if(current_time - zone.start_time > MAX_ZONE_AGE * PeriodSeconds()) {
        return false;
    }
    
    // Check zone strength
    if(zone.strength < ZONE_STRENGTH_THRESHOLD) {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Zone Management Functions                                          |
//+------------------------------------------------------------------+

//--- Merge Overlapping Zones
bool MergeZones(Zone &zone1, Zone &zone2, Zone &merged_zone) {
    // Check if zones overlap or are very close
    if(MathAbs(zone1.upper_price - zone2.lower_price) <= ZONE_MERGE_DISTANCE ||
       MathAbs(zone2.upper_price - zone1.lower_price) <= ZONE_MERGE_DISTANCE) {
        
        // Create merged zone
        merged_zone.start_time = MathMin(zone1.start_time, zone2.start_time);
        merged_zone.end_time = MathMax(zone1.end_time, zone2.end_time);
        merged_zone.upper_price = MathMax(zone1.upper_price, zone2.upper_price);
        merged_zone.lower_price = MathMin(zone1.lower_price, zone2.lower_price);
        merged_zone.strength = MathMax(zone1.strength, zone2.strength);
        merged_zone.is_supply = zone1.is_supply; // Assume both zones are of same type
        merged_zone.touches = zone1.touches + zone2.touches;
        merged_zone.active = true;
        
        return true;
    }
    
    return false;
}

//--- Update Zone Status
void UpdateZoneStatus(Zone &zone,
                     const double current_price,
                     const datetime current_time) {
    // Check if zone should be deactivated
    if(!IsZoneValid(zone, current_time)) {
        zone.active = false;
        return;
    }
    
    // Check if price has broken the zone
    if(zone.is_supply && current_price > zone.upper_price * 1.01) {
        zone.active = false;
    }
    else if(!zone.is_supply && current_price < zone.lower_price * 0.99) {
        zone.active = false;
    }
}

//--- Draw Zone on Chart
void DrawZone(const Zone &zone,
             const string name,
             const color zone_color,
             const double opacity = 0.3) {
    if(!zone.active) return;
    
    string obj_name = "Zone_" + name;
    
    // Create rectangle object
    ObjectCreate(0, obj_name, OBJ_RECTANGLE, 0,
                zone.start_time, zone.upper_price,
                zone.end_time, zone.lower_price);
                
    // Set object properties
    ObjectSetInteger(0, obj_name, OBJPROP_COLOR, zone_color);
    ObjectSetInteger(0, obj_name, OBJPROP_FILL, true);
    ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
    ObjectSetDouble(0, obj_name, OBJPROP_TRANSPARENCY, opacity * 100);
}
