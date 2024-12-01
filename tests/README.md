# Genius_Bryson Test Suite

This directory contains the test suite for the Genius_Bryson indicator. The tests ensure reliability, accuracy, and performance of all components.

## Test Structure

```
tests/
├── config.json              # Test configuration
├── GeniusBrysonTest.mq5    # Main test runner
├── test_data/              # Test data files
│   ├── patterns/           # Pattern test data
│   ├── zones/             # Zone test data
│   └── signals/           # Signal test data
└── test_results/          # Test results output
    ├── reports/           # Test reports
    ├── charts/            # Generated charts
    └── logs/             # Test logs
```

## Running Tests

### Prerequisites
1. MetaTrader 5 Platform
2. Compiled Genius_Bryson indicator
3. Test data files (provided or generated)

### Steps to Run Tests

1. **Setup**
   ```bash
   # Copy test files to MT5 directory
   cp -r tests/* "MT5_Directory/MQL5/Experts/GeniusBryson/tests/"
   ```

2. **Configure Tests**
   - Edit `config.json` to set test parameters
   - Adjust test data paths if needed
   - Set output directories

3. **Run Tests**
   - Open MetaEditor
   - Compile `GeniusBrysonTest.mq5`
   - Apply to chart in MT5
   - Tests will run automatically

## Test Categories

### 1. Pattern Recognition Tests
- Flag patterns
- Pennants
- Channels
- Triangles
- Head & Shoulders
- Double/Triple Tops/Bottoms
- Rounding Bottom
- Cup and Handle

### 2. Zone Detection Tests
- Supply zone identification
- Demand zone identification
- Zone strength calculation
- Zone merging logic

### 3. Fibonacci Analysis Tests
- Level calculation
- Swing point detection
- Zone highlighting
- Retracement validation

### 4. Signal Generation Tests
- Buy/Sell signal generation
- Signal strength calculation
- Confluence analysis
- Risk/Reward calculation

### 5. Performance Tests
- Processing speed
- Memory usage
- Resource utilization
- Optimization checks

## Configuration Options

### Test Settings
```json
{
    "test_settings": {
        "default": {
            "symbol": "EURUSD",
            "timeframe": "PERIOD_H1",
            "start_date": "2023.01.01",
            "end_date": "2023.12.31"
        }
    }
}
```

### Performance Criteria
```json
{
    "performance_tests": {
        "pattern_recognition": {
            "min_accuracy": 85.0,
            "max_false_positives": 15.0
        }
    }
}
```

## Test Data

### Using Provided Data
Test data is provided in CSV format:
```csv
datetime,open,high,low,close,volume
2023.01.01 00:00,1.2000,1.2010,1.1990,1.2005,1000
...
```

### Generating Test Data
Use the data generation utilities:
```mql5
// Generate pattern test data
GeneratePatternTestData(PATTERN_FLAG, 100);

// Generate zone test data
GenerateZoneTestData(ZONE_SUPPLY, 100);
```

## Test Results

### Output Format
```json
{
    "test_name": "Flag Pattern Detection",
    "status": "PASSED",
    "accuracy": 87.5,
    "execution_time": 0.15,
    "details": {
        "true_positives": 35,
        "false_positives": 5
    }
}
```

### Performance Metrics
- Accuracy
- Precision
- Recall
- F1 Score
- Processing Time
- Memory Usage

## Troubleshooting

### Common Issues

1. **Test Data Not Found**
   ```
   Solution: Verify test_data directory path in config.json
   ```

2. **Memory Errors**
   ```
   Solution: Adjust batch sizes in test configuration
   ```

3. **Performance Issues**
   ```
   Solution: Reduce test data size or optimize test parameters
   ```

### Debug Mode
Enable detailed logging:
```json
{
    "reporting": {
        "save_detailed_logs": true
    }
}
```

## Contributing

### Adding New Tests
1. Create test data file
2. Add test case to config.json
3. Implement test in GeniusBrysonTest.mq5
4. Update documentation

### Test Guidelines
- Write clear test descriptions
- Include both positive and negative cases
- Test edge cases
- Verify results thoroughly
- Document any assumptions

## Support

For test-related issues:
- Email: bnyaliti@gmail.com
- Phone: +254745959794
- Create GitHub issue

## Version Control

- Test files are versioned with main project
- Test data is versioned separately
- Results are not versioned (generated)

## Future Improvements

1. Automated test data generation
2. Continuous integration setup
3. Performance benchmarking
4. Extended test coverage
5. Real-time testing capabilities

---

For more information, refer to the main project documentation.
