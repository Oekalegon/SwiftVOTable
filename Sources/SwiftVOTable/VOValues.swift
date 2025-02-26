import Foundation
import OSLog

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

/// The type of the values.
public enum VOValuesType {
    /// The `VOValues` object is only valid for the table.
    case actual

    /// The generic domain of valid values.
    ///
    /// For instance [0,360> for longitude.
    case legal

    /// Another type of values.
    case other(String)

    /// Creates a new `VOValuesType` from a string.
    /// - Parameter type: The type as a string.
    public init(type: String?) {
        switch type {
        case nil: // legal is the default
            self = .legal
        case "actual":
            self = .actual
        case "legal":
            self = .legal
        default:
            self = .other(type!)
        }
    }

    /// The string representation of the type as used in the VOTable format.
    public var typeString: String {
        switch self {
        case .actual:
            "actual"
        case .legal:
            "legal"
        case let .other(type):
            type
        }
    }
}

/// A `VOValues` object is used to describe the domain of a field.
///
/// It may contain a maximum, minimum, and an option element.
public class VOValues: CustomStringConvertible {
    /// The identifier of the values.
    public let id: String?

    /// The type of the values.
    public let type: VOValuesType

    /// A reference to another `VOValues` element of the document.
    ///
    /// This value should be the same as an `id` of another `VOValues` element.
    public let reference: String?

    /// The value used to denote a null value.
    public let nullValue: String?

    /// The maximum value(s) of the domain.
    public var maximum: DomainValue?

    /// The minimum value(s) of the domain.
    public var minimum: DomainValue?

    /// The optional values of the domain.
    public var optionalValues: [OptionalValue]?

    /// Creates a new `VOValues` object.
    /// - Parameters:
    ///   - id: The identifier of the values.
    ///   - type: The type of the values.
    ///   - reference: A reference to another `VOValues` element of the document.
    ///   - nullValue: The value used to denote a null value.
    ///   - maximum: The maximum value(s) of the domain.
    ///   - minimum: The minimum value(s) of the domain.
    ///   - optionalValues: The optional values of the domain.
    public init(
        id: String? = nil,
        type: VOValuesType = .legal,
        reference: String? = nil,
        nullValue: String? = nil,
        maximum: DomainValue? = nil,
        minimum: DomainValue? = nil,
        optionalValues: [OptionalValue]? = nil
    ) {
        self.id = id
        self.type = type
        self.reference = reference
        self.nullValue = nullValue
        self.maximum = maximum
        self.minimum = minimum
        self.optionalValues = optionalValues
    }

    /// A description of the domain values.
    public var description: String {
        """
        VOValues(
            id: \(id ?? "nil"),
            type: \(type.typeString),
            reference: \(reference ?? "nil"),
            nullValue: \(nullValue ?? "nil"),
            maximum: \(maximum?.values.description ?? "nil"),
            minimum: \(minimum?.values.description ?? "nil"),
            option:  \(optionalValues?.description ?? "nil")
        )
        """
    }
}
