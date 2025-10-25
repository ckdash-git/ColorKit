# ColorsKit iOS Demo App

This directory contains a comprehensive SwiftUI demo app showcasing all advanced ColorsKit features.

## Features Demonstrated

### 🎨 Color Harmony
- Generate complementary, analogous, triadic, tetradic, split complementary, and monochromatic color schemes
- Interactive color picker and harmony type selection
- Accessibility analysis for generated colors

### 🔬 Perceptual Color Spaces
- Color space conversions (RGBA, XYZ, LAB, LUV)
- Perceptual vs. regular gradient comparison
- Delta E analysis for perceptual uniformity
- Customizable blend steps

### 🎭 Advanced Color Blending
- 12 different blend modes (multiply, screen, overlay, soft light, etc.)
- Interactive base and overlay color selection
- Real-time blend mode gallery preview
- Visual blend result comparison

### 🧠 Color Psychology Engine
- Emotion-based color generation (calm, energetic, warm, cool, etc.)
- Color emotional analysis with confidence scores
- Multi-emotion palette generation
- Primary emotion detection

### 📊 Data Visualization Gradients
- Sequential, diverging, heatmap gradients
- Scientific colormaps (Viridis, Plasma)
- Temperature gradients for thermal imaging
- Sample data visualization with bar charts and heatmaps

### 🌡️ Temperature & Advanced Gradients
- Multiple interpolation methods (Linear, Perceptual, HSL, Bézier, Ease)
- Animated gradient transitions
- Temperature preset gradients
- Real-time gradient generation

## Setup Options

### Option 1: Xcode Project (Recommended)
1. Open `ColorsKitDemo.xcodeproj` in Xcode
2. The project is already configured with ColorsKit as a local package dependency
3. Build and run the app

### Option 2: Swift Package Manager
1. Navigate to this directory in Terminal
2. Run `swift build` to build the package
3. Use the Package.swift for integration into other projects

## Project Structure

```
iOSAppDemo/
├── ColorsKitDemo.xcodeproj/     # Xcode project file
├── ColorsKitDemo/               # Source files
│   ├── App.swift               # Main app entry point
│   ├── ContentView.swift       # Main tab view
│   ├── ColorHarmonyView.swift  # Color harmony demo
│   ├── PerceptualColorsView.swift # Perceptual color spaces
│   ├── BlendingModesView.swift # Color blending modes
│   ├── ColorPsychologyView.swift # Color psychology engine
│   ├── DataVisualizationView.swift # Data viz gradients
│   └── TemperatureGradientsView.swift # Advanced gradients
├── Sources/                    # Swift Package sources (mirror)
├── Package.swift              # Swift Package configuration
└── README.md                  # This file
```

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Advanced Features Showcased

### Color Psychology Engine
- **Emotional Categories**: Calm, Energetic, Warm, Cool, Happy, Melancholy, Sophisticated, Playful, Natural, Neutral
- **Color Analysis**: HSL-based emotional profiling with confidence scores
- **Palette Generation**: Multi-emotion color palette creation

### Perceptual Color Mathematics
- **Color Spaces**: RGBA, XYZ, LAB, LUV conversions
- **Delta E Calculations**: CIE Delta E 2000 for perceptual color differences
- **Uniform Gradients**: Perceptually uniform color transitions

### Data Visualization
- **Scientific Colormaps**: Viridis, Plasma for research applications
- **Specialized Gradients**: Sequential, diverging, heatmap types
- **Real-world Examples**: Bar charts, heatmaps, thermal imaging

### Advanced Interpolation
- **Multiple Methods**: Linear RGB, Perceptual LAB, HSL, Bézier curves
- **Animation Support**: Smooth gradient transitions for UI animations
- **Temperature Mapping**: Thermal imaging color schemes

This demo app serves as both a showcase and a reference implementation for integrating ColorsKit's advanced features into iOS applications.