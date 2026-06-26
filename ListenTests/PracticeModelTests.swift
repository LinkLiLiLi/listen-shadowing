import XCTest
import SwiftData
@testable import Listen

@MainActor
final class PracticeModelTests: XCTestCase {
    private func makeModel() throws
        -> (PracticeModel, FakeAudioService, Clip, ModelContext) {
        let container = try makeInMemoryContainer()
        let ctx = container.mainContext
        let clip = Clip(title: "t", scriptText: "s",
                        originalAudioFilename: "orig-1.m4a",
                        createdAt: Date(timeIntervalSince1970: 0))
        ctx.insert(clip)
        try ctx.save()
        let audio = FakeAudioService()
        let store = RecordingStore(
            rootDirectory: FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString))
        var counter = 0
        let model = PracticeModel(
            clip: clip, audio: audio, store: store, context: ctx,
            idProvider: { counter += 1; return "ID\(counter)" },
            now: { Date(timeIntervalSince1970: 50) })
        return (model, audio, clip, ctx)
    }

    func test_playOriginal_loops() throws {
        let (model, audio, _, _) = try makeModel()
        try model.playOriginal(loop: true)
        XCTAssertEqual(audio.playedFilenames, ["orig-1.m4a"])
        XCTAssertTrue(audio.lastLoop)
    }

    func test_recordAttempt_appendsHistory() throws {
        let (model, audio, clip, _) = try makeModel()
        try model.startAttempt()
        XCTAssertTrue(model.isRecording)
        try model.stopAttempt()
        XCTAssertFalse(model.isRecording)
        XCTAssertEqual(clip.attempts.count, 1)
        XCTAssertEqual(clip.attempts.first?.audioFilename, "mine-ID1.m4a")
        XCTAssertEqual(audio.recordedFilenames, ["mine-ID1.m4a"])
        XCTAssertEqual(clip.lastPracticedAt, Date(timeIntervalSince1970: 50))
    }

    func test_playComparison_playsOriginalThenAttempt() throws {
        let (model, audio, _, _) = try makeModel()
        try model.startAttempt()
        try model.stopAttempt()
        let attempt = model.attemptsNewestFirst[0]
        try model.playComparison(attempt)
        XCTAssertEqual(audio.playedSequences,
                       [["orig-1.m4a", "mine-ID1.m4a"]])
    }

    func test_deleteAttempt_removesFromHistory() throws {
        let (model, _, clip, _) = try makeModel()
        try model.startAttempt()
        try model.stopAttempt()
        let attempt = model.attemptsNewestFirst[0]
        try model.deleteAttempt(attempt)
        XCTAssertEqual(clip.attempts.count, 0)
    }

    func test_attemptsNewestFirst_ordering() throws {
        let (model, _, clip, ctx) = try makeModel()
        clip.attempts.append(Attempt(audioFilename: "a.m4a",
                                     createdAt: Date(timeIntervalSince1970: 1)))
        clip.attempts.append(Attempt(audioFilename: "b.m4a",
                                     createdAt: Date(timeIntervalSince1970: 9)))
        try ctx.save()
        XCTAssertEqual(model.attemptsNewestFirst.map(\.audioFilename),
                       ["b.m4a", "a.m4a"])
    }
}
