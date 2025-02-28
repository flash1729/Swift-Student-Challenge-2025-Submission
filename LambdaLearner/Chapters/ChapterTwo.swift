import SwiftUI

struct ChapterTwoView: View {
    @StateObject private var interpreterState = InterpreterState()
    @State private var selectedSection: Int = 0
    
    private let sections = [
        "Recap",
        "Free Variables",
        "Alpha Equivalence",
        "Substitution",
        "Practice"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let interpreterWidth = min(
                max(geometry.size.width * 0.3, 300),
                max(geometry.size.width * 0.4, 500)
            )
            
            HStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Chapter Header
                            VStack(spacing: 16) {
                                Text("Chapter 2: The Inner Workings of Lambda Calculus")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                
                                Text("Discover how variables, equivalence, and substitution create the elegant machinery of lambda calculus.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
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
                .background(selectedSection == index ? Color.purple : Color.gray.opacity(0.2))
                .foregroundColor(selectedSection == index ? .white : .primary)
                .cornerRadius(20)
        }
    }
    
    @ViewBuilder
    private var contentSection: some View {
        switch selectedSection {
        case 0:
            RecapSection()
        case 1:
            FreeVariablesSection()
        case 2:
            AlphaEquivalenceSection()
        case 3:
            SubstitutionSection()
        case 4:
            Chapter2PracticeSection()
        default:
            EmptyView()
        }
    }
}

struct RecapSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Quick Recap: The Essence of Lambda Calculus")
            
            // Core syntax reminder
            ConceptCard(
                title: "The Three Pillars",
                color: .indigo,
                content: """
                Before we dive deeper, let's refresh our memory of the three fundamental components that make up lambda calculus: variables, functions (abstraction), and function application.
                """,
                icon: "number.circle.fill"
            )
            
            // Syntax rules
            VStack(spacing: 24) {
                ExampleView(
                    title: "Variables (x, y, z...)",
                    original: "x",
                    equivalent: "A simple name representing a value",
                    explanation: "Like variables in algebra, but can represent any computation",
                    color: .blue
                )
                
                ExampleView(
                    title: "Function Abstraction (λx.e)",
                    original: "λx.x",
                    equivalent: "Identity function",
                    explanation: "Creates a function that binds a variable",
                    color: .purple
                )
                
                ExampleView(
                    title: "Function Application",
                    original: "(λx.x) y",
                    equivalent: "y",
                    explanation: "Applies a function to an argument",
                    color: .green
                )
            }
            
            // Convention reminder
            ConceptCard(
                title: "Key Conventions",
                color: .orange,
                content: """
                Remember our two important rules:
                1. λ extends as far right as possible (λx.λy.x y = λx.(λy.(x y)))
                2. Function application associates to the left (x y z = (x y) z)
                """,
                icon: "list.bullet"
            )
            
            // Interpreter basics
            ConceptCard(
                title: "Using the Interpreter",
                color: .blue,
                content: """
                You can use either 'λ' or '\\' to write functions. All variables should be lowercase, and parentheses help control grouping. Try experimenting with the interpreter to test your understanding!
                """,
                icon: "terminal.fill"
            )
            
            TryItSection(
                example: "\\x. \\y. x",
                explanation: "Try this constant function - it takes two arguments and always returns the first one."
            )
        }
        .padding(.horizontal, 40)
    }
}

