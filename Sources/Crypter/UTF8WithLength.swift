//
//  UTF8WithLength.swift
//  UTF8WithLength
//
//  Created by Steven on 05.11.21.
//

import Foundation

/// Protocol with a static length property for generic types
public protocol Length {
    
    /// Static length for generic types
    static var length: UInt { get }
}

/// For generic types with length 16
public struct Length16: Length {
    public static let length: UInt = 16
}

/// For generic types with length 32
public struct Length32: Length {
    public static let length: UInt = 32
}

/// For generic types with length 64
public struct Length64: Length {
    public static let length: UInt = 64
}

/// Represents an utf-8 string with length specified in generic type `L`.
public struct UTF8<L> where L: Length {
    
    /// Errors thrown in initialization of UTF8
    public enum UTF8Error: Error {

        /// Error thrown if raw string can not be utf-8 encoded.
        case notUtf8
        
        /// Error thrown if raw string hasn't expected length specified in generic type `L`.
        case notExpectedLength
    }
    
    /// String that is uft-8 encoded and has length specified in generic type `L`.
    internal let rawString: String
    
    /// Initializes UTF8 with a string and checks if that string is uft-8 encoded and
    /// has length specified in generic type `L`.
    /// - Parameter rawString: String to check if is uft-8 encoded and
    /// has length specified in generic type `L`.
    public init(_ rawString: String) throws {
        guard rawString.data(using: .utf8) != nil else { throw UTF8Error.notUtf8 }
        guard rawString.count == L.length else { throw UTF8Error.notExpectedLength }
        self.rawString = rawString
    }
}
