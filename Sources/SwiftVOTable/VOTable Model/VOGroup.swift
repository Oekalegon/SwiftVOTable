import Foundation
import OSLog

/// A `VOGroup` is used to group together a set of `VOField`s, and
/// `VOParameter`s that are related to each other.
///
/// You can, for example, create a group that combines a value with
/// its error, or the coordinates (longitude and latitude) of an object.
public class VOGroup: CustomStringConvertible {
    /// The identifier of the group.
    public let id: String?

    /// The name of the group.
    public let name: String?

    /// The UCD of the group.
    ///
    /// The UCD is a standard classification of the physical quantity.
    public let ucd: String?

    /// The usage specfic type of the group.
    ///
    /// The utype is meant to express the role of the column in the context of an external data model
    public let utype: String?

    /// The reference of the group.
    ///
    /// The reference property is used to quote another element of the document in the definition of a FIELD or PARAM.
    /// For instance, the reference may be the ID of a COOSYS or TIMESYS element.
    public let reference: String?

    /// The fields that are part of the group.
    ///
    /// The fields are referenced by their `id`.
    public var fieldReferences: [String]?

    /// The parameters that are part of the group and
    /// are only defined for this group.
    public var parameters: [VOParameter]?

    /// The parameters that are part of the group and
    /// are referenced from other parts of the VOTABLE.
    ///
    /// The parameters are referenced by their `id`.
    public var parameterReferences: [String]?

    /// The sub-groups of the resource.
    public internal(set) var groups: [VOGroup]?

    /// The description of the resource.
    public var description: String {
        _description ?? "No description for this group"
    }

    private var _description: String?

    /// Sets the description of the group.
    /// - Parameter description: The description of the group.
    func setDescription(_ description: String) {
        self._description = description
    }

    /// Creates a new `VOGroup`.
    /// - Parameters:
    ///   - id: The identifier of the group.
    ///   - name: The name of the group.
    ///   - ucd: The UCD of the group.
    ///   - utype: The usage specfic type of the group.
    ///   - reference: The reference of the group.
    ///   - fieldReferences: The fields that are part of the group.
    ///   - parameters: The parameters that are part of the group and
    ///     are only defined for this group.
    ///   - parameterReferences: The parameters that are part of the group and
    ///     are referenced from other parts of the VOTABLE.
    ///   - groups: The sub-groups of the resource.
    ///   - description: The description of the group.
    public init(
        id: String? = nil,
        name: String? = nil,
        ucd: String? = nil,
        utype: String? = nil,
        reference: String? = nil,
        fieldReferences: [String]? = nil,
        parameters: [VOParameter]? = nil,
        parameterReferences: [String]? = nil,
        groups: [VOGroup]? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.ucd = ucd
        self.utype = utype
        self.reference = reference
        self.fieldReferences = fieldReferences
        self.parameters = parameters
        self.parameterReferences = parameterReferences
        self.groups = groups
        self._description = description
    }
}
