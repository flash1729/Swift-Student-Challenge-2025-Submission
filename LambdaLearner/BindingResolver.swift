import Foundation

class BindingResolver: TermVisitor {
    typealias T = any Term
    
    private var expanded: Bool = false
    private let bindings: [String: any Term]
    private let logger: Logger
    
    init(bindings: [String: any Term], logger: Logger) {
        self.bindings = bindings
        self.logger = logger
    }
    
    func resolveTerm(_ term: any Term) -> any Term {
        // Reset expanded flag at start
        self.expanded = false
        
        // Resolve the term
        let resolved = resolve(term)
        
        // Log delta summary only if expansions occurred
        if self.expanded {
            logger.vlog("Δ > \(stringify(resolved))")
        }
        
        return resolved
    }
    
    private func resolve(_ term: any Term) -> any Term {
        return term.accept(visitor: self)
    }
    
    func visitAbstraction(_ abstraction: Abstraction) -> any Term {
        abstraction.body = resolve(abstraction.body)
        return abstraction
    }
    
    func visitApplication(_ application: Application) -> any Term {
        application.function = resolve(application.function)
        application.argument = resolve(application.argument)
        return application
    }
    
    func visitVariable(_ variable: Variable) -> any Term {
        if variable.isFreeVar(), let binding = bindings[variable.name] {
            // Log the expansion exactly like TypeScript
            logger.vlog("    δ > expanded '\(variable.name)' into '\(stringify(binding))'")
            self.expanded = true
            
            // Clone and resolve the binding
            return resolve(clone(binding, newParent: variable.parent))
        }
        return variable
    }
}
