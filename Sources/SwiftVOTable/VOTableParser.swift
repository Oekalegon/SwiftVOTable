// swiftlint:disable file_length
import Foundation
import OSLog
import TabularData

// swiftlint:disable type_body_length
/// Parser for VOTable XML format
class VOTableParser: NSObject, XMLParserDelegate {
    private var currentValue: String = ""
    private var currentPath: [String] = []
    private var currentObjectPath: [Any] = []
    private var votable = VOTable()

    // MARK: - Parsing

    // MARK: Start Elements

    /// Parse VOTable data and return a VODataFrame
    /// - Parameter data: VOTable XML data
    /// - Returns: Parsed VODataFrame
    /// - Throws: Error if parsing fails
    func parse(_ data: Data) throws -> VOTable {
        self.currentPath = []
        self.votable = VOTable()
        let parser = XMLParser(data: data)
        parser.delegate = self

        guard parser.parse() else {
            throw VOTableError.parsingFailed(parser.parserError?.localizedDescription ?? "Unknown error")
        }

        return votable
    }

    private func parseDescription(value: String) {
        let parsedDescription = value.trimmingCharacters(in: .whitespacesAndNewlines)

        // Get the previous object in the path
        let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

        // Add the coordinate system to the last object in the current path
        if parentObject == nil { // VOTABLE
            votable.parsedDescription = parsedDescription
        } else if let resource = parentObject as? VOResource { // RESOURCE
            resource.setDescription(parsedDescription)
        } else if let table = parentObject as? VOResourceTable { // TABLE
            table.description = parsedDescription
        } else if let field = parentObject as? VOField { // FIELD
            field.setDescription(parsedDescription)
        } else if let parameter = parentObject as? VOParameter { // PARAM
            parameter.setDescription(parsedDescription)
        } else if let group = parentObject as? VOGroup { // GROUP
            group.setDescription(parsedDescription)
        } else {
            Logger.parser.warning("""
            Cannot add DESCRIPTION element to \(Swift.type(of: parentObject), privacy: .public), skipping
            """)
        }
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
                var coordinateSystems = votable.coordinateSystems ?? []
                coordinateSystems.append(coordinateSystem)
                votable.coordinateSystems = coordinateSystems
            } else if let resource = parentObject as? VOResource { // RESOURCE
                var coordinateSystems = resource.coordinateSystems ?? []
                coordinateSystems.append(coordinateSystem)
                resource.coordinateSystems = coordinateSystems
            } else {
                Logger.parser.warning("""
                Cannot add COOSYS element to \(Swift.type(of: parentObject), privacy: .public), skipping
                """)
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
                var timeSystems = votable.timeSystems ?? []
                timeSystems.append(timeSystem)
                votable.timeSystems = timeSystems
            } else if let resource = parentObject as? VOResource { // RESOURCE
                var timeSystems = resource.timeSystems ?? []
                timeSystems.append(timeSystem)
                resource.timeSystems = timeSystems
            } else {
                Logger.parser.warning("""
                Cannot add TIMESYS element to \(Swift.type(of: parentObject), privacy: .public), skipping
                """)
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
            var resources = votable.resources ?? []
            resources.append(resource)
            votable.resources = resources
        } else if let resource = parentObject as? VOResource { // RESOURCE
            var resources = resource.resources ?? []
            resources.append(resource)
            resource.resources = resources
        } else {
            Logger.parser.warning("""
            Cannot add RESOURCE element to \(Swift.type(of: parentObject), privacy: .public), skipping
            """)
        }

