import XCTest
@testable import Listen

final class FakeAudioServiceTests: XCTestCase {
    func test_record_thenStop_tracksState() throws {
        let svc = FakeAudioService()
        try svc.startRecording(to: "orig-1.m4a")
        XCTAssertTrue(svc.isRecording)
        XCTAssertEqual(svc.recordedFilenames, ["orig-1.m4a"])
        svc.stopRecording()
        XCTAssertFalse(svc.isRecording)
    }

    func test_play_withLoop_tracksLoopFlag() throws {
        let svc = FakeAudioService()
        try svc.play(filename: "orig-1.m4a", loop: true)
        XCTAssertTrue(svc.isPlaying)
        XCTAssertTrue(svc.lastLoop)
        XCTAssertEqual(svc.playedFilenames, ["orig-1.m4a"])
    }

    func test_playSequence_recordsOrder() throws {
        let svc = FakeAudioService()
        try svc.playSequence(["orig-1.m4a", "a1.m4a"])
        XCTAssertEqual(svc.playedSequences, [["orig-1.m4a", "a1.m4a"]])
    }
}
