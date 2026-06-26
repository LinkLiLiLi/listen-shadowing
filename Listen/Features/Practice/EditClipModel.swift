import Foundation
import SwiftData

@MainActor
final class EditClipModel: ObservableObject {
    @Published var title: String
    @Published var scriptText: String
    private let clip: Clip
    private let context: ModelContext
    private let container: ModelContainer // retains container so context stays valid (iOS 26)

    init(clip: Clip, context: ModelContext) {
        self.clip = clip
        self.context = context
        self.container = context.container // retains container so context stays valid (iOS 26)
        self.title = clip.title
        self.scriptText = clip.scriptText
    }

    func save() throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        clip.title = trimmed.isEmpty ? "未命名" : trimmed
        clip.scriptText = scriptText
        try context.save()
    }
}
