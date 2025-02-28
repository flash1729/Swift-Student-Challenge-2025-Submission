import SwiftUI

struct ChapterThreeView: View {
    @StateObject private var interpreterState = InterpreterState()
    @State private var selectedSection: Int = 0
    
    private let sections = [
        "Recap",
        "Beta Reduction",
        "Church-Rosser",
        "Normal Forms",
        "Reduction Strategies",
        "Normalization",
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
                            
                            VStack(spacing: 16) {
                                Text("Chapter 3: The Mechanics of Lambda Calculus")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                
                                Text("Discover how lambda expressions are evaluated and the different strategies we can use.")
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
            RecapSectionForThree()
        case 1:
            BetaReductionSection()
        case 2:
            ChurchRosserSection()
        case 3:
            NormalFormsSection()
        case 4:
            ReductionStrategiesSection()
        case 5:
            NormalizationSection()
        case 6:
            Chapter3PracticeSection()
        default:
            EmptyView()
        }
    }
}

// Custom View for showing reduction steps
struct ReductionStepView: View {
    let term: String
    let result: String
    let explanation: String
    let color: Color
    let isHighlighted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Text(term)
                    .font(.system(size: 18, design: .monospaced))
                    .foregroundColor(color)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                
                Text(result)
                    .font(.system(size: 18, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.vertical, 4)
            
            if !explanation.isEmpty {
                Text(explanation)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(isHighlighted ? 0.15 : 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(isHighlighted ? 0.4 : 0.2), lineWidth: 1)
                )
        )
    }
}

struct RecapSectionForThree: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Before We Begin...")
            
            ConceptCard(
                title: "The Story So Far",
                color: .indigo,
                content: """
                In our journey through lambda calculus, we've learned about variables, functions, and how to manipulate them through α-equivalence and substitution. Now we're ready to see how these expressions actually compute!
                """,
                icon: "book.fill"
            )
            
            
            ConceptCard(
                title: "Renaming Variables (α-equivalence)",
                color: .blue,
                content: """
                Remember: λx.x and λy.y are the same function! We can rename bound variables as long as we do it consistently and avoid name clashes.
                """,
                icon: "arrow.triangle.2.circlepath"
            )
            
            
            
            ConceptCard(
                title: "Substitution [N/x]",
                color: .purple,
                content: """
                When we substitute N for x, we replace all free occurrences of x with N, being careful to avoid variable capture through α-conversion when necessary.
                """,
                icon: "arrow.left.arrow.right"
            )
            
        
            VStack(spacing: 20) {
                Text("What's Next?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ExampleView(
                    title: "A Glimpse of β-reduction",
                    original: "(λx. x) y",
                    equivalent: "y",
                    explanation: "This simple reduction will be our gateway to understanding computation in lambda calculus",
                    color: .green
                )
            }
            
            
            TryItSection(
                example: "(\\x. x) ((\\y. y) z)",
                explanation: "Try this expression in the interpreter. How many steps do you think it will take to reduce? Which variable substitutions will happen first?"
            )
        }
        .padding(.horizontal, 40)
    }
}

