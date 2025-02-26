// swiftlint:disable file_length
import Foundation
import OSLog
import TabularData

class ParsingResult: CustomStringConvertible {
    let id: String?
    let version: String?
    var columnData: DataFrame?
    var data: DataFrame?
    var coordinateSystems: [VOCoordinateSystem]?
    var timeSystems: [VOTimeSystem]?
    var parsedDescription: String?
    var resources: [VOResource]?
    var parameters: [VOParameter]?
    var infos: [VOInfo]?

    public init(id: String? = nil, version: String? = nil) {
        self.id = id
        self.version = version
    }

    var description: String {
        """
        ParsingResult:
        - Description: \(parsedDescription ?? "nil")
        - Coordinate Systems: \(coordinateSystems?.description ?? "nil")
        - Time Systems: \(timeSystems?.description ?? "nil")
        - Resources: \(resources?.description ?? "nil")
        """
    }
}

// swiftlint:disable type_body_length
/// Parser for VOTable XML format
class VOTableParser: NSObject, XMLParserDelegate {
    private var currentValue: String = ""
    private var currentPath: [String] = []
    private var currentObjectPath: [Any] = []
    private var parsingResult = ParsingResult()

    // MARK: - Parsing

    // MARK: Start Elements

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

    private func parseDescription(value: String) {
        let parsedDescription = value.trimmingCharacters(in: .whitespacesAndNewlines)

        // Get the previous object in the path
        let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

        // Add the coordinate system to the last object in the current path
        if parentObject == nil { // VOTABLE
            parsingResult.parsedDescription = parsedDescription
        } else if let resource = parentObject as? VOResource { // RESOURCE
            resource.setDescription(parsedDescription)
        }
        // TODO: Add description to TABLE
        // TODO: Add description to FIELD
        // TODO: Add description to PARAM
        // TODO: Add description to GROUP
    }

    private func parseCoordinateSystem(attributes: [String: String]) {
        if let id = attributes["ID"] {
            // Create the coordinate system object
            let system = attributes["system"]
            let equinox = attributes["equinox"]
            let epoch = attributes["epoch"]
            let referencePosition = attributes["refposition"]
            let coordinateSystem = VOCoordinateSystem(
                id: id,
                system: system != nil ? ReferenceFrame(rawValue: system!) : nil,
                equinox: equinox != nil ? try? Date(epoch: equinox!) : nil,
                epoch: epoch != nil ? try? Date(epoch: epoch!) : nil,
                referencePosition: referencePosition != nil ? ReferencePosition(rawValue: referencePosition!) : nil
            )

            // Get the previous object in the path
            let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

            // Add the coordinate system to the last object in the current path
            if parentObject == nil { // VOTABLE
                var coordinateSystems = parsingResult.coordinateSystems ?? []
                coordinateSystems.append(coordinateSystem)
                parsingResult.coordinateSystems = coordinateSystems
            } else if let resource = parentObject as? VOResource { // RESOURCE
                var coordinateSystems = resource.coordinateSystems ?? []
                coordinateSystems.append(coordinateSystem)
                resource.coordinateSystems = coordinateSystems
            }
        }
    }

