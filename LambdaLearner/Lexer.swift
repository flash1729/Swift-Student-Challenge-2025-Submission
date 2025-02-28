// Lexer.swift

import Foundation

class Lexer {
    private(set) var source: String
    private var tokens: [Token] = []
    private var start: Int = 0
    private var current: Int = 0
    private var line: Int = 1
    private var lineStart: Int = 0
    private let logger: Logger
    
    // Keywords mapping
    private static let keywords: [String: TokenType] = [
        "lambda": .lambda,
        "env": .env,
        "unbind": .unbind,
        "help": .help
    ]
    
    init(source: String, logger: Logger = Logger()) {
        self.source = source
        self.logger = logger
    }
    
    func setSource(_ newSource: String) {
        source = newSource
        tokens = []
        start = 0
        current = 0
        line = 1
        lineStart = 0
    }
    
    func lexTokens() -> [Token] {
        tokens = []
        start = 0
        current = 0
        line = 1
        lineStart = 0
        
        while !isAtEnd() {
            start = current
            do {
                try scanToken()
            } catch {
                // Safely get the error character
                let errorChar = safeCharacterAt(current) ?? "?"
                logger.reportError(
                    makeErrorToken(String(errorChar)),
                    message: "Unexpected character: '\(errorChar)'"
                )
                
                // Advance past the error character to prevent infinite loop
                current += 1
                
                // Continue instead of break to keep processing the rest
                continue
            }
        }
        
        // Add final newline if not present
        if tokens.isEmpty || tokens.last?.type != .newline {
            tokens.append(makeToken(.newline, lexeme: "<newline>"))
        }
        
        // Add EOF token
        tokens.append(makeToken(.eof, lexeme: ""))
        
        return tokens
    }
    
    private func scanToken() throws {
        guard let c = safeCharacterAt(current) else {
            throw LexError()
        }
        
        advance()
        
        switch c {
        case "(": addToken(.leftParen)
        case ")": addToken(.rightParen)
        case "λ", "\\": addToken(.lambda)
        case ".": addToken(.dot)
        case "=": addToken(.equals)
        case " ", "\r", "\t": break  // Ignore whitespace
        case "\n":
            addToken(.newline)
            line += 1
            lineStart = current
        case "#":
            // Comment until end of line
            while peek() != "\n" && !isAtEnd() {
                _ = advance()
            }
        default:
            if c.isLowercase || c.isNumber {
                identifier()
            } else {
                throw LexError()
            }
        }
    }
    
    private func identifier() {
        while !isAtEnd() {
            let nextChar = safeCharacterAt(current)
            if let nextChar = nextChar,
               (nextChar.isLowercase || nextChar.isNumber) {
                current += 1
            } else {
                break
            }
        }
        
        let startIndex = source.index(source.startIndex, offsetBy: start)
        let currentIndex = source.index(source.startIndex, offsetBy: current)
        let text = String(source[startIndex..<currentIndex])
        
        // Check if it's a keyword or identifier
        let type = Lexer.keywords[text] ?? .identifier
        addToken(type)
    }
    
    private func match(_ expected: Character) -> Bool {
        if isAtEnd() || source[source.index(source.startIndex, offsetBy: current)] != expected {
            return false
        }
        current += 1
        return true
    }
    
    private func peek() -> Character {
        guard !isAtEnd() else { return "\0" }
        return safeCharacterAt(current) ?? "\0"
    }
    
    private func advance() -> Character {
        let char = safeCharacterAt(current) ?? "\0"
        current += 1
        return char
    }
    
    private func addToken(_ type: TokenType) {
        let startIndex = source.index(source.startIndex, offsetBy: start)
        let currentIndex = source.index(source.startIndex, offsetBy: current)
        let lexeme = String(source[startIndex..<currentIndex])
        tokens.append(makeToken(type, lexeme: lexeme))
    }
    
    private func safeCharacterAt(_ index: Int) -> Character? {
        guard index >= 0 && index < source.count else {
            return nil
        }
        return source[source.index(source.startIndex, offsetBy: index)]
    }
    
    private func makeToken(_ type: TokenType, lexeme: String) -> Token {
        return Token(
            type: type,
            lexeme: lexeme,
            line: line,
            start: start - lineStart + 1,
            length: current - start
        )
    }
    
    private func makeErrorToken(_ lexeme: String) -> Token {
        return Token(
            type: .error,
            lexeme: lexeme,
            line: line,
            start: max(current - lineStart, 0),
            length: 1
        )
    }
    
    private func isAtEnd() -> Bool {
        return current >= source.count
    }
}

// MARK: - Lexer Error
extension Lexer {
    enum LexerError: Error {
        case unexpectedCharacter(Character, position: Int)
        case invalidToken(String, position: Int)
    }
}