struct BetaReductionSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("β-Reduction: The Heart of Computation")
            
            
            ConceptCard(
                title: "What is β-Reduction?",
                color: .indigo,
                content: """
                β-reduction is the "execution" of lambda calculus. When we have a function application like (λx.M) N, we can reduce it by substituting N for x in M. This pattern (λx.M) N is called a β-redex.
                """,
                icon: "gearshape.2.fill"
            )
            
            // Basic Example
            VStack(spacing: 16) {
                Text("Simple β-reduction Example")
                    .font(.headline)
                
                ReductionStepView(
                    term: "(λx. x) y",
                    result: "y",
                    explanation: "Substitute y for x in the body x",
                    color: .blue,
                    isHighlighted: true
                )
            }
            
            
            ConceptCard(
                title: "Multiple Steps",
                color: .purple,
                content: """
                Often, we need multiple β-reductions to reach a final result. Let's see how this works with a more complex example.
                """,
                icon: "list.number"
            )
            
            VStack(spacing: 16) {
                Text("Step-by-Step Reduction")
                    .font(.headline)
                
                ReductionStepView(
                    term: "(λx. x x) ((λx. y) z)",
                    result: "((λx. y) z) ((λx. y) z)",
                    explanation: "First substitute ((λx. y) z) for outer x",
                    color: .purple,
                    isHighlighted: false
                )
                
                ReductionStepView(
                    term: "((λx. y) z) ((λx. y) z)",
                    result: "y ((λx. y) z)",
                    explanation: "Reduce left application",
                    color: .purple,
                    isHighlighted: false
                )
                
                ReductionStepView(
                    term: "y ((λx. y) z)",
                    result: "y y",
                    explanation: "Reduce remaining application",
                    color: .purple,
                    isHighlighted: true
                )
            }
            
            // Interactive practice
            TryItSection(
                example: "(\\x. \\y. x) z w",
                explanation: "Try reducing this expression. What do you think the final result will be?"
            )
        }
        .padding(.horizontal, 40)
    }
}

struct ChurchRosserSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("The Church-Rosser Theorem")
            
            ConceptCard(
                title: "Multiple Paths, Same Destination",
                color: .indigo,
                content: """
                When reducing lambda expressions, we often have a choice of which β-redex to reduce first. The Church-Rosser theorem tells us something remarkable: no matter which path we choose, if we can reach a final result, it will be the same!
                """,
                icon: "arrow.triangle.branch"
            )
            
            // Diamond example
            VStack(spacing: 24) {
                Text("The Diamond Property")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Image(systemName: "diamond.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue.opacity(0.6))
                
                Text("If M can reduce to both N₁ and N₂, then there exists some term P that both N₁ and N₂ can reduce to.")
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            
            // Example with different reduction paths
            ConceptCard(
                title: "Different Paths in Action",
                color: .purple,
                content: """
                Let's see how the same term can be reduced in different ways but reach the same result.
                """,
                icon: "arrow.triangle.merge"
            )
            
            VStack(spacing: 16) {
                Text("Path 1: Reduce outer redex first")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                ReductionStepView(
                    term: "(λx. λy. x) ((λz. z) w)",
                    result: "λy. ((λz. z) w)",
                    explanation: "Substitute ((λz. z) w) for x",
                    color: .blue,
                    isHighlighted: false
                )
                
                ReductionStepView(
                    term: "λy. ((λz. z) w)",
                    result: "λy. w",
                    explanation: "Reduce the remaining redex",
                    color: .blue,
                    isHighlighted: true
                )
            }
            
            VStack(spacing: 16) {
                Text("Path 2: Reduce inner redex first")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                ReductionStepView(
                    term: "(λx. λy. x) ((λz. z) w)",
                    result: "(λx. λy. x) w",
                    explanation: "Reduce (λz. z) w to w",
                    color: .purple,
                    isHighlighted: false
                )
                
                ReductionStepView(
                    term: "(λx. λy. x) w",
                    result: "λy. w",
                    explanation: "Substitute w for x",
                    color: .purple,
                    isHighlighted: true
                )
            }
            
            // Interactive verification
            TryItSection(
                example: "(\\x. \\y. x) ((\\z. z) w)",
                explanation: "Try this example in the interpreter. Try to follow both reduction paths!"
            )
        }
        .padding(.horizontal, 40)
    }
}

