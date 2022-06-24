import XCTest
@testable import Crypter

final class CrypterTestSuite: XCTestSuite {
    final class BitTests: XCTestCase {
        func testFromBool() {
            XCTAssertEqual(Bit(false), .zero)
            XCTAssertEqual(Bit(true), .one)
        }
        
        func testFromInt() {
            XCTAssertEqual(Bit(0), .zero)
            XCTAssertEqual(Bit(1), .one)
            XCTAssertEqual(Bit(-1), .one)
        }
        
        func testNot() {
            XCTAssertEqual(~Bit.zero, .one)
            XCTAssertEqual(~Bit.one, .zero)
        }
        
        func testAnd() {
            XCTAssertEqual(Bit.zero & Bit.zero, .zero)
            XCTAssertEqual(Bit.one & Bit.zero, .zero)
            XCTAssertEqual(Bit.zero & Bit.one, .zero)
            XCTAssertEqual(Bit.one & Bit.one, .one)
        }
        
        func testOr() {
            XCTAssertEqual(Bit.zero | Bit.zero, .zero)
            XCTAssertEqual(Bit.one | Bit.zero, .one)
            XCTAssertEqual(Bit.zero | Bit.one, .one)
            XCTAssertEqual(Bit.one | Bit.one, .one)
        }
        
        func testXor() {
            XCTAssertEqual(Bit.zero ^ Bit.zero, .zero)
            XCTAssertEqual(Bit.one ^ Bit.zero, .one)
            XCTAssertEqual(Bit.zero ^ Bit.one, .one)
            XCTAssertEqual(Bit.one ^ Bit.one, .zero)
        }
    }
    
    final class PseudoRandomTests: XCTestCase {
        func testRandomByte() {
            var pseudoRandom = PseudoRandom(seed: "ouiz7uio")
            let expectedBytes: [UInt8] = [132, 150, 115, 245, 137, 154, 232, 252, 253, 0, 236, 255, 34, 253, 223, 162, 62, 26, 224, 212, 37, 138, 180, 152, 98, 195, 155, 239, 170, 150, 28, 81]
            for expectedByte in expectedBytes {
                XCTAssertEqual(pseudoRandom.randomByte(), expectedByte)
            }
        }
    }
    
    final class BytesToBitIteratorTests: XCTestCase {
        func testBytesToBits1() {
            let bytes: [UInt8] = []
            var bytesToBitIterator = BytesToBitIterator(bytes)
            let expectedBits: [Bit] = []
            var index = 0
            while let bit = bytesToBitIterator.next() {
                XCTAssertEqual(bit, expectedBits[index])
                index += 1
            }
        }
        
        func testBytesToBits2() {
            let bytes: [UInt8] = [0x23]
            var bytesToBitIterator = BytesToBitIterator(bytes)
            let expectedBits: [Bit] = [.zero, .zero, .one, .zero, .zero, .zero, .one, .one]
            var index = 0
            while let bit = bytesToBitIterator.next() {
                XCTAssertEqual(bit, expectedBits[index])
                index += 1
            }
        }
        
        func testBytesToBits3() {
            let bytes: [UInt8] = [0x23, 0x45, 0x67, 0xaf]
            var bytesToBitIterator = BytesToBitIterator(bytes)
            let expectedBits: [Bit] = [
                .zero, .zero, .one, .zero, .zero, .zero, .one, .one,
                .zero, .one, .zero, .zero, .zero, .one, .zero, .one,
                .zero, .one, .one, .zero, .zero, .one, .one, .one,
                .one, .zero, .one, .zero, .one, .one, .one, .one,
            ]
            var index = 0
            while let bit = bytesToBitIterator.next() {
                XCTAssertEqual(bit, expectedBits[index])
                index += 1
            }
        }
    }
    
