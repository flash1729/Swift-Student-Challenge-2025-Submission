import SwiftUI

//struct InterpreterToggle: View {
//    @Binding var isVisible: Bool
//    @State private var isHovered = false
//    
//    var body: some View {
//        Button(action: {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                isVisible.toggle()
//            }
//        }) {
//            HStack(spacing: 8) {
//                // Lambda symbol with animation
//                Text("λ")
//                    .font(.system(size: 18, weight: .bold, design: .monospaced))
//                    .foregroundStyle(
//                        LinearGradient(
//                            colors: [.blue, .purple],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .rotationEffect(.degrees(isVisible ? 180 : 0))
//                
//                // Terminal icon with custom styling
//                Image(systemName: "terminal")
//                    .font(.system(size: 14))
//                    .foregroundColor(.white.opacity(0.9))
//                
//                // Text that changes based on state
//                Text(isVisible ? "Hide REPL" : "Show REPL")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.white.opacity(0.9))
//            }
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .background(
//                ZStack {
//                    // Base dark background
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(Color.black.opacity(0.6))
//                    
//                    // Animated gradient overlay
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(
//                            LinearGradient(
//                                colors: [
//                                    Color.blue.opacity(isHovered ? 0.3 : 0.1),
//                                    Color.purple.opacity(isHovered ? 0.3 : 0.1)
//                                ],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .scaleEffect(isHovered ? 1 : 0.95)
//                        .animation(.easeInOut(duration: 1.5).repeatForever(), value: isHovered)
//                }
//            )
//            // Glassmorphism effect
//            .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(
//                        LinearGradient(
//                            colors: [
//                                .white.opacity(0.3),
//                                .white.opacity(0.1)
//                            ],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        ),
//                        lineWidth: 1
//                    )
//            )
//            .shadow(color: .blue.opacity(0.2), radius: isHovered ? 8 : 4)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .onHover { hovering in
//            withAnimation(.easeInOut(duration: 0.2)) {
//                isHovered = hovering
//            }
//        }
//        // Position the button in the top-right corner with proper spacing
//        .padding(.top, 16)
//        .padding(.trailing, 16)
//        .offset(y: -8) // Slight offset to not interfere with the title
//    }
//}

struct InterpreterToggle: View {
    @Binding var isVisible: Bool
    @State private var isHovered = false
    @State private var gradientStart = UnitPoint(x: 0, y: 0)
    @State private var gradientEnd = UnitPoint(x: 1, y: 1)
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isVisible.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    // Lambda symbol
                    Text("λ")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
                    
                    Text(isVisible ? "Hide Interpreter" : "Show Interpreter")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Image(systemName: isVisible ? "chevron.right" : "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.6),
                                    Color.purple.opacity(0.6)
                                ],
                                startPoint: gradientStart,
                                endPoint: gradientEnd
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: isHovered ? 8 : 4)
                .scaleEffect(isHovered ? 1.02 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 2)) {
                    // Rotate gradient smoothly
                    let nextPoint = gradientStart.x == 0 ? 
                    (UnitPoint(x: 1, y: 0), UnitPoint(x: 0, y: 1)) :
                    (UnitPoint(x: 0, y: 0), UnitPoint(x: 1, y: 1))
                    gradientStart = nextPoint.0
                    gradientEnd = nextPoint.1
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

//struct InterpreterToggle: View {
//    @Binding var isVisible: Bool
//    @State private var isHovered = false
//    
//    var body: some View {
//        HStack {
//            Spacer()
//            Button(action: {
//                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                    isVisible.toggle()
//                }
//            }) {
//                HStack(spacing: 12) {
//                    // Lambda symbol with subtle float animation
//                    Text("λ")
//                        .font(.system(size: 22, weight: .bold, design: .monospaced))
//                        .foregroundStyle(
//                            LinearGradient(
//                                colors: [.blue, .purple.opacity(0.8)],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .offset(y: isHovered ? -2 : 0)
//                        .animation(
//                            Animation.easeInOut(duration: 1)
//                                .repeatForever(autoreverses: true),
//                            value: isHovered
//                        )
//                    
//                    Text(isVisible ? "Hide REPL" : "Show REPL")
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(.white)
//                    
//                    Image(systemName: isVisible ? "chevron.right" : "chevron.left")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.white.opacity(0.8))
//                }
//                .padding(.horizontal, 20)
//                .padding(.vertical, 12)
//                .background(
//                    ZStack {
//                        // Dynamic gradient background
//                        RoundedRectangle(cornerRadius: 25)
//                            .fill(
//                                LinearGradient(
//                                    colors: [
//                                        Color(red: 0.1, green: 0.2, blue: 0.3),
//                                        Color(red: 0.2, green: 0.3, blue: 0.4)
//                                    ],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                        
//                        // Animated gradient overlay
//                        RoundedRectangle(cornerRadius: 25)
//                            .fill(
//                                LinearGradient(
//                                    colors: [
//                                        Color.blue.opacity(isHovered ? 0.4 : 0.2),
//                                        Color.purple.opacity(isHovered ? 0.4 : 0.2)
//                                    ],
//                                    startPoint: isHovered ? .topLeading : .bottomTrailing,
//                                    endPoint: isHovered ? .bottomTrailing : .topLeading
//                                )
//                            )
//                            .animation(
//                                Animation.easeInOut(duration: 2.0)
//                                    .repeatForever(autoreverses: true),
//                                value: isHovered
//                            )
//                    }
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 25)
//                        .stroke(
//                            LinearGradient(
//                                colors: [
//                                    .white.opacity(0.5),
//                                    .white.opacity(0.2)
//                                ],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            ),
//                            lineWidth: 1
//                        )
//                )
//                .shadow(
//                    color: Color.blue.opacity(isHovered ? 0.4 : 0.2),
//                    radius: isHovered ? 15 : 10
//                )
//            }
//            .buttonStyle(PlainButtonStyle())
//            .onAppear { isHovered = true }
//            .onHover { hovering in
//                withAnimation(.easeInOut(duration: 0.3)) {
//                    isHovered = hovering
//                }
//            }
//        }
//        .padding(.horizontal, 24)
//        .padding(.vertical, 16)
//    }
//}
