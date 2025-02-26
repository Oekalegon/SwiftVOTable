import Foundation
import OSLog
import TabularData

struct ParsingResult: CustomStringConvertible {
    var columnData: DataFrame?
    var data: DataFrame?
    var coordinateSystem: VOCoordinateSystem?
    var timeSystem: VOTimeSystem?
    var parsedDescription: String?
    var resources: [VOResource]?

    var description: String {
        """
        ParsingResult:
        - Description: \(parsedDescription ?? "nil")
        - Coordinate System: \(coordinateSystem?.description ?? "nil")
        - Time System: \(timeSystem?.description ?? "nil")
        - Resources: \(resources?.description ?? "nil")
        """
    }
}

// swiftlint:disable type_body_length
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

    private var currentResourcePath: [VOResource] = []

    // MARK: - Parsing

    // MARK: Start Elements

    private func handleStartTableData() {
        inTableData = true
    }

    private func handleStartTR() {
        inTR = true
        currentRow = []
    }

    private func handleStartStream(attributes: [String: String]) {
        if let encoding = attributes["encoding"] {
            Logger.parser.info("Found STREAM with encoding: \(encoding, privacy: .public)")
        }
    }

    /// Parse VOTable data and return a VODataFrame
    /// - Parameter data: VOTable XML data
    /// - Returns: Parsed VODataFrame
    /// - Throws: Error if parsing fails
    func parse(_ data: Data) throws -> ParsingResult {
        self.currentPath = []
        self.parsingResult = ParsingResult()
        let parser = XMLParser(data: data)
        parser.delegate = self

        guard parser.parse() else {
            throw VOTableError.parsingFailed(parser.parserError?.localizedDescription ?? "Unknown error")
        }

        return parsingResult
    }

    private func parseDescription(path: [String], value: String) {
        var parent = [String]()
        parent.append(contentsOf: path)
        parent.removeLast()

        if parent.last == "VOTABLE" {
            Logger.parser.debug("Parsing DESCRIPTION element for VOTABLE")
            parsingResult.parsedDescription = value.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if inField {
            currentMetadata?.description = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func parseCoordinateSystem(path: [String], attributes: [String: String]) {
        if !self.pathMatches("VOTABLE/COOSYS", path),
           !self.pathMatches("VOTABLE/DEFINITIONS/COOSYS", path),
           !self.pathMatches("*/RESOURCE/COOSYS", path)
        {
            Logger.parser.warning("Skipping COOSYS element because path does not match: \(path, privacy: .public)")
            return
        }
        let id = attributes["ID"]
        let system = attributes["system"]
        let equinox = attributes["equinox"]
        let epoch = attributes["epoch"]
        let referencePosition = attributes["refposition"]
        Logger.parser.debug("Parsing COOSYS element with attributes: \(attributes, privacy: .public)")
        let coordinateSystem = VOCoordinateSystem(
            id: id,
            system: system != nil ? ReferenceFrame(rawValue: system!) : nil,
            equinox: equinox != nil ? try? Date(epoch: equinox!) : nil,
            epoch: epoch != nil ? try? Date(epoch: epoch!) : nil,
            referencePosition: referencePosition != nil ? ReferencePosition(rawValue: referencePosition!) : nil
        )
        Logger.parser.debug(
            "Parsed COOSYS element \("\(self.parsingResult.coordinateSystem?.description ?? "nil")", privacy: .public)"
        )
        if self.pathMatches("VOTABLE/COOSYS", path) {
            parsingResult.coordinateSystem = coordinateSystem
        } else if self.pathMatches("*/RESOURCE/COOSYS", currentPath), !currentResourcePath.isEmpty {
            currentResourcePath[currentResourcePath.count - 1].coordinateSystem = coordinateSystem
        }
    }

    private func parseTimeSystem(path: [String], attributes: [String: String]) {
        if !self.pathMatches("VOTABLE/TIMESYS", path),
           !self.pathMatches("VOTABLE/DEFINITIONS/TIMESYS", path),
           !self.pathMatches("*/RESOURCE/TIMESYS", path)
        {
            Logger.parser.warning("Skipping TIMESYS element because path does not match: \(path, privacy: .public)")
            return
        }
        let id = attributes["ID"]
        let timeOrigin = attributes["timeorigin"]
        let timeScale = attributes["timescale"]
        let referencePosition = attributes["refposition"]

        var timeOriginDate: Date?
        if let timeOriginString = timeOrigin {
            if timeOriginString == "MJD-origin" {
                timeOriginDate = Date.modifiedJulianDateOrigin
            } else if timeOriginString == "JD-origin" {
                timeOriginDate = Date.julianDateOrigin
            } else if let julianDate = Double(timeOriginString) {
                timeOriginDate = Date(julianDate: julianDate)
            }
        }
        Logger.parser.debug("Parsing TIMESYS element with attributes: \(attributes, privacy: .public)")
        let timeSystem = VOTimeSystem(
            id: id,
            timeOrigin: timeOriginDate,
            timeScale: timeScale != nil ? TimeScale(rawValue: timeScale!) : nil,
            referencePosition: referencePosition != nil ? ReferencePosition(rawValue: referencePosition!) : nil
        )

        if self.pathMatches("VOTABLE/TIMESYS", path) {
            parsingResult.timeSystem = timeSystem
        } else if self.pathMatches("*/RESOURCE/TIMESYS", currentPath), !currentResourcePath.isEmpty {
            currentResourcePath[currentResourcePath.count - 1].timeSystem = timeSystem
        }
    }

    private func parseResource(path: [String]) {
        if !self.pathMatches("VOTABLE/RESOURCE", path),
           !self.pathMatches("*/RESOURCE/RESOURCE", path)
        {
            Logger.parser.warning("Skipping RESOURCE element because path does not match: \(path, privacy: .public)")
            return
        }
        let resource = VOResource()
        currentResourcePath.append(resource)
    }

    // MARK: End Elements

    private func handleFieldElement(attributes: [String: String]) {
        inField = true
        let name = attributes["name"] ?? ""
        let datatype = attributes["datatype"] ?? "char"
        let unit = attributes["unit"]
        let ucd = attributes["ucd"]

        currentMetadata = ColumnMetadata(
            name: name,
            datatype: datatype,
            ucd: ucd,
            unit: unit,
            description: nil
        )
    }

    private func handleEndResource() {
        if let currentResource = currentResourcePath.last {
            self.addResource(currentResource, path: currentPath)
        }
        currentResourcePath.removeLast()
    }

    private func handleEndField() {
        inField = false
        if let metadata = currentMetadata {
            fields.append(metadata)
        }
        currentMetadata = nil
    }

    private func addResource(_ resource: VOResource, path: [String]) {
        if self.pathMatches("VOTABLE/RESOURCE", path) {
            parsingResult.resources?.append(resource)
        } else if self.pathMatches("*/RESOURCE/RESOURCE", path), !currentResourcePath.isEmpty {
            currentResourcePath[currentResourcePath.count - 1].resources?.append(resource)
        }
    }

    // MARK: - XMLParserDelegate

    // swiftlint:disable:next cyclomatic_complexity
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
        case "VOTABLE", "TABLE", "DATA", "INFO":
            break
        case "BINARY":
            Logger.parser.debug("Found BINARY data section")
        case "COOSYS":
            parseCoordinateSystem(path: currentPath, attributes: attributeDict)
        case "TIMESYS":
            parseTimeSystem(path: currentPath, attributes: attributeDict)
        case "RESOURCE":
            parseResource(path: currentPath)
        case "FIELD":
            handleFieldElement(attributes: attributeDict)
        case "STREAM":
            handleStartStream(attributes: attributeDict)
        case "TABLEDATA":
            handleStartTableData()
        case "TR":
            handleStartTR()
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
        case "VOTABLE", "TABLE", "DATA", "BINARY", "STREAM", "INFO":
            break
        case "RESOURCE":
            handleEndResource()
        case "FIELD":
            handleEndField()
        case "DESCRIPTION":
            self.parseDescription(path: currentPath, value: currentValue)
        case "TR":
            inTR = false
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

// swiftlint:enable type_body_length
