import Foundation
import OSLog
import TabularData

/// Parser for VOTable XML format
class VOTableParser: NSObject, XMLParserDelegate {
    private var currentMetadata: ColumnMetadata?
    private var currentElement: String = ""
    private var currentValue: String = ""

    // Track nested elements
    private var inField = false
    private var inTableData = false
    private var inTR = false
    private var currentRow: [String] = []

    // Store temporary field metadata
    private var fields: [ColumnMetadata] = []

    /// Parse VOTable data and return a VODataFrame
    /// - Parameter data: VOTable XML data
    /// - Returns: Parsed VODataFrame
    /// - Throws: Error if parsing fails
    func parse(_ data: Data) throws -> (metadata: DataFrame, data: DataFrame) {
        let parser = XMLParser(data: data)
        parser.delegate = self

        guard parser.parse() else {
            throw VOTableError.parsingFailed(parser.parserError?.localizedDescription ?? "Unknown error")
        }

        // TODO: Implement the parsing logic here
        return (metadata: DataFrame(), data: DataFrame())
    }

    // MARK: - XMLParserDelegate

    public func parser(
        _: XMLParser,
        didStartElement elementName: String,
        namespaceURI _: String?,
        qualifiedName _: String?,
        attributes attributeDict: [String: String]
    ) {
        currentElement = elementName

        switch elementName {
        case "VOTABLE", "RESOURCE", "TABLE", "DATA", "INFO":
            // Container elements, just track them
            break

        case "BINARY":
            Logger.parser.info("Found BINARY data section")

        case "STREAM":
            if let encoding = attributeDict["encoding"] {
                Logger.parser.info("Found STREAM with encoding: \(encoding, privacy: .public)")
            }

        case "FIELD":
            inField = true
            let name = attributeDict["name"] ?? ""
            let datatype = attributeDict["datatype"] ?? "char"
            let unit = attributeDict["unit"]
            let ucd = attributeDict["ucd"]

            currentMetadata = ColumnMetadata(
                name: name,
                datatype: datatype,
                ucd: ucd,
                unit: unit,
                description: nil
            )

        case "TABLEDATA":
            inTableData = true

        case "TR":
            inTR = true
            currentRow = []

        case "TD":
            currentValue = ""

        default:
            Logger.parser.debug("Unhandled element: \(elementName, privacy: .public)")
        }
    }

    public func parser(
        _: XMLParser,
        didEndElement elementName: String,
        namespaceURI _: String?,
        qualifiedName _: String?
    ) {
        Logger.parser.debug("Did End element: \(elementName, privacy: .public)")
        switch elementName {
        case "VOTABLE", "RESOURCE", "TABLE", "DATA", "BINARY", "STREAM", "INFO":
            // Container elements, nothing to do
            break

        case "FIELD":
            inField = false
            if let metadata = currentMetadata {
                fields.append(metadata)
            }
            currentMetadata = nil

        case "DESCRIPTION":
            if inField {
                currentMetadata?.description = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }

        case "TR":
            inTR = false
            // Process the row data here
            // TODO: Convert strings to appropriate types based on field metadata

        case "TD":
            if inTR {
                currentRow.append(currentValue.trimmingCharacters(in: .whitespacesAndNewlines))
            }

        case "TABLEDATA":
            inTableData = false

        default:
            Logger.parser.debug("Unhandled element: \(elementName, privacy: .public)")
        }
    }

    public func parser(_: XMLParser, foundCharacters string: String) {
        Logger.parser.debug("Found characters: \(string.prefix(20), privacy: .public)...")
        currentValue += string
    }
}
