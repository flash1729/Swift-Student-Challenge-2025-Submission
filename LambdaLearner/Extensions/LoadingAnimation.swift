import SwiftUI
 
// MARK: - Data Structure for Animation
struct ATElementData {
    var value: Bool
    var index: Int
    
    var invValue: CGFloat {
        value ? 0 : 1
    }
}

// MARK: - Animation Effect Protocol
protocol ATTextAnimateEffect: ViewModifier {
    var data: ATElementData { get }
    init(_ data: ATElementData)
}

// MARK: - Random Typo Animation
struct ATRandomTypoAnimation: ATTextAnimateEffect {
    let data: ATElementData
    
    init(_ data: ATElementData) {
        self.data = data
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: 6 * data.invValue, y: 0)
            .opacity(data.value ? 1 : 0)
            .animation(
                .easeInOut(duration: 0.5)
                .delay(Double(data.index) * 0.1),
                value: data.value
            )
    }
}

// MARK: - Animated Text View
struct ATAnimatedText<Effect: ATTextAnimateEffect>: View {
    let text: String
    let effect: Effect.Type
    let value: Bool
    
    init(text: String, effect: Effect.Type, value: Bool) {
        self.text = text
        self.effect = effect
        self.value = value
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .modifier(effect.init(
                        ATElementData(value: value, index: index)
                    ))
            }
        }
    }
}

// MARK: - Main Loading Animation View
struct LoadingAnimation: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ATAnimatedText(
                text: "LambdaLearner",
                effect: ATRandomTypoAnimation.self,
                value: isAnimating
            )
            .font(.system(size: 40, weight: .bold, design: .monospaced))
            .foregroundColor(.purple)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating.toggle()
            }
        }
    }
}

// MARK: - Splash Screen View
struct SplashScreen: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            if isActive {
                MainView()
            } else {
                LoadingAnimation()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

