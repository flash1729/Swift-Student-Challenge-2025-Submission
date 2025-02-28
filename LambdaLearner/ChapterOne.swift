import SwiftUI

class InterpreterState: ObservableObject {
    @Published var inputText: String = ""
    @Published var isVisible: Bool = false
    @Published var interpreter: Interpreter
    
    init() {
        let options = InterpreterOptions(
            verbosity: .high,
            renameFreeVars: false,
            showEquivalent: true
        )
        self.interpreter = Interpreter(options: options)
    }
    
    func tryExample(_ example: String) {
        inputText = example
        if !isVisible {
            withAnimation(.easeIn(duration: 0.25)) {
                isVisible = true
            }
        }
    }
}

struct Chapter1View: View {
    @StateObject private var interpreterState = InterpreterState()
    @State private var selectedSection: Int = 0
    
    private let sections = [
        "Introduction",
        "History",
        "Core Concepts",
        "Syntax",
        "Conventions",
        "Practice"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            
            let interpreterWidth = min(
                max(geometry.size.width * 0.3, 300), // Min width of 300
                max(geometry.size.width * 0.4, 500)  // Max width of 500 or 40% of window
            )
            
            HStack(spacing: 0) {
                // Main Content
                ZStack(alignment: .topTrailing) {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Chapter Header
                            VStack(spacing: 16) {
                                Text("Chapter 1: Introduction to Lambda Calculus")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                
                                Text("Learn the foundations of functional programming through lambda calculus, its history, and core concepts.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                //Toggle Button
                                InterpreterToggle(isVisible: $interpreterState.isVisible)
                            }
                            .padding(.top)
                            
                            // Section Navigation
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(0..<sections.count, id: \.self) { index in
                                        sectionButton(index)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Main Content
                            contentSection
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                        }
                    }
                }
                .frame(width: interpreterState.isVisible ? geometry.size.width - interpreterWidth : geometry.size.width)
                
                if interpreterState.isVisible {
                    ContentView(
                        interpreter: interpreterState.interpreter,
                        inputText: $interpreterState.inputText
                    )
                    .frame(width: interpreterWidth)
                    .background(Color(UIColor.systemBackground))
                    .shadow(radius: 5)
                    .transition(.move(edge: .trailing))
                }
            }
        }
        .environmentObject(interpreterState)
    }
    
    private func sectionButton(_ index: Int) -> some View {
        Button(action: { selectedSection = index }) {
            Text(sections[index])
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedSection == index ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(selectedSection == index ? .white : .primary)
                .cornerRadius(20)
        }
    }
    
    @ViewBuilder
    private var contentSection: some View {
        switch selectedSection {
        case 0:
            IntroductionSection()
        case 1:
            HistorySection()
        case 2:
            CoreConceptsSection()
        case 3:
            SyntaxSection()
        case 4:
            ConventionsSection()
        case 5:
            PracticeSection()
        default:
            EmptyView()
        }
    }
}

// Introduction Section - Explains what lambda calculus is and why it matters
struct IntroductionSection: View {
    var body: some View {
        VStack(spacing: 32) {
            
            SectionTitle("What is Lambda Calculus?")
                .padding(.bottom, 8)
            
            
            ConceptCard(
                title: "The Power of Pure Functions",
                color: .blue,
                content: """
                Imagine having the power to express any computation in the world using just functions. No loops, no variables, no complex data structures - just pure, elegant functions. This is the magic of lambda calculus, a mathematical system that forms the foundation of functional programming.
                """,
                icon: "wand.and.stars"
            )
            
            
            ConceptCard(
                title: "A Revolutionary Idea",
                color: .purple,
                content: """
                Created by Alonzo Church in the 1930s, lambda calculus revolutionized how we think about computation. Every time you use a function in modern programming languages like JavaScript or Python, you're building upon these foundational ideas.
                """,
                icon: "clock.fill"
            )
            
          
            ConceptCard(
                title: "Beautiful Minimalism",
                color: .green,
                content: """
                With just three core concepts - variables, functions, and function application - lambda calculus can express any computation possible. From simple arithmetic to complex algorithms, its elegant simplicity proves that less can indeed be more.
                """,
                icon: "leaf.fill"
            )
            
            
            ConceptCard(
                title: "Learn by Doing",
                color: .orange,
                content: """
                This course pairs theory with practice through an interactive interpreter. Experiment with expressions in real-time and watch as this simple system builds increasingly complex computations while maintaining its elegant simplicity.
                """,
                icon: "play.circle.fill"
            )
            
            
            VStack(spacing: 24) {
                Text("Why Lambda Calculus Matters")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                
                VStack(spacing: 16) {
                    KeyPointView(
                        text: "Foundation of Functional Programming",
                        description: "The theoretical bedrock that powers modern functional languages",
                        color: .blue
                    )
                    
                    KeyPointView(
                        text: "Power through Simplicity",
                        description: "Simple abstractions expressing complex ideas",
                        color: .purple
                    )
                    
                    KeyPointView(
                        text: "Universal Computation",
                        description: "Proof that simple functions can compute anything",
                        color: .green
                    )
                    
                    KeyPointView(
                        text: "Modern Influence",
                        description: "Shapes how we design programming languages today",
                        color: .orange
                    )
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.3))
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
        }
        .padding(.horizontal, 40)
    }
}

