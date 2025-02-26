import Foundation
import OSLog

public struct VOResource: CustomStringConvertible {
    private var _description: String?

    public var description: String {
        _description ?? "No description for this resource"
    }

    public internal(set) var coordinateSystem: VOCoordinateSystem?

    public internal(set) var timeSystem: VOTimeSystem?

    public internal(set) var resources: [VOResource]?

    public mutating func setDescription(_ description: String) {
        self._description = description
    }
}