    final class RandomBitIteratorTests: XCTestCase {
        func testRandomBits() {
            var randomBitIterator = RandomBitIterator(seed: "9087zhk32k4leq")
            let expectedBits: [Bit] = [
                .one, .one, .one, .one, .one, .one, .zero, .zero, .one, .one, .one, .zero, .one, .zero, .one, .zero, .one, .zero, .zero, .one, .zero, .zero, .zero, .zero, .one, .zero, .one, .zero, .one, .one, .zero, .one, .one,
                .one, .zero, .zero, .one, .zero, .one, .one, .one, .zero, .one, .one, .zero, .zero, .zero, .zero, .one, .zero, .zero, .zero, .zero, .one, .one, .zero, .zero, .one, .zero, .one, .one, .zero, .one, .zero, .zero, .zero,
                .one, .zero, .one, .one, .zero, .zero, .one, .zero, .zero, .one, .zero, .one, .one, .zero, .zero, .one, .one, .zero, .zero, .one, .one, .one, .zero, .one, .zero, .one, .zero, .one, .one, .zero, .one, .zero, .one,
            ];
            for expectedBit in expectedBits {
                XCTAssertEqual(randomBitIterator.next(), expectedBit)
            }
        }
    }
    
    final class CombineIteratorTests: XCTestCase {
        func testCombine1() {
            let iterator1 = [1, 2, 3].makeIterator()
            let iterator2 = [4, 5, 6].makeIterator()
            var combineIterator = CombineIterator(iterator1: iterator1, iterator2: iterator2) { [$0, $1] }
            let expectedData = [[1, 4], [2, 5], [3, 6]]
            for expected in expectedData {
                XCTAssertEqual(combineIterator.next(), expected)
            }
        }
        
        func testCombine2() {
            let iterator1 = [1, 2].makeIterator()
            let iterator2 = [4, 5, 6].makeIterator()
            var combineIterator = CombineIterator(iterator1: iterator1, iterator2: iterator2) { [$0, $1] }
            let expectedData = [[1, 4], [2, 5]]
            for expected in expectedData {
                XCTAssertEqual(combineIterator.next(), expected)
            }
        }
        
        func testCombine3() {
            let iterator1 = [1, 2, 3].makeIterator()
            let iterator2 = [4, 5].makeIterator()
            var combineIterator = CombineIterator(iterator1: iterator1, iterator2: iterator2) { [$0, $1] }
            let expectedData = [[1, 4], [2, 5]]
            for expected in expectedData {
                XCTAssertEqual(combineIterator.next(), expected)
            }
        }
    }
    
    final class ExtentionsTests: XCTestCase {
        func testByteToBits() {
            let dataset: [(UInt8, [Bit])] = [
                (0x00, [.zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero]),
                (0x01, [.zero, .zero, .zero, .zero, .zero, .zero, .zero, .one]),
                (0x4e, [.zero, .one, .zero, .zero, .one, .one, .one, .zero]),
                (0xff, [.one, .one, .one, .one, .one, .one, .one, .one]),
            ]
            for data in dataset {
                XCTAssertEqual(data.0.bits, data.1)
            }
        }
        
        func testUIntToBytes() {
            XCTAssertEqual(UInt8(0x93).bytes, [0x93])
            XCTAssertEqual(UInt16(0x93a9).bytes, [0x93, 0xa9])
            XCTAssertEqual(UInt32(0x93fe0187).bytes, [0x93, 0xfe, 0x01, 0x87])
            XCTAssertEqual(UInt64(0x930c6538abc5170a).bytes, [0x93, 0x0c, 0x65, 0x38, 0xab, 0xc5, 0x17, 0x0a])
        }
        
        func testBitIteratorToBytes1() {
            let bitIterator: some IteratorProtocol<Bit> = [].makeIterator()
            let expectedBytes: [UInt8] = []
            XCTAssertEqual(bitIterator.bytes, expectedBytes)
        }
        
        func testBitIteratorToBytes2() {
            let bitIterator: some IteratorProtocol<Bit> = [.zero, .zero, .one, .zero, .zero, .zero, .one, .one].makeIterator()
            let expectedBytes: [UInt8] = [0x23]
            XCTAssertEqual(bitIterator.bytes, expectedBytes)
        }
        
