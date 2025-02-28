import SwiftUI

import SwiftUI

struct ChapterFourView: View {
    @StateObject private var interpreterState = InterpreterState()
    @State private var selectedSection: Int = 0
    
    private let sections = [
        "Recap",
        "Boolean Encodings",
        "Logical Operators", 
        "Pairs & Data Structures",
        "Church Numerals",
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
                                Text("Chapter 4: Encoding Power of Lambda Calculus")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                
                                Text("Discover how lambda calculus can encode complex structures and computations using nothing but functions.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                InterpreterToggle(isVisible: $interpreterState.isVisible)
                            }
                            .padding(.top)
                            
                            
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
            RecapSectionForFour()
        case 1:
            BooleanEncodingsSection()
        case 2:
            LogicalOperatorsSection()
        case 3:
            PairsSection()
        case 4:
            ChurchNumeralsSection()
        case 5:
            ChapterFourPracticeSection()
        default:
            EmptyView()
        }
    }
}

// Detailed implementation of the Recap section
struct RecapSectionForFour: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Before We Begin: A Look Back at Reduction")
            
            
            ConceptCard(
                title: "β-Reduction Refresher",
                color: .indigo,
                content: """
                In Chapter 3, we learned that β-reduction is the core computation mechanism in lambda calculus. When we have (λx.M) N, we substitute N for x in M. This simple rule lets us evaluate any lambda expression.
                """,
                icon: "arrow.right.circle.fill"
            )
            
           
            VStack(spacing: 24) {
                Text("Different Ways to Reduce")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ExampleView(
                    title: "Normal Order",
                    original: "(λx.y) ((λx.x x) (λx.x x))",
                    equivalent: "y",
                    explanation: "Reduces outermost redex first - always finds normal form if it exists",
                    color: .blue
                )
                
                ExampleView(
                    title: "Call-by-Value",
                    original: "(λx.y) ((λx.x x) (λx.x x))",
                    equivalent: "⊥ (doesn't terminate)",
                    explanation: "Evaluates arguments first - matches most programming languages",
                    color: .purple
                )
            }
            
            
            ConceptCard(
                title: "Normal Forms",
                color: .green,
                content: """
                Remember: A term is in normal form when it contains no more β-redexes. Some terms, like Ω = (λx.x x) (λx.x x), have no normal form. Others might reach normal form under some strategies but not others.
                """,
                icon: "checkmark.circle.fill"
            )
            
            
            ConceptCard(
                title: "From Reduction to Construction",
                color: .orange,
                content: """
                Now that we understand how to evaluate lambda expressions, we're ready to build with them! We'll use our knowledge of reduction to create and work with lambda terms that encode familiar concepts like booleans, numbers, and data structures.
                """,
                icon: "building.2.fill"
            )
            
            
            VStack(spacing: 16) {
                Text("Try Different Reduction Strategies")
                    .font(.headline)
                
                // Example with non-terminating term
                ExampleView(
                    title: "Non-terminating Term",
                    original: "(λx. λy. x) ((λx. x x) (λx. x x)) z",
                    equivalent: "z (under normal order)",
                    explanation: "Normal order reaches z, call-by-value loops forever",
                    color: .orange
                )
                
                // Safe example for interpreter
                TryItSection(
                    example: "(\\x. \\y. x) ((\\z. z) w) v",
                    explanation: "This term is safe to try in the interpreter. Can you predict its normal form under different reduction strategies?"
                )
                
                // Note about interpreter limitations
                Text("Note: Our interpreter cannot handle non-terminating terms like (λx. x x)(λx. x x). For such terms, we'll explore their behavior theoretically!")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 40)
    }
}


