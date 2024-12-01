# Installation Guide for Genius_Bryson

This guide will walk you through the process of installing and setting up Genius_Bryson in your MetaTrader 5 platform.

## System Requirements

- MetaTrader 5 Platform (Latest version recommended)
- Windows 8.1 or higher
- Minimum 4GB RAM
- Internet connection for real-time analysis
- Active MT5 trading account (Demo or Live)

## Installation Steps

### 1. Download the Files

#### Option A: Via GitHub
1. Clone the repository:
   ```bash
   git clone https://github.com/nyaliti/Genius_Bryson.git
   ```
2. Navigate to the downloaded folder:
   ```bash
   cd Genius_Bryson
   ```

#### Option B: Direct Download
1. Visit [Releases](https://github.com/nyaliti/Genius_Bryson/releases)
2. Download the latest version
3. Extract the downloaded ZIP file

### 2. Install in MetaTrader 5

1. Open MetaTrader 5
2. Navigate to `File > Open Data Folder`
3. In the opened folder, go to:
   - For indicators: `MQL5/Indicators/`
   - For scripts: `MQL5/Scripts/`
4. Copy the respective files from Genius_Bryson to these folders:
   ```
   GeniusBryson.ex5 → MQL5/Indicators/
   GeniusBrysonHelper.ex5 → MQL5/Scripts/
   ```

### 3. Restart MetaTrader 5

1. Close MetaTrader 5 completely
2. Reopen MetaTrader 5
3. Verify installation:
   - Open Navigator window (Ctrl+N)
   - Look for "Genius_Bryson" under Custom Indicators

### 4. Apply to Chart

1. Drag and drop "Genius_Bryson" from Navigator to any chart
2. Configure initial settings in the properties window:
   - Pattern Recognition settings
   - Color schemes
   - Alert preferences
   - Analysis timeframes

## Configuration

### Basic Settings

```
Pattern Recognition:
- Minimum pattern size: 10 candles
- Maximum pattern lookback: 100 candles
- Pattern confidence threshold: 75%

Fibonacci Settings:
- Auto-drawn levels: -0.618, 0, 0.5, 0.618, 1, 1.618
- Zone highlight: 0.5-0.618 area

Visual Settings:
- Supply zone color: Light red
- Demand zone color: Light green
- Pattern lines: Blue
- Fibonacci lines: Golden
```

### Advanced Configuration

For advanced users, you can modify the following files:
- `config/patterns.ini` - Pattern recognition parameters
- `config/visual.ini` - Visual settings
- `config/alerts.ini` - Alert configurations

## Troubleshooting

### Common Issues

1. Indicator not showing in Navigator
   - Solution: Verify file placement in correct directory
   - Check for compilation errors in MetaEditor

2. Pattern Recognition not working
   - Solution: Verify minimum chart data loaded
   - Check timeframe settings

3. Visual elements not displaying
   - Solution: Check "Visual" settings in Properties
   - Verify chart template compatibility

### Error Codes

- E001: Installation path error
- E002: Configuration file missing
- E003: Memory allocation error
- E004: Data processing error

## Support

If you encounter any issues:

1. Check the [FAQ](FAQ.md)
2. Review [Troubleshooting Guide](TROUBLESHOOTING.md)
3. Contact support:
   - Email: bnyaliti@gmail.com
   - Phone: +254745959794
   - Create an issue on GitHub

## Updates

- Enable "Auto Update" in settings
- Check GitHub releases page regularly
- Subscribe to update notifications

## Uninstallation

1. Remove indicator from charts
2. Delete files from MT5 directories
3. Clear cache (optional):
   ```
   %APPDATA%/MetaTrader 5/Cache
   ```

## Next Steps

- Read the [Usage Guide](USAGE.md)
- Review [Examples](Examples/)
- Join the community forum

---

For additional support or custom installation requirements, please contact Bryson Omullo directly.
