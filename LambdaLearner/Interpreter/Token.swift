import SwiftUI
import Foundation

struct Token {
    let type: TokenType
    let lexeme: String
    let line: Int
    let start: Int
    let length: Int
    
    init(type: TokenType, lexeme: String, line: Int, start: Int, length: Int) {
        self.type = type
        self.lexeme = lexeme
        self.line = line
        self.start = start
        self.length = length
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        if type == .newline {
            return "<newline>"
        }
        return lexeme
    }
}

extension Token: Equatable {
    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.type == rhs.type &&
        lhs.lexeme == rhs.lexeme &&
        lhs.line == rhs.line &&
        lhs.start == rhs.start &&
        lhs.length == rhs.length
    }
}

