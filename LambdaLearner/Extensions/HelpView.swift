import SwiftUI

// MARK: - Help Section Models
struct HelpExample {
    let expression: String
    let description: String
    let explanation: String
}

struct HelpTopic {
    let title: String
    let description: String
    let examples: [HelpExample]
}

// MARK: - Help Content View
struct LambdaHelpView: View {
    @Binding var isPresented: Bool
    @Binding var interpreterInput: String
    @State private var selectedTopicIndex = 0
    
    private let topics: [HelpTopic] = [
        HelpTopic(
            title: "Using the Interpreter",
            description: "Learn how to effectively use the lambda calculus interpreter.",
            examples: [
                HelpExample(
                    expression: "\\x. x",
                    description: "Lambda Abstraction",
                    explanation: "Use '\\' or 'λ' to create lambda abstractions. Variables must be lowercase letters."
                ),
                HelpExample(
                    expression: "(\\x. x) y",
                    description: "Grouping & Application",
                    explanation: "Use parentheses for grouping. Spaces separate function applications. The interpreter will show each reduction step clearly."
                ),
                HelpExample(
                    expression: "\\x. \\y. (x y)",
                    description: "Nested Functions",
                    explanation: "Create multi-parameter functions using nested abstractions. The interpreter handles proper scoping and evaluation."
                )
            ]
        ),
        HelpTopic(
            title: "Basic Expressions",
            description: "Learn the fundamental building blocks of lambda calculus expressions.",
            examples: [
                HelpExample(
                    expression: "\\x. x",
                    description: "Identity Function",
                    explanation: "Takes an input and returns it unchanged. This is the simplest possible lambda function."
                ),
                HelpExample(
                    expression: "(\\x. x) y",
                    description: "Function Application",
                    explanation: "Applies the identity function to variable y. The result will be y."
                )
            ]
        ),
        HelpTopic(
            title: "Church Booleans",
            description: "Boolean values and operations represented in pure lambda calculus.",
            examples: [
                HelpExample(
                    expression: "true",
                    description: "Church True (\\t. \\f. t)",
                    explanation: "A function that takes two arguments and returns the first one."
                ),
                HelpExample(
                    expression: "false",
                    description: "Church False (\\t. \\f. f)",
                    explanation: "A function that takes two arguments and returns the second one."
                ),
                HelpExample(
                    expression: "(and true) false",
                    description: "Boolean AND",
                    explanation: "Performs logical AND operation on Church booleans."
                )
            ]
        ),
        HelpTopic(
            title: "Church Numerals",
            description: "Natural numbers encoded as repeated function application.",
            examples: [
                HelpExample(
                    expression: "zero",
                    description: "Church Zero (\\f. \\x. x)",
                    explanation: "Represents 0 as a function that applies f to x zero times."
                ),
                HelpExample(
                    expression: "one",
                    description: "Church One (\\f. \\x. f x)",
                    explanation: "Represents 1 as a function that applies f to x once."
                ),
                HelpExample(
                    expression: "(plus one) one",
                    description: "Addition",
                    explanation: "Adds two Church numerals together."
                )
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            helpHeader
            
            // Navigation
            topicNavigation
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    selectedTopicContent
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
    }
    
    private var helpHeader: some View {
        HStack {
            Text("Lambda Calculus Guide")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .imageScale(.large)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var topicNavigation: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(topics.indices, id: \.self) { index in
                    TopicButton(
                        title: topics[index].title,
                        isSelected: selectedTopicIndex == index,
                        action: { selectedTopicIndex = index }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var selectedTopicContent: some View {
        let topic = topics[selectedTopicIndex]
        
        return VStack(spacing: 24) {
            // Topic Description
            VStack(alignment: .leading, spacing: 12) {
                Text(topic.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            // Examples
            ForEach(topic.examples, id: \.expression) { example in
                ExampleCard(
                    example: example,
                    interpreterInput: $interpreterInput,
                    closeSheet: { isPresented = false }
                )
            }
        }
    }
}

// MARK: - Helper Views
struct TopicButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? 
                              AnyShapeStyle(
                                LinearGradient(
                                    colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                              ) : AnyShapeStyle(Color.black.opacity(0.3))
                             )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .cornerRadius(20)
        }
    }
}

struct ExampleCard: View {
    let example: HelpExample
    @Binding var interpreterInput: String
    let closeSheet: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and expression
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(example.description)
                        .font(.headline)
                    
                    Text(example.expression)
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                }
                
                Spacer()
                
                Button(action: {
                    interpreterInput = example.expression
                    closeSheet()
                }) {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.green)
                        .imageScale(.large)
                }
            }
            
            // Explanation with animation
            VStack(alignment: .leading, spacing: 8) {
                Text("How it works")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(example.explanation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Preview Provider
struct LambdaHelpView_Previews: PreviewProvider {
    static var previews: some View {
        let isPresented = Binding.constant(true)
        let interpreterInput = Binding.constant("")
        
        LambdaHelpView(
            isPresented: isPresented,
            interpreterInput: interpreterInput
        )
    }
}
