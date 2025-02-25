import Foundation
import Testing

@testable import SwiftVOTable

@Suite("VOTable Parser Tests")
struct VOTableParserTests {
    private static let testFiles = [
        "M13-IDs-votable.xml",
        "example-votable.xml",
    ]

    @Test("Parse VOTable file")
    func testParseVOTable() throws {
        for file in VOTableParserTests.testFiles {
            let url = URL(fileURLWithPath: "Tests/SwiftVOTableTests/Resources/\(file)")
            let data = try Data(contentsOf: url)
            let voDataFrame = try VODataFrame(data: data)
            // assert(voDataFrame.isEmpty == false)
            // Add expectations here using #expect
        }
    }

    @Test("Path matching")
    func testPathMatching() throws {
        let parser = VOTableParser()
        let path = ["a", "b", "c", "d", "e"]

        // Test exact matches
        #expect(parser.pathMatches("a/b/c/d/e", path))
        #expect(!parser.pathMatches("a/b/c/d/f", path))

        // Test wildcards at start
        #expect(parser.pathMatches("*/d/e", path))
        #expect(parser.pathMatches("*/b/*/e", path))
        #expect(!parser.pathMatches("*/b/a/*", path))

        // Test wildcards at end
        #expect(parser.pathMatches("a/b/*", path))
        #expect(parser.pathMatches("a/b/c/*", path))
        #expect(!parser.pathMatches("a/f/*", path))

        // Test multiple wildcards
        #expect(parser.pathMatches("*/b/*/d/*", path))
        #expect(!parser.pathMatches("*/f/*/d/*", path))

        // Test pattern length
        #expect(!parser.pathMatches("a/b/c/d/e/f", path))
        #expect(parser.pathMatches("a/b", ["a", "b"]))
    }
}
