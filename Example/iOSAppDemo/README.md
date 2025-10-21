# iOSAppDemo

A minimal SwiftUI demo app showcasing ColorKit usage.

## Create the demo

1. Open Xcode > File > New > Project > iOS App (SwiftUI).
2. Name: ColorKitDemo, Interface: SwiftUI, Language: Swift.
3. Add this package via File > Add Packages... and search your repo URL.
4. In `ContentView.swift`:

```swift
import SwiftUI
import ColorKit

struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("ColorKit Demo")
                .font(.title)
                .foregroundStyle(Color.dynamic(lightHex: "#1C1C1E", darkHex: "#FFFFFF"))

            Rectangle()
                .fill(SwiftUIGradientBuilder.linear(hexColors: ["#0A84FF", "#5E5CE6"]))
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("Contrast AA: \(AccessibilityUtils.meetsAA(foreground: "#000000", background: "#FFFFFF"))")
        }
        .padding()
        .background(Color.dynamic(lightHex: Palettes.defaultLight.colors["surface"]!, darkHex: Palettes.defaultDark.colors["surface"]!))
    }
}
```

Run the app and toggle dark mode to see dynamic adaptation.