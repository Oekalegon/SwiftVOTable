import Foundation
import OSLog

class VOData {
    var tableData: VOTableData?

    var binary: VOBinary?

    var binary2: VOBinary2?

    var fits: VOFits?

    init(tableData: VOTableData? = nil, binary: VOBinary? = nil, binary2: VOBinary2? = nil, fits: VOFits? = nil) {
        self.tableData = tableData
        self.binary = binary
        self.binary2 = binary2
        self.fits = fits
    }
}
