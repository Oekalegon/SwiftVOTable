import Foundation
import OSLog

/// A resource in a VOTable.
///
/// A resource is a container for data, metadata, and other resources.
/// It is used to group data and metadata that is related to a specific topic.
///
/// Resources can be nested to arbitrary depth.
///
/// See: https://www.ivoa.net/documents/VOTable/20250116/REC-VOTable-1.5.html#tth_sEc3.6
public struct VOResource: CustomStringConvertible {
    /// The identifier of the resource.
    public let id: String?

    /// The name of the resource.
    public let name: String?

    /// The type of the resource.
    public let type: String?

    /// The usage specfic type of the resource.
    public let utype: String?

    /// The description of the resource.
    public var description: String {
        _description ?? "No description for this resource"
    }

    private var _description: String?

    /// The coordinate system of the resource.
    public internal(set) var coordinateSystem: VOCoordinateSystem?

    /// The time system of the resource.
    public internal(set) var timeSystem: VOTimeSystem?

    /// The (sub-)resources of the resource.
    public internal(set) var resources: [VOResource]?

    /// Sets the description of the resource.
    /// - Parameter description: The description of the resource.
    mutating func setDescription(_ description: String) {
        self._description = description
    }

    public init(id: String? = nil, name: String? = nil, type: String? = nil, utype: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.utype = utype
    }
}