struct BooleanEncodingsSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Boolean Values in Lambda Calculus")
            
            
            ConceptCard(
                title: "The Essence of True and False",
                color: .indigo,
                content: """
                In lambda calculus, booleans are functions that make a choice between two options. This elegant encoding captures the fundamental nature of true/false decisions.
                """,
                icon: "switch.2"
            )
            
            // Core boolean definitions
            VStack(spacing: 24) {
                Text("The Foundation: True and False")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        ExampleView(
                            title: "True = λt.λf.t",
                            original: "\\t. \\f. t",
                            equivalent: "Returns first argument",
                            explanation: "Takes two arguments and always chooses the first one",
                            color: .blue
                        )
                        
                        // Concrete example for True
                        VStack(alignment: .leading, spacing: 8) {
                            Text("For example, if we apply true to 'apple' and 'banana':")
                                .font(.subheadline)
                            
                            ReductionStepView(
                                term: "true apple banana",
                                result: "apple",
                                explanation: "true always returns its first argument (apple)",
                                color: .blue,
                                isHighlighted: true
                            )
                            
                            Text("Think of it as: 'If true then apple else banana'")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // False value with detailed example
                    VStack(spacing: 16) {
                        ExampleView(
                            title: "False = λt.λf.f",
                            original: "\\t. \\f. f",
                            equivalent: "Returns second argument",
                            explanation: "Takes two arguments and always chooses the second one",
                            color: .red
                        )
                        
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("For example, if we apply false to 'apple' and 'banana':")
                                .font(.subheadline)
                            
                            ReductionStepView(
                                term: "false apple banana",
                                result: "banana",
                                explanation: "false always returns its second argument (banana)",
                                color: .red,
                                isHighlighted: true
                            )
                            
                            Text("Think of it as: 'If false then apple else banana'")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Summary connecting both concepts
                    ConceptCard(
                        title: "The Big Picture",
                        color: .purple,
                        content: """
                        These encodings represent the essence of choice:
                        • true chooses the first option (then-branch)
                        • false chooses the second option (else-branch)
                        
                        This is exactly how if-then-else works in programming!
                        """,
                        icon: "arrow.triangle.branch"
                    )
                    
                
                    TryItSection(
                        example: "true apple banana",
                        explanation: "Try it yourself! Use quotes for strings and see which one gets chosen."
                    )
                }
            }
            
            
            ConceptCard(
                title: "The Test Function",
                color: .green,
                content: """
                We can test our boolean values using a simple function:
                test = λl.λm.λn.l m n
                
                This allows us to create if-then-else behavior:
                • test true v w → v
                • test false v w → w
                """,
                icon: "checklist"
            )
            
            
            VStack(spacing: 16) {
                Text("Let's See It In Action")
                    .font(.headline)
                
                ReductionStepView(
                    term: "test true v w",
                    result: "v",
                    explanation: "Using true selects the first option",
                    color: .blue,
                    isHighlighted: true
                )
                
                ReductionStepView(
                    term: "test false v w",
                    result: "w",
                    explanation: "Using false selects the second option",
                    color: .red,
                    isHighlighted: true
                )
            }
            
            
            ConceptCard(
                title: "Beyond Lambda Calculus",
                color: .purple,
                content: """
                This encoding of booleans directly influences modern functional programming:
                • Pattern matching in ML and Haskell
                • Optional chaining in Swift
                • The Visitor pattern in object-oriented programming
                """,
                icon: "link"
            )
            
            
            ConceptCard(
                title: "Using the Interpreter",
                color: .blue,
                content: """
                Our interpreter has built-in support for common boolean terms:
                • 'true' for λt.λf.t
                • 'false' for λt.λf.f
                • 'and' for boolean AND
                • 'or' for boolean OR
                • 'not' for boolean NOT
                
                Try using these directly instead of writing out the full lambda terms!
                """,
                icon: "terminal.fill"
            )
            
            
            VStack(spacing: 16) {
                TryItSection(
                    example: "false apple banana",
                    explanation: "Using the built-in 'false' - much simpler than writing (\\t. \\f. t)!"
                )
                
                Text("Understanding Beta Reduction")
                    .font(.headline)
                    .padding(.top)
                
                ReductionStepView(
                    term: "(λt.λf.t) x y",
                    result: "x",
                    explanation: "Step by step: first t becomes x, then apply to y, result is x",
                    color: .green,
                    isHighlighted: false
                )
            }
        }
        .padding(.horizontal, 40)
    }
}

