// AST.swift

import Foundation


protocol TermVisitor {
    associatedtype T
    func visitAbstraction(_ abstraction: Abstraction) -> T
    func visitApplication(_ application: Application) -> T
    func visitVariable(_ variable: Variable) -> T
}

protocol StmtVisitor {
    associatedtype T
    func visitTermStmt(_ termStmt: TermStmt) -> T
    func visitBindingStmt(_ binding: BindingStmt) -> T
    func visitCommandStmt(_ command: CommandStmt) -> T
}

protocol Stmt {
    func accept<V: StmtVisitor>(visitor: V) -> V.T
}

class TermStmt: Stmt {
    var term: any Term
    
    init(term: any Term) {
        self.term = term
    }
    
    func accept<V: StmtVisitor>(visitor: V) -> V.T {
        return visitor.visitTermStmt(self)
    }
}

class BindingStmt: Stmt {
    let name: String
    let term: any Term
    
    init(name: String, term: any Term) {
        self.name = name
        self.term = term
    }
    
    func accept<V: StmtVisitor>(visitor: V) -> V.T {
        return visitor.visitBindingStmt(self)
    }
}

enum CommandType {
    case none
    case env
    case unbind
    case help
}

class CommandStmt: Stmt {
    let type: CommandType
    let argument: String?
    
    init(type: CommandType, argument: String? = nil) {
        self.type = type
        self.argument = argument
    }
    
    func accept<V: StmtVisitor>(visitor: V) -> V.T {
        return visitor.visitCommandStmt(self)
    }
}

protocol Term: AnyObject, Hashable {
    var parent: (any Term)? { get set }
    func accept<V: TermVisitor>(visitor: V) -> V.T
    func rename(newName: String, newId: Int, rootId: Int)
    func getAllBoundVarNames() -> Set<String>
    func getAllBoundVars() -> [Variable]
    func clone(newParent: (any Term)?) -> any Term
}

class Abstraction: Term {
    var name: String
    var id: Int
    var body: any Term
    weak var parent: (any Term)?
    
    init(name: String, id: Int, body: any Term) {
        self.name = name
        self.id = id
        self.body = body
        self.body.parent = self
    }
    
    func accept<V: TermVisitor>(visitor: V) -> V.T {
        return visitor.visitAbstraction(self)
    }
    
    func alphaReduce(newName: String) {
        rename(newName: newName, newId: newName.hash, rootId: id)
    }
    
    func betaReduce(argument: any Term, applicationParent: any Term) -> any Term {
        let replacements = getBoundVars()
        for rep in replacements {
            if let absParent = rep.parent as? Abstraction {
                absParent.body = argument.clone(newParent: absParent)
            } else if let appParent = rep.parent as? Application {
                if appParent.function === rep {
                    appParent.function = argument.clone(newParent: appParent)
                } else {
                    appParent.argument = argument.clone(newParent: appParent)
                }
            }
        }
        
        body.parent = applicationParent
        return body
    }
    
    func rename(newName: String, newId: Int, rootId: Int) {
        body.rename(newName: newName, newId: newId, rootId: rootId)
        if id == rootId {
            name = newName
            id = newId
        }
    }
    
    func getBoundVars() -> [Variable] {
        return getAllBoundVars().filter { $0.id == self.id }
    }
    
    func getAllBoundVarNames() -> Set<String> {
        return Set(getAllBoundVars().map { $0.name })
    }
    
    func getAllBoundVars() -> [Variable] {
        var vars: [Variable] = []
        traverseTerm(self, funcs: TermTraverseFuncs(
            absf: nil,
            appf: nil,
            vf: { variable in
                if variable.id == self.id || !variable.isFreeVar() {
                    vars.append(variable)
                }
            }
        ))
        return vars
    }
    
    func clone(newParent: (any Term)?) -> any Term {
        let cloned = Abstraction(name: name, id: id, body: body.clone(newParent: nil))
        cloned.parent = newParent
        return cloned
    }
}

class Application: Term {
    var function: any Term
    var argument: any Term
    weak var parent: (any Term)?
    
    init(function: any Term, argument: any Term) {
        self.function = function
        self.argument = argument
        self.function.parent = self
        self.argument.parent = self
    }
    
    func accept<V: TermVisitor>(visitor: V) -> V.T {
        return visitor.visitApplication(self)
    }
    
    func rename(newName: String, newId: Int, rootId: Int) {
        function.rename(newName: newName, newId: newId, rootId: rootId)
        argument.rename(newName: newName, newId: newId, rootId: rootId)
    }
    
    func getAllBoundVarNames() -> Set<String> {
        return function.getAllBoundVarNames().union(argument.getAllBoundVarNames())
    }
    
    func getAllBoundVars() -> [Variable] {
        return function.getAllBoundVars() + argument.getAllBoundVars()
    }
    
    func clone(newParent: (any Term)?) -> any Term {
        let cloned = Application(
            function: function.clone(newParent: nil),
            argument: argument.clone(newParent: nil)
        )
        cloned.parent = newParent
        return cloned
    }
}

class Variable: Term {
    private var _name: String
    private(set) var id: Int
    weak var parent: (any Term)?
    private var freeRenamed: Bool = false
    
    var name: String {
        get { _name }
    }
    
    init(name: String, id: Int) {
        self._name = name
        self.id = id
    }
    
    func accept<V: TermVisitor>(visitor: V) -> V.T {
        return visitor.visitVariable(self)
    }
    
    func clone(newParent: (any Term)?) -> any Term {
        let cloned = Variable(name: name, id: id)
        cloned.parent = newParent
        cloned.freeRenamed = self.freeRenamed
        return cloned
    }
    
    func isFreeVar() -> Bool {
        return id == 0
    }
    
    func wasFreeRenamed() -> Bool {
        return freeRenamed
    }
    
    func getParentAbstraction() -> Abstraction? {
        var current = parent
        while let curr = current {
            if let abs = curr as? Abstraction, id == abs.id {
                return abs
            }
            current = curr.parent
        }
        return nil
    }
    
    func renameFree(_ newName: String) {
        self.freeRenamed = true
        self._name = newName
    }
    
    func rename(newName: String, newId: Int, rootId: Int) {
        if id == rootId {
            self._name = newName
            self.id = newId
        }
    }
    
    func getAllBoundVarNames() -> Set<String> {
        return isFreeVar() ? [] : [name]
    }
    
    func getAllBoundVars() -> [Variable] {
        return isFreeVar() ? [] : [self]
    }
}

extension Abstraction: Hashable {
    static func == (lhs: Abstraction, rhs: Abstraction) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}

extension Variable: Hashable {
    static func == (lhs: Variable, rhs: Variable) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(_name)
        hasher.combine(id)
        hasher.combine(freeRenamed)
    }
}

extension Application: Hashable {
    static func == (lhs: Application, rhs: Application) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(function))
        hasher.combine(ObjectIdentifier(argument))
    }
}
