import Foundation

class RecursionDepthError: Error, CustomStringConvertible {
    var message: String
    var term: String
    
    init(_ term: String) {
        self.term = term
        self.message = """
        Non-terminating reduction detected in expression: \(term)
        This expression appears to reduce infinitely. Common examples of such terms include:
        - (λx.x x x) (λx.x x x)  [The omega combinator]
        - Terms with circular substitutions
        """
    }
    
    var description: String {
        return message
    }
}

class Reducer: TermVisitor {
    typealias T = any Term
    
    private var redex: any Term
    private var depth: Int = 0
    private let renameFreeVars: Bool
    private let logger: Logger
    
    private static let MAX_RECURSION_DEPTH: Int = 1000
    private var currentNamePrefix: Int = 0
    private var currentFreeNamePrefix: Int = 0
    
    init(renameFreeVars: Bool, logger: Logger) {
        self.renameFreeVars = renameFreeVars
        self.logger = logger
        self.redex = Variable(name: "", id: 0)
    }
    
    func reduceTerm(_ term: any Term) throws -> any Term {
        depth = 0
        redex = clone(term)
        return try reduce(redex)
    }
    
//    private func reduce(_ term: any Term) throws -> any Term {
//        if depth > Reducer.MAX_RECURSION_DEPTH {
//            throw RecursionDepthError(stringify(term))
//        }
//        depth += 1
//        let result = term.accept(visitor: self)
//        depth -= 1
//        return result
//    }
    
    private func reduce(_ term: any Term) throws -> any Term {
        if depth > Reducer.MAX_RECURSION_DEPTH {
            throw RecursionDepthError(stringify(term))
        }
        depth += 1
        defer { depth -= 1 }  // Ensure depth is decremented even if an error occurs
        
        return term.accept(visitor: self)
    }
    
    func visitAbstraction(_ abstraction: Abstraction) -> any Term {
        abstraction.body = try! reduce(abstraction.body)
        return abstraction
    }
    
    func visitApplication(_ application: Application) -> any Term {
        let fNormal = try! reduce(application.function)
        application.function = fNormal
        
        let xNormal = try! reduce(application.argument)
        application.argument = xNormal
        
        guard let abstraction = fNormal as? Abstraction else {
            return application
        }
        
        // Check for name conflicts and alpha reduce if needed
        let xNames = xNormal.getAllBoundVarNames()
        let conflicts = Set(abstraction.getAllBoundVarNames().filter { xNames.contains($0) })
        
        let conflictingAbs = Set(xNormal.getAllBoundVars()
            .filter { conflicts.contains($0.name) }
            .compactMap { $0.getParentAbstraction() })
        
        if !conflictingAbs.isEmpty {
            for abs in conflictingAbs {
                let newName = genNewName()
                logger.vlog("α > \(stringify(abs))")
                logger.vvlog("Alpha reducing with name '\(newName)'")
                abs.alphaReduce(newName: newName)
            }
            if !conflictingAbs.isEmpty {
                logger.vlog("α > \(stringify(redex))")
            }
        }
        
        logger.vvlog("\nBeta reducing '\(stringify(xNormal))' into '\(stringify(fNormal))'")
        let betaReduct = abstraction.betaReduce(
            argument: xNormal,
            applicationParent: application.parent ?? application
        )
        
        if let parent = application.parent {
            if let parentAbs = parent as? Abstraction {
                parentAbs.body = betaReduct
                betaReduct.parent = parentAbs
            } else if let parentApp = parent as? Application {
                if parentApp.function === application {
                    parentApp.function = betaReduct
                } else {
                    parentApp.argument = betaReduct
                }
                betaReduct.parent = parentApp
            }
        } else {
            redex = betaReduct
            betaReduct.parent = nil
        }
        
        logger.vlog("β > \(stringify(redex))")
        return try! reduce(betaReduct)
    }
    
    func visitVariable(_ variable: Variable) -> any Term {
        if renameFreeVars && !variable.wasFreeRenamed() && variable.isFreeVar() {
            let newName = genNewFreeName()
            logger.vvlog("\nRenaming free variable '\(variable.name)' to '\(newName)'")
            logger.vlog("ε > '\(variable.name)' → '\(newName)'")
            variable.renameFree(newName)
        }
        return variable
    }
    
    private func genNewName() -> String {
        let name = "X\(currentNamePrefix)"
        currentNamePrefix += 1
        return name
    }
    
    private func genNewFreeName() -> String {
        let name = "X`\(currentFreeNamePrefix)"
        currentFreeNamePrefix += 1
        return name
    }
}