//struct ConceptCard: View {
//    let title: String
//    let color: Color
//    let content: String
//    let icon: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack(spacing: 12) {
//                Image(systemName: icon)
//                    .font(.system(size: 24))
//                    .foregroundColor(color)
//                
//                Text(title)
//                    .font(.system(size: 22, weight: .bold))
//                    .foregroundColor(.white)
//            }
//            
//            Text(content)
//                .font(.system(size: 18))
//                .foregroundColor(.white.opacity(0.9))
//                .lineSpacing(6)
//        }
//        .padding(24)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(color.opacity(0.1))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(color.opacity(0.3), lineWidth: 1)
//                )
//        )
//    }
//}
//
//struct KeyPointView: View {
//    let text: String
//    let description: String
//    let color: Color
//    
//    var body: some View {
//        HStack(spacing: 16) {
//            Image(systemName: "checkmark.circle.fill")
//                .font(.system(size: 24))
//                .foregroundColor(color)
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(text)
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundColor(.white)
//                
//                Text(description)
//                    .font(.system(size: 16))
//                    .foregroundColor(.gray)
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}

// History Section - Tells the story of Church and Turing
struct HistorySection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("The Birth of Computation Theory")
            
            // Introduction to the era
            ConceptCard(
                title: "The Quest for Computability",
                color: .indigo,
                content: """
                In the 1930s, mathematicians sought to answer a fundamental question: What exactly can be computed? This quest would lead to groundbreaking discoveries that shape computer science to this day.
                """,
                icon: "clock.fill"
            )
            
            // Church's contribution
            VStack(spacing: 24) {
                Text("The Lambda Calculus Revolution")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ExampleView(
                    title: "Alonzo Church (1929-1932)",
                    original: "Princeton University",
                    equivalent: "Lambda Calculus",
                    explanation: """
                    Developed lambda calculus as a formal system for understanding 
                    computation, laying the foundation for functional programming.
                    """,
                    color: .blue
                )
                
                ConceptCard(
                    title: "Church's Insight",
                    color: .blue,
                    content: """
                    Church showed that any computable function could be expressed 
                    using nothing but functions. This elegant insight would later 
                    inspire languages like Lisp, ML, and Haskell.
                    """,
                    icon: "function"
                )
            }
            
            // Turing's contribution
            VStack(spacing: 24) {
                Text("The Machine Perspective")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ExampleView(
                    title: "Alan Turing (1935)",
                    original: "Cambridge University",
                    equivalent: "Turing Machine",
                    explanation: """
                    Invented an abstract machine model that could simulate any computation,
                    providing a mechanical view of computation.
                    """,
                    color: .purple
                )
                
                ConceptCard(
                    title: "Turing's Innovation",
                    color: .purple,
                    content: """
                    Turing's machine model provided a mechanical way to understand computation, showing that complex calculations could be broken down into simple, mechanical steps.
                    """,
                    icon: "gearshape.2.fill"
                )
            }
            
            // The synthesis
            ConceptCard(
                title: "The Church-Turing Thesis",
                color: .green,
                content: """
                The remarkable discovery that these two very different approaches - Church's functions and Turing's machines - could compute exactly the same things. This equivalence helped define the boundaries of what can be computed.
                
                Key Implications:
                • Different models have equal power
                • Defined limits of computation
                • United mathematical and mechanical views
                • Foundation of computer science
                """,
                icon: "equal.circle.fill"
            )
        }
        .padding(.horizontal, 40)
    }
}

