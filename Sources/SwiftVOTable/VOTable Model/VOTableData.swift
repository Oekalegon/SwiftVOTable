import Foundation
import OSLog

class VOTableData {
    var trs: [VOTR]?

    public init(trs: [VOTR]? = nil) {
        self.trs = trs
    }
}

class VOTR {
    let id: String?
    var tds: [VOTD]?

    init(id: String? = nil, tds: [VOTD]? = nil) {
        self.id = id
        self.tds = tds
    }
}

class VOTD {
    let encoding: String?
    var value: String?

    init(encoding: String? = nil, value: String? = nil) {
        self.encoding = encoding
        self.value = value
    }
}