struct LogicalOperatorsSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Building Logical Operators")
            
            
            ConceptCard(
                title: "From Booleans to Logic",
                color: .indigo,
                content: """
                With our boolean values defined, we can build the familiar logical operators: AND, OR, and NOT. Each operator is just a function that manipulates our boolean values.
                """,
                icon: "function"
            )
            
            // The NOT operator
            VStack(spacing: 24) {
                Text("Negation (NOT)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ConceptCard(
                    title: "NOT = λb.b false true",
                    color: .purple,
                    content: """
                    The NOT operator flips a boolean value:
                    • Applies the input boolean to false and true
                    • If input is true, returns false
                    • If input is false, returns true
                    """,
                    icon: "arrow.2.circlepath"
                )
                
                ExampleView(
                    title: "NOT true",
                    original: "(λb.b false true) true",
                    equivalent: "false",
                    explanation: "Returns false when given true",
                    color: .blue
                )
            }
            
            // The AND operator
            VStack(spacing: 24) {
                Text("Conjunction (AND)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ConceptCard(
                    title: "AND = λa.λb.a b false",
                    color: .green,
                    content: """
                    If a is true, return b
                    If a is false, return false
                    
                    This matches the AND truth table perfectly!
                    """,
                    icon: "plus.square"
                )
                
                // Truth table as examples
                HStack(spacing: 20) {
                    VStack(spacing: 12) {
                        ExampleView(
                            title: "true AND true",
                            original: "(λa.λb.a b false) true true",
                            equivalent: "true",
                            explanation: "Both inputs true → true",
                            color: .green
                        )
                        
                        ExampleView(
                            title: "true AND false",
                            original: "(λa.λb.a b false) true false",
                            equivalent: "false",
                            explanation: "Mixed inputs → false",
                            color: .red
                        )
                    }
                    
                    VStack(spacing: 12) {
                        ExampleView(
                            title: "false AND true",
                            original: "(λa.λb.a b false) false true",
                            equivalent: "false",
                            explanation: "Mixed inputs → false",
                            color: .red
                        )
                        
                        ExampleView(
                            title: "false AND false",
                            original: "(λa.λb.a b false) false false",
                            equivalent: "false",
                            explanation: "Both inputs false → false",
                            color: .red
                        )
                    }
                }
            }
            
            // The OR operator
            VStack(spacing: 24) {
                Text("Disjunction (OR)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ConceptCard(
                    title: "OR = λa.λb.a true b",
                    color: .orange,
                    content: """
                    If a is true, return true
                    If a is false, return b
                    
                    Notice how this mirrors the AND operator's structure!
                    """,
                    icon: "plus.square.fill"
                )
                
                ExampleView(
                    title: "OR Reduction Example",
                    original: "(λa.λb.a true b) false true",
                    equivalent: "true",
                    explanation: "If either input is true, result is true",
                    color: .orange
                )
            }
            
            
            VStack(spacing: 16) {
                Text("Using Built-in Operators")
                    .font(.headline)
                
                TryItSection(
                    example: "(\\a.\\b.a true b) true false",
                    explanation: "Using learnt concepts to build examples"
                )
                
                TryItSection(
                    example: "not (or true false)",
                    explanation: "We can even compose operators - try predicting the result!"
                )
                
                Text("Note: Built-in operators make complex expressions much easier to read and write!")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                
                Text("Understanding the Reduction")
                    .font(.headline)
                    .padding(.top)
                
                ReductionStepView(
                    term: "(λa.λb.a b false) true false",
                    result: "(λb.true b false) false",
                    explanation: "First substitute true for a",
                    color: .green,
                    isHighlighted: false
                )
                
                ReductionStepView(
                    term: "(λb.true b false) false",
                    result: "false",
                    explanation: "Then substitute false for b and reduce",
                    color: .green,
                    isHighlighted: true
                )
            }
            
            
            ConceptCard(
                title: "Building More Complex Operations",
                color: .purple,
                content: """
                These basic operators can be combined to create more complex ones:
                • XOR (exclusive or)
                • IMPLIES (logical implication)
                • NAND (not and)
                • NOR (not or)
                
                Try building some yourself!
                """,
                icon: "square.stack.3d.up.fill"
            )
        }
        .padding(.horizontal, 40)
    }
}

