import Foundation
import SwiftData

@Model
final class Attempt {
    var audioFilename: String
    var createdAt: Date
    var clip: Clip?

    init(audioFilename: String, createdAt: Date) {
        self.audioFilename = audioFilename
        self.createdAt = createdAt
    }
}
