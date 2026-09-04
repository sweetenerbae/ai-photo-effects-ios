import XCTest
@testable import BroadAppsTestApp

final class EnvironmentTests: XCTestCase {
    func testURLResolverBuildsRelativeAndKeepsAbsoluteURLs() throws {
        let relative = try XCTUnwrap(URLResolver.absolute("/images/avatar.jpg"))
        XCTAssertEqual(relative.scheme, "https")
        XCTAssertEqual(relative.host, "portfolio-demo.invalid")
        XCTAssertEqual(relative.path, "/images/avatar.jpg")

        let absolute = try XCTUnwrap(URLResolver.absolute("https://cdn.example.com/a.jpg"))
        XCTAssertEqual(absolute.absoluteString, "https://cdn.example.com/a.jpg")
    }

    func testURLResolverRejectsEmptyAndUnsupportedURLs() {
        XCTAssertNil(URLResolver.absolute(nil))
        XCTAssertNil(URLResolver.absolute("   "))
        XCTAssertNil(URLResolver.absolute("ftp://example.com/file"))
    }

    func testPortfolioRepositoryReturnsUsableCategories() async throws {
        let categories = try await MockEffectsRepository().fetchCategories(
            lang: "en",
            gender: "f",
            tag: nil,
            showAll: false
        )

        XCTAssertFalse(categories.isEmpty)
        XCTAssertTrue(categories.allSatisfy { !$0.templates.isEmpty })
        XCTAssertTrue(categories.flatMap(\.templates).allSatisfy { $0.isEnabled == true })
    }
}
