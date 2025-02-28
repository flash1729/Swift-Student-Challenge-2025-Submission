// Utils.swift

import Foundation

struct TermTransformFuncs<T> {
    let absf: (Abstraction, T) -> T
    let appf: (Application, T, T) -> T
    let vf: (Variable) -> T
}

//func transformTerm<T>(_ root: (any Term)?, funcs: TermTransformFuncs<T>) -> T? {
//    guard let root = root else {
//        print("Warning: Attempted to transform nil term")
//        return nil
//    }
//    
//    do {
//        if let abs = root as? Abstraction {
//            let body = transformTerm(abs.body, funcs: funcs)
//            guard let body = body else { return nil }
//            return funcs.absf(abs, body)
//        } else if let app = root as? Application {
//            let function = transformTerm(app.function, funcs: funcs)
//            let argument = transformTerm(app.argument, funcs: funcs)
//            guard let function = function, let argument = argument else { return nil }
//            return funcs.appf(app, function, argument)
//        } else if let variable = root as? Variable {
//            return funcs.vf(variable)
//        } else {
//            print("Error: Unknown term type: \(type(of: root))")
//            return nil
//        }
//    } catch {
//        print("Error during term transformation: \(error)")
//        return nil
//    }
//}

class TransformError: Error {
    let message: String
    init(_ message: String) {
        self.message = message
    }
}

// Thread-safe depth counter to handle parallel transformations
private let depthLock = NSLock()
private var currentDepth: Int = 0
private let MAX_TRANSFORM_DEPTH = 1000

private func incrementDepth() throws {
    depthLock.lock()
    defer { depthLock.unlock() }
    
    currentDepth += 1
    if currentDepth > MAX_TRANSFORM_DEPTH {
        currentDepth = 0  // Reset depth before throwing
        throw TransformError("Maximum transform depth exceeded - possible infinite recursion")
    }
}

private func decrementDepth() {
    depthLock.lock()
    defer { depthLock.unlock() }
    currentDepth = max(0, currentDepth - 1)
}

func transformTerm<T>(_ root: (any Term)?, funcs: TermTransformFuncs<T>) -> T? {
    // Reset depth at the start of a new transformation
    currentDepth = 0
    
    return try? transformTermWithDepth(root, funcs: funcs)
}

private func transformTermWithDepth<T>(_ root: (any Term)?, funcs: TermTransformFuncs<T>) throws -> T? {
    guard let root = root else {
        print("Warning: Attempted to transform nil term")
        return nil
    }
    
    // Increment depth and ensure we decrement on exit
    try incrementDepth()
    defer { decrementDepth() }
    
    do {
        switch root {
        case let abs as Abstraction:
            // Transform abstraction body
            guard let body = try transformTermWithDepth(abs.body, funcs: funcs) else {
                return nil
            }
            return funcs.absf(abs, body)
            
        case let app as Application:
            // Transform both function and argument
            guard let function = try transformTermWithDepth(app.function, funcs: funcs),
                  let argument = try transformTermWithDepth(app.argument, funcs: funcs) else {
                return nil
            }
            return funcs.appf(app, function, argument)
            
        case let variable as Variable:
            // Variables are leaf nodes, no recursion needed
            return funcs.vf(variable)
            
        default:
            print("Error: Unknown term type: \(type(of: root))")
            return nil
        }
    } catch let transformError as TransformError {
        print("Transform error: \(transformError.message)")
        throw transformError
    } catch {
        print("Unexpected error during term transformation: \(error)")
        throw TransformError("Unexpected error during transformation")
    }
}

// Helper function to safely transform terms with a custom error handler
func safeTransformTerm<T>(_ root: (any Term)?, funcs: TermTransformFuncs<T>, onError: ((String) -> Void)? = nil) -> T? {
    do {
        return try transformTermWithDepth(root, funcs: funcs)
    } catch let error as TransformError {
        onError?(error.message)
        return nil
    } catch {
        onError?("Unexpected error during term transformation")
        return nil
    }
}

struct TermTraverseFuncs {
    let absf: ((Abstraction) -> Void)?
    let appf: ((Application) -> Void)?
    let vf: ((Variable) -> Void)?
}

func traverseTerm(_ root:any Term, funcs: TermTraverseFuncs) {
    transformTerm(root, funcs: TermTransformFuncs<Void>(
        absf: { abs, _ in funcs.absf?(abs) },
        appf: { app, _, _ in funcs.appf?(app) },
        vf: { v in funcs.vf?(v) }
    ))
}

func stringify(_ term: (any Term)?) -> String {
    guard let term = term else { return "nil" }
    
    return transformTerm(term, funcs: TermTransformFuncs<String>(
        absf: { abs, body in "(λ\(abs.name). \(body))" },
        appf: { _, function, argument in "(\(function) \(argument))" },
        vf: { v in v.name }
    )) ?? "invalid term"
}

func clone(_ term: any Term, newParent: (any Term)? = nil) -> any Term {
    let cloned = term.clone(newParent: newParent)
    cloned.parent = newParent
    return cloned
}

extension Set {
    func join(separator: String) -> String {
        return self.map { "\($0)" }.joined(separator: separator)
    }
}