struct CoreConceptsSection: View {
    var body: some View {
        VStack(spacing: 32) {
            
            SectionTitle("The Building Blocks of Lambda Calculus")
                .padding(.bottom, 8)
            
            
            ConceptCard(
                title: "The Power of Simplicity",
                color: .indigo,
                content: """
                Lambda calculus is built on three elegantly simple concepts. Think of them as the LEGO blocks of computation - with just these three pieces, you can build anything computationally possible.
                """,
                icon: "cube.fill"
            )
            
            
            ConceptCard(
                title: "Variables",
                color: .blue,
                content: """
                Just like x and y in algebra, variables in lambda calculus are placeholders. But here's the twist - they don't hold numbers or strings, they can represent any computation. Think of them as universal containers that can hold any idea.
                """,
                icon: "x.circle.fill"
            )
            
            ConceptCard(
                title: "Functions (Abstraction)",
                color: .purple,
                content: """
                This is where the magic happens. Functions in lambda calculus are pure and powerful. They're like machines that take an input and produce an output, but with no side effects. Every modern programming language's functions trace their lineage to this concept.
                """,
                icon: "function"
            )
            
            ConceptCard(
                title: "Function Application",
                color: .green,
                content: """
                The act of using a function - like plugging numbers into a formula. But in lambda calculus, you can apply functions to other functions, creating layers of abstraction that can express incredibly complex computations.
                """,
                icon: "arrow.right.circle.fill"
            )
            
            
            ConceptCard(
                title: "Building Complex from Simple",
                color: .orange,
                content: """
                Together, these three concepts form a complete computational system. It's like having a universal LEGO set - you can build anything from a simple calculator to a full computer simulator, all using just these three pieces.
                """,
                icon: "building.2.fill"
            )
            
            
            HStack(spacing: 20) {
                ForEach(0..<3) { index in
                    VStack(spacing: 12) {
                        Image(systemName: [
                            "x.circle.fill",
                            "function",
                            "arrow.right.circle.fill"
                        ][index])
                        .font(.system(size: 32))
                        .foregroundColor([.blue, .purple, .green][index])
                        
                        Text([
                            "Variables",
                            "Functions",
                            "Application"
                        ][index])
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.clear)
                    )
                    
                    if index < 2 {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 20)
            
            
            Text("Simple individually, powerful together")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .padding(.horizontal, 40)
    }
}

// Syntax Section - Shows the formal grammar rules
struct SyntaxSection: View {
    var body: some View {
        VStack(spacing: 20) {
            SectionTitle("The Grammar of Pure Computation")
            
            ContentText("""
            The beauty of lambda calculus lies in its minimalist syntax. Like a haiku of computation, it achieves profound expressiveness through strict simplicity.
            """)
            
            SyntaxRule(
                rule: "e ::= x",
                name: "Variables",
                explanation: """
                Single letters like x, y, z represent values or computations. They're the basic building blocks of our expressions.
                """
            )
            
            SyntaxRule(
                rule: "e ::= λx.e",
                name: "Function Abstraction",
                explanation: """
                The λ symbol (or backslash) introduces a function. 'λx.e' means "a function that takes x and returns e". It's like 'x => e' in modern programming.
                """
            )
            
            SyntaxRule(
                rule: "e ::= e₁ e₂",
                name: "Function Application",
                explanation: """
                Putting two expressions next to each other applies the first as a function to the second. Simple juxtaposition is all we need!
                """
            )
            
            ContentText("""
            With just these three rules, we can express any computation possible. As the Beatles might have said:
            
            ♪ All you need is ~~Love~~ *Functions* ♪
            """)
        }
    }
}

// Conventions Section - Explains important notation rules
struct ConventionsSection: View {
    var body: some View {
        VStack(spacing: 32) {
            // Main title
            SectionTitle("The Rules of the Game")
                .padding(.bottom, 8)
            
            
            ConceptCard(
                title: "Making Lambda Calculus Readable",
                color: .indigo,
                content: """
                Just as musical notation has conventions that make complex compositions easier to read, lambda calculus has two elegant rules that simplify how we write and understand expressions.
                """,
                icon: "book.fill"
            )
            
            
            VStack(spacing: 24) {
                ConceptCard(
                    title: "Rule 1: The Scope of λ",
                    color: .blue,
                    content: """
                    The scope of a λ extends as far right as possible, only limited by parentheses. This elegant convention helps us write cleaner expressions by reducing unnecessary parentheses.
                    """,
                    icon: "arrow.right.to.line.alt"
                )
                
                
                ExampleView(
                    title: "Scope Example",
                    original: "λx.λy.x y",
                    equivalent: "λx.(λy.(x y))",
                    explanation: "The scope of each λ extends to everything that follows",
                    color: .blue
                )
            }
            
            
            VStack(spacing: 24) {
                ConceptCard(
                    title: "Rule 2: Left Associativity",
                    color: .purple,
                    content: """
                    When we see multiple applications, we group them from the left - just like most programming languages. This natural reading order makes expressions more intuitive.
                    """,
                    icon: "arrow.left"
                )
                
                
                ExampleView(
                    title: "Association Example",
                    original: "x y z",
                    equivalent: "(x y) z",
                    explanation: "Applications group from left to right",
                    color: .purple
                )
            }
            
            
            VStack(spacing: 20) {
                Text("Rules in Action")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 24) {
                    RuleCard(
                        expression: "λx.λy.x y z",
                        interpretation: "λx.(λy.((x y) z))",
                        rule: "Both rules combined",
                        color: .green
                    )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.green.opacity(0.1))
                )
            }
            
            VStack(spacing: 24) {
                Text("Try the Conventions!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                TryItSection(
                    example: "\\x. \\y. \\z. x y z",
                    explanation: """
                    Our interpreter automatically applies these conventions! Try this expression and notice how it:
                    1. Extends each λ's scope to the right
                    2. Groups applications from left to right
                    Your input will be parsed as: λx.(λy.(λz.((x y) z)))
                    """
                )
                
                ExampleView(
                    title: "More to Try",
                    original: "\\f. \\g. \\x. f (g x)",
                    equivalent: "Function composition without extra parentheses",
                    explanation: "The interpreter understands scope and grouping conventions",
                    color: .green
                )
            }
            
            // Practical importance note
            ConceptCard(
                title: "Why These Rules Matter",
                color: .orange,
                content: """
                These conventions aren't just about saving keystrokes - they make lambda calculus expressions more natural to read and write while preserving their precise mathematical meaning. As you practice, these rules will become second nature.
                """,
                icon: "lightbulb.fill"
            )
        }
        .padding(.horizontal, 40)
    }
}

