import Foundation
import OSLog

public class VOResourceTable {
    public let id: String?
    public let name: String?
    public let ucd: String?
    public let utype: String?
    public let reference: String?
    public let nrows: Int?

    public var description: String?
    public var fields: [VOField]?
    public var parameters: [VOParameter]?
    public var groups: [VOGroup]?
    public var links: [VOLink]?
    // TODO: Add Data
    public var infos: [VOInfo]?

    public init(
        id: String? = nil,
        name: String? = nil,
        ucd: String? = nil,
        utype: String? = nil,
        reference: String? = nil,
        nrows: Int? = nil,
        description: String? = nil,
        fields: [VOField]? = nil,
        parameters: [VOParameter]? = nil,
        groups: [VOGroup]? = nil,
        links: [VOLink]? = nil,
        infos: [VOInfo]? = nil
    ) {
        self.id = id
        self.name = name
        self.ucd = ucd
        self.utype = utype
        self.reference = reference
        self.nrows = nrows
        self.description = description
        self.fields = fields
        self.parameters = parameters
        self.groups = groups
        self.links = links
        self.infos = infos
    }
}
