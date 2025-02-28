// Parser.swift

import Foundation

class Parser {
    private var tokens: [Token]
    private var current: Int = 0
    private let logger: Logger
    private var idList: AbstractionIndexList
    
    init(tokens: [Token] = [], logger: Logger = Logger(), startIndex: Int = 1) {
        self.tokens = tokens
        self.logger = logger
        self.idList = AbstractionIndexList(startIndex: startIndex)
    }
    
    func setTokens(_ tokens: [Token]) {
        self.tokens = tokens
        self.current = 0
    }
    
    func currentIndex() -> Int {
        return idList.currentIndex()
    }
    
    func parse() -> [Stmt] {
        var statements: [Stmt] = []
        while !isAtEnd() {
            if let stmt = parseStatement() {
                statements.append(stmt)
            }
        }
        return statements
    }
    
//    func parseTerm() -> (any Term)? {
//        do {
//            guard !isAtEnd() else {
//                print("Parser reached end of input")
//                return nil
//            }
//            
////            print("Starting to parse term at token: \(peek())")
//            let termStmt = try parseTermStatement()
//            
//            if !isAtEnd() {
//                print("Warning: Extra tokens after term")
//                throw makeError(peek(), "Unexpected token '\(peek().lexeme)'")
//            }
//            
////            print("Successfully parsed term")
//            return termStmt.term
//        } catch {
//            print("Error parsing term: \(error)")
//            return nil
//        }
//    }
    
    func parseTerm() -> (any Term)? {
        do {
            guard !isAtEnd() else {
                print("Parser reached end of input")
                return nil
            }
            
            let termStmt = try parseTermStatement()
            
            if !isAtEnd() {
                print("Warning: Extra tokens after term")
                throw makeError(peek(), "Unexpected token '\(peek().lexeme)'")
            }
            
            // Instead of using if let, we can directly check the term
            let term = termStmt.term
            if isNonTerminatingPattern(term) {
                let errorToken = Token(type: .error, lexeme: "", line: 1, start: 0, length: 0)
                logger.reportError(
                    errorToken, 
                    message: "Non-terminating expression detected. This would lead to infinite reduction.",
                    verbose: true
                )
                return nil
            }
            
            return termStmt.term
        } catch {
            print("Error parsing term: \(error)")
            return nil
        }
    }
    
    private func isNonTerminatingPattern(_ term: any Term) -> Bool {
        // Convert term to string for pattern matching
        let termStr = stringify(term)
        
        // Check for common non-terminating patterns
        let isOmegaTerm = termStr.contains("(λx. x x x)") || 
        termStr.contains("(λx. (x x))") ||
        (termStr.contains("x x") && termStr.contains("λx"))
        
        return isOmegaTerm
    }
    
    private func parseStatement() -> Stmt? {
        do {
            // Skip newlines
            while match(.newline) {}
            
            // Check for different statement types
            if check(.identifier) && checkNext(.equals) {
                return try parseBindingStatement()
            } else if match(.env) {
                return parseCommandStatement(.env, "env")
            } else if match(.help) {
                return parseCommandStatement(.help, "help")
            } else if match(.unbind) {
                return try parseUnbindStatement()
            }
            
            return try parseTermStatement()
        } catch {
            synchronize()
            return nil
        }
    }
    
    private func parseBindingStatement() throws -> BindingStmt {
        let nameToken = try consume(.identifier, "Expected identifier")
        _ = try consume(.equals, "Expected '=' after identifier")
        let term = try parseLambdaTerm()
        _ = try consume(.newline, "Expected newline after binding")
        return BindingStmt(name: nameToken.lexeme, term: term)
    }
    
    private func parseCommandStatement(_ type: TokenType, _ str: String) -> CommandStmt {
        let cmdType: CommandType = {
            switch type {
            case .env: return .env
            case .help: return .help
            default: return .none
            }
        }()
        
        if !isAtEnd() && !check(.newline) {
            do {
                _ = try consume(.newline, "Expected newline after \(str) command")
            } catch {
                // Handle or ignore error as needed
            }
        }
        
        return CommandStmt(type: cmdType)
    }
    
    private func parseUnbindStatement() throws -> CommandStmt {
        let name = try consume(.identifier, "Expected identifier after unbind").lexeme
        try consume(.newline, "Expected newline after unbind statement")
        return CommandStmt(type: .unbind, argument: name)
    }
    
