import SwiftUI
import ColorsKit

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var baseColor = "#0A84FF"
    @State private var selectedEmotion: EmotionalCategory = .energetic
    @State private var selectedHarmony: ColorHarmonyType = .complementary
    @State private var selectedBlendMode: ColorsKit.BlendMode = .multiply
    @State private var temperature: Double = 6500
    @State private var tint: Double = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
                // Color Harmony Tab
                ColorHarmonyView(baseColor: $baseColor, selectedHarmony: $selectedHarmony)
                    .tabItem {
                        Image(systemName: "paintpalette")
                        Text("Harmony")
                    }
                    .tag(0)
                
                // Perceptual Colors Tab
                PerceptualColorsView()
                    .tabItem {
                        Image(systemName: "eye")
                        Text("Perceptual")
                    }
                    .tag(1)
                
                // Blending Modes Tab
                BlendingModesView()
                    .tabItem {
                        Image(systemName: "square.on.square")
                        Text("Blending")
                    }
                    .tag(2)
                
                // Color Psychology Tab
                ColorPsychologyView()
                    .tabItem {
                        Image(systemName: "brain.head.profile")
                        Text("Psychology")
                    }
                    .tag(3)
                
                // Data Visualization Tab
                DataVisualizationView()
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Data Viz")
                    }
                    .tag(4)
                
                // Temperature & Gradients Tab
                TemperatureGradientsView()
                    .tabItem {
                        Image(systemName: "thermometer")
                        Text("Temperature")
                    }
                    .tag(5)
        }
    }
}

#Preview {
    ContentView()
}