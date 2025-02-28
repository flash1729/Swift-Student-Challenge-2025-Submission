//
//  ContentView.swift
//  LambdaLearner
//
//  Created by Aditya Medhane on 28/02/25.
//

import SwiftUI

// MARK: - Custom Styles
struct InterpreterTextFieldStyle: TextFieldStyle {
    let isProcessing: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .blue.opacity(isProcessing ? 0.3 : 0.5),
                                .purple.opacity(isProcessing ? 0.3 : 0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

struct InterpreterToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                configuration.label
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? Color.blue : Color.gray)
                    .frame(width: 36, height: 20)
                    .overlay(
                        Circle()
                            .fill(.white)
                            .padding(2)
                            .offset(x: configuration.isOn ? 8 : -8)
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Helper Views
struct QuickCommandButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: [
                            Color(.systemGray5),
                            Color(.systemGray4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(8)
        }
    }
}

struct LogDisplayView: View {
    let logEntry: LogEntry
    
    var body: some View {
        Text(logEntry.formattedMessage)
            .font(.system(.body, design: .monospaced))
            .foregroundColor(colorForLogType(logEntry.type))
            .padding(.leading, CGFloat(logEntry.indentationLevel * 4) * 8)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func colorForLogType(_ type: LogType) -> Color {
        switch type {
        case .normal:
            return .blue
        case .inputEcho:
            return Color(red: 0.3, green: 0.7, blue: 1.0)
        case .originalTerm:
            return Color(red: 0.3, green: 0.7, blue: 1.0)
        case .parsedInput:
            return Color(red: 0.4, green: 0.8, blue: 1.0)
        case .alphaReduction:
            return Color(red: 0.3, green: 0.9, blue: 0.4)
        case .deltaExpansion:
            return Color(red: 0.0, green: 0.8, blue: 0.8)
        case .deltaSummary:
            return Color(red: 1.0, green: 0.6, blue: 0.0)
        case .betaReduction(let explanation):
            return explanation != nil ?
            Color(red: 0.7, green: 0.3, blue: 1.0) :
            Color(red: 0.5, green: 0.0, blue: 0.8)
        case .finalResult:
            return Color(red: 0.0, green: 1.0, blue: 0.5)
        case .equivalence:
            return Color(red: 0.8, green: 0.8, blue: 0.8)
        case .error:
            return Color(red: 1.0, green: 0.3, blue: 0.3)
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @ObservedObject private var interpreter: Interpreter
    @Binding var inputText: String
    @State private var isProcessing: Bool = false
    @State private var renameFreeVars: Bool = false
    @State private var verbosityLevel: Verbosity = .high
    @State private var showingHelp = false
    
    init(interpreter: Interpreter, inputText: Binding<String>) {
        self._interpreter = ObservedObject(wrappedValue: interpreter)
        self._inputText = inputText
    }
    
    //    init(initialInput: String = "") {
    //        let options = InterpreterOptions(
    //            verbosity: .high,
    //            renameFreeVars: false,
    //            showEquivalent: true
    //        )
    //        self._interpreter = ObservedObject(wrappedValue: Interpreter(options: options))
    //        let state = State(initialValue: initialInput)
    //        self._inputText = Binding(
    //            get: { state.wrappedValue },
    //            set: { state.wrappedValue = $0 }
    //        )
    //    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with Lambda symbol
            HStack {
                Spacer()
                
                HStack(spacing: 8) {  // This inner HStack keeps λ and "Interpreter" together
                    Text("λ")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Interpreter")
                        .font(.title)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Button(action: { showingHelp = true }) {
                    Image(systemName: "questionmark.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.blue)
                    Text("Help")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }
            
            // Input Section
            VStack(spacing: 16) {
                // Expression input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Expression")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    
                    TextField("Enter lambda expression (e.g., \\x. x)", text: $inputText)
                        .textFieldStyle(InterpreterTextFieldStyle(isProcessing: isProcessing))
                        .font(.system(.body, design: .monospaced))
                }
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Verbosity Level")
                        
                        Picker("Verbosity", selection: $verbosityLevel) {
                            Text("None").tag(Verbosity.none)
                            Text("Low").tag(Verbosity.low)
                            Text("High").tag(Verbosity.high)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(maxWidth: 200)
                        .onChange(of: verbosityLevel) {
                            updateInterpreterOptions()
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("Rename Free Variables")
                                .font(.subheadline)
                            
                            Toggle("", isOn: $renameFreeVars)
                                .labelsHidden()
                                .toggleStyle(InterpreterToggleStyle())
                        }
                        .onChange(of: renameFreeVars) {
                            updateInterpreterOptions()
                        }
                    }
                    
                    Button(action: evaluateExpression) {
                        Text("Evaluate")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [
                                        isProcessing || inputText.isEmpty ? .gray : .blue,
                                        isProcessing || inputText.isEmpty ? .gray.opacity(0.7) : .purple
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .disabled(isProcessing || inputText.isEmpty)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(interpreter.logger.logEntries) { entry in
                            LogDisplayView(logEntry: entry)
                                .id(entry.id)
                                .transition(.opacity)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .onChange(of: interpreter.logger.logEntries.count) {
                    if let lastId = interpreter.logger.logEntries.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding()
        .sheet(isPresented: $showingHelp) {
            LambdaHelpView(
                isPresented: $showingHelp,
                interpreterInput: $inputText
            )
        }
    }
    
    private func evaluateExpression() {
        guard !inputText.isEmpty else { return }
        
        DispatchQueue.main.async {
            isProcessing = true
            interpreter.logger.clearLogs()
            
            // Ensure we're using the latest options
            let currentOptions = InterpreterOptions(
                verbosity: verbosityLevel,
                renameFreeVars: renameFreeVars,
                showEquivalent: true
            )
            interpreter.setOptions(currentOptions)
            
            // Log input immediately
            interpreter.logger.logInputEcho(inputText)
            
            // Perform evaluation on background thread
            DispatchQueue.global(qos: .userInitiated).async {
                // First check for commands
                if let command = parseCommand(inputText) {
                    let result = interpreter.handleCommand(command)
                    DispatchQueue.main.async {
                        interpreter.logger.log(result, type: .normal)
                        isProcessing = false
                    }
                    return
                }
                
                // Perform the actual evaluation
                let (_, error) = interpreter.evaluate(inputText)
                
                // Handle results on main thread
                DispatchQueue.main.async {
                    if let error = error {
                        if let recursionError = error as? RecursionDepthError {
                            // Special handling for recursion depth errors
                            let errorToken = Token(type: .error, lexeme: "", line: 1, start: 0, length: 0)
                            interpreter.logger.reportError(
                                errorToken,
                                message: recursionError.message,
                                verbose: true
                            )
                        } else {
                            // Handle other errors
                            let errorToken = Token(type: .error, lexeme: "", line: 1, start: 0, length: 0)
                            interpreter.logger.reportError(
                                errorToken,
                                message: String(describing: error)
                            )
                        }
                    }
                    isProcessing = false
                }
            }
        }
    }
    
    private func parseCommand(_ input: String) -> CommandStmt? {
        switch input.lowercased() {
        case "env":
            return CommandStmt(type: .env)
        case "help":
            return CommandStmt(type: .help)
        default:
            if input.hasPrefix("unbind ") {
                let name = String(input.dropFirst(7)).trimmingCharacters(in: .whitespaces)
                return CommandStmt(type: .unbind, argument: name)
            }
            return nil
        }
    }
    
    private func updateInterpreterOptions() {
        let options = InterpreterOptions(
            verbosity: verbosityLevel,
            renameFreeVars: renameFreeVars,
            showEquivalent: true
        )
        interpreter.setOptions(options)
    }
}


// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let interpreter = Interpreter(options: InterpreterOptions(
            verbosity: .high,
            renameFreeVars: false,
            showEquivalent: true
        ))
        let text = State(initialValue: "")
        return ContentView(
            interpreter: interpreter,
            inputText: text.projectedValue
        )
    }
}