struct NormalFormsSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("β-Normal Forms and Equivalence")
            
            ConceptCard(
                title: "What is a β-Normal Form?",
                color: .indigo,
                content: """
                A term is in β-normal form when it contains no β-redexes - that is, no subterms of the form (λx.M) N that can be reduced further.
                """,
                icon: "checkmark.circle.fill"
            )
            
            // Examples of normal forms
            VStack(spacing: 24) {
                Text("Examples of Normal Forms")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ExampleView(
                    title: "Already in normal form",
                    original: "λx. x",
                    equivalent: "Cannot be reduced further",
                    explanation: "The identity function is already in normal form",
                    color: .blue
                )
                
                ExampleView(
                    title: "Not in normal form",
                    original: "(λx. x) y",
                    equivalent: "Can be reduced to y",
                    explanation: "Contains a redex that can be reduced",
                    color: .purple
                )
            }
            
            // β-equivalence
            ConceptCard(
                title: "β-Equivalence",
                color: .green,
                content: """
                Two terms are β-equivalent if they can be reduced to the same normal form. Thanks to the Church-Rosser theorem, this gives us a well-defined notion of "equality" for lambda terms.
                """,
                icon: "equal.circle.fill"
            )
            
            VStack(spacing: 16) {
                Text("β-Equivalent Terms")
                    .font(.headline)
                
                ExampleView(
                    title: "Example 1",
                    original: "(λx. x) ((λy. y) z)",
                    equivalent: "z",
                    explanation: "Both reduce to z",
                    color: .blue
                )
                
                ExampleView(
                    title: "Example 2",
                    original: "(λx. λy. x) a b",
                    equivalent: "a",
                    explanation: "Multiple steps, but both reach a",
                    color: .purple
                )
            }
            
            // Terms without normal forms
            ConceptCard(
                title: "Not All Terms Have Normal Forms",
                color: .orange,
                content: """
                Some terms, when reduced, never reach a normal form. The most famous example is Ω = (λx. x x) (λx. x x), which reduces to itself indefinitely.
                """,
                icon: "infinity"
            )
            
            // Interactive exploration
            TryItSection(
                example: "(\\x. x x) (\\x. x x)",
                explanation: "Try the Ω term in the interpreter - but be prepared to stop it!"
            )
        }
        .padding(.horizontal, 40)
    }
}

struct ReductionStrategiesSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Different Ways to Reduce")
            
            ConceptCard(
                title: "Why Do We Need Different Strategies?",
                color: .indigo,
                content: """
                While the Church-Rosser theorem tells us that all reduction paths lead to the same result (if one exists), some paths are more efficient than others. Different strategies also have different properties that make them useful in different contexts.
                """,
                icon: "arrow.triangle.branch"
            )
            
            // Complex example that we'll use throughout
            ConceptCard(
                title: "Our Running Example",
                color: .blue,
                content: """
                Let's explore each strategy using this expression:
                (λx.y) ((λx.x x) (λx.x x))
                This term is particularly interesting because it contains the Ω term as an argument!
                """,
                icon: "doc.text.magnifyingglass"
            )
            
            // Full β-reduction
            VStack(spacing: 24) {
                Text("Full β-reduction")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ConceptCard(
                    title: "Non-deterministic Reduction",
                    color: .purple,
                    content: """
                    In full β-reduction, we can choose any redex to reduce at each step. This flexibility can be both a blessing and a curse.
                    """,
                    icon: "arrow.triangle.merge"
                )
                
                // Show multiple possible paths
                VStack(spacing: 16) {
                    Text("Path 1: Reduce outer redex first")
                        .font(.headline)
                    
                    ReductionStepView(
                        term: "(λx.y) ((λx.x x) (λx.x x))",
                        result: "y",
                        explanation: "Immediately get y by reducing outer redex",
                        color: .green,
                        isHighlighted: true
                    )
                }
                
                VStack(spacing: 16) {
                    Text("Path 2: Try reducing inner redex")
                        .font(.headline)
                    
                    ReductionStepView(
                        term: "(λx.y) ((λx.x x) (λx.x x))",
                        result: "(λx.y) ((λx.x x) (λx.x x))",
                        explanation: "Reduces to itself indefinitely!",
                        color: .red,
                        isHighlighted: true
                    )
                }
            }
            
            // Normal Order Strategy
            VStack(spacing: 24) {
                Text("Normal Order Strategy")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ConceptCard(
                    title: "Leftmost-Outermost First",
                    color: .green,
                    content: """
                    Normal order always reduces the leftmost, outermost redex first. This strategy is guaranteed to find a normal form if one exists.
                    """,
                    icon: "arrow.left"
                )
                
                ReductionSequenceView(steps: [
                    ("(λx.y) ((λx.x x) (λx.x x))", "Start with our term"),
                    ("y", "Reduce outermost redex first"),
                    ("y", "Already in normal form!")
                ], color: .green)
            }
            
            // Call-by-Name
            VStack(spacing: 24) {
                Text("Call-by-Name")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ConceptCard(
                    title: "Arguments Last",
                    color: .orange,
                    content: """
                    Similar to normal order, but never reduces under λ. This can be more efficient but might miss some simplifications.
                    """,
                    icon: "chevron.right.circle"
                )
                
                ExampleView(
                    title: "Call-by-Name Example",
                    original: "(λx.y) ((λx.x x) (λx.x x))",
                    equivalent: "y",
                    explanation: "Same result, but won't reduce under abstractions",
                    color: .orange
                )
            }
            
            // Call-by-Value
            VStack(spacing: 24) {
                Text("Call-by-Value")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ConceptCard(
                    title: "Arguments First",
                    color: .blue,
                    content: """
                    Evaluates arguments before applying functions. This is how most programming languages work, but it can get stuck where other strategies succeed.
                    """,
                    icon: "arrow.right.circle"
                )
                
                ReductionSequenceView(steps: [
                    ("(λx.y) ((λx.x x) (λx.x x))", "Try to evaluate argument first"),
                    ("(λx.y) ((λx.x x) (λx.x x))", "Argument doesn't terminate!"),
                    ("⊥", "Strategy fails to find normal form")
                ], color: .red)
            }
            
            // Strategy Comparison
            ConceptCard(
                title: "Choosing a Strategy",
                color: .purple,
                content: """
                • Normal Order is the most reliable for finding normal forms
                • Call-by-Value matches typical programming languages
                • Call-by-Name can be more efficient for unused arguments
                • Call-by-Need (Lazy Evaluation) combines Call-by-Name's efficiency with sharing
                """,
                icon: "list.bullet"
            )
            
            // Interactive exploration
            TryItSection(
                example: "(\\x. y) ((\\x. x x) (\\x. x x))",
                explanation: "Try this term with different evaluation strategies in the interpreter!"
            )
        }
        .padding(.horizontal, 40)
    }
}

