# Genius_Bryson Test Data

This directory contains sample test data files used for testing and validating the Genius_Bryson indicator's functionality.

## Directory Structure

```
test_data/
├── patterns/           # Chart pattern test data
│   └── flag_pattern.csv
├── zones/             # Supply/Demand zone test data
│   └── supply_zone.csv
├── fibonacci/         # Fibonacci analysis test data
│   └── fibonacci_trend.csv
└── signals/           # Trading signal test data
    ├── buy_signal.csv
    └── sell_signal.csv
```

## Data Format

All test data files follow a standard CSV format:

```csv
datetime,open,high,low,close,volume
2024.01.01 00:00,1.2000,1.2010,1.1990,1.2005,1000
```

### Fields Description
- `datetime`: Date and time in "YYYY.MM.DD HH:MM" format
- `open`: Opening price
- `high`: Highest price during the period
- `low`: Lowest price during the period
- `close`: Closing price
- `volume`: Trading volume

## Test Data Sets

### Pattern Test Data
Located in `patterns/` directory:
- `flag_pattern.csv`: Contains price data forming a flag pattern
  - Trend: Upward
  - Pattern Duration: 10 periods
  - Volume Profile: Increasing during pattern formation

### Zone Test Data
Located in `zones/` directory:
- `supply_zone.csv`: Contains price data with supply zone formation
  - Zone Formation: Strong rejection from supply level
  - Volume Profile: Higher than average during zone formation
  - Price Action: Clear reversal after zone test

### Fibonacci Test Data
Located in `fibonacci/` directory:
- `fibonacci_trend.csv`: Contains price data for Fibonacci analysis
  - Trend: Clear uptrend followed by retracement
  - Key Levels: Contains 0.5 and 0.618 retracement levels
  - Price Action: Respects Fibonacci levels

### Signal Test Data
Located in `signals/` directory:
- `buy_signal.csv`: Contains data triggering buy signals
  - Pattern: Bullish trend development
  - Volume: Increasing on breakouts
  - Support/Resistance: Clear level breaks

- `sell_signal.csv`: Contains data triggering sell signals
  - Pattern: Bearish trend development
  - Volume: Increasing on breakdowns
  - Support/Resistance: Clear level breaks

## Usage

### Loading Test Data
```mql5
// Example of loading test data in MQL5
string filename = "test_data/patterns/flag_pattern.csv";
int handle = FileOpen(filename, FILE_READ|FILE_CSV);
if(handle != INVALID_HANDLE) {
    // Skip header
    FileReadString(handle);
    
    // Read data
    while(!FileIsEnding(handle)) {
        datetime time = StringToTime(FileReadString(handle));
        double open = StringToDouble(FileReadString(handle));
        double high = StringToDouble(FileReadString(handle));
        double low = StringToDouble(FileReadString(handle));
        double close = StringToDouble(FileReadString(handle));
        long volume = StringToInteger(FileReadString(handle));
        
        // Process data...
    }
    FileClose(handle);
}
```

### Running Tests
1. Copy test data to MT5 directory:
   ```
   MT5_Directory/MQL5/Files/GeniusBryson/test_data/
   ```

2. Use in test scripts:
   ```mql5
   // Example test case
   bool TestFlagPattern() {
       // Load test data
       LoadTestData("patterns/flag_pattern.csv");
       
       // Run pattern detection
       bool pattern_found = DetectFlag(rates, 0, 10);
       
       // Verify results
       Assert(pattern_found == true, "Flag pattern not detected");
       return pattern_found;
   }
   ```

## Data Generation

Test data can be generated using the `TestDataGenerator.mq5` script:

```mql5
// Generate new test data
TestDataGenerator generator;
generator.GeneratePatternData(PATTERN_FLAG, 100);
```

## Contributing

When adding new test data:
1. Follow the established CSV format
2. Include clear pattern/signal formation
3. Use realistic price movements
4. Document data characteristics
5. Verify data quality

## Validation

Test data is validated for:
- Format consistency
- Price range realism
- Volume profile accuracy
- Pattern clarity
- Signal strength

## Notes

- All price data uses 5 decimal places
- Volume is integer-based
- Datetime uses MT5 standard format
- Files contain 10 periods minimum
- Price movements are realistic

## Support

For issues with test data:
- Email: bnyaliti@gmail.com
- Phone: +254745959794
- Create GitHub issue