        func testBitIteratorToBytes3() {
            let bitIterator: some IteratorProtocol<Bit> = [
                .zero, .zero, .one, .zero, .zero, .zero, .one, .one,
                .zero, .one, .zero, .zero, .zero, .one, .zero, .one,
                .zero, .one, .one, .zero, .zero, .one, .one, .one,
                .one, .zero, .one, .zero, .one, .one, .one, .one,
            ].makeIterator()
            let expectedBytes: [UInt8] = [0x23, 0x45, 0x67, 0xaf]
            XCTAssertEqual(bitIterator.bytes, expectedBytes)
        }
    }
    
    final class CrypterTests: XCTestCase {
        struct CrypterTestData: Codable {
            let aesOriginal: Data
            let vernamOriginal: Data
            let aesVernamOriginal: Data
            let aesEncrypted: Data
            let vernamEncrypted: Data
            let aesVernamEncrypted: Data
        }
        
        let crypterTestData: CrypterTestData = {
            let crypterTestDataUrl = URL(fileURLWithPath: Bundle.module.path(forResource: "crypterTestData", ofType: "json")!)
            let crypterTestDataJson = try! Data(contentsOf: crypterTestDataUrl)
            let decoder = JSONDecoder()
            return try! decoder.decode(CrypterTestData.self, from: crypterTestDataJson)
        }()
        
        let crypter: Crypter = {
            let cryptionKeys = Crypter.Keys(encryptionKey: try! UTF8<Length32>("GWf]2K;*R{AL8Puc~:X@SM-Nt.?TBv,a"),
                                            initialisationVector: try! UTF8<Length16>("hwG5zFWc`6Rd)/&8"),
                                            vernamKey: try! UTF8<Length32>("q'9~jp8*v]4u-2f#s\"VdKy;HQmD$+nxL"))
            return Crypter(keys: cryptionKeys)
        }()
        
        func testAes1() throws {
            let aesEncryptedBytes = try crypter.encryptAes(crypterTestData.aesOriginal.bytes)
            let aesDecryptedBytes = try crypter.decryptAes(aesEncryptedBytes)
            XCTAssertEqual(crypterTestData.aesOriginal.bytes, aesDecryptedBytes)
        }
        
        func testAes2() throws {
            let aesDecryptedBytes = try crypter.decryptAes(crypterTestData.aesEncrypted.bytes)
            XCTAssertEqual(crypterTestData.aesOriginal.bytes, aesDecryptedBytes)
        }
        
        func testVernam1() throws {
            let vernamEncryptedBytes = crypter.encryptVernamCipher(crypterTestData.vernamOriginal.bytes)
            let vernamDecryptedBytes = crypter.decryptVernamCipher(vernamEncryptedBytes)
            XCTAssertEqual(crypterTestData.vernamOriginal.bytes, vernamDecryptedBytes)
        }
        
        func testVernam2() throws {
            let vernamDecryptedBytes = crypter.decryptVernamCipher(crypterTestData.vernamEncrypted.bytes)
            XCTAssertEqual(crypterTestData.vernamOriginal.bytes, vernamDecryptedBytes)
        }
        
        func testVernamAndAes1() throws {
            let aesVernamEncryptedBytes = try crypter.encryptVernamAndAes(crypterTestData.aesVernamOriginal.bytes)
            let aesVernamDecryptedBytes = try crypter.decryptAesAndVernam(aesVernamEncryptedBytes)
            XCTAssertEqual(crypterTestData.aesVernamOriginal.bytes, aesVernamDecryptedBytes)
        }
        
        func testVernamAndAes2() throws {
            let aesVernamDecryptedBytes = try crypter.decryptAesAndVernam(crypterTestData.aesVernamEncrypted.bytes)
            XCTAssertEqual(crypterTestData.aesVernamOriginal.bytes, aesVernamDecryptedBytes)
        }
    }
}
