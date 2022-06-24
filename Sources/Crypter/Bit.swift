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
    public init(_ number: some FixedWidthInteger) {
        self.init(number != 0)
    }
    
    /// Initializes with an bool. `zero` if bool is false, `one` otherwise.
    /// - Parameter bool: Bool for bit initialization
    public init(_ bool: Bool) {
        self = bool ? .one : .zero
    }
    
    /// Value of the bit. 0 if bit is`zero`, 1 if it's `one`.
    public var value: Int {
        switch self {
        case .zero: return 0
        case .one: return 1
        }
    }
}

extension Bit {
    
    /// Not operation a bit:
    ///
    /// - not 1 = 0
    /// - not 0 = 1
    /// - Parameter rhs: Rhs of not operation
    /// - Returns: Result of not operation
    public static func not(rhs: Bit) -> Bit {
        switch rhs {
        case .zero: return .one
        case .one: return .zero
        }
    }
    
    /// Not operation a bit:
    ///
    /// - not 1 = 0
    /// - not 0 = 1
    /// - Parameter rhs: Rhs of not operation
    /// - Returns: Result of not operation
    public static prefix func ~(rhs: Bit) -> Bit {
        return Bit.not(rhs: rhs)
    }
    
    /// AND operation of two bits:
    ///
    /// - 0 and 0 = 0 and 1 = 1 and 0  = 0
    /// - 1 and 1 = 1
    /// - Parameters:
    ///   - lhs: Lhs of and operation
    ///   - rhs: Rhs of and operation
    /// - Returns: Result of and operation
    public static func and(lhs: Bit, rhs: Bit) -> Bit {
        switch (lhs, rhs) {
        case (.zero, .zero), (.zero, .one), (.one, .zero): return .zero
        case (.one, .one): return .one
        }
    }
    
    /// AND operation of two bits:
    ///
    /// - 0 and 0 = 0 and 1 = 1 and 0  = 0
    /// - 1 and 1 = 1
    /// - Parameters:
    ///   - lhs: Lhs of and operation
    ///   - rhs: Rhs of and operation
    /// - Returns: Result of and operation
    public static func &(lhs: Bit, rhs: Bit) -> Bit {
        return Bit.and(lhs: lhs, rhs: rhs)
    }
    
    /// OR operation of two bits:
    ///
    /// - 0 or 0  = 0
    /// - 1 or 1 = 1 or 0 = 0 or 1 = 1
    /// - Parameters:
    ///   - lhs: Lhs of or operation
    ///   - rhs: Rhs of or operation
    /// - Returns: Result of or operation
    public static func or(lhs: Bit, rhs: Bit) -> Bit {
        switch (lhs, rhs) {
        case (.zero, .zero): return .zero
        case (.zero, .one), (.one, .zero), (.one, .one): return .one
        }
    }
    
    /// OR operation of two bits:
    ///
    /// - 0 or 0  = 0
    /// - 1 or 1 = 1 or 0 = 0 or 1 = 1
    /// - Parameters:
    ///   - lhs: Lhs of or operation
    ///   - rhs: Rhs of or operation
    /// - Returns: Result of or operation
    public static func |(lhs: Bit, rhs: Bit) -> Bit {
        return Bit.or(lhs: lhs, rhs: rhs)
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
    
    /// XOR operation of two bits:
    ///
    /// - 0 xor 0 = 1 xor 1 = 0
    /// - 1 xor 0 = 0 xor 1 = 1
    /// - Parameters:
    ///   - lhs: Lhs of xor operation
    ///   - rhs: Rhs of xor operation
    /// - Returns: Result of xor operation
    public static func ^(lhs: Bit, rhs: Bit) -> Bit {
        return Bit.xor(lhs: lhs, rhs: rhs)
    }
}

extension Bit: Equatable {
    public static func ==(lhs: Bit, rhs: Bit) -> Bool {
        switch (lhs, rhs) {
        case (.zero, .zero), (.one, .one): return true
        case (.zero, .one), (.one, .zero): return false
        }
    }
}

extension Bit: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .zero: hasher.combine(0)
        case .one: hasher.combine(1)
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