//struct ExampleView: View {
//    let title: String
//    let original: String
//    let equivalent: String
//    let explanation: String
//    let color: Color
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text(title)
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundColor(.white)
//            
//            HStack(spacing: 20) {
//                Text(original)
//                    .font(.system(size: 20, design: .monospaced))
//                    .foregroundColor(color)
//                
//                Image(systemName: "arrow.right")
//                    .foregroundColor(.gray)
//                
//                Text(equivalent)
//                    .font(.system(size: 20, design: .monospaced))
//                    .foregroundColor(.white.opacity(0.9))
//            }
//            
//            Text(explanation)
//                .font(.system(size: 16))
//                .foregroundColor(.gray)
//        }
//        .padding(20)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(
//            RoundedRectangle(cornerRadius: 15)
//                .fill(color.opacity(0.1))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 15)
//                        .stroke(color.opacity(0.3), lineWidth: 1)
//                )
//        )
//    }
//}
//

//struct RuleCard: View {
//    let expression: String
//    let interpretation: String
//    let rule: String
//    let color: Color
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            Text(expression)
//                .font(.system(size: 22, design: .monospaced))
//                .foregroundColor(color)
//            
//            Image(systemName: "arrow.down")
//                .foregroundColor(.gray)
//            
//            Text(interpretation)
//                .font(.system(size: 22, design: .monospaced))
//                .foregroundColor(.white)
//            
//            Text(rule)
//                .font(.system(size: 16))
//                .foregroundColor(.gray)
//                .padding(.top, 4)
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 15)
//                .fill(color.opacity(0.1))
//        )
//    }
//}

