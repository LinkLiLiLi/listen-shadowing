import Foundation
import AVFoundation

final class AVAudioService: NSObject, AudioService {
    private let store: RecordingStore
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var sequenceQueue: [String] = []

    init(store: RecordingStore) {
        self.store = store
        super.init()
    }

    var isRecording: Bool { recorder?.isRecording ?? false }
    var isPlaying: Bool { player?.isPlaying ?? false }

    func startRecording(to filename: String) throws {
        try store.ensureRootExists()
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default,
                                options: [.defaultToSpeaker])
        try session.setActive(true)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        let rec = try AVAudioRecorder(url: store.url(for: filename),
                                      settings: settings)
        guard rec.record() else {
            throw AudioServiceError.recorderUnavailable
        }
        recorder = rec
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
    }

    func play(filename: String, loop: Bool) throws {
        try startPlayer(filename: filename, loop: loop)
    }

    func playSequence(_ filenames: [String]) throws {
        sequenceQueue = Array(filenames.dropFirst())
        guard let first = filenames.first else { return }
        try startPlayer(filename: first, loop: false)
    }

    func stop() {
        player?.stop()
        player = nil
        sequenceQueue = []
    }

    private func startPlayer(filename: String, loop: Bool) throws {
        let url = store.url(for: filename)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw AudioServiceError.fileNotFound(filename)
        }
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
        let p = try AVAudioPlayer(contentsOf: url)
        p.delegate = self
        p.numberOfLoops = loop ? -1 : 0
        p.play()
        player = p
    }
}

extension AVAudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                     successfully flag: Bool) {
        guard !sequenceQueue.isEmpty else { return }
        let next = sequenceQueue.removeFirst()
        // TODO: 若序列中某文件缺失，这里会静默中断；后续可上报错误
        try? startPlayer(filename: next, loop: false)
    }
}
