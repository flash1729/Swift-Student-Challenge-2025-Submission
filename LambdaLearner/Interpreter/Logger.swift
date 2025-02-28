// Logger.swift

import Foundation
import SwiftUI
import Combine

class LexError: Error {
    static let type = "lexerror"
}

class ParseError: Error {
    static let type = "parseerror"
}

enum LogType {
    case normal
    case inputEcho
    case parsedInput
    case originalTerm
    case alphaReduction(explanation: String?)
    case betaReduction(explanation: String?)
    case deltaExpansion(original: String, expanded: String)
    case deltaSummary
    case finalResult
    case equivalence
    case error(details: String?)
}

struct LogEntry: Identifiable {
    let id = UUID()
    let parentID: UUID?
    let sequence: Int
    let message: String
    let type: LogType
    let timestamp: Date
    
    var formattedMessage: String {
        switch type {
        case .normal:
            return message
        case .inputEcho:
            return "λ> \(message)"
        case .parsedInput:
            return "λ > \(message)"
        case .originalTerm:
            return "λ > \(message)"
        case .alphaReduction(let explanation):
            let base = "α > \(message)"
            if let exp = explanation {
                return "    \(exp)"  // Changed to match TypeScript format
            }
            return base
        case .betaReduction(let explanation):
            let base = "β > \(message)"
            if let exp = explanation {
                return base + "\n    " + exp  // Changed to match TypeScript format
            }
            return base
        case .deltaExpansion(let original, let expanded):
            return "    δ > expanded '\(original)' into '\(expanded)'"  // Added spacing
        case .deltaSummary:
            return "Δ > \(message)"
        case .finalResult:
            return ">>> \(message)"
        case .equivalence:
            return "    ↳ equivalent to: \(message)"  // Modified to match TypeScript
        case .error(let details):
            let base = "Error: \(message)"
            if let det = details {
                // Format multi-line error messages properly
                let formattedDetails = det.split(separator: "\n")
                    .map { "    \($0)" }
                    .joined(separator: "\n")
                return "\(base)\n\(formattedDetails)"
            }
            return base
        }
    }
    
    var indentationLevel: Int {
        // For delta expansions and equivalence, we want indentation
        switch type {
        case .deltaExpansion, .equivalence:
            return 1  // This gives us the 4-space indentation
        case .betaReduction(let explanation) where explanation != nil:
            return 1  // For beta reduction explanations
        default:
            return 0
        }
    }
}

extension LogEntry: Equatable {
    static func == (lhs: LogEntry, rhs: LogEntry) -> Bool {
        lhs.id == rhs.id
    }
}

extension LogEntry: Comparable {
    static func < (lhs: LogEntry, rhs: LogEntry) -> Bool {
        if lhs.sequence != rhs.sequence {
            return lhs.sequence < rhs.sequence
        }
        return lhs.timestamp < rhs.timestamp
    }
}

class Logger: ObservableObject {
    @Published private(set) var logEntries: [LogEntry] = []
    @Published private(set) var hasError: Bool = false
    
    private var verbosity: Verbosity
    private var source: [String]
    private var sequenceCounter: Int = 0
    private var entryCache: [UUID: LogEntry] = [:]
    
    init(options: LoggerOptions? = nil) {
        self.verbosity = .none
        self.source = []
        self.setOptions(options)
    }
    
    func setOptions(_ options: LoggerOptions?) {
        if let options = options {
            self.verbosity = options.verbosity ?? self.verbosity
            if let source = options.source {
                self.source = source.components(separatedBy: .newlines)
            }
        }
    }
    
    @discardableResult
    public func log(_ message: String, type: LogType, parentID: UUID? = nil) -> UUID {
        let sequence = incrementSequence()
        let entry = LogEntry(
            parentID: parentID,
            sequence: sequence,
            message: message,
            type: type,
            timestamp: Date()
        )
        
        entryCache[entry.id] = entry
        
        DispatchQueue.main.async {
            self.logEntries.append(entry)
        }
        
        return entry.id
    }
    
