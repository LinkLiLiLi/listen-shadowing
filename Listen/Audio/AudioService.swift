import Foundation

protocol AudioService: AnyObject {
    var isRecording: Bool { get }
    var isPlaying: Bool { get }
    func startRecording(to filename: String) throws
    func stopRecording()
    func play(filename: String, loop: Bool) throws
    func playSequence(_ filenames: [String]) throws
    func stop()
}

enum AudioServiceError: Error {
    case recorderUnavailable
    case fileNotFound(String)
}
