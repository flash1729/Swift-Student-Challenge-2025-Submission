import SwiftUI
import Foundation

enum TokenType {
    case leftParen     // For '('
    case rightParen    // For ')'
    case lambda        // For 'λ', '\', or 'lambda'
    case env          // For environment commands
    case unbind       // For unbinding variables
    case help         // For help command
    case dot          // For '.'
    case identifier   // For variable names and identifiers
    case equals       // For '='
    case newline      // For line endings
    case eof          // End of file
    case error        // For error tokens
}