    @discardableResult
    func vlog(_ messages: String..., type: LogType = .normal, parentID: UUID? = nil) -> UUID? {
        guard verbosity >= .low else { return nil }
        return log(messages.joined(separator: " "), type: type, parentID: parentID)
    }
    
    @discardableResult
    func vvlog(_ messages: String..., type: LogType = .normal, parentID: UUID? = nil) -> UUID? {
        guard verbosity >= .high else { return nil }
        return log(messages.joined(separator: " "), type: type, parentID: parentID)
    }
    
    private func incrementSequence() -> Int {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        sequenceCounter += 1
        return sequenceCounter
    }
    
    private func mostRecentEntry(withParent parentID: UUID? = nil) -> UUID? {
        logEntries.last { entry in
            entry.parentID == parentID
        }?.id
    }
    
    @discardableResult
    func logInputEcho(_ input: String) -> UUID {
        log(input, type: .inputEcho)
    }
    
    @discardableResult
    func logTerm(_ term: String, parentID: UUID? = nil) -> UUID {
        log(term, type: .originalTerm, parentID: parentID)
    }
    
    func logAlphaReduction(_ term: String, explanation: String? = nil, parentID: UUID? = nil) {
        guard verbosity >= .low else { return }
        log(term, type: .alphaReduction(explanation: explanation), parentID: parentID)
    }
    
    func logBetaReduction(_ term: String, original: String? = nil, result: String? = nil, parentID: UUID? = nil) {
        guard verbosity >= .low else { return }
        let explanation = original != nil && result != nil ?
        "Beta reducing '\(original!)' into '\(result!)'" : nil
        log(term, type: .betaReduction(explanation: explanation), parentID: parentID)
    }
    
    func logDeltaExpansion(_ originalVar: String, expandedTerm: String, parentID: UUID? = nil) {
        guard verbosity >= .low else { return }
        log("", type: .deltaExpansion(original: originalVar, expanded: expandedTerm), parentID: parentID)
    }
    
    func logDeltaSummary(_ term: String, parentID: UUID? = nil) {
        guard verbosity >= .low else { return }
        log(term, type: .deltaSummary, parentID: parentID)
    }
    
    @discardableResult
    func logFinalResult(_ term: String, parentID: UUID? = nil) -> UUID {
        log(term, type: .finalResult, parentID: parentID)
    }
    
    func logEquivalence(_ terms: [String], parentID: UUID? = nil) {
        log("equivalent to: \(terms.joined(separator: ", "))", type: .equivalence, parentID: parentID)
    }
    
    private func logErrorContext(_ token: Token, parentID: UUID) {
        guard token.line - 1 < source.count else { return }
        
        let line = source[token.line - 1]
        let safeStart = max(token.start, 0)
        var indicator = String(repeating: " ", count: safeStart)
        indicator += String(repeating: "^", count: max(token.length, 1))
        
        if token.type == .eof {
            indicator += "^"
        }
        
        _ = log(
            "\(line)\n\(indicator)",
            type: .error(details: nil),
            parentID: parentID
        )
    }
    
    func reportError(_ token: Token, message: String, verbose: Bool = true, parentID: UUID? = nil) {
        hasError = true
        let location = token.type == .eof ? 
        "end of file" : 
        "line \(token.line) [\(token.start), \(token.start + token.length)]"
        
        let errorMessage = "\(location): \(message)"
        let errorID = log(errorMessage, type: .error(details: nil))
        
        if verbose && token.line - 1 < source.count {
            logErrorContext(token, parentID: errorID)
        }
    }
    
    func clearLogs() {
        DispatchQueue.main.async {
            self.logEntries.removeAll()
            self.hasError = false
            self.entryCache.removeAll()
            self.sequenceCounter = 0
        }
    }
    
    func getReductionSteps() -> [LogEntry] {
        logEntries.filter { entry in
            switch entry.type {
            case .originalTerm, .alphaReduction, .betaReduction,
                    .deltaExpansion, .finalResult, .equivalence:
                return true
            default:
                return false
            }
        }
    }
}

extension Verbosity: Comparable {
    static func < (lhs: Verbosity, rhs: Verbosity) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
