# Troubleshooting Guide for Genius_Bryson

This guide helps you diagnose and resolve common issues that may arise while using the Genius_Bryson indicator.

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Pattern Recognition Issues](#pattern-recognition-issues)
3. [Zone Detection Issues](#zone-detection-issues)
4. [Signal Generation Issues](#signal-generation-issues)
5. [Performance Issues](#performance-issues)
6. [Visual Issues](#visual-issues)
7. [Alert Issues](#alert-issues)
8. [Common Error Codes](#common-error-codes)

## Installation Issues

### Indicator Not Showing in Navigator

**Symptoms:**
- Indicator doesn't appear in MT5 Navigator window
- "Invalid parameter" error when adding to chart

**Solutions:**
1. Verify file placement:
   ```
   MT5_Directory/MQL5/Indicators/GeniusBryson.ex5
   MT5_Directory/MQL5/Include/GeniusBryson/*.mqh
   ```
2. Check file permissions
3. Restart MetaTrader 5
4. Recompile indicator

### Compilation Errors

**Symptoms:**
- Error messages during compilation
- Indicator fails to compile

**Solutions:**
1. Verify all required files are present
2. Check MQL5 include paths
3. Update MetaEditor
4. Clear compiler cache

## Pattern Recognition Issues

### Patterns Not Detected

**Symptoms:**
- Known patterns aren't being identified
- False pattern detections

**Solutions:**
1. Check pattern settings:
   ```mql5
   settings.Patterns.MinPatternBars = 10;
   settings.Patterns.ConfidenceThreshold = 75.0;
   ```
2. Verify sufficient price history
3. Adjust pattern sensitivity

### Incorrect Pattern Classification

**Symptoms:**
- Patterns misidentified
- Wrong pattern types reported

**Solutions:**
1. Increase confidence threshold
2. Verify pattern size requirements
3. Check market context settings

## Zone Detection Issues

### Zones Not Displaying

**Symptoms:**
- Supply/Demand zones not visible
- Zones disappear unexpectedly

**Solutions:**
1. Check zone settings:
   ```mql5
   settings.Zones.MinZoneBars = 5;
   settings.Zones.ZoneStrength = 70.0;
   ```
2. Verify zone visualization settings
3. Check zone age limits

### Incorrect Zone Strength

**Symptoms:**
- Zone strength seems incorrect
- Zones not reflecting market conditions

**Solutions:**
1. Adjust strength calculation parameters
2. Verify volume confirmation
3. Check zone validation criteria

## Signal Generation Issues

### No Signals Generated

**Symptoms:**
- No trading signals appear
- Missing entry/exit points

**Solutions:**
1. Check signal settings:
   ```mql5
   settings.Signals.MinSignalStrength = 70.0;
   settings.Signals.MinConfluence = 3;
   ```
2. Verify confluence factors
3. Check market conditions

### False Signals

**Symptoms:**
- Too many signals
- Inaccurate signals

**Solutions:**
1. Increase signal strength threshold
2. Adjust confluence requirements
3. Verify signal validation criteria

## Performance Issues

### Slow Chart Updates

**Symptoms:**
- Delayed indicator response
- High CPU usage

**Solutions:**
1. Optimize settings:
   ```mql5
   settings.Patterns.MaxPatternBars = 100;
   settings.Zones.DeleteInactive = true;
   ```
2. Reduce calculation frequency
3. Clear chart objects regularly

### Memory Usage

**Symptoms:**
- High memory consumption
- System slowdown

**Solutions:**
1. Enable automatic cleanup
2. Reduce history buffer
3. Optimize object management

## Visual Issues

### Display Problems

**Symptoms:**
- Objects not displaying correctly
- Visual elements misaligned

**Solutions:**
1. Check visual settings:
   ```mql5
   settings.Colors.PatternLines = clrBlue;
   settings.Colors.ZoneOpacity = 0.3;
   ```
2. Verify chart properties
3. Reset visual elements

### Chart Clutter

**Symptoms:**
- Too many objects on chart
- Overlapping elements

**Solutions:**
1. Enable automatic cleanup
2. Adjust display settings
3. Filter less important elements

## Alert Issues

### Alerts Not Working

**Symptoms:**
- Missing notifications
- Silent alerts

**Solutions:**
1. Check alert settings:
   ```mql5
   settings.Alerts.EnablePopup = true;
   settings.Alerts.EnableSound = true;
   ```
2. Verify MT5 notification settings
3. Check sound file existence

### Too Many Alerts

**Symptoms:**
- Excessive notifications
- Alert spam

**Solutions:**
1. Adjust alert conditions
2. Increase alert thresholds
3. Filter alert types

## Common Error Codes

### Error 4001: Array Out of Range

**Cause:** Insufficient price data or buffer overflow

**Solutions:**
1. Check data requirements:
   ```mql5
   if(rates_total < InpPatternBars) return(0);
   ```
2. Verify array sizes
3. Check buffer allocations

### Error 4102: Invalid Handle

**Cause:** Failed to create indicator handle

**Solutions:**
1. Check indicator initialization:
   ```mql5
   if(handle == INVALID_HANDLE) {
       Print("Failed to create indicator handle");
       return(INIT_FAILED);
   }
   ```
2. Verify indicator parameters
3. Check available memory

### Error 4201: Object Already Exists

**Cause:** Duplicate chart objects

**Solutions:**
1. Use unique object names:
   ```mql5
   string obj_name = prefix + "_" + TimeToString(time);
   if(ObjectFind(0, obj_name) >= 0) {
       ObjectDelete(0, obj_name);
   }
   ```
2. Clean up old objects
3. Check object management

## Additional Resources

### Logging

Enable detailed logging for troubleshooting:
```mql5
Logger.SetLogLevel(LOG_DEBUG);
Logger.EnableFileOutput(true);
```

### Debug Mode

Activate debug mode for additional information:
```mql5
#define DEBUG_MODE
#ifdef DEBUG_MODE
    Print("Debug: ", debug_info);
#endif
```

### Support Contacts

For additional support:
- Email: bnyaliti@gmail.com
- Phone: +254745959794
- GitHub Issues: [Report a Bug](https://github.com/nyaliti/Genius_Bryson/issues)

## Version-Specific Issues

Check [CHANGELOG.md](CHANGELOG.md) for version-specific issues and their resolutions.

---

If you encounter issues not covered in this guide, please contact support with:
1. Error message/description
2. Steps to reproduce
3. Indicator settings
4. MT5 version
5. System specifications
