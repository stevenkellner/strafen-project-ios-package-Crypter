//
//  CombineIterator.swift
//  CombineIterator
//
//  Created by Steven on 05.11.21.
//

import Foundation

/// Combines to iterators with an closure to combine both elements. If an iterator
/// has more elements than the other, these elements are droped.
internal struct CombineIterator<I1, I2, R>: IteratorProtocol where I1: IteratorProtocol, I2: IteratorProtocol {
    
    /// First iterator
    private var iterator1: I1
    
    /// Second iterator
    private var iterator2: I2
    
    /// Closure to combine elements of the iterators
    private let combineElement: (I1.Element, I2.Element) -> R
    
    /// Initializes with two iterators and transformation closure
    /// - Parameters:
    ///   - iterator1: First iterator
    ///   - iterator2: Second iterator
    ///   - combineElement: Closure to combine elements of the iterators
    public init(iterator1: I1, iterator2: I2, combineElement: @escaping (I1.Element, I2.Element) -> R) {
        self.iterator1 = iterator1
        self.iterator2 = iterator2
        self.combineElement = combineElement
    }
    
    mutating public func next() -> R? {
        guard let element1 = self.iterator1.next(),
              let element2 = self.iterator2.next() else { return nil }
        return self.combineElement(element1, element2)
    }
}
