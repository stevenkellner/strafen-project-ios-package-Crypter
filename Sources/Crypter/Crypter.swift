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
        public let encryptionKey: UTF8<Length32>?
        
        /// Initialisation vector for aes
        public let initialisationVector: UTF8<Length16>?
        
        /// Key for vernam
        public let vernamKey: UTF8<Length32>?
        
        /// Initializes keys.
        /// - Parameters:
        ///   - encryptionKey: Encryption key for aes
        ///   - initialisationVector: Initialisation vector for aes
        ///   - vernamKey: Key for vernam
        public init(encryptionKey: UTF8<Length32>, initialisationVector: UTF8<Length16>, vernamKey: UTF8<Length32>) {
            self.encryptionKey = encryptionKey
            self.initialisationVector = initialisationVector
            self.vernamKey = vernamKey
        }
        
        /// Initializes keys.
        /// - Parameters:
        ///   - encryptionKey: Encryption key for aes
        ///   - initialisationVector: Initialisation vector for aes
        public init(encryptionKey: UTF8<Length32>, initialisationVector: UTF8<Length16>) {
            self.encryptionKey = encryptionKey
            self.initialisationVector = initialisationVector
            self.vernamKey = nil
        }
        
        /// Initializes keys.
        /// - Parameters:
        ///   - vernamKey: Key for vernam
        public init(vernamKey: UTF8<Length32>) {
            self.encryptionKey = nil
            self.initialisationVector = nil
            self.vernamKey = vernamKey
        }
    }
    
    /// Type of a cryption key
    public enum CryptionKeyType {
        
        /// Encryption key for aes
        case encryptionKey
        
        /// Initialisation vector for aes
        case initialisationVector
        
        /// Key for vernam
        case vernamKey
    }
    
    /// Errors thrown in en- and decrytion
    public enum CryptionError: Error {
        
        /// A necessary key for cryption is not set
        case cryptionKeyNotSet(key: CryptionKeyType)
        
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
    
    /// Get the key string of specified key type.
    /// - Parameter keyType: Type of the key
    /// - Returns: String key
    private func key(_ keyType: CryptionKeyType) throws -> String {
        let rawKey: String?
        switch keyType {
        case .encryptionKey:
            rawKey = self.cryptionKeys.encryptionKey?.rawString
        case .initialisationVector:
            rawKey = self.cryptionKeys.initialisationVector?.rawString
        case .vernamKey:
            rawKey = self.cryptionKeys.vernamKey?.rawString
        }
        guard let rawKey else {
            throw CryptionError.cryptionKeyNotSet(key: keyType)
        }
        return rawKey
    }
    
    /// Encrypts bytes with aes.
    /// - Parameter bytes: Bytes to encrypt
    /// - Returns: Encrypted bytes
    public func encryptAes(_ bytes: [UInt8]) throws -> [UInt8] {
        do {
            let aes = try AES(key: self.key(.encryptionKey), iv: self.key(.initialisationVector))
            return try aes.encrypt(bytes)
        } catch {
            throw CryptionError.encryptAesError
        }
    }
    
    /// Encrypts data with aes.
    /// - Parameter data: Data to encrypt
    /// - Returns: Encrypted data
    @inlinable public func encryptAes(_ data: Data) throws -> Data {
        return Data(try self.encryptAes(Array(data)))
    }
    
    /// Decrypts bytes with aes.
    /// - Parameter bytes: Bytes to decrypt
    /// - Returns: Decrypted bytes
    public func decryptAes(_ bytes: [UInt8]) throws -> [UInt8] {
        do {
            let aes = try AES(key: self.key(.encryptionKey), iv: self.key(.initialisationVector))
            return try aes.decrypt(bytes)
        } catch {
            throw CryptionError.decryptAesError
        }
    }
    
    /// Decrypts data with aes.
    /// - Parameter bytes: Data to decrypt
    /// - Returns: Decrypted data
    @inlinable func decryptAes(_ data: Data) throws -> Data {
        return Data(try self.decryptAes(Array(data)))
    }
    
    /// Encrypts bytes with vernam.
    /// - Parameter bytes: Bytes to encrypt
    /// - Returns: Encrypted bytes and key for vernam
    public func encryptVernamCipher(_ bytes: [UInt8]) throws -> [UInt8] {
        let key = String.randomKey(length: 32)
        let randomBitIterator = try RandomBitIterator(seed: key + self.key(.vernamKey))
        let bytesToBitsIterator = BytesToBitIterator(bytes)
        let combineIterator = CombineIterator(iterator1: randomBitIterator, iterator2: bytesToBitsIterator, combineElement: ^)
        return key.utf8Bytes + combineIterator.bytes
    }
    
    /// Encrypts data with vernam.
    /// - Parameter bytes: Data to encrypt
    /// - Returns: Encrypted data and key for vernam
    @inlinable func encryptVernamCipher(_ data: Data) throws -> Data {
        return Data(try self.encryptVernamCipher(Array(data)))
    }
    
    /// Decryptes bytes with vernam
    /// - Parameter bytes:  First 32 bytes is key for vernam, other bytes is text to decrypt
    /// - Returns: Decrypted bytes
    public func decryptVernamCipher(_ bytes: [UInt8]) throws -> [UInt8] {
        let randomBitIterator = try RandomBitIterator(seed: [UInt8](bytes.prefix(32)).utf8String + self.key(.vernamKey))
        let stringToBitIterator = BytesToBitIterator([UInt8](bytes.dropFirst(32)))
        let combineIterator = CombineIterator(iterator1: randomBitIterator, iterator2: stringToBitIterator, combineElement: ^)
        return combineIterator.bytes
    }
    
    /// Decryptes data with vernam
    /// - Parameter bytes:  First 32 bytes is key for vernam, other bytes is text to decrypt
    /// - Returns: Decrypted data
    @inlinable func decryptVernamCipher(_ data: Data) throws -> Data {
        return Data(try self.decryptVernamCipher(Array(data)))
    }
    
    /// Encrypts bytes with vernam and then with aes.
    /// - Parameter bytes: Bytes to encrypt
    /// - Returns: Encrypted bytes
    public func encryptVernamAndAes(_ bytes: [UInt8]) throws -> [UInt8] {
        let vernamEncryptedBytes = try self.encryptVernamCipher(bytes)
        return try self.encryptAes(vernamEncryptedBytes)
    }
    
    /// Encrypts data with vernam and then with aes.
    /// - Parameter bytes: Data to encrypt
    /// - Returns: Encrypted data
    @inlinable func encryptVernamAndAes(_ data: Data) throws -> Data {
        return Data(try self.encryptVernamAndAes(Array(data)))
    }
    
    /// Decrypts bytes with aes and then with vernam.
    /// - Parameter encrypted: Bytes to decrypt
    /// - Returns: Decrypted bytes
    public func decryptAesAndVernam(_ encrypted: [UInt8]) throws -> [UInt8] {
        let aesDecryptedBytes = try self.decryptAes(encrypted)
        return try self.decryptVernamCipher(aesDecryptedBytes);
    }
    
    /// Decrypts data with aes and then with vernam.
    /// - Parameter encrypted: Data to decrypt
    /// - Returns: Decrypted data
    @inlinable func decryptAesAndVernam(_ data: Data) throws -> Data {
        return Data(try self.decryptAesAndVernam(Array(data)))
    }
}
