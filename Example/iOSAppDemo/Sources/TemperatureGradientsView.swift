import SwiftUI
import ColorsKit

struct TemperatureGradientsView: View {
    @State private var selectedInterpolation: GradientInterpolation = .linear
    @State private var startColor = "#0066CC"
    @State private var endColor = "#FF3366"
    @State private var gradientSteps = 8
    @State private var generatedGradient: [String] = []
    @State private var animationProgress: Double = 0.0
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Temperature & Advanced Gradients")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Color Input Section
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Start Color")
                                .font(.headline)
                            HStack {
                                TextField("Hex color", text: $startColor)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Rectangle()
                                    .fill(Color(hex: startColor) ?? Color.gray)
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(8)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("End Color")
                                .font(.headline)
                            HStack {
                                TextField("Hex color", text: $endColor)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Rectangle()
                                    .fill(Color(hex: endColor) ?? Color.gray)
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Interpolation Method")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Picker("Interpolation", selection: $selectedInterpolation) {
                            ForEach(GradientInterpolation.allCases, id: \.self) { method in
                                Text(method.displayName)
                                    .tag(method)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Steps: \(gradientSteps)")
                            .font(.subheadline)
                            .padding(.horizontal)
                        
                        Slider(value: Binding(
                            get: { Double(gradientSteps) },
                            set: { gradientSteps = Int($0) }
                        ), in: 3...15, step: 1)
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
                        Text("Generated Gradient (\(selectedInterpolation.displayName))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Gradient Bar
                        HStack(spacing: 1) {
                            ForEach(generatedGradient, id: \.self) { colorHex in
                                Rectangle()
                                    .fill(Color(hex: colorHex) ?? Color.gray)
                                    .frame(height: 80)
                            }
                        }
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        // Color Values Grid
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
                
                // Animation Demo
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gradient Animation")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        // Animated Progress Bar
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Progress: \(Int(animationProgress * 100))%")
                                .font(.subheadline)
                                .padding(.horizontal)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 20)
                                        .cornerRadius(10)
                                    
                                    Rectangle()
                                        .fill(getAnimatedColor())
                                        .frame(width: geometry.size.width * animationProgress, height: 20)
                                        .cornerRadius(10)
                                        .animation(.easeInOut(duration: 0.3), value: animationProgress)
                                }
                            }
                            .frame(height: 20)
                            .padding(.horizontal)
                        }
                        
                        // Animation Controls
                        HStack(spacing: 16) {
                            Button(isAnimating ? "Stop" : "Start Animation") {
                                toggleAnimation()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Reset") {
                                resetAnimation()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        // Manual Progress Control
                        VStack(alignment: .leading) {
                            Text("Manual Progress")
                                .font(.subheadline)
                                .padding(.horizontal)
                            
                            Slider(value: $animationProgress, in: 0...1)
                                .padding(.horizontal)
                                .disabled(isAnimating)
                        }
                    }
                }
                
                // Temperature Presets
                VStack(alignment: .leading, spacing: 16) {
                    Text("Temperature Presets")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(TemperaturePreset.allCases, id: \.self) { preset in
                            Button(action: {
                                applyTemperaturePreset(preset)
                            }) {
                                VStack(spacing: 8) {
                                    HStack(spacing: 1) {
                                        ForEach(preset.colors, id: \.self) { colorHex in
                                            Rectangle()
                                                .fill(Color(hex: colorHex) ?? Color.gray)
                                                .frame(height: 40)
                                        }
                                    }
                                    .cornerRadius(6)
                                    
                                    Text(preset.displayName)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Interpolation Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Interpolation Methods")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Text(selectedInterpolation.description)
                        .font(.body)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .onAppear {
            generateGradient()
        }
        .onChange(of: startColor) { _ in generateGradient() }
        .onChange(of: endColor) { _ in generateGradient() }
        .onChange(of: selectedInterpolation) { _ in generateGradient() }
        .onChange(of: gradientSteps) { _ in generateGradient() }
    }
    
    private func generateGradient() {
        guard let start = try? HexColorFormatter.parse(startColor),
              let end = try? HexColorFormatter.parse(endColor) else {
            return
        }
        
        generatedGradient = GradientGenerator.generateGradient(
            from: start,
            to: end,
            steps: gradientSteps,
            interpolation: selectedInterpolation
        )
    }
    
    private func getAnimatedColor() -> Color {
        guard !generatedGradient.isEmpty else { return Color.gray }
        
        let index = min(Int(animationProgress * Double(generatedGradient.count - 1)), generatedGradient.count - 1)
        return Color(hex: generatedGradient[index]) ?? Color.gray
    }
    
    private func toggleAnimation() {
        if isAnimating {
            isAnimating = false
        } else {
            isAnimating = true
            animateProgress()
        }
    }
    
    private func animateProgress() {
        guard isAnimating else { return }
        
        withAnimation(.linear(duration: 0.05)) {
            animationProgress += 0.02
            if animationProgress >= 1.0 {
                animationProgress = 0.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            animateProgress()
        }
    }
    
    private func resetAnimation() {
        isAnimating = false
        animationProgress = 0.0
    }
    
    private func applyTemperaturePreset(_ preset: TemperaturePreset) {
        startColor = preset.colors.first ?? "#000000"
        endColor = preset.colors.last ?? "#FFFFFF"
        generateGradient()
    }
}

extension GradientInterpolation {
    var displayName: String {
        switch self {
        case .linear: return "Linear RGB"
        case .perceptual: return "Perceptual (LAB)"
        case .hsl: return "HSL"
        case .bezier: return "Bézier"
        case .ease: return "Ease"
        }
    }
    
    var description: String {
        switch self {
        case .linear:
            return "Linear interpolation in RGB color space. Simple and fast, but may produce muddy colors in the middle."
        case .perceptual:
            return "Perceptually uniform interpolation using LAB color space. Produces more natural-looking gradients."
        case .hsl:
            return "Interpolation in HSL color space, maintaining hue relationships for more vibrant transitions."
        case .bezier:
            return "Smooth Bézier curve interpolation for elegant, non-linear color transitions."
        case .ease:
            return "Eased interpolation with smooth acceleration and deceleration for natural motion."
        }
    }
}

enum TemperaturePreset: String, CaseIterable {
    case coolToWarm = "coolToWarm"
    case thermal = "thermal"
    case arctic = "arctic"
    case sunset = "sunset"
    case ocean = "ocean"
    case fire = "fire"
    
    var displayName: String {
        switch self {
        case .coolToWarm: return "Cool to Warm"
        case .thermal: return "Thermal"
        case .arctic: return "Arctic"
        case .sunset: return "Sunset"
        case .ocean: return "Ocean Depths"
        case .fire: return "Fire"
        }
    }
    
    var colors: [String] {
        switch self {
        case .coolToWarm:
            return ["#0066CC", "#FFFFFF", "#FF3366"]
        case .thermal:
            return ["#000080", "#0000FF", "#00FFFF", "#00FF00", "#FFFF00", "#FF0000", "#FFFFFF"]
        case .arctic:
            return ["#001122", "#003366", "#0066CC", "#66CCFF", "#FFFFFF"]
        case .sunset:
            return ["#FF6B35", "#F7931E", "#FFD23F", "#FF6B6B", "#C44569"]
        case .ocean:
            return ["#000080", "#0033AA", "#0066CC", "#0099FF", "#66CCFF"]
        case .fire:
            return ["#8B0000", "#FF0000", "#FF4500", "#FFA500", "#FFFF00", "#FFFFFF"]
        }
    }
}

#Preview {
    TemperatureGradientsView()
}