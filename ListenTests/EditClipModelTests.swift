import XCTest
import SwiftData
@testable import Listen

@MainActor
final class EditClipModelTests: XCTestCase {
    func test_save_writesBackTitleAndScript() throws {
        let container = try makeInMemoryContainer()
        let ctx = container.mainContext
        let clip = Clip(title: "old", scriptText: "old script",
                        originalAudioFilename: "o.m4a",
                        createdAt: Date(timeIntervalSince1970: 0))
        ctx.insert(clip)
        try ctx.save()

        let model = EditClipModel(clip: clip, context: ctx)
        model.title = "new"
        model.scriptText = "new script"
        try model.save()

        let fetched = try ctx.fetch(FetchDescriptor<Clip>()).first
        XCTAssertEqual(fetched?.title, "new")
        XCTAssertEqual(fetched?.scriptText, "new script")
    }
}