struct FreeVariablesSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Understanding Free Variables")
            
            ConceptCard(
                title: "The Scope of Freedom",
                color: .indigo,
                content: """
                In lambda calculus, variables can be either bound (like parameters in a function) or free (like global variables in programming). Understanding this distinction is crucial for working with lambda expressions.
                """,
                icon: "signature"
            )
            
            // Visual explanation of bound vs free
            VStack(spacing: 24) {
                ConceptCard(
                    title: "Bound Variables",
                    color: .blue,
                    content: """
                    A variable is bound when it appears in the body of a lambda expression that has that variable as its parameter. Think of them like function parameters in programming.
                    """,
                    icon: "link"
                )
                
                ExampleView(
                    title: "Bound Variable Example",
                    original: "λx. x y",
                    equivalent: "x is bound, y is free",
                    explanation: "x is bound by λ, but y isn't bound by any lambda",
                    color: .blue
                )
            }
            
            VStack(spacing: 24) {
                ConceptCard(
                    title: "Free Variables",
                    color: .purple,
                    content: """
                    A variable is free when it's not bound by any enclosing lambda. These are like global variables or external references in your expression.
                    """,
                    icon: "arrow.up.forward"
                )
                
                ExampleView(
                    title: "Free Variable Example",
                    original: "λx. y z",
                    equivalent: "Both y and z are free",
                    explanation: "Neither y nor z is bound by the lambda",
                    color: .purple
                )
            }
            
            // Understanding FV(t)
            ConceptCard(
                title: "Free Variables Function: FV(t)",
                color: .green,
                content: """
                To formally find free variables in a term t, we use the FV(t) function:
                • FV(x) = {x}
                • FV(λx.t₁) = FV(t₁) - {x}
                • FV(t₁ t₂) = FV(t₁) ∪ FV(t₂)
                """,
                icon: "function"
            )
            
            // Interactive examples
            TryItSection(
                example: "\\x. (\\y. x) y",
                explanation: "This expression has both bound and free occurrences of y. Can you identify which is which?"
            )
            
            // Real-world connection
            ConceptCard(
                title: "Why Free Variables Matter",
                color: .orange,
                content: """
                Understanding free variables is crucial for:
                • Avoiding naming conflicts
                • Understanding variable scope
                • Proper substitution
                • Program correctness
                """,
                icon: "exclamationmark.triangle"
            )
        }
        .padding(.horizontal, 40)
    }
}

struct AlphaEquivalenceSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Alpha Equivalence: Same Function, Different Names")
            
            ConceptCard(
                title: "What is α-equivalence?",
                color: .indigo,
                content: """
                Just as the function f(x) = x² is the same as g(y) = y², lambda expressions that differ only in their bound variable names are considered equivalent. This is called α-equivalence.
                """,
                icon: "equal.circle"
            )
            
            // Basic example
            ExampleView(
                title: "Simple α-equivalence",
                original: "λx. x",
                equivalent: "λy. y",
                explanation: "These are the same function - the identity function",
                color: .blue
            )
            
            // More complex example
            VStack(spacing: 24) {
                ConceptCard(
                    title: "Static Scoping",
                    color: .purple,
                    content: """
                    Lambda calculus uses static scoping - the meaning of a variable is determined by where it appears in the code, not where it's used.
                    """,
                    icon: "scope"
                )
                
                ExampleView(
                    title: "Nested Functions",
                    original: "λx. λy. x y",
                    equivalent: "λa. λb. a b",
                    explanation: "Consistently renaming bound variables preserves meaning",
                    color: .purple
                )
            }
            
            // Cautions and edge cases
            ConceptCard(
                title: "When Names Matter",
                color: .orange,
                content: """
                Be careful! We can only rename bound variables. Free variables must keep their original names since they might refer to specific values from the outside.
                """,
                icon: "exclamationmark.triangle"
            )
            
            // Interactive exploration
            TryItSection(
                example: "(\\x. x y) z",
                explanation: "Try renaming the bound variable x to something else. Notice how y and z must stay the same!"
            )
            
            // Practical importance
            ConceptCard(
                title: "Why α-equivalence Matters",
                color: .green,
                content: """
                α-equivalence is crucial for:
                • Avoiding name clashes during substitution
                • Understanding program equivalence
                • Implementing interpreters correctly
                • Reasoning about programs
                """,
                icon: "checkmark.circle"
            )
        }
        .padding(.horizontal, 40)
    }
}

