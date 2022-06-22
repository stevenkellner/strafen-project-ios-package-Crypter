//
//  RandomBitIterator.swift
//  RandomBitIterator
//
//  Created by Steven on 05.11.21.
//

import Foundation

/// Iterator to generate an endless steam of bits depending on specified seed.
internal struct RandomBitIterator: IteratorProtocol {
    
    /// Pseudo random number generator
    private var pseudoRandom: PseudoRandom
    
    /// Iterator for bytes to bits
    private var bytesToBitsIterator: BytesToBitIterator
    
    /// Initializes RandomBitIterator with a seed
    /// - Parameter seed: Seed of the random bit iterator
    public init(seed: String) {
        self.pseudoRandom = PseudoRandom(seed: seed)
        let bytes = UInt32(self.pseudoRandom.random() * Double(1<<32)).bytes
        self.bytesToBitsIterator = BytesToBitIterator(bytes)
    }
    
    public mutating func next() -> Bit? {
        guard let bit = self.bytesToBitsIterator.next() else {
            let bytes = UInt32(self.pseudoRandom.random() * Double(1<<32)).bytes
            self.bytesToBitsIterator = BytesToBitIterator(bytes)
            return self.next()
        }
        return bit
    }
}
