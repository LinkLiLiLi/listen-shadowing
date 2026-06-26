import XCTest
@testable import Listen

final class RecordingStoreTests: XCTestCase {
    private func tempDir() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    func test_makeFilename_isDeterministic() {
        let store = RecordingStore(rootDirectory: tempDir())
        XCTAssertEqual(store.makeFilename(prefix: "orig", id: "ABC"),
                       "orig-ABC.m4a")
    }

    func test_url_joinsRoot() {
        let root = tempDir()
        let store = RecordingStore(rootDirectory: root)
        XCTAssertEqual(store.url(for: "x.m4a"),
                       root.appendingPathComponent("x.m4a"))
    }

    func test_ensureRootExists_createsDirectory() throws {
        let root = tempDir()
        let store = RecordingStore(rootDirectory: root)
        try store.ensureRootExists()
        var isDir: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.path,
                                                     isDirectory: &isDir))
        XCTAssertTrue(isDir.boolValue)
    }

    func test_delete_missingFile_doesNotThrow() throws {
        let store = RecordingStore(rootDirectory: tempDir())
        XCTAssertNoThrow(try store.delete(filename: "nope.m4a"))
    }
}
