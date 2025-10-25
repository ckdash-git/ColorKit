import SwiftUI
import ColorsKit

struct ColorPsychologyView: View {
    @State private var selectedEmotion: EmotionalCategory = .calm
    @State private var emotionColors: [String] = []
    @State private var inputColor = "#FF6B6B"
    @State private var emotionalProfile: [EmotionalCategory: Double] = [:]
    @State private var primaryEmotion: EmotionalCategory = .calm
    @State private var selectedEmotions: Set<EmotionalCategory> = [.calm, .energetic]
    @State private var multiEmotionPalette: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Color Psychology Engine")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Emotion-Based Color Generation
                VStack(alignment: .leading, spacing: 16) {
                    Text("Generate Colors by Emotion")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        Picker("Select Emotion", selection: $selectedEmotion) {
                            ForEach(EmotionalCategory.allCases, id: \.self) { emotion in
                                Text(emotion.rawValue.capitalized)
                                    .tag(emotion)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal)
                        
                        Button("Generate Colors") {
                            generateEmotionColors()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if !emotionColors.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(selectedEmotion.rawValue.capitalized) Colors")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                                    ForEach(emotionColors, id: \.self) { colorHex in
                                        VStack(spacing: 4) {
                                            Rectangle()
                                                .fill(Color(hex: colorHex) ?? Color.gray)
                                                .frame(height: 60)
                                                .cornerRadius(8)
                                            
                                            Text(colorHex)
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Color Emotional Analysis
                VStack(alignment: .leading, spacing: 16) {
                    Text("Analyze Color Emotions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        HStack {
                            TextField("Enter hex color", text: $inputColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Rectangle()
                                .fill(Color(hex: inputColor) ?? Color.gray)
                                .frame(width: 50, height: 40)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        Button("Analyze Emotions") {
                            analyzeColorEmotions()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if !emotionalProfile.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Primary Emotion: \(primaryEmotion.rawValue.capitalized)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                Text("Emotional Profile")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal)
                                
                                ForEach(emotionalProfile.sorted(by: { $0.value > $1.value }), id: \.key) { emotion, confidence in
                                    HStack {
                                        Text(emotion.rawValue.capitalized)
                                            .font(.caption)
                                            .frame(width: 80, alignment: .leading)
                                        
                                        ProgressView(value: confidence, total: 1.0)
                                            .progressViewStyle(LinearProgressViewStyle())
                                        
                                        Text("\(Int(confidence * 100))%")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .frame(width: 40, alignment: .trailing)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // Multi-Emotion Palette Generation
                VStack(alignment: .leading, spacing: 16) {
                    Text("Multi-Emotion Palette")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        Text("Select Emotions to Combine")
                            .font(.subheadline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(EmotionalCategory.allCases, id: \.self) { emotion in
                                Button(action: {
                                    if selectedEmotions.contains(emotion) {
                                        selectedEmotions.remove(emotion)
                                    } else {
                                        selectedEmotions.insert(emotion)
                                    }
                                }) {
                                    Text(emotion.rawValue.capitalized)
                                        .font(.caption)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(selectedEmotions.contains(emotion) ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedEmotions.contains(emotion) ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Button("Generate Multi-Emotion Palette") {
                            generateMultiEmotionPalette()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedEmotions.isEmpty)
                        
                        if !multiEmotionPalette.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Combined Palette")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                                    ForEach(multiEmotionPalette, id: \.self) { colorHex in
                                        VStack(spacing: 4) {
                                            Rectangle()
                                                .fill(Color(hex: colorHex) ?? Color.gray)
                                                .frame(height: 50)
                                                .cornerRadius(8)
                                            
                                            Text(colorHex)
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
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
            generateEmotionColors()
            analyzeColorEmotions()
        }
    }
    
    private func generateEmotionColors() {
        emotionColors = ColorPsychology.colorsFor(emotion: selectedEmotion)
    }
    
    private func analyzeColorEmotions() {
        guard let rgba = try? HexColorFormatter.parse(inputColor) else {
            return
        }
        
        primaryEmotion = ColorPsychology.primaryEmotion(for: rgba)
        emotionalProfile = ColorPsychology.emotionalProfile(for: rgba)
    }
    
    private func generateMultiEmotionPalette() {
        multiEmotionPalette = ColorPsychology.generatePalette(
            for: Array(selectedEmotions),
            count: min(selectedEmotions.count * 2, 10)
        )
    }
}



#Preview {
    ColorPsychologyView()
}