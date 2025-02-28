// Interpreter.swift

import Foundation

class Interpreter: ObservableObject {
    @Published var logger: Logger
    private var lexer: Lexer!      
    private var parser: Parser!
    private var bindingResolver: BindingResolver!
    private var options: InterpreterOptions
    private var bindings: [String: any Term]
    
    // Add hash tracking like TypeScript
    private var structureHashes: [Int: Set<String>] = [:]
    private var startIndex: Int = 1
    
    init(options: InterpreterOptions = InterpreterOptions()) {
        // 1. Initialize simple properties first
        self.options = options
        self.bindings = [:]
        
        // 2. Create the logger FIRST
        self.logger = Logger(options: LoggerOptions(
            verbosity: options.verbosity,
            transports: options.transports
        ))
        
        // 3. Now initialize lexer/parser using the logger
        self.lexer = Lexer(source: "", logger: self.logger)
        self.parser = Parser(tokens: [], logger: self.logger)
        
        // 4. Initialize remaining components
        self.bindingResolver = BindingResolver(
            bindings: self.bindings,
            logger: self.logger
        )
        
        // 5. Final setup
        self.setupBuiltInTerms()
    }
    
    private func setupBuiltInTerms() {
        // Define terms exactly as in TypeScript
        let definitions: [String: String] = [
            // Logic
            "true": "(λt. (λf. t))",
            "false": "(λt. (λf. f))",
            "and": "(λa. (λb. ((a b) a)))",
            "or": "(λa. (λb. ((a a) b)))",
            "not": "(λb. ((b false) true))",
            "if": "(λp. (λa. (λb. ((p a) b))))",
            
            // Lists
            "pair|cons": "(λx. (λy. (λf. ((f x) y))))",
            "first|car": "(λp. (p true))",
            "second|cdr": "(λp. (p false))",
            "nil|empty": "(λx. true)",
            "null|isempty": "(λp. (p (λx. (λy. false))))",
            
            // Trees
            "tree": "(λd. (λl. (λr. ((pair d) ((pair l) r)))))",
            "datum": "(λt. (first t))",
            "left": "(λt. (first (second t)))",
            "right": "(λt. (second (second t)))",
            
            // Arithmetic
            "zero": "(λf. (λx. x))",
            "one": "(λf. (λx. (f x)))",
            "two": "(λf. (λx. (f (f x))))",
            "three": "(λf. (λx. (f (f (f x)))))",
            "four": "(λf. (λx. (f (f (f (f x))))))",
            "five": "(λf. (λx. (f (f (f (f (f x)))))))",
            "incr": "(λn. (λf. (λy. (f ((n f) y)))))",
            "plus": "(λm. (λn. ((m incr) n)))",
            "times": "(λm. (λn. ((m (plus n)) zero)))",
            "iszero": "(λn. ((n (λy. false)) true))"
        ]
        
        // Parse each term and add to bindings
        for (key, definition) in definitions {
            let subkeys = key.split(separator: "|")
            
            lexer.setSource(definition)
            let tokens = lexer.lexTokens()
            parser.setTokens(tokens)
            
            if let term = parser.parseTerm() {
                for subkey in subkeys {
                    let key = String(subkey)
                    bindings[key] = term
                    addHash(term: term, name: key)
                }
            }
        }
        
        startIndex = parser.currentIndex()
    }
    
    private func addHash(term: any Term, name: String) {
        let hash = structureHash(term)
        if structureHashes[hash] == nil {
            structureHashes[hash] = Set<String>()
        }
        structureHashes[hash]?.insert(name)
    }
    
    private func deleteHash(term: any Term, name: String) {
        let hash = structureHash(term)
        structureHashes[hash]?.remove(name)
    }
    
    func evaluate(_ input: String) -> (term: (any Term)?, error: Error?) {
        do {
            logger.clearLogs()
            
//            logger.log(input, type: .inputEcho)
            
            lexer.setSource(input)
            let tokens = lexer.lexTokens()
            
            parser.setTokens(tokens)
            guard let term = parser.parseTerm() else {
                let errorToken = Token(type: .error, lexeme: "", line: 1, start: 0, length: 0)
                logger.reportError(errorToken, message: "Failed to parse expression")
                return (nil, ParseError())
            }
            
            logger.log(stringify(term), type: .parsedInput)
            
            let resolvedTerm = bindingResolver.resolveTerm(term)
            
            let reducer = Reducer(
                renameFreeVars: options.renameFreeVars ?? false,
                logger: logger
            )
            
            let reducedTerm = try reducer.reduceTerm(resolvedTerm)
            let resultID = logger.logFinalResult(stringify(reducedTerm))
            
            let hash = structureHash(reducedTerm)
            if let equivalentTerms = structureHashes[hash], !equivalentTerms.isEmpty {
                logger.logEquivalence(Array(equivalentTerms), parentID: resultID)
            }
            
            return (reducedTerm, nil)
        } catch let error as RecursionDepthError {
            let errorToken = Token(type: .error, lexeme: "", line: 1, start: 0, length: 0)
            logger.reportError(errorToken, message: error.message)
            return (nil, error)
        } catch {
            let errorToken = Token(type: .error, lexeme: "", line: 1, start: 0, length: 0)
            logger.reportError(errorToken, message: String(describing: error))
            return (nil, error)
        }
    }
    
    func setOptions(_ options: InterpreterOptions) {
        self.options = options
        logger.setOptions(LoggerOptions(verbosity: options.verbosity))
        bindingResolver = BindingResolver(bindings: self.bindings, logger: logger)
    }
    
    func handleCommand(_ command: CommandStmt) -> String {
        switch command.type {
        case .env:
            return printBindings()
        case .unbind:
            if let name = command.argument {
                return unbindVariable(name)
            }
            return "Missing argument for unbind"
        case .help:
            return printHelp()
        case .none:
            return "Unknown command"
        }
    }
    
    private func printBindings() -> String {
        var result = "Current bindings:\n"
        for (name, term) in bindings {
            result += "\(name):\t\(stringify(term))\n"
        }
        return result
    }
    
    private func unbindVariable(_ name: String) -> String {
        if let term = bindings[name] {
            deleteHash(term: term, name: name)
            bindings.removeValue(forKey: name)
            return "Unbound '\(name)'"
        }
        return "'\(name)' was not bound"
    }
    
    private func printHelp() -> String {
        return """
       Available commands:
       env               - Show current environment
       unbind <name>    - Remove binding
       help             - Show this help
       
       Examples:
       \\x. x           - Identity function
       (\\x. x) y       - Application
       \\t. \\f. t       - Church true
       \\t. \\f. f       - Church false
       
       Built-in terms:
       true  - Church boolean true
       false - Church boolean false
       and   - Church boolean AND
       or    - Church boolean OR
       not   - Church boolean NOT
       """
    }
}
