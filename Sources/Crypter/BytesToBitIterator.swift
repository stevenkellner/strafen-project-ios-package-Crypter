//
//  BytesToBitIterator.swift
//  BytesToBitIterator
//
//  Created by Steven on 05.11.21.
//

import Foundation

/// Iterator to convert an array of bytes to bits
internal struct BytesToBitIterator: IteratorProtocol {
    
    /// Iterator of array of bytes
    private var bytesIterator: IndexingIterator<[UInt8]>
    
    /// Current iterator of array of bits
    private var currentBitsIterator: IndexingIterator<[Bit]>?
    
    /// Initializes iterator with array of bytes to convert to bits
    /// - Parameter bytes: Bytes to convert to bits
    public init(_ bytes: [UInt8]) {
        self.bytesIterator = bytes.makeIterator()
        self.currentBitsIterator = self.bytesIterator.next()?.bits.makeIterator()
    }
    
    public mutating func next() -> Bit? {
        guard self.currentBitsIterator != nil else { return nil }
        guard let bit = self.currentBitsIterator!.next() else {
            self.currentBitsIterator = self.bytesIterator.next()?.bits.makeIterator()
            return self.next()
        }
        return bit
    }
}
