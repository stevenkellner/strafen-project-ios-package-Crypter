//
//  Extensions.swift
//  Extensions
//
//  Created by Steven on 05.11.21.
//

import Foundation

extension FixedWidthInteger {
    
    /// Bytes array of the integer
    internal var bytes: [UInt8] {
        let totalBytesCount = MemoryLayout<Self>.size
        var number = self
        var bytesArray = [UInt8](repeating: .zero, count: totalBytesCount)
        for index in 0..<totalBytesCount {
            let byte = number & 0xff
            number = (number - byte) / 256
            bytesArray[totalBytesCount - index - 1] = UInt8(byte)
        }
        return bytesArray
    }
}

extension UInt8 {
    
    /// Bits array of the byte
    internal var bits: [Bit] {
        let totalBitsCount = MemoryLayout<UInt8>.size * 8
        var byte = self
        var bitsArray = [Bit](repeating: .zero, count: totalBitsCount)
        for index in 0..<totalBitsCount {
            let bit = byte & 0x01;
            byte = (byte - bit) / 2;
            bitsArray[totalBitsCount - index - 1] = Bit(bit)
        }
        return bitsArray
    }
}

extension Character {
    
    /// Unicode scalar code point of the character
    internal var unicodeScalarCodePoint: UInt32 {
        let scalars = self.unicodeScalars
        return scalars[scalars.startIndex].value
    }
}

extension Collection {
    
    /// Reduces the collection into an initial result.
    /// - Parameters:
    ///    - initialResult: Initial result of reduction
    ///    - updateAccumulatingResult: Closure to update result with next element and index
    /// - Returns: Result of reduction
    internal func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element, Index) throws -> ()) rethrows -> Result {
        var result = initialResult
        for index in self.indices {
            try updateAccumulatingResult(&result, self[index], index)
        }
        return result
    }
    
    /// Reduces the collection with an initial result
    /// - Parameters:
    ///    - initialResult: Initial result of reduction
    ///    - nextPartialResult: Closure to get next partial result with next element and index
    /// - Returns: Result of reduction
    internal func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element, Index) throws -> Result) rethrows -> Result {
        return try self.reduce(into: initialResult) { $0 = try nextPartialResult($0, $1, $2) }
    }
}

extension Sequence {
    
    /// Mappes the sequence to a new array by appending contents of element transforming
    /// result to last partial result.
    /// - Parameter transform: Closure to transform an element to a new array.
    /// - Returns: New mapped array
    internal func mapFlat<T>(_ transform: (Element) throws -> [T]) rethrows -> [T] {
        try self.reduce(into: [T]()) { $0.append(contentsOf: try transform($1)) }
    }
}
