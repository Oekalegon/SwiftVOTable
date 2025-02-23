import Foundation
import Testing

@testable import SwiftVOTable

@Suite("VOTable Parser Tests")
struct VOTableParserTests {
    @Test("Parse VOTable file")
    func testParseVOTable() throws {
        let url = URL(fileURLWithPath: "Tests/SwiftVOTableTests/Resources/M13-IDs-votable.xml")
        let data = try Data(contentsOf: url)
        let voDataFrame = try VODataFrame(data: data)
        // assert(voDataFrame.isEmpty == false)
        // Add expectations here using #expect
    }
}
