import Foundation
import TabularData

/// Metadata for a column in a VOTable file.
public class ColumnMetadata {
    /// Name of the column.
    public let name: String

    /// Datatype of the column.
    public let datatype: String

    /// UCD of the column.
    public let ucd: String?

    /// Unit of the column.
    public let unit: String?

    /// Description of the column.
    public var description: String?

    /// Initialize a ColumnMetadata instance.
    ///
    /// - Parameters:
    ///   - name: Name of the column.
    ///   - datatype: Datatype of the column.
    ///   - ucd: UCD of the column.
    ///   - unit: Unit of the column.
    ///   - description: Description of the column.
    public init(name: String, datatype: String, ucd: String?, unit: String?, description: String?) {
        self.name = name
        self.datatype = datatype
        self.ucd = ucd
        self.unit = unit
        self.description = description
    }
}

/// This class represents data in tabular format, specifically in VOTable format.
///
/// It has the same functionality as Apple's `DataFrame` class from the TabularData package,
/// but extends it with all the extra metadata support required for VOTable files.
/// Parsing of VOTable files is available through specific initializers.
public class VODataFrame: CustomStringConvertible {
    // Internal storage
    private var dataFrame: DataFrame
    private var metadataFrame: DataFrame

    private var _description: String?

    /// Description of the VODataFrame
    ///
    /// This property equates to the `DESCRIPTION` element in the VOTable format.
    public var description: String {
        _description ?? ""
    }

    /// Column names in the DataFrame
    public var columns: [String] {
        Array(dataFrame.columns.map(\.name))
    }

    /// Number of rows in the DataFrame
    public var rowCount: Int {
        dataFrame.rows.count
    }

    /// Returns true if the DataFrame has no rows, i.e. if it is empty.
    public var isEmpty: Bool {
        dataFrame.rows.isEmpty
    }

    /// Initialize an empty VODataFrame
    public init() {
        self.dataFrame = DataFrame()
        self.metadataFrame = DataFrame()
        self._description = nil
        self.addMetadataColumns()
    }

    public init(data: Data) throws {
        self.dataFrame = DataFrame()
        self.metadataFrame = DataFrame()
        self._description = nil
        self.addMetadataColumns()

        let parser = VOTableParser()
        let (metadata, data) = try parser.parse(data)
        self.dataFrame = data
        self.metadataFrame = metadata
    }

    private func addMetadataColumns() {
        // Add metadata columns
        metadataFrame.append(column: Column(name: "name", contents: [String]()))
        metadataFrame.append(column: Column(name: "datatype", contents: [String]()))
        metadataFrame.append(column: Column(name: "ucd", contents: [String?]()))
        metadataFrame.append(column: Column(name: "unit", contents: [String?]()))
        metadataFrame.append(column: Column(name: "description", contents: [String?]()))
    }

    /// Add a column to the DataFrame
    public func addColumn(
        _ column: [some Any],
        metadata: ColumnMetadata
    ) {
        // Add data column
        dataFrame.append(column: Column(name: metadata.name, contents: column))

        // Add metadata
        metadataFrame.append(row: [
            "name": metadata.name,
            "datatype": metadata.datatype,
            "ucd": metadata.ucd as Any?,
            "unit": metadata.unit as Any?,
            "description": metadata.description as Any?,
        ])
    }

    /// Get all metadata as a DataFrame
    public var metadata: DataFrame {
        metadataFrame
    }

    /// Get a row at the specified index
    public func row(at index: Int) -> DataFrame.Row {
        dataFrame.rows[index]
    }

    /// Filter rows based on a predicate
    public func filter(_ predicate: @escaping (DataFrame.Row) -> Bool) -> VODataFrame {
        let filtered = VODataFrame()
        filtered.dataFrame = DataFrame(dataFrame.filter(predicate))
        filtered.metadataFrame = metadataFrame
        return filtered
    }

    /// Access to underlying DataFrame
    public var underlying: DataFrame {
        dataFrame
    }
}
