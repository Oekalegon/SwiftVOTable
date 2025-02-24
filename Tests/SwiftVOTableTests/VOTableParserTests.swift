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
}