struct NormalizationSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Understanding Normalization")
            
            ConceptCard(
                title: "What is Normalization?",
                color: .indigo,
                content: """
                A term 'normalizes' under a strategy if reduction using that strategy leads to a normal form. But not all terms normalize, and some normalize under some strategies but not others!
                """,
                icon: "arrow.down.right.circle"
            )
            
            // Weak vs Strong Normalization
            VStack(spacing: 24) {
                ConceptCard(
                    title: "Weak vs Strong Normalization",
                    color: .purple,
                    content: """
                    • Weak Normalization: Some reduction sequence leads to a normal form
                    • Strong Normalization: Every reduction sequence leads to a normal form
                    """,
                    icon: "arrow.up.and.down.circle"
                )
                
                ExampleView(
                    title: "Weakly Normalizing Term",
                    original: "(λx.y) ((λx.x x) (λx.x x))",
                    equivalent: "y",
                    explanation: "Some paths normalize (to y), others don't",
                    color: .blue
                )
            }
            
            // Terms that Always Normalize
            ConceptCard(
                title: "Guaranteed to Normalize",
                color: .green,
                content: """
                Some terms, like λx.x (identity function) and all beta-normal forms, are strongly normalizing - every reduction strategy will work!
                """,
                icon: "checkmark.circle.fill"
            )
            
            // Terms that Never Normalize
            ConceptCard(
                title: "The Famous Ω (Omega) Term",
                color: .red,
                content: """
                Ω = (λx.x x) (λx.x x) is the classic example of a term that never reaches normal form - it reduces to itself forever!
                """,
                icon: "infinity"
            )
            
            // Strategy-Dependent Normalization
            VStack(spacing: 24) {
                Text("Strategy Matters!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ExampleView(
                    title: "Normal Order Success",
                    original: "(λx.y) Ω",
                    equivalent: "y",
                    explanation: "Normal order finds normal form",
                    color: .green
                )
                
                ExampleView(
                    title: "Call-by-Value Failure",
                    original: "(λx.y) Ω",
                    equivalent: "⊥",
                    explanation: "Call-by-value gets stuck trying to evaluate Ω",
                    color: .red
                )
            }
            
            // Interactive Examples
            TryItSection(
                example: "(\\x. x) ((\\y. y) z)",
                explanation: "This is a nested application of the identity function. Try evaluating it step by step!"
            )
        }
        .padding(.horizontal, 40)
    }
}

