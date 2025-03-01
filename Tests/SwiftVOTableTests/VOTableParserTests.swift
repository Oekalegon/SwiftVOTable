import Foundation
import OSLog
import Testing

@testable import SwiftVOTable

@Suite("VOTable Parser Tests")
struct VOTableParserTests {
    private static let testFiles = [
        "M13-IDs-votable.xml",
        "example-votable.xml",
        "example-with-time-votable.xml",
    ]

    @Test("Parse VOTable file")
    func testParseVOTable() throws {
        for file in VOTableParserTests.testFiles {
            Logger.test.info("Testing file: \(file)")
            let url = URL(fileURLWithPath: "Tests/SwiftVOTableTests/Resources/\(file)")
            let data = try Data(contentsOf: url)
            let voDataFrame = try VODataFrame(data: data)
            // assert(voDataFrame.isEmpty == false)
            // Add expectations here using #expect
        }
    }

    @Test("Parse VOTable file with time system")
    func testParseVOTableWithTimeSystem() throws {
        let url = URL(fileURLWithPath: "Tests/SwiftVOTableTests/Resources/example-with-time-votable.xml")
        let data = try Data(contentsOf: url)
        let voDataFrame = try VODataFrame(data: data)

        // assert(voDataFrame.isEmpty == false)
    }
}
