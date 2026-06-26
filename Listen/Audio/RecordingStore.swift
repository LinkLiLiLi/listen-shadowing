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
        do {
            try FileManager.default.removeItem(at: target)
        } catch let error as NSError
            where error.domain == NSCocoaErrorDomain
                && error.code == NSFileNoSuchFileError {
            // 文件不存在视为已删除，不报错
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
