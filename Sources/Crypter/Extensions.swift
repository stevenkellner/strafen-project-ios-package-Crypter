//
//  Extensions.swift
//  Extensions
//
//  Created by Steven on 05.11.21.
//

import Foundation

extension FixedWidthInteger where Self: UnsignedInteger {
    
    /// Bytes array of the integer
    internal var bytes: [UInt8] {
        let totalBytesCount = MemoryLayout<Self>.size
        var number = self
        var bytesArray = [UInt8](repeating: .zero, count: totalBytesCount)
        for index in 0..<totalBytesCount {
            bytesArray[totalBytesCount - index - 1] = UInt8(number & 0xff)
            number >>= 8
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
            bitsArray[totalBitsCount - index - 1] = Bit(byte & 0x01)
            byte >>= 1
        }
        return bitsArray
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

extension IteratorProtocol<Bit> {
    
    /// Converts an iterator of bits to an array of bytes.
    /// If itterator has number of bit not dividable to 8, the last bits are droped.
    /// - Returns: Array of bytes.
    internal var bytes: [UInt8] {
        var bytes = [UInt8]()
        var iterator = self
        var currentByte: UInt8 = 0
        var index = 0
        while let bit = iterator.next() {
            currentByte += UInt8(bit.value * (1 << (7 - index)))
            index += 1
            if index == 8 {
                bytes.append(currentByte)
                currentByte = 0
                index = 0
            }
        }
        return bytes
    }
}

extension UnicodeScalar {
    
    /// Genarates a random unicode scalar with code point between `0...0xD7FF` or `0xE000...0x10FFFF`.
    /// - Returns: Random unicode scalar
    internal static func random() -> UnicodeScalar {
        let totalPossibleChars: UInt32 = 0xD7FF + 0x10FFFF - 0xE000 + 2
        let v = UInt32.random(in: 0..<totalPossibleChars)
        return UnicodeScalar(v <= 0xD7FF ? v : v + 0xE000 - 0xD7FF - 1)!
    }
}

extension String {
        
    /// Errors that can occurs while encoding unishort string.
    internal enum UnishortEncodingError: Error {
        
        /// Data is invalid to encode to unishort string.
        case invalidUnicodeScalarData
    }
    
    /// Initializes string by encoding specified unishort data.
    /// - Parameter unishortData: Unishort data to encode.
    public init(unishortData: Data) {
        self.init()
        for byte in unishortData {
            self.append(Character(UnicodeScalar(byte)))
        }
    }
    
    /// Unishort data of this string.
    public var unishortData: Data {
        get throws {
            var data = Data()
            for char in self {
                guard let value = char.unicodeScalars.first?.value, value <= UInt8.max else {
                    throw UnishortEncodingError.invalidUnicodeScalarData
                }
                data.append(UInt8(value))
            }
            return data
        }
    }
    
    /// Generates an utf8 key with specified length
    /// - Parameter length: Length of key to generate
    /// - Returns: Generated key
    internal static func randomKey(length: UInt) -> String {
        return (0..<length).reduce(into: "") { result, _ in
            result.append(String(data: Data([UInt8.random(in: 33...126)]), encoding: .utf8)!)
        }
    }
    
    /// Genrates a random string with unicode scalar code points between `0...0xD7FF` or `0xE000...0x10FFFF`.
    /// - Parameter length: Length of the string to generate.
    /// - Returns: Random string
    internal static func random(length: UInt) -> String {
        return (0..<length).reduce(into: "") { result, _ in
            let currentLength = result.count
            while result.count != currentLength + 1 {
                result.append(Character(UnicodeScalar.random()))
            }
        }
    }
    
    /// Converts this utf8 string to bytes.
    /// - Returns: Bytes of this utf8 string..
    internal var utf8Bytes: [UInt8] {
        return self.reduce(into: [UInt8]()) { list, char in
            list.append(String(char).data(using: .utf8)!.last!)
        }
    }
}

extension Data {
    
    /// Initializes data by encoding specified unishort string.
    /// - Parameter unishortString: Unishort string to encode.
    @inlinable public init(unishortString: String) throws {
        self = try unishortString.unishortData
    }
    
    /// Unishort string of this data.
    @inlinable public var unishortString: String {
        return String(unishortData: self)
    }
}

extension Array where Element == UInt8 {
    
    /// Initializes bytes by encoding specified unishort string.
    /// - Parameter unishortString: Unishort string to encode.
    @inlinable public init(unishortString: String) throws {
        self = Array(try unishortString.unishortData)
    }
    
    /// Unishort string of this bytes.
    @inlinable public var unishortString: String {
        return String(unishortData: Data(self))
    }
    
    /// Converts sequence of bytes to utf8 string.
    /// - Returns: Utf8 string of bytes.
    internal var utf8String: String {
        return String(data: Data(self), encoding: .utf8)!
    }
}

extension DateFormatter {

    /// Date formatter for iso8601 format with milliseconds
    public static var iso8601WithMilliseconds: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }
}
