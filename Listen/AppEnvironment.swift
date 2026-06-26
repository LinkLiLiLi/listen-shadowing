import Foundation

@MainActor
final class AppEnvironment {
    let store: RecordingStore
    let audio: AudioService

    init() {
        let store = RecordingStore.defaultStore()
        self.store = store
        self.audio = AVAudioService(store: store)
    }
}
