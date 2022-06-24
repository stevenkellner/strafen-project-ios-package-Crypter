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
    
    /// Encrypts bytes with vernam.
    /// - Parameter bytes: Bytes to encrypt
    /// - Returns: Encrypted bytes and key for vernam
    public func encryptVernamCipher(_ bytes: [UInt8]) -> [UInt8] {
        let key = String.randomKey(length: 32)
        let randomBitIterator = RandomBitIterator(seed: key + self.cryptionKeys.vernamKey.rawString)
        let bytesToBitsIterator = BytesToBitIterator(bytes)
        let combineIterator = CombineIterator(iterator1: randomBitIterator, iterator2: bytesToBitsIterator, combineElement: ^)
        return key.utf8Bytes + combineIterator.bytes
    }
    
    /// Decryptes bytes with vernam
    /// - Parameter bytes:  First 32 bytes is key for vernam, other bytes is text to decrypt
    /// - Returns: Decrypted bytes
    public func decryptVernamCipher(_ bytes: [UInt8]) -> [UInt8] {
        let randomBitIterator = RandomBitIterator(seed: [UInt8](bytes.prefix(32)).utf8String + self.cryptionKeys.vernamKey.rawString)
        let stringToBitIterator = BytesToBitIterator([UInt8](bytes.dropFirst(32)))
        let combineIterator = CombineIterator(iterator1: randomBitIterator, iterator2: stringToBitIterator, combineElement: ^)
        return combineIterator.bytes
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
}
