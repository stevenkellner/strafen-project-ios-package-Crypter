//
//  PseudoRandom.swift
//  PseudoRandom
//
//  Created by Steven on 05.11.21.
//

import Foundation

/// Generates random numbers in [0.0, 1.0) depending on a specified seed.
internal struct PseudoRandom {
    
    /// Initial mash
    private let INITIAL_MASH_N = 0xefc8249d
    
    /// States of the generator
    private struct State {
        
        /// State 0
        var state0: Double
        
        /// State 1
        var state1: Double
        
        /// State 2
        var state2: Double
        
        /// Constant state
        var constant: Double
    }
    
    /// State of the generator
    private var state: State
    
    /// Initializes PseudoRandom with a seed
    /// - Parameter seed: Seed of the pseudo random number generator
    public init(seed: String) {
        var n = Double(self.INITIAL_MASH_N)
        n = PseudoRandom.mash(n, data: " ")
        var state0 = PseudoRandom.mashResult(n)
        n = PseudoRandom.mash(n, data: " ")
        var state1 = PseudoRandom.mashResult(n)
        n = PseudoRandom.mash(n, data: " ")
        var state2 = PseudoRandom.mashResult(n)
        n = PseudoRandom.mash(n, data: seed)
        state0 -= PseudoRandom.mashResult(n)
        if (state0 < 0) { state0 += 1 }
        n = PseudoRandom.mash(n, data: seed)
        state1 -= PseudoRandom.mashResult(n)
        if (state1 < 0) { state1 += 1 }
        n = PseudoRandom.mash(n, data: seed)
        state2 -= PseudoRandom.mashResult(n)
        if (state2 < 0) { state2 += 1 }
        self.state = State(state0: state0, state1: state1, state2: state2, constant: 1)
    }
    
    /// Mashes number `m` and data to a number
    /// - Parameters:
    ///   - m: Number `m`
    ///   - data: Data to mash
    /// - Returns: Mashed number
    private static func mash(_ m: Double, data: String) -> Double {
        var n = m
        for unicodeScalarCodePoint in data.unicodeScalars {
            n += Double(unicodeScalarCodePoint.value)
            var h = 0.02519603282416938 * n
            n = h.rounded(.towardZero)
            h -= n
            h *= n
            n = h.rounded(.towardZero)
            h -= n
            n += h * 0x100000000
        }
        return n
    }
    
    /// Mashes number `n`
    /// - Parameter n: Number `n`
    /// - Returns: Mashed number
    private static func mashResult(_ n: Double) -> Double {
        return n.rounded(.towardZero) * 2.3283064365386963e-10
    }
    
    /// Generates next pseudo random number between [0.0, 1.0).
    /// - Returns: Random number between [0.0, 1.0)
    private mutating func random() -> Double {
        let t = 2091639 * self.state.state0 + self.state.constant * 2.3283064365386963e-10
        self.state.state0 = self.state.state1
        self.state.state1 = self.state.state2
        self.state.constant = t.rounded(.towardZero)
        self.state.state2 = t - self.state.constant
        return self.state.state2
    }
    
    /// Generates next pseudo random number between 0 and 255.
    /// - Returns: Random number between 0 and 255.
    public mutating func randomByte() -> UInt8 {
        return UInt8(self.random() * 256)
    }
}
