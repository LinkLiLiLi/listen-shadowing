import Foundation
import SwiftData

@MainActor
final class RecordClipModel: ObservableObject {
    enum RecordError: Error { case noRecording }

    @Published var title = ""
    @Published var scriptText = ""
    @Published var hasRecording = false
    @Published var isRecording = false

    private let audio: AudioService
    private let store: RecordingStore
    private let context: ModelContext
    private let container: ModelContainer  // retains container so context stays valid
    private let idProvider: () -> String
    private let now: () -> Date
    private var pendingFilename: String?

    init(audio: AudioService,
         store: RecordingStore,
         context: ModelContext,
         idProvider: @escaping () -> String = { UUID().uuidString },
         now: @escaping () -> Date = Date.init) {
        self.audio = audio
        self.store = store
        self.context = context
        self.container = context.container
        self.idProvider = idProvider
        self.now = now
    }

    func startRecording() throws {
        let filename = store.makeFilename(prefix: "orig", id: idProvider())
        try audio.startRecording(to: filename)
        pendingFilename = filename
        isRecording = true
        hasRecording = false
    }

    func stopRecording() {
        audio.stopRecording()
        isRecording = false
        hasRecording = pendingFilename != nil
    }

    func cancel() {
        if isRecording {
            audio.stopRecording()
        }
        if let filename = pendingFilename {
            try? store.delete(filename: filename)
        }
        pendingFilename = nil
        isRecording = false
        hasRecording = false
    }

    func save() throws -> Clip {
        guard let filename = pendingFilename else {
            throw RecordError.noRecording
        }
        let finalTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let clip = Clip(
            title: finalTitle.isEmpty ? "未命名" : finalTitle,
            scriptText: scriptText,
            originalAudioFilename: filename,
            createdAt: now())
        context.insert(clip)
        try context.save()
        pendingFilename = nil
        hasRecording = false
        return clip
    }
}
