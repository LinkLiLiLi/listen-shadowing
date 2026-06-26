import Foundation
import SwiftData

@Model
final class Clip {
    var title: String
    var scriptText: String
    var originalAudioFilename: String
    var createdAt: Date
    var lastPracticedAt: Date?
    @Relationship(deleteRule: .cascade, inverse: \Attempt.clip)
    var attempts: [Attempt] = []
    var collection: PracticeCollection?

    init(title: String,
         scriptText: String,
         originalAudioFilename: String,
         createdAt: Date) {
        self.title = title
        self.scriptText = scriptText
        self.originalAudioFilename = originalAudioFilename
        self.createdAt = createdAt
    }
}
