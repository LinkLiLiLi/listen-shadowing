import XCTest
import SwiftData
@testable import Listen

final class ModelTests: XCTestCase {
    @MainActor
    func test_insertClip_persistsAndFetches() throws {
        let container = try makeInMemoryContainer()
        let ctx = container.mainContext

        let clip = Clip(title: "How you doin'",
                        scriptText: "How you doin'?",
                        originalAudioFilename: "orig-1.m4a",
                        createdAt: Date(timeIntervalSince1970: 0))
        ctx.insert(clip)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Clip>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "How you doin'")
        XCTAssertTrue(fetched.first?.attempts.isEmpty ?? false)
    }

    @MainActor
    func test_addAttempts_keepsHistory() throws {
        let container = try makeInMemoryContainer()
        let ctx = container.mainContext

        let clip = Clip(title: "t", scriptText: "s",
                        originalAudioFilename: "o.m4a",
                        createdAt: Date(timeIntervalSince1970: 0))
        ctx.insert(clip)
        clip.attempts.append(Attempt(audioFilename: "a1.m4a",
                                     createdAt: Date(timeIntervalSince1970: 1)))
        clip.attempts.append(Attempt(audioFilename: "a2.m4a",
                                     createdAt: Date(timeIntervalSince1970: 2)))
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Clip>()).first
        XCTAssertEqual(fetched?.attempts.count, 2)
    }

    @MainActor
    func test_deleteClip_cascadesAttempts() throws {
        let container = try makeInMemoryContainer()
        let ctx = container.mainContext

        let clip = Clip(title: "t", scriptText: "s",
                        originalAudioFilename: "o.m4a",
                        createdAt: Date(timeIntervalSince1970: 0))
        ctx.insert(clip)
        clip.attempts.append(Attempt(audioFilename: "a1.m4a",
                                     createdAt: Date(timeIntervalSince1970: 1)))
        try ctx.save()

        ctx.delete(clip)
        try ctx.save()

        XCTAssertEqual(try ctx.fetch(FetchDescriptor<Attempt>()).count, 0)
    }
}