struct PairsSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Data Structures with Pure Functions")
            
            
            ConceptCard(
                title: "Beyond Simple Values",
                color: .indigo,
                content: """
                How can we represent data structures using only functions? With lambda calculus, we can encode pairs - the building blocks of more complex data structures - using nothing but functions!
                """,
                icon: "square.stack.3d.up.fill"
            )
            
            // Pair Constructor
            VStack(spacing: 24) {
                Text("Creating Pairs")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ConceptCard(
                    title: "The Pair Constructor",
                    color: .blue,
                    content: """
                    A pair (f,s) is encoded as:
                    pair = λf.λs.λb.b f s
                    
                    It takes:
                    • First value (f)
                    • Second value (s)
                    • A boolean function (b) that chooses which value to return
                    """,
                    icon: "link"
                )
                
                
                ExampleView(
                    title: "Building a Pair",
                    original: "pair v w",
                    equivalent: "λb.b v w",
                    explanation: "Creates a function that takes a boolean to select v or w",
                    color: .blue
                )
            }
            
            
            VStack(spacing: 24) {
                Text("Accessing Pair Elements")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 20) {
                    
                    VStack(spacing: 16) {
                        ConceptCard(
                            title: "Getting First Element",
                            color: .green,
                            content: """
                            fst = λp.p true
                            
                            Gives the pair a 'true' function to select the first element
                            """,
                            icon: "arrow.left"
                        )
                        
                        ExampleView(
                            title: "Example: fst (pair v w)",
                            original: "(λp.p true) (λb.b v w)",
                            equivalent: "v",
                            explanation: "Uses true to select first value",
                            color: .green
                        )
                    }
                    
                    
                    VStack(spacing: 16) {
                        ConceptCard(
                            title: "Getting Second Element",
                            color: .purple,
                            content: """
                            snd = λp.p false
                            
                            Gives the pair a 'false' function to select the second element
                            """,
                            icon: "arrow.right"
                        )
                        
                        ExampleView(
                            title: "Example: snd (pair v w)",
                            original: "(λp.p false) (λb.b v w)",
                            equivalent: "w",
                            explanation: "Uses false to select second value",
                            color: .purple
                        )
                    }
                }
            }
            
            
            ConceptCard(
                title: "Using the Interpreter",
                color: .orange,
                content: """
                Our interpreter provides built-in support for pairs:
                • 'pair' or 'cons' for pair constructor
                • 'first' or 'car' for accessing first element
                • 'second' or 'cdr' for accessing second element
                """,
                icon: "terminal.fill"
            )
            
            
            VStack(spacing: 16) {
                Text("Try It Yourself!")
                    .font(.headline)
                
                TryItSection(
                    example: "first (pair x y)",
                    explanation: "This will return the first element (x) from the pair"
                )
                
                
                Text("Understanding the Steps")
                    .font(.headline)
                    .padding(.top)
                
                ReductionStepView(
                    term: "first (pair x y)",
                    result: "(λp.p true) (λb.b x y)",
                    explanation: "First, create the pair structure",
                    color: .blue,
                    isHighlighted: false
                )
                
                ReductionStepView(
                    term: "(λb.b x y) true",
                    result: "x",
                    explanation: "Then apply true to select first element",
                    color: .green,
                    isHighlighted: true
                )
            }
            
            
            ConceptCard(
                title: "Fun with Pairs",
                color: .purple,
                content: """
                We can build more complex operations:
                • Swap function to exchange elements
                • Nested pairs for longer sequences
                • Building lists using pairs
                
                Try implementing some yourself!
                """,
                icon: "arrow.2.squarepath"
            )
        }
        .padding(.horizontal, 40)
    }
}

