import Foundation
import SwiftData

@MainActor
func makeInMemoryContainer() throws -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(
        for: Clip.self, Attempt.self, PracticeCollection.self,
        configurations: config
    )
}
