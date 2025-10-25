import SwiftUI
import ColorsKit

struct BlendingModesView: View {
    @State private var baseColor = "#FF6B6B"
    @State private var overlayColor = "#4ECDC4"
    @State private var selectedBlendMode: ColorsKit.BlendMode = .normal
    @State private var blendedResult: String = "#FF6B6B"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Advanced Color Blending")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Color Input Section
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Base Color")
                                .font(.headline)
                            HStack {
                                TextField("Hex color", text: $baseColor)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Rectangle()
                                    .fill(Color(hex: baseColor) ?? Color.gray)
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(8)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Overlay Color")
                                .font(.headline)
                            HStack {
                                TextField("Hex color", text: $overlayColor)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Rectangle()
                                    .fill(Color(hex: overlayColor) ?? Color.gray)
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Blend Mode")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Picker("Blend Mode", selection: $selectedBlendMode) {
                            ForEach(ColorsKit.BlendMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue.capitalized)
                                    .tag(mode)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal)
                    }
                    
                    Button("Blend Colors") {
                        blendColors()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // Blended Result
                VStack(spacing: 16) {
                    Text("Blended Result")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        VStack {
                            Rectangle()
                                .fill(Color(hex: baseColor) ?? Color.gray)
                                .frame(width: 80, height: 80)
                                .cornerRadius(12)
                            Text("Base")
                                .font(.caption)
                        }
                        
                        Text("+")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack {
                            Rectangle()
                                .fill(Color(hex: overlayColor) ?? Color.gray)
                                .frame(width: 80, height: 80)
                                .cornerRadius(12)
                            Text("Overlay")
                                .font(.caption)
                        }
                        
                        Text("=")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack {
                            Rectangle()
                                .fill(Color(hex: blendedResult) ?? Color.gray)
                                .frame(width: 80, height: 80)
                                .cornerRadius(12)
                            Text(selectedBlendMode.rawValue.capitalized)
                                .font(.caption)
                        }
                    }
                    
                    Text("Result: \(blendedResult)")
                        .font(.monospaced(.body)())
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                // Blend Mode Gallery
                VStack(alignment: .leading, spacing: 16) {
                    Text("Blend Mode Gallery")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(ColorsKit.BlendMode.allCases, id: \.self) { mode in
                            VStack(spacing: 8) {
                                Rectangle()
                                    .fill(Color(hex: getBlendedColor(mode: mode)) ?? Color.gray)
                                    .frame(height: 60)
                                    .cornerRadius(8)
                                
                                Text(mode.rawValue.capitalized)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                            }
                            .onTapGesture {
                                selectedBlendMode = mode
                                blendColors()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .onAppear {
            blendColors()
        }
        .onChange(of: baseColor) { _ in blendColors() }
        .onChange(of: overlayColor) { _ in blendColors() }
        .onChange(of: selectedBlendMode) { _ in blendColors() }
    }
    
    private func blendColors() {
        guard let base = try? HexColorFormatter.parse(baseColor),
              let overlay = try? HexColorFormatter.parse(overlayColor) else {
            return
        }
        
        let blended = AdvancedBlending.blend(overlay, base, mode: selectedBlendMode)
        blendedResult = HexColorFormatter.format(blended) ?? "#000000"
    }
    
    private func getBlendedColor(mode: ColorsKit.BlendMode) -> String {
        guard let base = try? HexColorFormatter.parse(baseColor),
              let overlay = try? HexColorFormatter.parse(overlayColor) else {
            return "#000000"
        }
        
        let blended = AdvancedBlending.blend(overlay, base, mode: mode)
        return HexColorFormatter.format(blended) ?? "#000000"
    }
}



#Preview {
    BlendingModesView()
}