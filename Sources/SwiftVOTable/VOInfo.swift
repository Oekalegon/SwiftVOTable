import Foundation
import OSLog

public class VOInfo: CustomStringConvertible {
    /// The identifier of the info element.
    public let id: String?

    /// The name of the info element.
    public let name: String

    /// The value of the info element.
    public internal(set) var value: String

    /// The extended/external datatype of the info element.
    public let xType: String?

    /// The unit of the info element.
    public let unit: String?

    /// The UCD of the info element.
    ///
    /// The UCD is a standard classification of the physical quantity.
    public let ucd: String?

    /// The usage specfic type of the info element.
    ///
    /// The utype is meant to express the role of the column in the context of an external data model
    public let utype: String?

    /// The reference of the info element.
    ///
    /// The reference property is used to quote another element of the document in the definition of a FIELD or PARAM.
    /// For instance, the reference may be the ID of a COOSYS or TIMESYS element.
    public let reference: String?

    public init(
        id: String? = nil,
        name: String,
        value: String,
        xType: String? = nil,
        unit: String? = nil,
        ucd: String? = nil,
        utype: String? = nil,
        reference: String?
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.xType = xType
        self.utype = utype
        self.reference = reference
        self.unit = unit
        self.ucd = ucd
    }

    public var description: String {
        "INFO: \(value)"
    }
}