    private func parseTimeSystem(attributes: [String: String]) {
        if let id = attributes["ID"],
           let timeScale = attributes["timescale"],
           let refpos = attributes["refposition"]
        {
            // Create the time system object
            let timeOrigin = attributes["timeorigin"]
            let referencePosition = ReferencePosition(rawValue: refpos)

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
                timeScale: TimeScale(rawValue: timeScale) ?? .unknown,
                referencePosition: referencePosition
            )

            // Get the previous object in the path
            let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

            // Add the coordinate system to the last object in the current path
            if parentObject == nil { // VOTABLE
                var timeSystems = parsingResult.timeSystems ?? []
                timeSystems.append(timeSystem)
                parsingResult.timeSystems = timeSystems
            } else if let resource = parentObject as? VOResource { // RESOURCE
                var timeSystems = resource.timeSystems ?? []
                timeSystems.append(timeSystem)
                resource.timeSystems = timeSystems
            }
        }
    }

    private func parseResource(attributes: [String: String]) {
        // Create the resource object
        let id = attributes["ID"]
        let name = attributes["name"]
        let type = attributes["type"]
        let utype = attributes["utype"]

        let resource = VOResource(id: id, name: name, type: type, utype: utype)

        // Get the previous object in the path
        let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

        // Add the coordinate system to the last object in the current path
        if parentObject == nil { // VOTABLE
            var resources = parsingResult.resources ?? []
            resources.append(resource)
            parsingResult.resources = resources
        } else if let resource = parentObject as? VOResource { // RESOURCE
            var resources = resource.resources ?? []
            resources.append(resource)
            resource.resources = resources
        }

        // A Resource can have sub-elements so it needs to be added to the current path
        currentObjectPath.append(resource)
    }

    private func parseParameter(attributes: [String: String]) {
        if let name = attributes["name"],
           let datatype = attributes["datatype"],
           let parameterValue = attributes["value"]
        {
            // Create the parameter object
            let id = attributes["ID"]
            let unit = attributes["unit"]
            let widthStr = attributes["width"]
            let precisionStr = attributes["precision"]
            let xType = attributes["xtype"]
            let ucd = attributes["ucd"]
            let utype = attributes["utype"]
            let reference = attributes["ref"]
            let arraySizeStr = attributes["arraysize"]

            let width = widthStr != nil ? Int(widthStr!) : nil
            let precision = precisionStr != nil ? FieldPrecision(precision: precisionStr!) : nil
            var arraySize = 1
            var arraySizeInfinite = false
            switch arraySizeStr {
            case nil:
                break
            case "*":
                arraySizeInfinite = true
            default:
                if let arraySizeInt = Int(arraySizeStr!) {
                    arraySize = arraySizeInt
                }
            }

            let parameter = VOParameter(
                id: id,
                name: name,
                datatype: datatype,
                parameterValue: parameterValue,
                arraySize: arraySize,
                arraySizeInfinite: arraySizeInfinite,
                width: width,
                precision: precision,
                xType: xType,
                unit: unit,
                ucd: ucd,
                utype: utype,
                reference: reference
            )

            // Get the previous object in the path
            let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

            // Add the coordinate system to the last object in the current path
            if parentObject == nil { // VOTABLE
                var parameters = parsingResult.parameters ?? []
                parameters.append(parameter)
                parsingResult.parameters = parameters
            }

            // TODO: Add parameter to RESOURCE
            // TODO: Add parameter to TABLE
            // TODO: Add parameter to GROUP
        }
    }

    private func parseField(attributes: [String: String]) {
        if let name = attributes["name"],
           let datatype = attributes["datatype"]
        {
            // Create the field object
            let id = attributes["ID"]
            let unit = attributes["unit"]
            let widthStr = attributes["width"]
            let precisionStr = attributes["precision"]
            let xType = attributes["xtype"]
            let ucd = attributes["ucd"]
            let utype = attributes["utype"]
            let reference = attributes["ref"]
            let arraySizeStr = attributes["arraysize"]
            let type = attributes["type"]

            let width = widthStr != nil ? Int(widthStr!) : nil
            let precision = precisionStr != nil ? FieldPrecision(precision: precisionStr!) : nil
            var arraySize = 1
            var arraySizeInfinite = false
            switch arraySizeStr {
            case nil:
                break
            case "*":
                arraySizeInfinite = true
            default:
                if let arraySizeInt = Int(arraySizeStr!) {
                    arraySize = arraySizeInt
                }
            }

            let field = VOField(
                id: id,
                name: name,
                datatype: datatype,
                arraySize: arraySize,
                arraySizeInfinite: arraySizeInfinite,
                width: width,
                precision: precision,
                xType: xType,
                unit: unit,
                ucd: ucd,
                utype: utype,
                reference: reference,
                type: type
            )

            // Get the previous object in the path
            let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

            // Add the coordinate system to the last object in the current path
            // TODO: Add field to TABLE
        }
    }

    private func parseInfo(attributes: [String: String]) {
        if let name = attributes["name"],
           let value = attributes["value"]
        {
            // Create the info object
            let id = attributes["ID"]
            let xType = attributes["xtype"]
            let unit = attributes["unit"]
            let ucd = attributes["ucd"]
            let utype = attributes["utype"]
            let reference = attributes["ref"]

            let info = VOInfo(
                id: id,
                name: name,
                value: value,
                xType: xType,
                unit: unit,
                ucd: ucd,
                utype: utype,
                reference: reference
            )

            // Get the previous object in the path
            let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

            // Add the info to the last object in the current path
            if parentObject == nil { // VOTABLE
                parsingResult.infos = [info]
            } else if let resource = parentObject as? VOResource { // RESOURCE
                var infos = resource.infos ?? []
                infos.append(info)
                resource.infos = infos
            }

            // TODO: Add info to TABLE
        }
    }

    // MARK: - XMLParserDelegate

    public func parser(
        _: XMLParser,
        didStartElement elementName: String,
        namespaceURI _: String?,
        qualifiedName _: String?,
        attributes attributeDict: [String: String]
    ) {
        currentPath.append(elementName)

        switch elementName {
        case "VOTABLE", "DESCRIPTION":
            break
        case "BINARY":
            Logger.parser.debug("Found BINARY data section")
        case "COOSYS":
            parseCoordinateSystem(attributes: attributeDict)
        case "TIMESYS":
            parseTimeSystem(attributes: attributeDict)
        case "RESOURCE":
            parseResource(attributes: attributeDict)
        case "PARAM":
            parseParameter(attributes: attributeDict)
        case "FIELD":
            parseField(attributes: attributeDict)
        case "INFO":
            parseInfo(attributes: attributeDict)
        default:
            Logger.parser.debug("Unhandled element: \(elementName, privacy: .public)")
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    public func parser(
        _: XMLParser,
        didEndElement elementName: String,
        namespaceURI _: String?,
        qualifiedName _: String?
    ) {
        let currentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil
        switch elementName {
        case "VOTABLE":
            break
        case "RESOURCE":
            // Remove the resource from the current path
            if currentObject is VOResource {
                currentObjectPath.removeLast()
            }
        case "PARAM":
            // Remove the parameter from the current path
            if currentObject is VOParameter {
                currentObjectPath.removeLast()
            }
        case "FIELD":
            // Remove the field from the current path
            if currentObject is VOField {
                currentObjectPath.removeLast()
            }
        case "INFO":
            // Remove the info from the current path
            if let info = currentObject as? VOInfo {
                let textValue = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if textValue.count > 0 {
                    if info.value.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                        // If the info already has a value, and also a text value
                        // we need to add a new line to the value with the text value
                        info.value += "\n\(textValue)"
                    } else {
                        info.value = textValue
                    }
                }
                currentObjectPath.removeLast()
            }
        case "DESCRIPTION":
            self.parseDescription(value: currentValue)
        default:
            Logger.parser.debug("Unhandled element: \(elementName, privacy: .public)")
        }

        currentPath.removeLast()
    }

    public func parser(_: XMLParser, foundCharacters string: String) {
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
