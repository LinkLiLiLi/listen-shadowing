import Foundation
import SwiftData

@Model
final class PracticeCollection {
    var name: String
    @Relationship(deleteRule: .nullify, inverse: \Clip.collection)
    var clips: [Clip] = []

    init(name: String) {
        self.name = name
    }
}
