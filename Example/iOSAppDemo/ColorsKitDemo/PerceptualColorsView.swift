import SwiftUI
import ColorsKit

struct PerceptualColorsView: View {
    @State private var inputColor = "#FF6B6B"
    @State private var targetColor = "#4ECDC4"
    @State private var blendSteps = 5
    @State private var perceptualGradient: [String] = []
    @State private var regularGradient: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Perceptual Color Spaces")
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
                                TextField("Hex color", text: $inputColor)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Rectangle()
                                    .fill(Color(hex: inputColor) ?? Color.gray)
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(8)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("End Color")
                                .font(.headline)
                            HStack {
                                TextField("Hex color", text: $targetColor)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Rectangle()
                                    .fill(Color(hex: targetColor) ?? Color.gray)
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Blend Steps: \(blendSteps)")
                            .font(.headline)
                        Slider(value: Binding(
                            get: { Double(blendSteps) },
                            set: { blendSteps = Int($0) }
                        ), in: 3...10, step: 1)
                    }
                    .padding(.horizontal)
                    
                    Button("Generate Gradients") {
                        generateGradients()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // Color Space Information
                if let rgba = try? HexColorFormatter.parse(inputColor) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color Space Conversions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            let xyz = ColorSpaceConverter.rgbaToXYZ(rgba)
                            let lab = ColorSpaceConverter.xyzToLAB(xyz)
                            let luv = ColorSpaceConverter.xyzToLUV(xyz)
                            
                            HStack {
                                Rectangle()
                                    .fill(Color(hex: inputColor) ?? Color.gray)
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(6)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("RGBA: (\(String(format: "%.2f", rgba.r)), \(String(format: "%.2f", rgba.g)), \(String(format: "%.2f", rgba.b)), \(String(format: "%.2f", rgba.a)))")
                                        .font(.caption)
                                    Text("XYZ: (\(String(format: "%.2f", xyz.x)), \(String(format: "%.2f", xyz.y)), \(String(format: "%.2f", xyz.z)))")
                                        .font(.caption)
                                    Text("LAB: (\(String(format: "%.1f", lab.l)), \(String(format: "%.1f", lab.a)), \(String(format: "%.1f", lab.b)))")
                                        .font(.caption)
                                    Text("LUV: (\(String(format: "%.1f", luv.l)), \(String(format: "%.1f", luv.u)), \(String(format: "%.1f", luv.v)))")
                                        .font(.caption)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Gradient Comparison
                if !perceptualGradient.isEmpty && !regularGradient.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Gradient Comparison")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Perceptual (LAB) Gradient")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal)
                            
                            HStack(spacing: 2) {
                                ForEach(perceptualGradient, id: \.self) { colorHex in
                                    Rectangle()
                                        .fill(Color(hex: colorHex) ?? Color.gray)
                                        .frame(height: 60)
                                }
                            }
                            .cornerRadius(8)
                            .padding(.horizontal)
                            
                            Text("Regular (RGB) Gradient")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal)
                            
                            HStack(spacing: 2) {
                                ForEach(regularGradient, id: \.self) { colorHex in
                                    Rectangle()
                                        .fill(Color(hex: colorHex) ?? Color.gray)
                                        .frame(height: 60)
                                }
                            }
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                        
                        // Delta E Analysis
                        if perceptualGradient.count > 1 {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Perceptual Uniformity (Delta E)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal)
                                
                                ForEach(0..<perceptualGradient.count-1, id: \.self) { index in
                                    if let color1 = try? HexColorFormatter.parse(perceptualGradient[index]),
                                       let color2 = try? HexColorFormatter.parse(perceptualGradient[index + 1]) {
                                        let deltaE = PerceptualColorMath.deltaE2000(color1, color2)
                                        
                                        HStack {
                                            Rectangle()
                                                .fill(Color(hex: perceptualGradient[index]) ?? Color.gray)
                                                .frame(width: 20, height: 20)
                                                .cornerRadius(4)
                                            
                                            Text("→")
                                                .font(.caption)
                                            
                                            Rectangle()
                                                .fill(Color(hex: perceptualGradient[index + 1]) ?? Color.gray)
                                                .frame(width: 20, height: 20)
                                                .cornerRadius(4)
                                            
                                            Text("ΔE: \(String(format: "%.1f", deltaE))")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            generateGradients()
        }
    }
    
    private func generateGradients() {
        guard let startRGBA = try? HexColorFormatter.parse(inputColor),
              let endRGBA = try? HexColorFormatter.parse(targetColor) else {
            return
        }
        
        // Generate perceptual gradient
        perceptualGradient = PerceptualColorMath.perceptualGradient(
            from: startRGBA,
            to: endRGBA,
            steps: blendSteps
        ).compactMap { HexColorFormatter.format($0) }
        
        // Generate regular RGB gradient for comparison
        regularGradient = []
        for i in 0..<blendSteps {
            let t = Double(i) / Double(blendSteps - 1)
            let blended = RGBA(
                r: startRGBA.r + (endRGBA.r - startRGBA.r) * t,
                g: startRGBA.g + (endRGBA.g - startRGBA.g) * t,
                b: startRGBA.b + (endRGBA.b - startRGBA.b) * t,
                a: startRGBA.a + (endRGBA.a - startRGBA.a) * t
            )
            let hex = HexColorFormatter.format(blended)
            regularGradient.append(hex)
        }
    }
}

#Preview {
    PerceptualColorsView()
}