// Practice Section - Interactive exercises and interpreter usage
struct PracticeSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Hands-on Lambda Calculus")
            
            // Introduction
            ConceptCard(
                title: "Your Lambda Laboratory",
                color: .indigo,
                content: """
                Time to put theory into practice! Our interactive interpreter lets you 
                experiment with lambda calculus firsthand. Let's start with some 
                fundamental exercises.
                """,
                icon: "keyboard.fill"
            )
            
            
            ConceptCard(
                title: "Using the Interpreter",
                color: .blue,
                content: """
                Key things to remember:
                • Use '\\' or 'λ' for lambda abstractions
                • Variables are lowercase letters
                • Parentheses control grouping
                • Spaces separate applications
                • The interpreter shows each reduction step
                """,
                icon: "terminal.fill"
            )
            
            // Basic exercises
            VStack(spacing: 24) {
                Text("Getting Started")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ExerciseCard(
                    title: "The Identity Function",
                    problem: "Write the simplest useful function - one that returns its input unchanged",
                    hint: "Think about a function that takes x and returns x",
                    solution: "λx. x",
                    interpreterExample: "\\x. x"
                )
                
                ExerciseCard(
                    title: "Function Application",
                    problem: "Apply the identity function to a variable y",
                    hint: "Wrap the function in parentheses before application",
                    solution: "(λx. x) y",
                    interpreterExample: "(\\x. x) y"
                )
            }
            
            
            VStack(spacing: 24) {
                Text("Building Complexity")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ExerciseCard(
                    title: "Multiple Arguments",
                    problem: "Create a function that takes two arguments and returns the first one",
                    hint: "Use nested lambda abstractions",
                    solution: "λx.λy. x",
                    interpreterExample: "\\x. \\y. x"
                )
                
                ExerciseCard(
                    title: "Function Composition",
                    problem: "Apply one function's result to another function",
                    hint: "Think about how to chain function applications",
                    solution: "(λf.λg.λx. f (g x))",
                    interpreterExample: "(\\f. \\g. \\x. f (g x)) (\\x. x) (\\y. y)"
                )
            }
            
            
            VStack(spacing: 16) {
                Text("Experiment!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                TryItSection(
                    example: "(\\x. \\y. x) a b",
                    explanation: "This function takes two arguments and returns the first. Try modifying it to return the second argument instead!"
                )
            }
            
            
            ConceptCard(
                title: "What's Next?",
                color: .purple,
                content: """
                We've learned the basics of lambda expressions and how to use our 
                interpreter. In the coming chapters, we'll see how to build complex 
                structures like booleans, numbers, and data structures using nothing 
                but these simple tools!
                """,
                icon: "arrow.right.circle.fill"
            )
        }
        .padding(.horizontal, 40)
    }
}

//struct TryItSection: View {
//    @EnvironmentObject private var interpreterState: InterpreterState
//    let example: String
//    let explanation: String
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            Text("Try It Yourself!")
//                .font(.headline)
//            
//            Text(explanation)
//                .font(.body)
//                .multilineTextAlignment(.center)
//            
//            VStack(spacing: 16) {
//                Text(example)
//                    .font(.system(.body, design: .monospaced))
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.gray.opacity(0.2))
//                    .cornerRadius(8)
//                
//                Button(action: {
//                    interpreterState.tryExample(example)
//                }) {
//                    HStack {
//                        Image(systemName: "play.circle.fill")
//                        Text("Try in Interpreter")
//                    }
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 8)
//                    .background(Color.green)
//                    .cornerRadius(20)
//                }
//            }
//        }
//        .padding()
//        .frame(maxWidth: .infinity)
//        .background(Color.green.opacity(0.1))
//        .cornerRadius(12)
//    }
//}

//struct SectionTitle: View {
//    let title: String
//    
//    init(_ title: String) {
//        self.title = title
//    }
//    
//    var body: some View {
//        Text(title)
//            .font(.title)
//            .fontWeight(.bold)
//            .multilineTextAlignment(.center)
//            .frame(maxWidth: .infinity, alignment: .center)
//            .padding(.top)
//    }
//}
//
//struct ContentText: View {
//    let text: String
//    
//    init(_ text: String) {
//        self.text = text
//    }
//    
//    var body: some View {
//        Text(text)
//            .font(.body)
//            .lineSpacing(4)
//            .multilineTextAlignment(.center)
//            .frame(maxWidth: .infinity)
//    }
//}
//
//struct InfoBox: View {
//    let title: String
//    let content: [String]
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            Text(title)
//                .font(.headline)
//            
//            ForEach(content, id: \.self) { point in
//                HStack(alignment: .top, spacing: 8) {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(.green)
//                    Text(point)
//                }
//            }
//        }
//        .padding()
//        .frame(maxWidth: .infinity)
//        .background(Color.blue.opacity(0.1))
//        .cornerRadius(12)
//    }
//}

struct PersonProfile: View {
    let name: String
    let year: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.headline)
            Text(year)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

//struct SyntaxRule: View {
//    let rule: String
//    let name: String
//    let explanation: String
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            Text(rule)
//                .font(.system(.title2, design: .monospaced))
//            Text(name)
//                .font(.headline)
//                .foregroundColor(.blue)
//            Text(explanation)
//                .font(.body)
//                .multilineTextAlignment(.center)
//        }
//        .padding()
//        .frame(maxWidth: .infinity)
//        .background(Color.gray.opacity(0.1))
//        .cornerRadius(12)
//    }
//}
//
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

//struct Chapter1View_Previews: PreviewProvider {
//    static var previews: some View {
//        Chapter1View()
//    }
//}
