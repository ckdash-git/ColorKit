import SwiftUI
import ColorsKit

struct ColorHarmonyView: View {
    @Binding var baseColor: String
    @Binding var selectedHarmony: ColorHarmonyType
    @State private var generatedColors: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Color Harmony Generator")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Base Color Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Base Color")
                        .font(.headline)
                    
                    HStack {
                        TextField("Enter hex color", text: $baseColor)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: baseColor) { _ in
                                generateHarmony()
                            }
                        
                        Rectangle()
                            .fill(Color(hex: baseColor) ?? Color.gray)
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Harmony Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Harmony Type")
                        .font(.headline)
                    
                    Picker("Harmony Type", selection: $selectedHarmony) {
                        Text("Complementary").tag(ColorHarmonyType.complementary)
                        Text("Analogous").tag(ColorHarmonyType.analogous)
                        Text("Triadic").tag(ColorHarmonyType.triadic)
                        Text("Tetradic").tag(ColorHarmonyType.tetradic)
                        Text("Split Complementary").tag(ColorHarmonyType.splitComplementary)
                        Text("Monochromatic").tag(ColorHarmonyType.monochromatic)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedHarmony) { _ in
                        generateHarmony()
                    }
                }
                .padding(.horizontal)
                
                // Generated Colors Display
                if !generatedColors.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Generated Harmony")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(generatedColors, id: \.self) { colorHex in
                                VStack(spacing: 4) {
                                    Rectangle()
                                        .fill(Color(hex: colorHex) ?? Color.gray)
                                        .frame(height: 80)
                                        .cornerRadius(8)
                                    
                                    Text(colorHex)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Accessibility Information
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Accessibility Analysis")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(Array(generatedColors.enumerated()), id: \.offset) { index, colorHex in
                                HStack {
                                    Rectangle()
                                        .fill(Color(hex: colorHex) ?? Color.gray)
                                        .frame(width: 20, height: 20)
                                        .cornerRadius(4)
                                    
                                    Text(colorHex)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    if let contrastRatio = getContrastRatio(colorHex, "#FFFFFF") {
                                        Text("AA: \(contrastRatio >= 4.5 ? "✓" : "✗")")
                                            .font(.caption)
                                            .foregroundColor(contrastRatio >= 4.5 ? .green : .red)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            generateHarmony()
        }
    }
    
    private func generateHarmony() {
        generatedColors = ColorHarmonyGenerator.generateHarmony(from: baseColor, type: selectedHarmony)
    }
    
    private func getContrastRatio(_ foreground: String, _ background: String) -> Double? {
        guard let fg = try? HexColorFormatter.parse(foreground),
              let bg = try? HexColorFormatter.parse(background) else {
            return nil
        }
        return ColorMath.contrastRatio(fg, bg)
    }
}

#Preview {
    ColorHarmonyView(baseColor: .constant("#0A84FF"), selectedHarmony: .constant(.complementary))
}