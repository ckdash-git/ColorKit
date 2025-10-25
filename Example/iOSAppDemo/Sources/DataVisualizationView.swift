import SwiftUI
import ColorsKit

struct DataVisualizationView: View {
    @State private var selectedGradientType: DataVisualizationType = .sequential
    @State private var gradientSteps = 7
    @State private var generatedGradient: [String] = []
    @State private var sampleData: [Double] = [0.1, 0.3, 0.5, 0.7, 0.9, 0.4, 0.8, 0.2, 0.6]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Data Visualization Gradients")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Gradient Type Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gradient Type")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Picker("Gradient Type", selection: $selectedGradientType) {
                        ForEach(DataVisualizationType.allCases, id: \.self) { type in
                            Text(type.displayName)
                                .tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Steps: \(gradientSteps)")
                            .font(.subheadline)
                            .padding(.horizontal)
                        
                        Slider(value: Binding(
                            get: { Double(gradientSteps) },
                            set: { gradientSteps = Int($0) }
                        ), in: 3...12, step: 1)
                        .padding(.horizontal)
                    }
                    
                    Button("Generate Gradient") {
                        generateGradient()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // Generated Gradient Display
                if !generatedGradient.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Generated Gradient")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Gradient Bar
                        HStack(spacing: 2) {
                            ForEach(generatedGradient, id: \.self) { colorHex in
                                Rectangle()
                                    .fill(Color(hex: colorHex) ?? Color.gray)
                                    .frame(height: 60)
                            }
                        }
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        // Color Values
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(gradientSteps, 4)), spacing: 8) {
                            ForEach(Array(generatedGradient.enumerated()), id: \.offset) { index, colorHex in
                                VStack(spacing: 4) {
                                    Rectangle()
                                        .fill(Color(hex: colorHex) ?? Color.gray)
                                        .frame(height: 40)
                                        .cornerRadius(6)
                                    
                                    Text(colorHex)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Sample Data Visualization
                if !generatedGradient.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sample Data Visualization")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Bar Chart
                        HStack(alignment: .bottom, spacing: 4) {
                            ForEach(Array(sampleData.enumerated()), id: \.offset) { index, value in
                                let colorIndex = min(Int(value * Double(generatedGradient.count - 1)), generatedGradient.count - 1)
                                let colorHex = generatedGradient[colorIndex]
                                
                                VStack(spacing: 4) {
                                    Rectangle()
                                        .fill(Color(hex: colorHex) ?? Color.gray)
                                        .frame(width: 30, height: CGFloat(value * 100))
                                        .cornerRadius(4)
                                    
                                    Text("\(Int(value * 100))")
                                        .font(.caption2)
                                }
                            }
                        }
                        .frame(height: 120)
                        .padding(.horizontal)
                        
                        // Heatmap Grid
                        Text("Heatmap Sample")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 2) {
                            ForEach(0..<24, id: \.self) { index in
                                let value = Double.random(in: 0...1)
                                let colorIndex = min(Int(value * Double(generatedGradient.count - 1)), generatedGradient.count - 1)
                                let colorHex = generatedGradient[colorIndex]
                                
                                Rectangle()
                                    .fill(Color(hex: colorHex) ?? Color.gray)
                                    .frame(height: 30)
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Gradient Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Gradient Information")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(selectedGradientType.description)
                            .font(.body)
                            .padding(.horizontal)
                        
                        Text("Best Use Cases:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal)
                        
                        ForEach(selectedGradientType.useCases, id: \.self) { useCase in
                            Text("• \(useCase)")
                                .font(.caption)
                                .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            generateGradient()
        }
        .onChange(of: selectedGradientType) { _ in generateGradient() }
        .onChange(of: gradientSteps) { _ in generateGradient() }
    }
    
    private func generateGradient() {
        generatedGradient = GradientGenerator.generateDataVisualizationGradient(
            type: selectedGradientType,
            steps: gradientSteps
        )
    }
}

extension DataVisualizationType: @retroactive CaseIterable {
    public static var allCases: [DataVisualizationType] {
        return [.sequential, .diverging, .heatmap, .viridis, .plasma, .temperature]
    }
    
    var displayName: String {
        switch self {
        case .sequential: return "Sequential"
        case .diverging: return "Diverging"
        case .heatmap: return "Heatmap"
        case .viridis: return "Viridis"
        case .plasma: return "Plasma"
        case .temperature: return "Temperature"
        }
    }
    
    var description: String {
        switch self {
        case .sequential:
            return "Sequential gradients show progression from low to high values using a single hue with varying lightness and saturation."
        case .diverging:
            return "Diverging gradients emphasize deviations from a central value, using two contrasting hues that meet at a neutral midpoint."
        case .heatmap:
            return "Heatmap gradients use the classic blue-to-red spectrum, ideal for showing intensity or density data."
        case .viridis:
            return "Viridis is a perceptually uniform colormap that works well for scientific data visualization and is colorblind-friendly."
        case .plasma:
            return "Plasma provides high contrast and perceptual uniformity, excellent for highlighting data patterns and outliers."
        case .temperature:
            return "Temperature gradients simulate thermal imaging, progressing from cool blues through warm reds to hot whites."
        }
    }
    
    var useCases: [String] {
        switch self {
        case .sequential:
            return ["Population density maps", "Sales performance charts", "Progress indicators", "Elevation maps"]
        case .diverging:
            return ["Temperature anomalies", "Survey responses", "Financial gains/losses", "Correlation matrices"]
        case .heatmap:
            return ["Website analytics", "Correlation matrices", "Density plots", "Activity tracking"]
        case .viridis:
            return ["Scientific data", "Medical imaging", "Accessibility-focused charts", "Academic publications"]
        case .plasma:
            return ["Astronomical data", "High-contrast visualizations", "Pattern detection", "Outlier identification"]
        case .temperature:
            return ["Thermal imaging", "Weather maps", "Heat distribution", "Energy consumption"]
        }
    }
}

#Preview {
    DataVisualizationView()
}