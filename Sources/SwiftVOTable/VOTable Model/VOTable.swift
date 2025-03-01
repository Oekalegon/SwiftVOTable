import Foundation
import OSLog

class VOTable: CustomStringConvertible {
    let id: String?
    let version: String?
    var coordinateSystems: [VOCoordinateSystem]?
    var timeSystems: [VOTimeSystem]?
    var parsedDescription: String?
    var resources: [VOResource]?
    var parameters: [VOParameter]?
    var infos: [VOInfo]?
    var groups: [VOGroup]?

    public init(id: String? = nil, version: String? = nil) {
        self.id = id
        self.version = version
    }

    var description: String {
        """
        ParsingResult:
        - Description: \(parsedDescription ?? "nil")
        - Coordinate Systems: \(coordinateSystems?.description ?? "nil")
        - Time Systems: \(timeSystems?.description ?? "nil")
        - Resources: \(resources?.description ?? "nil")
        """
    }
}
