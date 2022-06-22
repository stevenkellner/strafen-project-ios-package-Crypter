//
//  Crypter.swift
//  Crypter
//
//  Created by Steven on 05.11.21.
//

import Foundation
import CryptoSwift

/// Used to en- and decrypt vernam and aes.
public struct Crypter {
    
    /// Keys used for en- and decrytion.
    public struct Keys {
        
        /// Encryption key for aes
        public let encryptionKey: UTF8<Length32>
        
        /// Initialisation vector for aes
        public let initialisationVector: UTF8<Length16>
        
        /// Key for vernam
        public let vernamKey: UTF8<Length32>
    }
    
    /// Errors thrown in en- and decrytion
    public enum CrytptionError: Error {
        
        /// Error thrown in encyption of aes
        case encryptAesError
        
        /// Error thrown in decyption of aes
        case decryptAesError
    }
        
    /// Keys used for en- and decrytion.
    private let cryptionKeys: Keys
    
    /// Initializes Crypter with cryption keys.
    /// - Parameter cryptionKeys: Keys used for en- and decrytion.
    public init(keys cryptionKeys: Keys) {
        self.cryptionKeys = cryptionKeys
    }
    
    /// Encrypts bytes with aes.
    /// - Parameter bytes: Bytes to encrypt
    /// - Returns: Encrypted bytes
    public func encryptAes(_ bytes: [UInt8]) throws -> [UInt8] {
        do {
            let aes = try AES(key: self.cryptionKeys.encryptionKey.rawString, iv: self.cryptionKeys.initialisationVector.rawString)
            return try aes.encrypt(bytes)
        } catch {
            throw CrytptionError.encryptAesError
        }
    }
    
    /// Decrypts bytes with aes.
    /// - Parameter bytes: Bytes to decrypt
    /// - Returns: Decrypted bytes
    public func decryptAes(_ bytes: [UInt8]) throws -> [UInt8] {
        do {
            let aes = try AES(key: self.cryptionKeys.encryptionKey.rawString, iv: self.cryptionKeys.initialisationVector.rawString)
            return try aes.decrypt(bytes)
        } catch {
            throw CrytptionError.decryptAesError
        }
    }
    
    /// Generates an utf-8 key with specified length
    /// - Parameter length: Length of key to generate
    /// - Returns: Generated key
    private func randomKey(length: UInt) -> String {
        (0..<length).reduce(into: "") { result, _ in
            result.append(String(data: Data([UInt8.random(in: 33...126)]), encoding: .utf8)!)
        }
    }
    
    /// Converts an iterator of bits to an array of bytes.
    /// If itterator has number of bit not dividable to 8, the last bits are droped.
    /// - Returns: Array of bytes.
    private func bitIteratorToBytes<T>(_ iterator: T) -> [UInt8] where T: IteratorProtocol, T.Element == Bit {
        var bytes = [UInt8]()
        var iterator = iterator
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
    
    /// Converts specified utf8 string to bytes.
    /// - Parameter string: Utf8 string to convert to bytes.
    /// - Returns: Bytes of specifed utf8 string.
    private func utf8ToBytes(_ string: String) -> [UInt8] {
        string.reduce(into: [UInt8]()) { list, char in
            list.append(String(char).data(using: .utf8)!.last!)
        }
    }
    
    /// Converts specified bytes to utf8 string.
    /// - Parameter bytes: Bytes to convert to utf8 string.
    /// - Returns: Utf8 string of specified bytes.
    private func bytesToUtf8(_ bytes: [UInt8]) -> String {
        String(data: Data(bytes), encoding: .utf8)!
    }
    
    /// Encrypts bytes with vernam.
    /// - Parameter bytes: Bytes to encrypt
    /// - Returns: Encrypted bytes and key for vernam
    public func encryptVernamCipher(_ bytes: [UInt8]) -> [UInt8] {
        let key = self.randomKey(length: 32)
        let randomBitIterator = RandomBitIterator(seed: key + self.cryptionKeys.vernamKey.rawString)
        let bytesToBitsIterator = BytesToBitIterator(bytes)
        let combineIterator = CombineIterator(iterator1: randomBitIterator, iterator2: bytesToBitsIterator) { Bit.xor(lhs: $0, rhs: $1) }
        return self.utf8ToBytes(key) + self.bitIteratorToBytes(combineIterator)
    }
    
    /// Decryptes bytes with vernam
    /// - Parameter bytes:  First 32 bytes is key for vernam, other bytes is text to decrypt
    /// - Returns: Decrypted bytes
    public func decryptVernamCipher(_ bytes: [UInt8]) -> [UInt8] {
        let randomBitIterator = RandomBitIterator(seed: self.bytesToUtf8([UInt8](bytes.prefix(32))) + self.cryptionKeys.vernamKey.rawString)
        let stringToBitIterator = BytesToBitIterator([UInt8](bytes.dropFirst(32)))
        let combineIterator = CombineIterator(iterator1: randomBitIterator, iterator2: stringToBitIterator) { Bit.xor(lhs: $0, rhs: $1) }
        return self.bitIteratorToBytes(combineIterator)
    }
    
    /// Encrypts bytes with vernam and then with aes.
    /// - Parameter bytes: Bytes to encrypt
    /// - Returns: Encrypted bytes
    public func encryptVernamAndAes(_ bytes: [UInt8]) throws -> [UInt8] {
        let vernamEncryptedBytes = self.encryptVernamCipher(bytes)
        return try self.encryptAes(vernamEncryptedBytes)
    }
    
    /// Decrypts bytes with aes and then with vernam.
    /// - Parameter encrypted: Bytes to decrypt
    /// - Returns: Decrypted bytes
    public func decryptAesAndVernam(_ encrypted: [UInt8]) throws -> [UInt8] {
        let aesDecryptedBytes = try self.decryptAes(encrypted)
        return self.decryptVernamCipher(aesDecryptedBytes);
    }
    
    /// Converts string to array of bytes. One char converts to 4 bytes.
    /// - Parameter string: String to convert to bytes
    /// - Returns: String as array of bytes
    public static func stringToBytes(_ string: String) -> [UInt8] {
        string.mapFlat { $0.unicodeScalarCodePoint.bytes }
    }
    
    /// Converts array of bytes to string. 4 bytes converts to one char.
    /// - Parameter bytes: Bytes to convert to string
    /// - Returns: Array of bytes as string
    public static func bytesToString(_ bytes: [UInt8]) -> String {
        var currentInt: UInt32 = 0
        return bytes.reduce(into: "") {
            currentInt += UInt32($1) << (8 * (3 - $2 % 4))
            if $2 % 4 == 3 {
                $0.append(Character(UnicodeScalar(currentInt) ?? UnicodeScalar(0)))
                currentInt = 0
            }
        }
    }
}
