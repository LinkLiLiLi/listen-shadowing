import XCTest
import SwiftData
@testable import Listen

@MainActor
final class RecordClipModelTests: XCTestCase {
    private func makeModel() throws
        -> (RecordClipModel, FakeAudioService, ModelContext) {
        let container = try makeInMemoryContainer()
        let audio = FakeAudioService()
        let store = RecordingStore(
            rootDirectory: FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString))
        var counter = 0
        let model = RecordClipModel(
            audio: audio, store: store, context: container.mainContext,
            idProvider: { counter += 1; return "ID\(counter)" },
            now: { Date(timeIntervalSince1970: 100) })
        return (model, audio, container.mainContext)
    }

    func test_save_withoutRecording_throws() throws {
        let (model, _, _) = try makeModel()
        XCTAssertThrowsError(try model.save())
    }

    func test_record_thenSave_createsClipWithFile() throws {
        let (model, audio, ctx) = try makeModel()
        try model.startRecording()
        XCTAssertTrue(model.isRecording)
        model.stopRecording()
        XCTAssertTrue(model.hasRecording)
        XCTAssertEqual(audio.recordedFilenames, ["orig-ID1.m4a"])

        model.title = "How you doin'"
        model.scriptText = "How you doin'?"
        let clip = try model.save()

        XCTAssertEqual(clip.originalAudioFilename, "orig-ID1.m4a")
        XCTAssertEqual(clip.title, "How you doin'")
        XCTAssertEqual(clip.scriptText, "How you doin'?")
        XCTAssertEqual(try ctx.fetch(FetchDescriptor<Clip>()).count, 1)
    }

    func test_save_emptyTitle_usesPlaceholder() throws {
        let (model, _, _) = try makeModel()
        try model.startRecording()
        model.stopRecording()
        let clip = try model.save()
        XCTAssertEqual(clip.title, "未命名")
    }
}
