import Foundation
import OSLog

/// The role of a linked resource.
public enum ContentRole {
    /// The linked resource is a document.
    case document

    /// The linked resource describes the type of the containing resource.
    case type

    /// Other type of linked resource.
    ///
    /// Can be used for uses outside of the VOTable specification.
    /// - Parameter description: The description of the linked resource.
    case other(String)

    /// Creates a new `ContentRole` from a string.
    /// - Parameter role: The role as a string.
    public init(role: String?) {
        switch role {
        case nil:
            self = .document
        case "document":
            self = .document
        case "type":
            self = .type
        default:
            self = .other(role!)
        }
    }

    /// The string representation of the role as used in the VOTable format.
    public var roleString: String {
        switch self {
        case .document:
            "document"
        case .type:
            "type"
        case let .other(role):
            role
        }
    }
}

/// A `VOLink` object is used to describe a link to a resource.
///
/// See [LINK in the VOTable reference]
/// (https://www.ivoa.net/documents/VOTable/20250116/REC-VOTable-1.5.html#tth_sEc3.7)
/// for more information.
public class VOLink: CustomStringConvertible {
    /// The identifier of the link.
    public let id: String?

    /// The title of the link.
    public let title: String?

    /// The value of the link.
    public let value: String?

    /// The action associated with the link.
    public let action: String?

    /// The role of the linked resource.
    public let contentRole: ContentRole

    /// The mime type of the content.
    public let contentType: String?

    /// The url of the resource.
    public let url: URL?

    /// Creates a new `VOLink` object.
    /// - Parameters:
    ///   - id: The identifier of the link.
    ///   - title: The title of the link.
    ///   - value: The value of the link.
    ///   - action: The action associated with the link.
    ///   - url: The url of the resource.
    ///   - contentType: The mime type of the content.
    ///   - contentRole: The role of the linked resource.
    public init(
        id: String? = nil,
        title: String? = nil,
        value: String? = nil,
        action: String? = nil,
        url: URL? = nil,
        contentType: String? = nil,
        contentRole: ContentRole = .document
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.action = action
        self.url = url
        self.contentRole = contentRole
        self.contentType = contentType
    }

    /// A description of the `VOLink` object.
    public var description: String {
        "VOLink url: \(url.debugDescription), contentType: \(contentType ?? "nil"), contentRole: \(contentRole)"
    }
}