struct SubstitutionSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Substitution: The Heart of Computation")
            
            ConceptCard(
                title: "What is Substitution?",
                color: .indigo,
                content: """
                Substitution is how we 'run' lambda calculus programs. It's the process of replacing variables with expressions, but it needs to be done carefully to preserve meaning.
                """,
                icon: "arrow.2.circlepath"
            )
            
            // Basic substitution
            VStack(spacing: 24) {
                ConceptCard(
                    title: "Basic Substitution",
                    color: .blue,
                    content: """
                    We write M[N/x] to mean "substitute N for free occurrences of x in M". This is like evaluating a function by replacing its parameter with an argument.
                    """,
                    icon: "function"
                )
                
                ExampleView(
                    title: "Simple Substitution",
                    original: "(λx. x y)[z/y]",
                    equivalent: "λx. x z",
                    explanation: "Replace free y with z",
                    color: .blue
                )
            }
            
            // Substitution challenges
            VStack(spacing: 24) {
                ConceptCard(
                    title: "Variable Capture Problem",
                    color: .purple,
                    content: """
                    We must be careful not to let free variables become accidentally bound during substitution. This is called variable capture.
                    """,
                    icon: "exclamationmark.triangle"
                )
                
                ExampleView(
                    title: "Avoiding Capture",
                    original: "(λx. y)[x/y]",
                    equivalent: "λz. x",
                    explanation: "Must rename bound variable to avoid capture",
                    color: .purple
                )
            }
            
            // Rules of substitution
            ConceptCard(
                title: "Substitution Rules",
                color: .green,
                content: """
                1. x[N/x] = N
                2. y[N/x] = y (if x ≠ y)
                3. (M₁ M₂)[N/x] = (M₁[N/x]) (M₂[N/x])
                4. (λx.M)[N/x] = λx.M
                5. (λy.M)[N/x] = λy.M[N/x] if x ≠ y and y ∉ FV(N)
                """,
                icon: "list.number"
            )
            
            // Interactive practice
            TryItSection(
                example: "(\\x. \\y. x) z",
                explanation: "Try evaluating this expression step by step using substitution."
            )
        }
        .padding(.horizontal, 40)
    }
}

struct Chapter2PracticeSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Practice Makes Perfect")
            
            ConceptCard(
                title: "Putting It All Together",
                color: .indigo,
                content: """
                Let's practice identifying free variables, understanding α-equivalence, and performing substitutions. Use the interpreter to verify your answers!
                """,
                icon: "graduationcap"
            )
            
            // Free Variables Practice
            ExerciseCard(
                title: "Free Variables Exercise",
                problem: "What are the free variables in λx. (λy. x z) y?",
                hint: "Look for variables not bound by any λ",
                solution: "z is free, others are bound",
                interpreterExample: "\\x. (\\y. x z) y"
            )
            
            // Alpha Equivalence Practice
            ExerciseCard(
                title: "α-equivalence Exercise",
                problem: "Is λx. λy. x y equivalent to λy. λx. y x?",
                hint: "Try renaming variables consistently",
                solution: "No, they're different functions",
                interpreterExample: "(\\x. \\y. x y) a b"
            )
            
            // Substitution Practice
            ExerciseCard(
                title: "Substitution Exercise",
                problem: "Evaluate (λx. λy. x) z w",
                hint: "Apply one substitution at a time",
                solution: "First x becomes z, then we get λy.z, finally z",
                interpreterExample: "(\\x. \\y. x) z w"
            )
            
            // Complex Expression
            TryItSection(
                example: "(\\x. \\y. x) ((\\z. z) w)",
                explanation: "Try evaluating this expression using the interpreter. Can you predict the result before running it?"
            )
            
            // Final Challenge
            ConceptCard(
                title: "Challenge Problem",
                color: .orange,
                content: """
                Consider the expression: (λx. λy. x) ((λx. x) y)
                1. Identify the free variables
                2. Find an α-equivalent expression
                3. Evaluate it step by step
                """,
                icon: "star.fill"
            )
        }
        .padding(.horizontal, 40)
    }
}

