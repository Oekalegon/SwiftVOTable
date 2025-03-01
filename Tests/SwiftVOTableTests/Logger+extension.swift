import Foundation
import OSLog

extension Logger {
    /// The logger for the SwiftTAP library.
    static let test = Logger(subsystem: "com.oekalegon.swift-votable-tests", category: "test")
}
