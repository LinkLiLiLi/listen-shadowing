import Foundation
@testable import Listen

final class FakeAudioService: AudioService {
    private(set) var isRecording = false
    private(set) var isPlaying = false
    private(set) var recordedFilenames: [String] = []
    private(set) var playedFilenames: [String] = []
    private(set) var playedSequences: [[String]] = []
    private(set) var lastLoop = false

    func startRecording(to filename: String) throws {
        isRecording = true
        recordedFilenames.append(filename)
    }
    func stopRecording() { isRecording = false }
    func play(filename: String, loop: Bool) throws {
        isPlaying = true
        playedFilenames.append(filename)
        lastLoop = loop
    }
    func playSequence(_ filenames: [String]) throws {
        isPlaying = true
        playedSequences.append(filenames)
    }
    func stop() { isPlaying = false }
}