struct ChurchNumeralsSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Numbers as Functions: Church Numerals")
            
            
            ConceptCard(
                title: "What are Church Numerals?",
                color: .indigo,
                content: """
                Church numerals represent natural numbers as functions that apply another function n times. Each number is essentially an "iteration counter"!
                """,
                icon: "number.circle.fill"
            )
            
            // Basic numbers
            VStack(spacing: 24) {
                Text("The Building Blocks")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Zero
                VStack(spacing: 16) {
                    ConceptCard(
                        title: "Zero: λs.λz.z",
                        color: .blue,
                        content: """
                        Zero applies a function s to an initial value z... zero times!
                        It just returns z unchanged.
                        """,
                        icon: "0.circle.fill"
                    )
                    
                    ExampleView(
                        title: "zero = λs.λz.z",
                        original: "Applies function 0 times",
                        equivalent: "Just returns z",
                        explanation: "Think: do nothing 0 times",
                        color: .blue
                    )
                }
                
                // One
                VStack(spacing: 16) {
                    ConceptCard(
                        title: "One: λs.λz.s z",
                        color: .green,
                        content: """
                        One applies the function s to z exactly once.
                        """,
                        icon: "1.circle.fill"
                    )
                    
                    ExampleView(
                        title: "one = λs.λz.s z",
                        original: "Applies function once",
                        equivalent: "Returns s(z)",
                        explanation: "Think: do s once",
                        color: .green
                    )
                }
                
                // Two
                VStack(spacing: 16) {
                    ConceptCard(
                        title: "Two: λs.λz.s (s z)",
                        color: .purple,
                        content: """
                        Two applies the function s to z twice.
                        Notice the pattern forming!
                        """,
                        icon: "2.circle.fill"
                    )
                    
                    ExampleView(
                        title: "two = λs.λz.s (s z)",
                        original: "Applies function twice",
                        equivalent: "Returns s(s(z))",
                        explanation: "Think: do s twice",
                        color: .purple
                    )
                }
            }
            
            // Visual Pattern
            ConceptCard(
                title: "The Pattern",
                color: .orange,
                content: """
                Each numeral n is a function that:
                • Takes a function s and initial value z
                • Applies s to z exactly n times
                
                n = λs.λz.s(s(...s(z)...)) [s applied n times]
                """,
                icon: "repeat"
            )
            
            // Built-in support
            ConceptCard(
                title: "Using the Interpreter",
                color: .blue,
                content: """
                Our interpreter provides common Church numerals:
                • zero through five
                • succ (successor function)
                • plus (addition)
                • times (multiplication)
                """,
                icon: "terminal.fill"
            )
            
            // Interactive Examples
            VStack(spacing: 16) {
                Text("Try It Yourself!")
                    .font(.headline)
                
                TryItSection(
                    example: "plus two three",
                    explanation: "This adds Church numerals two and three"
                )
                
                // Explanation of computation
                Text("Understanding the Result")
                    .font(.headline)
                    .padding(.top)
                
                ReductionStepView(
                    term: "plus two three",
                    result: "λs.λz.s(s(s(s(s z))))",
                    explanation: "Applies s five times - representing 2 + 3 = 5",
                    color: .green,
                    isHighlighted: true
                )
            }
            
            // Arithmetic operations
            VStack(spacing: 24) {
                Text("Arithmetic Operations")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Addition
                ConceptCard(
                    title: "Addition (plus)",
                    color: .blue,
                    content: """
                    plus = λm.λn.λs.λz.m s (n s z)
                    
                    Applies s first n times, then m more times
                    """,
                    icon: "plus"
                )
                
                // Multiplication
                ConceptCard(
                    title: "Multiplication (times)",
                    color: .purple,
                    content: """
                    times = λm.λn.λs.λz.m (n s) z
                    
                    Applies (n s) m times - composing the functions!
                    """,
                    icon: "multiply"
                )
            }
            
            // Practice section
            VStack(spacing: 16) {
                Text("Practice with Church Numerals")
                    .font(.title3)
                    .padding(.top)
                
                TryItSection(
                    example: "times two three",
                    explanation: "Try multiplying numbers. Can you predict how many times s will be applied?"
                )
                
                Text("Pro tip: These operations build a function that applies s multiple times. The number of applications represents the resulting number!")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 40)
    }
}

