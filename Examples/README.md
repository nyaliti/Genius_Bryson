# Genius_Bryson Examples

This directory contains example implementations demonstrating various ways to use the Genius_Bryson indicator. Each example is designed to showcase different features and integration possibilities.

## Available Examples

### 1. Basic Usage (`BasicUsage.mq5`)
A simple implementation showing the core features of Genius_Bryson:
- Pattern recognition
- Supply/Demand zone detection
- Fibonacci analysis
- Signal generation
- Basic visualization

### 2. Advanced Usage (`AdvancedUsage.mq5`)
Demonstrates advanced features and customization:
- Multiple timeframe analysis
- Custom pattern validation
- Advanced signal filtering
- Risk management integration
- Performance monitoring

### 3. Backtest Optimization (`BacktestOptimization.mq5`)
Shows how to:
- Backtest the indicator
- Optimize parameters
- Track performance metrics
- Generate performance reports
- Analyze results

### 4. Custom Patterns (`CustomPatterns.mq5`)
Examples of creating and integrating custom patterns:
- Harmonic patterns (Bat, Butterfly, Gartley)
- Three Drives pattern
- ABCD pattern
- Custom pattern visualization
- Pattern confidence calculation

### 5. External Integration (`ExternalIntegration.mq5`)
Demonstrates integration with external data sources:
- Economic calendar data
- Market sentiment analysis
- News feed integration
- External technical signals
- API communication

### 6. Automated Trading (`AutomatedTrading.mq5`)
Complete example of automated trading implementation:
- Signal execution
- Position management
- Risk management
- Trade monitoring
- Performance tracking

## Usage Instructions

1. Copy the example files to your MetaTrader 5 directory:
   ```
   MT5_Directory/MQL5/Experts/GeniusBryson/Examples/
   ```

2. Compile the desired example file in MetaEditor

3. Apply to chart:
   - Open MetaTrader 5
   - Drag the compiled example from Navigator to chart
   - Configure inputs in Properties window
   - Click "OK" to start

## Example Configuration

Each example can be configured through input parameters. Here's a basic configuration guide:

### Basic Usage
```mql5
input int    InpPatternBars = 100;        // Pattern Detection Bars
input double InpConfidenceThreshold = 75;  // Pattern Confidence
input bool   InpShowSupplyDemand = true;  // Show Supply/Demand Zones
```

### Advanced Usage
```mql5
input ENUM_TRADING_MODE InpTradingMode = MODE_MODERATE;  // Trading Mode
input double InpRiskPercent = 1.0;                       // Risk Per Trade (%)
input int    InpMaxPositions = 3;                        // Maximum Positions
```

### Backtest Optimization
```mql5
input datetime InpStartDate = D'2023.01.01';  // Backtest Start Date
input datetime InpEndDate = D'2023.12.31';    // Backtest End Date
input double   InpConfidenceMin = 65.0;       // Min Pattern Confidence
```

## Best Practices

1. Always test examples on demo account first
2. Start with BasicUsage.mq5 to understand core functionality
3. Gradually explore more advanced examples
4. Customize parameters based on your trading style
5. Monitor system resource usage
6. Keep logs for troubleshooting

## Resource Usage

Examples are optimized for performance but may require significant resources:
- BasicUsage: Low resource usage
- AdvancedUsage: Moderate resource usage
- BacktestOptimization: High resource usage during testing
- CustomPatterns: Moderate resource usage
- ExternalIntegration: Varies based on API calls
- AutomatedTrading: Moderate to high resource usage

## Troubleshooting

Common issues and solutions:

1. Compilation Errors
   - Verify all required files are present
   - Check include paths
   - Update MetaEditor

2. Runtime Errors
   - Check error log
   - Verify parameter values
   - Monitor system resources

3. Performance Issues
   - Reduce update frequency
   - Limit number of patterns
   - Optimize timeframe selection

## Support

For issues or questions:
- Email: bnyaliti@gmail.com
- Phone: +254745959794
- Create GitHub issue

## Contributing

Feel free to:
1. Submit bug reports
2. Suggest improvements
3. Share your customizations
4. Contribute new examples

## License

All examples are covered under the main project's MIT License.

## Version History

See main [CHANGELOG.md](../CHANGELOG.md) for version history and updates.

---

For more detailed documentation, refer to the main project documentation files.
