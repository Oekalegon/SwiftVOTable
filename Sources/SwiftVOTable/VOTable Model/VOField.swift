import Foundation
import OSLog

/// The datatype of a field.
///
/// The datatype is used to indicate the type of the data in the field.
public enum VODataType: String {
    /// The datatype is a boolean.
    case boolean

    /// The datatype is a bit.
    case bit

    /// The datatype is an unsigned byte.
    case unsignedByte

    /// The datatype is a char.
    ///
    /// For a sequence of `char`s, i.e. a string, the `arraySize` attribute of the field
    /// should be specified (either a number to limit the number of characters or `*` for
    /// a string of unspecified length).
    case char

    /// The datatype is a unicode char.
    ///
    /// For a sequence of `unicodeChar`s, i.e. a string, the `arraySize` attribute of the field
    /// should be specified (either a number to limit the number of characters or `*` for
    /// a string of unspecified length).
    case unicodeChar

    /// The datatype is a short.
    case short // int16

    /// The datatype is an integer.
    case int // int32

    /// The datatype is a long.
    case long // int64

    /// The datatype is a float.
    case float

    /// The datatype is a double.
    case double

    /// The datatype is a complex number with a float precision.
    ///
    /// In VOTable, this consists of two float values, the real and imaginary part respectively.
    case floatComplex

    /// The datatype is a complex number with a double precision.
    ///
    /// In VOTable, this consists of two double values, the real and imaginary part respectively.
    case doubleComplex
}

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
    public let datatype: VODataType

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

    /// Creates a new `VOField` with the given parameters.
    /// - Parameters:
    ///   - id: The identifier of the field.
    ///   - name: The name of the field.
    ///   - datatype: The datatype of the field.
    ///   - arraySize: The size of the array of the field.
    ///   - arraySizeInfinite: Indicates if the array size is infinite.
    ///   - width: The width of the field.
    ///   - precision: The precision of the field.
    ///   - xType: The extended/external datatype of the field.
    ///   - unit: The unit of the field.
    ///   - ucd: The UCD of the field.
    ///   - utype: The usage specfic type of the field.
    ///   - reference: The reference of the field.
    ///   - type: Reserved for future use.
    ///   - description: The description of the field.
    ///   - values: The domain values of the field.
    ///   - links: The links of the field.
    public init(
        id: String? = nil,
        name: String,
        datatype: VODataType,
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