struct ChapterFourPracticeSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Put Your Lambda Powers to Work!")
            
            
            ConceptCard(
                title: "Time to Practice",
                color: .indigo,
                content: """
                Let's combine everything we've learned about encodings in lambda calculus:
                • Boolean values and logic
                • Data structures with pairs
                • Numbers and arithmetic
                • Combining it all together!
                """,
                icon: "dumbbell.fill"
            )
            
            // Boolean Practice
            VStack(spacing: 24) {
                Text("Boolean Logic Exercises")
                    .font(.title2)
                    .fontWeight(.bold)
                
                
                ExerciseCard(
                    title: "Simple Logic",
                    problem: "What will (and true (not false)) evaluate to?",
                    hint: "Break it down: first evaluate (not false), then apply and",
                    solution: "true",
                    interpreterExample: "and true (not false)"
                )
                
                
                ExerciseCard(
                    title: "Composed Operations",
                    problem: "Implement exclusive-or (XOR) using and, or, and not",
                    hint: "XOR is true when inputs are different",
                    solution: "λx.λy.or (and x (not y)) (and (not x) y)",
                    interpreterExample: "or (and true (not false)) (and (not true) false)"
                )
                
                
                TryItSection(
                    example: "not (and true false)",
                    explanation: "Try composing boolean operations. The interpreter has built-in support for these!"
                )
            }
            
            // Pairs Practice
            VStack(spacing: 24) {
                Text("Working with Pairs")
                    .font(.title2)
                    .fontWeight(.bold)
                
                
                ExerciseCard(
                    title: "Pair Access",
                    problem: "What will second (pair (first p) (second p)) return, where p is a pair?",
                    hint: "Think about how pair constructors and accessors work together",
                    solution: "second p",
                    interpreterExample: "pair true false" 
                )
                
                
                ExerciseCard(
                    title: "Pair Operations",
                    problem: "Write a function that swaps the elements of a pair",
                    hint: "Use pair constructor with elements in reverse order",
                    solution: "λp.pair (second p) (first p)",
                    interpreterExample: "pair (second (pair true false)) (first (pair true false))"
                )
            }
            
            // Church Numerals Practice
            VStack(spacing: 24) {
                Text("Church Numeral Computations")
                    .font(.title2)
                    .fontWeight(.bold)
                
                
                ExerciseCard(
                    title: "Simple Arithmetic",
                    problem: "What Church numeral results from (plus two (times one three))?",
                    hint: "First compute (times one three), then add two",
                    solution: "five",
                    interpreterExample: "plus two (times one three)"
                )
                
                
                ExerciseCard(
                    title: "Number Properties",
                    problem: "Show that (times m one) equals m for any Church numeral m",
                    hint: "Think about what it means to apply a function m×1 times",
                    solution: "Both apply the function m times to z"
                    // No interpreter example as this is a theoretical proof
                )
                
                // Interactive numeral practice remains
                TryItSection(
                    example: "plus (times two two) one",
                    explanation: "Try complex arithmetic expressions using built-in Church numerals"
                )
            }
            
            // Combined Challenges
            VStack(spacing: 24) {
                Text("Putting It All Together")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ConceptCard(
                    title: "Challenge Problems",
                    color: .purple,
                    content: """
                    Now try these exercises that combine multiple concepts:
                    1. Create a pair of booleans and write operations on them
                    2. Use Church numerals to count true values in a pair
                    3. Build complex data structures using nested pairs
                    """,
                    icon: "star.fill"
                )
                
                
                ExerciseCard(
                    title: "Boolean Pair Operations",
                    problem: "Write a function that takes a pair of booleans and returns true if they're the same",
                    hint: "Use pairs, boolean operations, and function composition",
                    solution: "λp.or (and (first p) (second p)) (and (not (first p)) (not (second p)))",
                    interpreterExample: "and (first (pair true true)) (second (pair true true))"
                )
                
                
                ExerciseCard(
                    title: "Conditional Counting",
                    problem: "Count how many true values are in a pair of booleans",
                    hint: "Convert booleans to Church numerals and add them",
                    solution: "λp.plus (if (first p) one zero) (if (second p) one zero)",
                    interpreterExample: "plus (if true one zero) (if false one zero)"
                )
            }
            
            
            VStack(spacing: 16) {
                ConceptCard(
                    title: "Master Challenge",
                    color: .orange,
                    content: """
                    Final Boss: Implement a stack using pairs!
                    • push: Add an element to the front
                    • pop: Remove the first element
                    • isEmpty: Check if stack is empty
                    
                    Use nested pairs and booleans to build this data structure.
                    """,
                    icon: "trophy.fill"
                )
                
                Text("Note: This combines everything we've learned about encodings!")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
            
            
            ConceptCard(
                title: "Helpful Tips",
                color: .blue,
                content: """
                Remember these built-in terms:
                • Booleans: true, false, and, or, not
                • Pairs: pair, first, second
                • Numbers: zero through five, plus, times
                
                Use them to make complex expressions more readable!
                """,
                icon: "lightbulb.fill"
            )
        }
        .padding(.horizontal, 40)
    }
}
