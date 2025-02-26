import Foundation
import OSLog

/// The precision of a field.
///
/// The precision is used to indicate the number of significant digits of the quantity.
/// It is either defined as the number of digits after the decimal point (F) or as the
/// relative precision with respect to the exponent (E).
///
/// If the precision is given as `.float(2)` and the value is `0.152` than the rounded
/// value with regard to precision would be `0.15`.
///
/// If the precision is given as `.exponent(2)` or $10^{-2}$ and the value is `1234` than the
/// precision is $1234 \cross 10^{-2} = 12.34$, i.e. the rounded
/// value with regard to precision would be $12.3\cross 10^{-2}$.
public enum FieldPrecision {
    /// The precision is defined as the number of digits after the decimal point.
    case float(Int)

    /// The precision is defined as the relative precision with respect to the exponent.
    case exponent(Int)

    /// Creates a new precision from a string as used in the VOTable format.
    ///
    /// The string is expected to be in the format `E<precision>` or `F<precision>`,
    /// although only integers in the string are also allowed and interpreted as
    /// being a `.float` precision.
    ///
    /// - Parameter precision: The precision as a string.
    init?(precision: String) {
        if precision.hasPrefix("E") {
            self = .exponent(Int(precision.dropFirst())!)
        } else if precision.hasPrefix("F") {
            self = .float(Int(precision.dropFirst())!)
        } else {
            if let intValue = Int(precision) {
                self = .float(intValue)
            } else {
                return nil
            }
        }
    }

    var precisionString: String {
        switch self {
        case let .float(precision):
            "F\(precision)"
        case let .exponent(precision):
            "E\(precision)"
        }
    }
}

/// A domain value is a value that can be used to describe the domain of a field,
/// it is either a maximum or minimum value for a `VOValues` object.
///
/// The value is an array of doubles and the inclusive flag indicates if the value is included
/// in the domain. Usually the value will be a single value, but if the `VOField` is an array,
/// the value will be an array of doubles.
public class DomainValue {
    /// The values of the domain value.
    public let values: [Any]

    /// Indicates if the value is included in the domain.
    public let inclusive: Bool?

    /// Creates a new domain value with a single value.
    /// - Parameters:
    ///   - value: The value of the domain value.
    ///   - inclusive: Indicates if the value is included in the domain.
    public init(value: Any, inclusive: Bool? = nil) {
        self.values = [value]
        self.inclusive = inclusive
    }

    /// Creates a new domain value with an array of values.
    /// - Parameters:
    ///   - values: The values of the domain value.
    ///   - inclusive: Indicates if the value is included in the domain.
    public init(values: [Any], inclusive: Bool? = nil) {
        self.values = values
        self.inclusive = inclusive
    }
}

/// An optional value is a value that can be used to describe the optional value the bounds of a field.
public class OptionalValue: CustomStringConvertible {
    /// The name of the optional value.
    public let name: String?

    /// The values of the optional value.
    public let values: [Any]

    /// Optional values can be nested to create a tree of optional values.
    public var optionalValues: [OptionalValue]?

    public init(name: String?, values: [Any], optionalValues: [OptionalValue]? = nil) {
        self.name = name
        self.values = values
        self.optionalValues = optionalValues
    }

    public var description: String {
        """
        OptionalValue(
            name: \(name ?? "nil"),
            values: \(values.description),
            optionalValues: \(optionalValues?.description ?? "nil")
        )
        """
    }
}

/// A `VOValues` object is used to describe the domain of a field.
///
/// It may contain a maximum, minimum, and an option element.
public class VOValues: CustomStringConvertible {
    /// The maximum value(s) of the domain.
    public var maximum: DomainValue?

    /// The minimum value(s) of the domain.
    public var minimum: DomainValue?

    /// The optional values of the domain.
    public var optionalValues: [OptionalValue]?

    /// Creates a new `VOValues` object.
    /// - Parameters:
    ///   - maximum: The maximum value(s) of the domain.
    ///   - minimum: The minimum value(s) of the domain.
    ///   - optionalValues: The optional values of the domain.
    public init(maximum: DomainValue? = nil, minimum: DomainValue? = nil, optionalValues: [OptionalValue]? = nil) {
        self.maximum = maximum
        self.minimum = minimum
        self.optionalValues = optionalValues
    }

    /// A description of the domain values.
    public var description: String {
        """
        VOValues(
            maximum: \(maximum?.values.description ?? "nil"),
            minimum: \(minimum?.values.description ?? "nil"),
            option:  \(optionalValues?.description ?? "nil")
        )
        """
    }
}

/// Represents a field in a VOTable.
///
/// A field is a single column in a table.
/// It contains a name, a datatype, a size, a width, a precision, a UCD, a usage specific type,
/// a reference, a type, and a description.
public class VOField: CustomStringConvertible {
    /// The identifier of the field.
    public let id: String?

    /// The name of the field.
    public let name: String

    /// The datatype of the field.
    public let datatype: String

    /// The size of the array of the field.
    public let arraySize: Int

    /// Indicates if the array size is infinite, in that case the array size is not specified.
    public let arraySizeInfinite: Bool

    /// The width of the value, i.e. it is meant to indicate to the application the number of
    /// characters to be used for input or output of the quantity.
    public let width: Int?

    /// The precision of the value, i.e. it is meant to indicate to the application the number of
    /// significant digits of the quantity.
    public let precision: FieldPrecision?

    /// The extended/external datatype of the field.
    public let xType: String?

    /// The unit of the field.
    public let unit: String?

    /// The UCD of the field.
    ///
    /// The UCD is a standard classification of the physical quantity.
    public let ucd: String?

    /// The usage specfic type of the field.
    ///
    /// The utype is meant to express the role of the column in the context of an external data model
    public let utype: String?

    /// The reference of the field.
    ///
    /// The reference property is used to quote another element of the document in the definition of a FIELD or PARAM.
    /// For instance, the reference may be the ID of a COOSYS or TIMESYS element.
    public let reference: String?

    /// Reserved for future use.
    public let type: String?

    /// The description of the field.
    public var description: String {
        _description ?? "No description for this field"
    }

    private var _description: String?

    /// Domain values of the field.
    public var values: VOValues?

    /// Links to resources for the field.
    ///
    /// Multiple links can be provided for a field.
    public var links: [VOLink]?

    /// Sets the description of the field.
    /// - Parameter description: The description of the field.
    func setDescription(_ description: String) {
        self._description = description
    }

    public init(
        id: String? = nil,
        name: String,
        datatype: String,
        arraySize: Int = 1,
        arraySizeInfinite: Bool = false,
        width: Int? = nil,
        precision: FieldPrecision? = nil,
        xType: String? = nil,
        unit: String? = nil,
        ucd: String? = nil,
        utype: String? = nil,
        reference: String? = nil,
        type: String? = nil,
        description: String? = nil,
        values: VOValues? = nil,
        links: [VOLink]? = nil
    ) {
        self.id = id
        self.name = name
        self.datatype = datatype
        self.arraySize = arraySize
        self.arraySizeInfinite = arraySizeInfinite
        self.width = width
        self.precision = precision
        self.xType = xType
        self.unit = unit
        self.ucd = ucd
        self.utype = utype
        self.reference = reference
        self.type = type
        self._description = description
        self.values = values
        self.links = links
    }
}

/// A `VOParameter` is a field that contains a set value.

public class VOParameter: VOField {
    public let parameterValues: [Any]

    public init(
        id: String? = nil,
        name: String,
        datatype: String,
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

    public init(
        id: String? = nil,
        name: String,
        datatype: String,
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
