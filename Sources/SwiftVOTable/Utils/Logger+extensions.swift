import Foundation
import OSLog

extension Logger {
    /// The logger for the SwiftTAP library.
    static let parser = Logger(subsystem: "com.oekalegon.swift-votable", category: "parser")
    static let votable = Logger(subsystem: "com.oekalegon.swift-votable", category: "votable")
}
