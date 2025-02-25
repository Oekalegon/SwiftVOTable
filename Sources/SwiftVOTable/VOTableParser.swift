import Foundation
import OSLog
import TabularData

struct ParsingResult {
    var columnData: DataFrame?
    var data: DataFrame?
    var coordinateSystem: VOCoordinateSystem?
    var description: String?
}

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

    private var parsingResult = ParsingResult()

    private var currentPath: [String] = []

    // MARK: - Parsing

    /// Parse VOTable data and return a VODataFrame
    /// - Parameter data: VOTable XML data
    /// - Returns: Parsed VODataFrame
    /// - Throws: Error if parsing fails
    func parse(_ data: Data) throws -> (metadata: DataFrame, data: DataFrame) {
        self.currentPath = []
        self.parsingResult = ParsingResult()
        let parser = XMLParser(data: data)
        parser.delegate = self

        guard parser.parse() else {
            throw VOTableError.parsingFailed(parser.parserError?.localizedDescription ?? "Unknown error")
        }

        // TODO: Implement the parsing logic here
        return (metadata: DataFrame(), data: DataFrame())
    }

    private func parseDescription(path: [String], value: String) {
        var parent = [String]()
        parent.append(contentsOf: path)
        parent.removeLast()

        if parent.last == "VOTABLE" {
            Logger.parser.debug("Parsing DESCRIPTION element for VOTABLE")
            parsingResult.description = value.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if inField {
            currentMetadata?.description = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func parseCoordinateSystem(path: [String], attributes: [String: String]) {
        if !self.pathMatches("VOTABLE/COOSYS", path), !self.pathMatches("VOTABLE/DEFINITIONS/COOSYS", path) {
            Logger.parser.warning("Skipping COOSYS element because path does not match: \(path, privacy: .public)")
            return
        }
        let id = attributes["ID"]
        let system = attributes["system"]
        let equinox = attributes["equinox"]
        let epoch = attributes["epoch"]
        let referencePosition = attributes["refposition"]
        Logger.parser.debug("Parsing COOSYS element with attributes: \(attributes, privacy: .public)")
        parsingResult.coordinateSystem = VOCoordinateSystem(
            id: id,
            system: system != nil ? ReferenceFrame(rawValue: system!) : nil,
            equinox: equinox != nil ? try? Date(epoch: equinox!) : nil,
            epoch: epoch != nil ? try? Date(epoch: epoch!) : nil,
            referencePosition: referencePosition != nil ? ReferencePosition(rawValue: referencePosition!) : nil
        )
        Logger.parser.debug(
            "Parsed COOSYS element \("\(self.parsingResult.coordinateSystem?.description ?? "nil")", privacy: .public)"
        )
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

        currentPath.append(elementName)

        switch elementName {
        case "VOTABLE", "RESOURCE", "TABLE", "DATA", "INFO":
            // Container elements, just track them
            break

        case "BINARY":
            Logger.parser.debug("Found BINARY data section")

        case "COOSYS":
            self.parseCoordinateSystem(path: currentPath, attributes: attributeDict)

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
        Logger.parser.debug("Did End element: \(self.currentPath.joined(separator: "/"), privacy: .public)")

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
            self.parseDescription(path: currentPath, value: currentValue)

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

        currentPath.removeLast()
    }

    public func parser(_: XMLParser, foundCharacters string: String) {
        Logger.parser.debug("Found characters: \(string.prefix(20), privacy: .public)...")
        currentValue += string
    }

    // MARK: - Path Matching

    /// Tests if a path pattern matches a given path array
    /// - Parameters:
    ///   - pattern: Pattern string with '/' as separator and '*' as wildcard
    ///   - path: Array of path components to test against
    /// - Returns: true if pattern matches path
    func pathMatches(_ pattern: String, _ path: [String]) -> Bool {
        let patternParts = pattern.split(separator: "/")
        let pathParts = path

        // If no wildcards, lengths must match exactly
        if !patternParts.contains("*") {
            if patternParts.count != pathParts.count {
                return false
            }
            return zip(patternParts, pathParts).allSatisfy { $0 == $1 }
        }

        // With wildcards, we need to match segments flexibly
        var patternIndex = 0
        var pathIndex = 0

        while patternIndex < patternParts.count && pathIndex < pathParts.count {
            let pattern = String(patternParts[patternIndex])

            if pattern == "*" {
                // For wildcard, try to match the next non-wildcard pattern part
                if patternIndex == patternParts.count - 1 {
                    // Last pattern is wildcard, matches rest of path
                    return true
                }

                // Look ahead to next pattern part
                patternIndex += 1
                let nextPattern = String(patternParts[patternIndex])

                // Find next matching path segment
                while pathIndex < pathParts.count, pathParts[pathIndex] != nextPattern {
                    pathIndex += 1
                }
            } else if pattern == pathParts[pathIndex] {
                // Exact match, continue
                patternIndex += 1
                pathIndex += 1
            } else {
                return false
            }
        }

        // Check if we matched everything
        return patternIndex == patternParts.count ||
            (patternIndex == patternParts.count - 1 && patternParts.last == "*")
    }
}
