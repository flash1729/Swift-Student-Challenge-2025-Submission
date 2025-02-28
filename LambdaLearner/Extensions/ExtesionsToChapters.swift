import SwiftUI

struct SectionTitle: View {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top)
    }
}

struct ContentText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.body)
            .lineSpacing(4)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

struct InfoBox: View {
    let title: String
    let content: [String]
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
            
            ForEach(content, id: \.self) { point in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(point)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SyntaxRule: View {
    let rule: String
    let name: String
    let explanation: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(rule)
                .font(.system(.title2, design: .monospaced))
            Text(name)
                .font(.headline)
                .foregroundColor(.blue)
            Text(explanation)
                .font(.body)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

//struct ExerciseCard: View {
//    @EnvironmentObject private var interpreterState: InterpreterState
//    let title: String
//    let problem: String
//    let hint: String
//    let solution: String
//    
//    @State private var showingSolution = false
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            Text(title)
//                .font(.headline)
//            
//            Text(problem)
//                .font(.body)
//                .multilineTextAlignment(.center)
//            
//            Button(action: { showingSolution.toggle() }) {
//                Text(showingSolution ? "Hide Hint" : "Show Hint")
//                    .font(.callout)
//                    .foregroundColor(.blue)
//            }
//            
//            if showingSolution {
//                VStack(spacing: 8) {
//                    Text("Hint: \(hint)")
//                        .font(.callout)
//                        .foregroundColor(.secondary)
//                    
//                    HStack {
//                        Text("Solution: \(solution)")
//                            .font(.system(.body, design: .monospaced))
//                        
//                        Button(action: {
//                            interpreterState.tryExample(solution)
//                        }) {
//                            Image(systemName: "play.circle.fill")
//                                .foregroundColor(.green)
//                        }
//                    }
//                    .padding(8)
//                    .background(Color.green.opacity(0.1))
//                    .cornerRadius(4)
//                }
//            }
//        }
//        .padding()
//        .frame(maxWidth: .infinity)
//        .background(Color.orange.opacity(0.1))
//        .cornerRadius(12)
//    }
//}

struct ExerciseCard: View {
    @EnvironmentObject private var interpreterState: InterpreterState
    let title: String
    let problem: String
    let hint: String
    let solution: String
    // New property for interpreter example
    let interpreterExample: String?
    
    @State private var showingSolution = false
    
    // Initialize with optional interpreter example
    init(
        title: String,
        problem: String,
        hint: String,
        solution: String,
        interpreterExample: String? = nil
    ) {
        self.title = title
        self.problem = problem
        self.hint = hint
        self.solution = solution
        self.interpreterExample = interpreterExample
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
            
            Text(problem)
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button(action: { showingSolution.toggle() }) {
                Text(showingSolution ? "Hide Solution" : "Show Solution")
                    .font(.callout)
                    .foregroundColor(.blue)
            }
            
            if showingSolution {
                VStack(spacing: 12) {
                    // Hint
                    Text("Hint: \(hint)")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                    
                    // Solution with optional try button
                    VStack(spacing: 8) {
                        Text("Solution: \(solution)")
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Only show Try button if we have an interpreter example
                        if let example = interpreterExample {
                            Button(action: {
                                interpreterState.tryExample(example)
                            }) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("Try in Interpreter")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ConceptCard: View {
    let title: String
    let color: Color
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(content)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(6)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct KeyPointView: View {
    let text: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TryItSection: View {
    @EnvironmentObject private var interpreterState: InterpreterState
    let example: String
    let explanation: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Try It Yourself!")
                .font(.headline)
            
            Text(explanation)
                .font(.body)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                Text(example)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                Button(action: {
                    interpreterState.tryExample(example)
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Try in Interpreter")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(20)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ExampleView: View {
    let title: String
    let original: String
    let equivalent: String
    let explanation: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                Text(original)
                    .font(.system(size: 20, design: .monospaced))
                    .foregroundColor(color)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                
                Text(equivalent)
                    .font(.system(size: 20, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Text(explanation)
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// Helper view for showing rule applications
struct RuleCard: View {
    let expression: String
    let interpretation: String
    let rule: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(expression)
                .font(.system(size: 22, design: .monospaced))
                .foregroundColor(color)
            
            Image(systemName: "arrow.down")
                .foregroundColor(.gray)
            
            Text(interpretation)
                .font(.system(size: 22, design: .monospaced))
                .foregroundColor(.white)
            
            Text(rule)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.1))
        )
    }
}
