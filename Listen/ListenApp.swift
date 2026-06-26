import SwiftUI
import SwiftData

@main
struct ListenApp: App {
    let container: ModelContainer
    let environment = AppEnvironment()

    init() {
        do {
            container = try ModelContainer(
                for: Clip.self, Attempt.self, PracticeCollection.self)
        } catch {
            fatalError("无法创建 ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ClipLibraryView(environment: environment)
        }
        .modelContainer(container)
    }
}
