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
}

/// A `VOLink` object is used to describe a link to a resource.
///
/// See [LINK in the VOTable reference]
/// (https://www.ivoa.net/documents/VOTable/20250116/REC-VOTable-1.5.html#tth_sEc3.7)
/// for more information.
public class VOLink: CustomStringConvertible {
    /// The role of the linked resource.
    public let contentRole: ContentRole

    /// The mime type of the content.
    public let contentType: String?

    /// The url of the resource.
    public let url: URL

    /// Creates a new `VOLink` object.
    /// - Parameters:
    ///   - url: The url of the resource.
    ///   - contentType: The mime type of the content.
    ///   - contentRole: The role of the linked resource.
    public init(url: URL, contentType: String? = nil, contentRole: ContentRole = .document) {
        self.url = url
        self.contentRole = contentRole
        self.contentType = contentType
    }

    /// A description of the `VOLink` object.
    public var description: String {
        "VOLink url: \(url), contentType: \(contentType ?? "nil"), contentRole: \(contentRole)"
    }
}
