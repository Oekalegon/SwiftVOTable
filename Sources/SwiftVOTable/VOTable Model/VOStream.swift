import Foundation
import OSLog

class VOStream {
    let type: String?
    let href: URL?
    let actuate: String?
    let encoding: String?
    let expires: Date?
    let rights: String?

    init(
        type: String? = nil,
        href: URL? = nil,
        actuate: String? = nil,
        encoding: String? = nil,
        expires: Date? = nil,
        rights: String? = nil
    ) {
        self.type = type
        self.href = href
        self.actuate = actuate
        self.encoding = encoding
        self.expires = expires
        self.rights = rights
    }
}
