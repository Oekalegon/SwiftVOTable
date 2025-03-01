import Foundation
import OSLog

/// A `VOParameter` is a field that contains a set value.
///
/// This value is valid for the whole table or resource, and is not
/// a column of the table. One can think of it as an extra column in the table,
/// where the values are the same for each row.
public class VOParameter: VOField {
    /// The values of the parameter.
    public let parameterValues: [Any]

    /// Creates a new `VOParameter` with a single value.
    /// - Parameters:
    ///   - id: The identifier of the parameter.
    ///   - name: The name of the parameter.
    ///   - datatype: The datatype of the parameter.
    ///   - parameterValue: The value of the parameter.
    ///   - arraySize: The size of the parameter.
    ///   - arraySizeInfinite: Indicates if the parameter is an infinite array.
    ///   - width: The width of the parameter.
    ///   - precision: The precision of the parameter.
    ///   - xType: The xType of the parameter.
    ///   - unit: The unit of the parameter.
    ///   - ucd: The ucd of the parameter.
    ///   - utype: The utype of the parameter.
    ///   - reference: The reference of the parameter.
    ///   - description: The description of the parameter.
    ///   - values: The values of the parameter.
    ///   - links: The links of the parameter.
    public init(
        id: String? = nil,
        name: String,
        datatype: VODataType,
        parameterValue: Any,
        arraySize: Int = 1,
        arraySizeInfinite: Bool = false,
        width: Int? = nil,
        precision: FieldPrecision? = nil,
        xType: String? = nil,
        unit: String? = nil,
        ucd: String? = nil,
        utype: String? = nil,
        reference: String? = nil,
        description: String? = nil,
        values: VOValues? = nil,
        links: [VOLink]? = nil
    ) {
        self.parameterValues = [parameterValue]
        super.init(
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
            type: nil,
            description: description,
            values: values,
            links: links
        )
    }

    /// Creates a new `VOParameter` with an array of values.
    /// - Parameters:
    ///   - id: The identifier of the parameter.
    ///   - name: The name of the parameter.
    ///   - datatype: The datatype of the parameter.
    ///   - parameterValues: The values of the parameter.
    ///   - arraySize: The size of the parameter.
    ///   - arraySizeInfinite: Indicates if the parameter is an infinite array.
    ///   - width: The width of the parameter.
    ///   - precision: The precision of the parameter.
    ///   - xType: The xType of the parameter.
    ///   - unit: The unit of the parameter.
    ///   - ucd: The ucd of the parameter.
    ///   - utype: The utype of the parameter.
    ///   - reference: The reference of the parameter.
    ///   - description: The description of the parameter.
    ///   - values: The values of the parameter.
    ///   - links: The links of the parameter.
    public init(
        id: String? = nil,
        name: String,
        datatype: VODataType,
        parameterValues: [Any],
        arraySize: Int = 1,
        arraySizeInfinite: Bool = false,
        width: Int? = nil,
        precision: FieldPrecision? = nil,
        xType: String? = nil,
        unit: String? = nil,
        ucd: String? = nil,
        utype: String? = nil,
        reference: String? = nil,
        description: String? = nil,
        values: VOValues? = nil,
        links: [VOLink]? = nil
    ) {
        self.parameterValues = parameterValues
        super.init(
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
            description: description,
            values: values,
            links: links
        )
    }
}