struct Chapter3PracticeSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SectionTitle("Put It All Together")
            
            ConceptCard(
                title: "Your Lambda Calculus Laboratory",
                color: .indigo,
                content: """
                Now it's time to apply everything we've learned about reduction strategies and normalization. Let's explore some challenging examples!
                """,
                icon: "flask"
            )
            
            
            VStack(spacing: 24) {
                Text("Warm-up Exercises")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ExerciseCard(
                    title: "Simple β-reduction",
                    problem: "Reduce (λx.λy.x) a b using any strategy",
                    hint: "Try normal order - reduce leftmost, outermost redex first",
                    solution: "a",
                    interpreterExample: "(\\x. \\y. x) a b"
                )
                
                ExerciseCard(
                    title: "Multiple Steps",
                    problem: "Reduce (λz.z z) (λy.y)",
                    hint: "Watch for creating new redexes as you reduce",
                    solution: "λX0.X0",
                    interpreterExample: "(\\z. z z) (\\y. y)"
                )
            }
            
            
            VStack(spacing: 24) {
                Text("Compare Strategies")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ExerciseCard(
                    title: "Strategy Differences",
                    problem: "Reduce (λx.y) ((λz.z) a) using normal order",
                    hint: "With normal order, we don't need to evaluate the argument first",
                    solution: "y",
                    interpreterExample: "(\\x. y) ((\\z. z) a)"
                )
                
                ExerciseCard(
                    title: "Finding Normal Forms",
                    problem: "Which strategy will normalize (λx.y) ((λz.z) (λw.w))?",
                    hint: "Think about which strategies evaluate arguments first",
                    solution: "Both strategies reach y",
                    interpreterExample: "(\\x. y) ((\\z. z) (\\w. w))"
                )
            }
            
            // Challenge Problems
            ConceptCard(
                title: "Challenge Problems",
                color: .purple,
                content: """
                Ready for some harder examples? These will test your understanding of reduction strategies and normalization!
                """,
                icon: "star.fill"
            )
            
            VStack(spacing: 24) {
                ExerciseCard(
                    title: "Complex Reduction",
                    problem: "Reduce (λx.λy.x y) ((λz.z) w) v",
                    hint: "Try different reduction orders - do they all reach the same result?",
                    solution: "w v",
                    interpreterExample: "(\\x. \\y. x y) ((\\z. z) w) v"
                )
                
                ExerciseCard(
                    title: "Strategy Analysis",
                    problem: "Reduce (λx.λy.y) ((λx.x) a) z",
                    hint: "Consider which parts need to be evaluated to reach normal form",
                    solution: "z",
                    interpreterExample: "(\\x. \\y. y) ((\\x. x) a) z"
                )
            }
            
            
            TryItSection(
                example: "(\\x. \\y. \\z. x z (y z)) (\\x. x) (\\x. x) w",
                explanation: "Try reducing this expression. It involves multiple abstractions and applications. Can you predict the final result?"
            )
        }
        .padding(.horizontal, 40)
    }
}

struct ReductionSequenceView: View {
    let steps: [(term: String, explanation: String)]
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                ReductionStepView(
                    term: step.term,
                    result: index < steps.count - 1 ? steps[index + 1].term : step.term,
                    explanation: step.explanation,
                    color: color,
                    isHighlighted: index == steps.count - 1
                )
            }
        }
    }
}
