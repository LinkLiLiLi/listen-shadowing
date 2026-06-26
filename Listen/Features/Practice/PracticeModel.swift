import Foundation
import SwiftData

@MainActor
final class PracticeModel: ObservableObject {
    @Published var isRecording = false

    let clip: Clip
    private let audio: AudioService
    private let store: RecordingStore
    private let context: ModelContext
    private let container: ModelContainer  // retains container so context stays valid (iOS 26)
    private let idProvider: () -> String
    private let now: () -> Date
    private var pendingFilename: String?

    init(clip: Clip,
         audio: AudioService,
         store: RecordingStore,
         context: ModelContext,
         idProvider: @escaping () -> String = { UUID().uuidString },
         now: @escaping () -> Date = Date.init) {
        self.clip = clip
        self.audio = audio
        self.store = store
        self.context = context
        self.container = context.container
        self.idProvider = idProvider
        self.now = now
    }

    var attemptsNewestFirst: [Attempt] {
        clip.attempts.sorted { $0.createdAt > $1.createdAt }
    }

    func playOriginal(loop: Bool) throws {
        try audio.play(filename: clip.originalAudioFilename, loop: loop)
    }

    func startAttempt() throws {
        let filename = store.makeFilename(prefix: "mine", id: idProvider())
        try audio.startRecording(to: filename)
        pendingFilename = filename
        isRecording = true
    }

    func stopAttempt() throws {
        audio.stopRecording()
        isRecording = false
        guard let filename = pendingFilename else { return }
        let attempt = Attempt(audioFilename: filename, createdAt: now())
        clip.attempts.append(attempt)
        clip.lastPracticedAt = now()
        try context.save()
        pendingFilename = nil
    }

    func playAttempt(_ attempt: Attempt, loop: Bool) throws {
        try audio.play(filename: attempt.audioFilename, loop: loop)
    }

    func playComparison(_ attempt: Attempt) throws {
        try audio.playSequence([clip.originalAudioFilename,
                                attempt.audioFilename])
    }

    func deleteAttempt(_ attempt: Attempt) throws {
        try? store.delete(filename: attempt.audioFilename)
        context.delete(attempt)
        try context.save()
    }
}
