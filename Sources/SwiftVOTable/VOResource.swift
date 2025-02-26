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
public class VOResource: CustomStringConvertible {
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

    /// Sets the description of the resource.
    /// - Parameter description: The description of the resource.
    func setDescription(_ description: String) {
        self._description = description
    }

    /// The coordinate systems of the resource.
    public internal(set) var coordinateSystems: [VOCoordinateSystem]?

    /// The time systems of the resource.
    public internal(set) var timeSystems: [VOTimeSystem]?

    /// The (sub-)resources of the resource.
    public internal(set) var resources: [VOResource]?

    /// The info elements of the resource.
    public internal(set) var infos: [VOInfo]?

    /// The groups of the resource.
    public internal(set) var groups: [VOGroup]?

    /// The parameters defined for the resource.
    public var parameters: [VOParameter]?

    public init(
        id: String? = nil,
        name: String? = nil,
        type: String? = nil,
        utype: String? = nil,
        coordinateSystems: [VOCoordinateSystem]? = nil,
        timeSystems: [VOTimeSystem]? = nil,
        resources: [VOResource]? = nil,
        infos: [VOInfo]? = nil,
        groups: [VOGroup]? = nil,
        parameters: [VOParameter]? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.utype = utype
        self.coordinateSystems = coordinateSystems
        self.timeSystems = timeSystems
        self.resources = resources
        self.infos = infos
        self.groups = groups
        self.parameters = parameters
    }
}