    private func parseTermStatement() throws -> TermStmt {
        let term = try parseLambdaTerm()
        try consume(.newline, "Expected newline after term")
        return TermStmt(term: term)
    }
    
    private func parseLambdaTerm() throws -> any Term {
        if match(.lambda) {
            return try parseAbstraction()
        }
        return try parseApplication()
    }
    
    private func parseAbstraction() throws -> any Term {
        var identifiers: [String] = []
        
        // Parse one or more identifiers
        let firstIdent = try consume(.identifier, "Expected identifier after lambda")
        identifiers.append(firstIdent.lexeme)
        
        while check(.identifier) {
            identifiers.append(advance().lexeme)
        }
        
        try consume(.dot, "Expected '.' after lambda parameters")
        
        // Give each abstraction its own id
        identifiers.forEach { ident in
            idList.push(ident)
        }
        
        // Create nested abstractions from innermost out
        let body = try parseLambdaTerm()
        var result = body
        
        for ident in identifiers.reversed() {
            let id = idList.get(ident)
            result = Abstraction(name: ident, id: id, body: result)
            idList.pop(ident)
        }
        
        return result
    }
    
    private func parseApplication() throws -> any Term {
        var term = try parseAtom()
        
        while !isAtEnd() && (check(.leftParen) || check(.identifier) || check(.lambda)) {
            let right = try parseAtom()
            term = Application(function: term, argument: right)
        }
        
        return term
    }
    
    private func parseAtom() throws -> any Term {
        if match(.leftParen) {
            let expr = try parseLambdaTerm()
            try consume(.rightParen, "Expected ')' after expression")
            return expr
        }
        
        if match(.identifier) {
            let name = previous().lexeme
            return Variable(name: name, id: idList.has(name) ? idList.get(name) : 0)
        }
        
        if match(.lambda) {
            return try parseAbstraction()
        }
        
        throw makeError(peek(), "Expected expression")
    }
    
    // MARK: - Helper Methods
//    private func match(_ type: TokenType) -> Bool {
//        if check(type) {
//            advance()
//            return true
//        }
//        return false
//    }
    private func match(_ type: TokenType) -> Bool {
        if check(type) {
            _ = advance()  // This is fine as is, we explicitly ignore with _
            return true
        }
        return false
    }
    
    private func check(_ type: TokenType) -> Bool {
        if isAtEnd() {
            return false
        }
        return peek().type == type
    }
    
    private func checkNext(_ type: TokenType) -> Bool {
        if current + 1 >= tokens.count {
            return false
        }
        return tokens[current + 1].type == type
    }
    
    private func advance() -> Token {
        if !isAtEnd() {
            current += 1
        }
        return previous()
    }
    
    private func consume(_ type: TokenType, _ message: String) throws -> Token {
        if check(type) {
            return advance()
        }
        throw makeError(peek(), message)
    }
    
    private func synchronize() {
        advance()
        while !isAtEnd() {
            if previous().type == .newline {
                return
            }
            advance()
        }
    }
    
    private func isAtEnd() -> Bool {
        return peek().type == .eof
    }
    
    private func peek() -> Token {
        return tokens[current]
    }
    
    private func previous() -> Token {
        return tokens[current - 1]
    }
    
    private func makeError(_ token: Token, _ message: String) -> ParseError {
        logger.reportError(token, message: message)
        return ParseError()
    }
}

// MARK: - Abstraction Index List
private class AbstractionIndexList {
    private var counter: Int
    private var ids: [String: [Int]] = [:]
    
    init(startIndex: Int) {
        self.counter = startIndex
    }
    
    func currentIndex() -> Int {
        return counter
    }
    
    func push(_ name: String) {
        if ids[name] == nil {
            ids[name] = []
        }
        ids[name]?.append(counter)
        counter += 1
    }
    
    func pop(_ name: String) {
        ids[name]?.removeLast()
        if ids[name]?.isEmpty == true {
            ids.removeValue(forKey: name)
        }
    }
    
    func get(_ name: String) -> Int {
        return ids[name]?.last ?? 0
    }
    
    func has(_ name: String) -> Bool {
        return ids[name] != nil && !(ids[name]?.isEmpty ?? true)
    }
}