        // A Resource can have sub-elements so it needs to be added to the current path
        currentObjectPath.append(resource)
    }

    // swiftlint:disable:next function_body_length
    private func parseParameter(attributes: [String: String]) {
        if let name = attributes["name"],
           let datatypeStr = attributes["datatype"],
           let datatype = VODataType(rawValue: datatypeStr),
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

            let parameterValues = parameterValue.split(separator: " ").map(\.self)

            let parameter = VOParameter(
                id: id,
                name: name,
                datatype: datatype,
                parameterValues: parameterValues,
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
                var parameters = votable.parameters ?? []
                parameters.append(parameter)
                votable.parameters = parameters
            } else if let resource = parentObject as? VOResource { // RESOURCE
                var parameters = resource.parameters ?? []
                parameters.append(parameter)
                resource.parameters = parameters
            } else if let group = parentObject as? VOGroup { // GROUP
                var parameters = group.parameters ?? []
                parameters.append(parameter)
                group.parameters = parameters
            } else if let table = parentObject as? VOResourceTable { // TABLE
                var parameters = table.parameters ?? []
                parameters.append(parameter)
                table.parameters = parameters
            } else {
                Logger.parser.warning("""
                Cannot add PARAM element to \(Swift.type(of: parentObject), privacy: .public), skipping
                """)
            }

            currentObjectPath.append(parameter)
        }
    }

    // swiftlint:disable:next function_body_length
    private func parseField(attributes: [String: String]) {
        if let name = attributes["name"],
           let datatypeStr = attributes["datatype"],
           let datatype = VODataType(rawValue: datatypeStr)
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
            if let table = parentObject as? VOResourceTable { // TABLE
                var fields = table.fields ?? []
                fields.append(field)
                table.fields = fields
            } else {
                Logger.parser.warning("""
                Cannot add FIELD element to \(Swift.type(of: parentObject), privacy: .public)
                """)
            }

            currentObjectPath.append(field)
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
                var infos: [VOInfo] = votable.infos ?? []
                infos.append(info)
                votable.infos = infos
            } else if let resource = parentObject as? VOResource { // RESOURCE
                var infos: [VOInfo] = resource.infos ?? []
                infos.append(info)
                resource.infos = infos
            } else if let table = parentObject as? VOResourceTable { // TABLE
                var infos: [VOInfo] = table.infos ?? []
                infos.append(info)
                table.infos = infos
            } else {
                Logger.parser.warning("""
                Cannot add INFO element to \(Swift.type(of: parentObject), privacy: .public), skipping
                """)
            }
        }
    }

    private func parseGroup(attributes: [String: String]) {
        // Create the group object
        let id = attributes["ID"]
        let name = attributes["name"]
        let ucd = attributes["ucd"]
        let utype = attributes["utype"]
        let reference = attributes["ref"]

        let group = VOGroup(id: id, name: name, ucd: ucd, utype: utype, reference: reference)

        // Get the previous object in the path
        let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

        // Add the group to the last object in the current path
        if parentObject == nil { // VOTABLE
            var groups = votable.groups ?? []
            groups.append(group)
            votable.groups = groups
        } else if let resource = parentObject as? VOResource { // RESOURCE
            var groups = resource.groups ?? []
            groups.append(group)
            resource.groups = groups
        } else if let group = parentObject as? VOGroup { // GROUP
            var groups = group.groups ?? []
            groups.append(group)
            group.groups = groups
        } else if let table = parentObject as? VOResourceTable { // TABLE
            var groups = table.groups ?? []
            groups.append(group)
            table.groups = groups
        } else {
            Logger.parser.warning("""
            Cannot add GROUP element to \(Swift.type(of: parentObject), privacy: .public), skipping
            """)
        }

        currentObjectPath.append(group)
    }

    private func parseValues(attributes: [String: String]) {
        let id = attributes["ID"]
        let typeStr = attributes["type"]
        let type = VOValuesType(type: typeStr)
        let reference = attributes["ref"]
        let nullValue = attributes["null"]

        let values = VOValues(id: id, type: type, reference: reference, nullValue: nullValue)

        // Get the previous object in the path
        let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

        // Add the values to the last object in the current path
        if let field = parentObject as? VOField { // VOField
            field.values = values
        } else if let parameter = parentObject as? VOParameter { // VOParameter
            parameter.values = values
        } else {
            Logger.parser.warning("""
            Cannot add VALUES element to \(parentObject.debugDescription, privacy: .public), skipping
            """)
        }

        currentObjectPath.append(values)
    }

    private func parseMin(attributes: [String: String]) {
        if let value = attributes["value"] {
            let inclusive = attributes["inclusive"]
            let values = value.split(separator: " ").map(\.self)
            let convertedValues = convertValues(values)
            let min = DomainValue(values: convertedValues, inclusive: inclusive == "true")
            let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

            // Add the min to the last object in the current path
            if let values = parentObject as? VOValues {
                values.minimum = min
            } else {
                Logger.parser.warning("""
                Cannot add MIN element to \(Swift.type(of: parentObject), privacy: .public), skipping
                """)
            }
        }
    }

    private func parseMax(attributes: [String: String]) {
        if let value = attributes["value"] {
            let inclusive = attributes["inclusive"]
            let stringValues = value.split(separator: " ").map(\.self)
            let convertedValues = convertValues(stringValues)
            let max = DomainValue(values: convertedValues, inclusive: inclusive == "true")
            let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

            // Add the max to the last object in the current path
            if let values = parentObject as? VOValues { // VOValues
                values.maximum = max
            } else {
                Logger.parser.warning("""
                Cannot add MAX element to \(Swift.type(of: parentObject), privacy: .public), skipping
                """)
            }
        }
    }

    private func parseOption(attributes: [String: String]) {
        if let value = attributes["value"] {
            let name = attributes["name"]
            let stringValues = value.split(separator: " ")
            let convertedValues = convertValues(stringValues)
            let optionalValue = OptionalValue(name: name, values: convertedValues)
            let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

            // Add the option to the last object in the current path
            if let values = parentObject as? VOValues { // VOValues
                var optionalValues = values.optionalValues ?? []
                optionalValues.append(optionalValue)
                values.optionalValues = optionalValues
            } else if let optionalValue = parentObject as? OptionalValue {
                var optionalValues = optionalValue.optionalValues ?? []
                optionalValues.append(optionalValue)
                optionalValue.optionalValues = optionalValues
            } else {
                Logger.parser.warning("""
                Cannot add OPTION element to \(Swift.type(of: parentObject), privacy: .public), skipping
                """)
            }
        }
    }

    private func parseLink(attributes: [String: String]) {
        let id = attributes["ID"]
        let title = attributes["title"]
        let value = attributes["value"]
        let action = attributes["action"]
        let urlStr = attributes["href"]
        let url = urlStr != nil ? URL(string: urlStr!) : nil
        let contentType = attributes["content-type"]
        let contentRoleStr = attributes["content-role"]
        let contentRole = ContentRole(role: contentRoleStr)

        let link = VOLink(
            id: id,
            title: title,
            value: value,
            action: action,
            url: url,
            contentType: contentType,
            contentRole: contentRole
        )

        let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

        if let resource = parentObject as? VOResource {
            var links = resource.links ?? []
            links.append(link)
            resource.links = links
        } else if let field = parentObject as? VOField {
            var links = field.links ?? []
            links.append(link)
            field.links = links
        } else if let parameter = parentObject as? VOParameter {
            var links = parameter.links ?? []
            links.append(link)
            parameter.links = links
        } else if let table = parentObject as? VOResourceTable { // TABLE
            var links = table.links ?? []
            links.append(link)
            table.links = links
        } else {
            Logger.parser.warning("""
            Cannot add LINK element to \(Swift.type(of: parentObject), privacy: .public), skipping
            """)
        }
    }

    private func parseTable(attributes: [String: String]) {
        let id = attributes["ID"]
        let name = attributes["name"]
        let ucd = attributes["ucd"]
        let utype = attributes["utype"]
        let reference = attributes["ref"]
        let nrowsStr: String? = attributes["nrows"]
        let nrows = nrowsStr != nil ? Int(nrowsStr!) : nil

        let table = VOResourceTable(
            id: id,
            name: name,
            ucd: ucd,
            utype: utype,
            reference: reference,
            nrows: nrows
        )

        // Get the previous object in the path
        let parentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil

        // Add the table to the last object in the current path
        if let resource = parentObject as? VOResource { // VOResource
            var tables = resource.tables ?? []
            tables.append(table)
            resource.tables = tables
        } else {
            Logger.parser.warning("""
            Cannot add TABLE element to \(Swift.type(of: parentObject), privacy: .public), skipping
            """)
        }

        currentObjectPath.append(table)
    }

    private func parseData() {
        let data = VOData()
        currentObjectPath.append(data)
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
        case "VALUES":
            parseValues(attributes: attributeDict)
        case "MIN":
            parseMin(attributes: attributeDict)
        case "MAX":
            parseMax(attributes: attributeDict)
        case "OPTION":
            parseOption(attributes: attributeDict)
        case "LINK":
            parseLink(attributes: attributeDict)
        case "INFO":
            parseInfo(attributes: attributeDict)
        case "GROUP":
            parseGroup(attributes: attributeDict)
        case "TABLE":
            parseTable(attributes: attributeDict)
        case "DATA":
            parseData()
        case "FIELDref":
            // Add the field reference to the group as a string
            if let group = currentObjectPath.last as? VOGroup {
                var fieldReferences = group.fieldReferences ?? []
                fieldReferences.append(currentValue.trimmingCharacters(in: .whitespacesAndNewlines))
                group.fieldReferences = fieldReferences
            }
        case "PARAMref":
            // Add the parameter reference to the group as a string
            if let group = currentObjectPath.last as? VOGroup {
                var parameterReferences = group.parameterReferences ?? []
                parameterReferences.append(currentValue.trimmingCharacters(in: .whitespacesAndNewlines))
                group.parameterReferences = parameterReferences
            }
        default:
            Logger.parser.debug("Unhandled element: \(elementName, privacy: .public)")
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public func parser(
        _: XMLParser,
        didEndElement elementName: String,
        namespaceURI _: String?,
        qualifiedName _: String?
    ) {
        let currentObject = currentObjectPath.count > 0 ? currentObjectPath[currentObjectPath.count - 1] : nil
        switch elementName {
        case "VOTABLE", "FIELDref", "PARAMref", "COOSYS", "TIMESYS":
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
        case "VALUES":
            // Remove the values from the current path
            if currentObject is VOValues {
                currentObjectPath.removeLast()
            }
        case "MIN":
            // Remove the min from the current path
            if currentObject is DomainValue {
                currentObjectPath.removeLast()
            }
        case "MAX":
            // Remove the max from the current path
            if currentObject is DomainValue {
                currentObjectPath.removeLast()
            }
        case "OPTION":
            // Remove the option from the current path
            if currentObject is OptionalValue {
                currentObjectPath.removeLast()
            }
        case "LINK":
            // Remove the link from the current path
            if currentObject is VOLink {
                currentObjectPath.removeLast()
            }
        case "INFO":
            // Remove the info from the current path
            if let info = currentObject as? VOInfo {
                let textValue = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
                info.textValue = textValue
                currentObjectPath.removeLast()
            }
        case "GROUP":
            // Remove the group from the current path
            if currentObject is VOGroup {
                currentObjectPath.removeLast()
            }
        case "TABLE":
            // Remove the table from the current path
            if currentObject is VOResourceTable {
                currentObjectPath.removeLast()
            }
        case "DATA":
            // Remove the data from the current path
            if currentObject is VOData {
                currentObjectPath.removeLast()
            }
        case "DESCRIPTION":
            self.parseDescription(value: currentValue)
        default:
            Logger.parser.debug("Unhandled element (end): \(elementName, privacy: .public)")
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

    /// Converts an array of substrings to an array of Any values
    /// - Parameter values: Array of substrings to convert
    /// - Returns: Array of Any values
    func convertValues(_ values: [Substring]) -> [Any] {
        values.map { str in
            // Try Double first
            if let doubleValue = Double(str) {
                return doubleValue
            }
            // Try Int next
            if let intValue = Int(str) {
                return intValue
            }
            // Fall back to String
            return String(str)
        }
    }
}

// swiftlint:enable type_body_length
