//
//  Bit.swift
//  Bit
//
//  Created by Steven on 05.11.21.
//

import Foundation

/// Represents a bit, either `zero` or `one`.
internal enum Bit {
    
    /// Represents bit `zero`
    case zero
    
    /// Represents bit `one`
    case one
    
    /// Initializes with an integer. `zero` if number is 0, `one` otherwise.
    /// - Parameter number: Integer for bit initialization
    public init<T>(_ number: T) where T: FixedWidthInteger {
        self = number == 0 ? .zero : .one
    }
    
    /// Initializes with an bool. `zero` if bool is false, `one` otherwise.
    /// - Parameter bool: Bool for bit initialization
    public init(_ bool: Bool) {
        self = bool ? .one : .zero
    }
    
    /// XOR operation of two bits:
    ///
    /// - 0 xor 0 = 1 xor 1 = 0
    /// - 1 xor 0 = 0 xor 1 = 1
    /// - Parameters:
    ///   - lhs: Lhs of xor operation
    ///   - rhs: Rhs of xor operation
    /// - Returns: Result of xor operation
    public static func xor(lhs: Bit, rhs: Bit) -> Bit {
        switch (lhs, rhs) {
        case (.zero, .zero), (.one, .one): return .zero
        case (.zero, .one), (.one, .zero): return .one
        }
    }
    
    /// Value of the bit. 0 if bit is`zero`, 1 if it's `one`.
    public var value: Int {
        switch self {
        case .zero: return 0
        case .one: return 1
        }
    }
}

extension Bit: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .zero: return "0"
        case .one: return "1"
        }
    }
    
    public var debugDescription: String {
        self.description
    }
}
