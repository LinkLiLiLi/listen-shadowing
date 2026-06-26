import Foundation

struct RecordingStore {
    let rootDirectory: URL

    func url(for filename: String) -> URL {
        rootDirectory.appendingPathComponent(filename)
    }

    func makeFilename(prefix: String, id: String) -> String {
        "\(prefix)-\(id).m4a"
    }

    func ensureRootExists() throws {
        try FileManager.default.createDirectory(
            at: rootDirectory, withIntermediateDirectories: true)
    }

    func delete(filename: String) throws {
        let target = url(for: filename)
        if FileManager.default.fileExists(atPath: target.path) {
            try FileManager.default.removeItem(at: target)
        }
    }

    static func defaultStore() -> RecordingStore {
        let docs = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask)[0]
        return RecordingStore(
            rootDirectory: docs.appendingPathComponent("recordings",
                                                       isDirectory: true))
    }
}
