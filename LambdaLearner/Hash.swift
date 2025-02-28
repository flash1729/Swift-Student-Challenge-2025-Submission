// Hash.swift

import Foundation

// MARK: - String Hashing Extension
extension String {
    func hash32() -> Int {
        var hash = 0
        for char in self.unicodeScalars {
            hash = ((hash &<< 5) &- hash) &+ Int(char.value)
            hash = hash & hash // Convert to 32-bit integer
        }
        return hash
    }
}

// MARK: - Random Number Generation
private class RNG {
    private var state: UInt64
    
    init(seed: String) {
        self.state = UInt64(seed.hash32())
    }
    
    func next() -> Double {
        state = state &* 2862933555777941757 &+ 3037000493
        return Double(UInt32(state >> 32)) / Double(UInt32.max)
    }
}

// MARK: - Term Hashing
func hash(_ term: any Term) -> Int {
    let rand = RNG(seed: "c4lcvlv5")
    return transformTerm(term, funcs: TermTransformFuncs<Int>(
        absf: { abs, body in
            let randInt = Int(rand.next() * 10000) // Smaller range
            let nameHash = abs.name.hash32()
            return (randInt ^ 
                    7919) &+ // Use smaller prime numbers
            ((17 &* nameHash) &+ 
             body)
        },
        appf: { _, funcVal, argVal in
            let randInt = Int(rand.next() * 10000) // Smaller range
            return (randInt ^ 
                    7907) &+
            ((13 &* funcVal) &+
             (19 &* argVal))
        },
        vf: { v in
            let randInt = Int(rand.next() * 10000) // Smaller range
            let nameHash = v.name.hash32()
            return (randInt ^ 
                    7901) &+
            (23 &* nameHash)
        }
    )) ?? 0
}

// MARK: - Structural Hashing
func structureHash(_ term: any Term) -> Int {
    let rand = RNG(seed: "l4mbda")
    var ids: [String: Int] = [:]
    
//    print("Starting structure hash for term: \(stringify(term))")
    
    func idFor(_ name: String) -> Int {
        if let existingId = ids[name] {
//            print("Using existing id for \(name): \(existingId)")
            return existingId
        }
        let newId = Int(rand.next() * 10000) // Smaller range
//        print("Generated new id for \(name): \(newId)")
        ids[name] = newId
        return newId
    }
    
    let result = transformTerm(term, funcs: TermTransformFuncs<Int>(
        absf: { abs, body in
//            print("Processing abstraction: \(abs.name)")
            let randInt = Int(rand.next() * 10000)
            let nameId = idFor(abs.name)
            return (randInt ^ 
                    7877) &+
            ((29 &* nameId) &+
             body)
        },
        appf: { _, funcVal, argVal in
//            print("Processing application")
            let randInt = Int(rand.next() * 10000)
            return (randInt ^ 
                    7867) &+
            ((31 &* funcVal) &+
             (37 &* argVal))
        },
        vf: { v in
//            print("Processing variable: \(v.name)")
            let randInt = Int(rand.next() * 10000)
            let nameId = idFor(v.name)
            return (randInt ^ 
                    7853) &+
            (41 &* nameId)
        }
    )) ?? 0
    
//    print("Completed structure hash with result: \(result)")
    return result
}
