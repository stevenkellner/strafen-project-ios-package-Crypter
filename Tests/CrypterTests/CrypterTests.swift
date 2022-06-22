import XCTest
@testable import Crypter


fileprivate struct CrypterTestData: Decodable {
    let aesOriginal: Data
    let vernamOriginal: Data
    let aesVernamOriginal: Data
    let expectedAesEncryted: Data
}

fileprivate let crypterTestDataUrl = URL(fileURLWithPath: Bundle.module.path(forResource: "crypterTestData", ofType: "json")!)
fileprivate let crypterTestDataJson = try! Data(contentsOf: crypterTestDataUrl)
fileprivate let decoder = JSONDecoder()
fileprivate let crypterTestData = try! decoder.decode(CrypterTestData.self, from: crypterTestDataJson)

fileprivate let cryptionKeys = Crypter.Keys(encryptionKey: try! UTF8<Length32>("GWf]2K;*R{AL8Puc~:X@SM-Nt.?TBv,a"),
                                            initialisationVector: try! UTF8<Length16>("hwG5zFWc`6Rd)/&8"),
                                            vernamKey: try! UTF8<Length32>("q'9~jp8*v]4u-2f#s\"VdKy;HQmD$+nxL"))
fileprivate let crypter = Crypter(keys: cryptionKeys)

final class CrypterTests: XCTestCase {
     func testAes() throws {
        let aesEncrytedBytes = try crypter.encryptAes(crypterTestData.aesOriginal.bytes)
        XCTAssertEqual(crypterTestData.expectedAesEncryted.bytes, aesEncrytedBytes)
        let aesDecryptedBytes = try crypter.decryptAes(aesEncrytedBytes)
        XCTAssertEqual(crypterTestData.aesOriginal.bytes, aesDecryptedBytes)
    }
    
    func testVernam() throws {
        let vernamEncrytedBytes = crypter.encryptVernamCipher(crypterTestData.vernamOriginal.bytes)
        let vernamDecrytedBytes = crypter.decryptVernamCipher(vernamEncrytedBytes)
        XCTAssertEqual(crypterTestData.vernamOriginal.bytes, vernamDecrytedBytes)
    }
    
    func testVernamAndAes() throws {
        let aesVernamEncrytedBytes = try crypter.encryptVernamAndAes(crypterTestData.aesVernamOriginal.bytes)
        let aesVernamDecrytedBytes = try crypter.decryptAesAndVernam(aesVernamEncrytedBytes)
        XCTAssertEqual(crypterTestData.aesVernamOriginal.bytes, aesVernamDecrytedBytes)
    }
}
