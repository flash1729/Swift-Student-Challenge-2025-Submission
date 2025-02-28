// Extensions.swift

import Foundation

// MARK: - Term Extensions
extension Term {
    var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
    
    var structureHashValue: Int {
        return structureHash(self)
    }
    
    func isStructurallyEquivalent(to other: any Term) -> Bool {
        return self.structureHashValue == other.structureHashValue
    }
}

// MARK: - String Extensions
extension String {
    var hash: Int {
        return self.hash32()
    }
}

// MARK: - Collection Extensions
extension Collection where Element: CustomStringConvertible {
    func joinedDescription(_ separator: String = ", ") -> String {
        return self.map { "\($0)" }.joined(separator: separator)
    }
}

// MARK: - Set Extensions
extension Set {
    func join(_ separator: String) -> String {
        return self.map { "\($0)" }.joined(separator: separator)
    }
}

// MARK: - Array Extensions
extension Array where Element == Variable {
    func boundVariableNames() -> Set<String> {
        return Set(self.filter { !$0.isFreeVar() }.map { $0.name })
    }
}

// MARK: - Error Extensions
extension Error {
    var localizedDescription: String {
        switch self {
        case is LexError:
            return "Lexical analysis error"
        case is ParseError:
            return "Parsing error"
        default:
            return "\(self)"
        }
    }
}
