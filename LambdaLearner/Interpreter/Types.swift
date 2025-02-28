// Types.swift

import Foundation

// Logging verbosity levels
enum Verbosity: Int {
    case none = 0
    case low
    case high
}

// Type alias for logging transport functions
typealias LoggerTransport = (String) -> Void

// Options for interpreter configuration
struct InterpreterOptions {
    var verbosity: Verbosity?
    var transports: [LoggerTransport]?
    var renameFreeVars: Bool?
    var showEquivalent: Bool?
    
    init(verbosity: Verbosity? = nil,
         transports: [LoggerTransport]? = nil,
         renameFreeVars: Bool? = nil,
         showEquivalent: Bool? = nil) {
        self.verbosity = verbosity
        self.transports = transports
        self.renameFreeVars = renameFreeVars
        self.showEquivalent = showEquivalent
    }
}

// Options for logger configuration
struct LoggerOptions {
    var verbosity: Verbosity?
    var transports: [LoggerTransport]?
    var source: String?
    
    init(verbosity: Verbosity? = nil,
         transports: [LoggerTransport]? = nil,
         source: String? = nil) {
        self.verbosity = verbosity
        self.transports = transports
        self.source = source
    }
}
