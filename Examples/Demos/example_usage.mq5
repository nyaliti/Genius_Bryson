# Example Usage of Genius Bryson Indicator

// This script demonstrates how to attach the Genius Bryson indicator to a chart and customize its settings.

input int period = 14; // Example input for a moving average period
input color patternColor = clrBlue; // Color for chart patterns
input color fibColor = clrRed; // Color for Fibonacci levels

// Attach the Genius Bryson indicator
void OnStart()
{
    // Check if the indicator is available
    if (IndicatorCreate(0, "Genius Bryson", 0, 0) == 0)
    {
        Print("Genius Bryson indicator attached successfully.");
    }
    else
    {
        Print("Failed to attach Genius Bryson indicator.");
    }

    // Customize settings
    SetIndicatorColor(0, patternColor);
    SetFibonacciColor(fibColor);
}

// Function to set the color of the indicator patterns
void SetIndicatorColor(int index, color color)
{
    // Set the color for the specified index
    IndicatorSetInteger(index, INDICATOR_COLOR, color);
}

// Function to set the color of Fibonacci levels
void SetFibonacciColor(color color)
{
    // Set the color for Fibonacci levels
    IndicatorSetInteger(0, INDICATOR_FIB_COLOR, color);
}
