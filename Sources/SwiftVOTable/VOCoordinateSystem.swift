import Foundation
import OSLog

/// Reference frame of the coordinate system.
///
/// This enum is based on the IVOA Reference Frame Vocabulary.
/// See https://www.ivoa.net/rdf/refframe/2022-02-22/refframe.html
///
/// A collection of reference frames in common use in astronomy, organised by top-level categories
/// (equatorial, galactic, etc). These concepts are used in VOTable's COOSYS, in SimpleDALRegExt's
/// PosParam type, and of course in the Coords data model. Where no more precise reference are given,
/// http://www.iaufs.org/res.html is often of help.
public enum ReferenceFrame: String, CaseIterable {
    /// Horizontal coordinate system, i.e. the azimuth/elevation system.
    case horizontal = "AZ_EL"

    /// Generic bodycentric coordinates.
    ///
    /// Data annotated in this way cannot be automatically combined with any other data.
    /// Use or create more specific terms if at all possible.
    case body = "BODY"

    /// Ecliptical coordinate system; the ecliptic of J2000.0 is assumed.
    case ecliptic = "ECLIPTIC"

    /// Equatorial coordinate system.
    ///
    /// Only use for old, pre-FK4 equatorial coordinates.
    case equatorial = "EQUATORIAL"

    /// FK4 equatorial coordinate system.
    ///
    /// Positions based on the 4th Fundamental Katalog.
    /// If no equinox is defined with this frame, assume B1950.0.
    case fk4 = "FK4"

    /// FK5 equatorial coordinate system.
    ///
    /// Positions based on the 5th Fundamental Katalog.
    /// If no equinox is defined with this frame, assume J2000.0.
    /// Applications not requiring extremely high precision can identify FK5 at J2000 with ICRS.
    case fk5 = "FK5"

    /// Galactic coordinate system.
    ///
    /// Galactic coordinates, modern definition: Pole at precisely FK4 B1950 192.25, 27.4, origin at
    /// approximately FK4 B1950 265.55, -28.92. See 1960MNRAS.121..123B for details.
    case galactic = "GALACTIC"

    /// Old, pre-1958, Galactic coordinates.
    ///
    /// See 1960MNRAS.121..123B for details.
    case oldGalactic = "GALACTIC_I"

    /// Generic galactic coordinates.
    ///
    /// Umbrella term for Galactic coordinates.
    /// If at all possible, use a more specific term, as historically, many different conventions have been in use.
    case genericGalactic = "GENERIC_GALACTIC"

    /// ICRS equatorial coordinate system.
    ///
    /// International Celestial Reference System as defined by 1998AJ....116..516M.
    case icrs = "ICRS"

    /// SuperGalactic coordinate system.
    ///
    /// Pole at GALACTIC 47.37, +6.32, origin at GALACTIC 137.37
    case superGalactic = "SUPER_GALACTIC"

    /// Unknown reference frame.
    ///
    /// Only to be used as a last resort or for simulations.
    /// Data annotated in this way cannot be automatically combined with any other data.
    case unknown = "UNKNOWN"

    /// Ecliptic coordinate system for the FK4 ecliptic (of B1950.0).
    case eclipticFK4 = "ecl_FK4"

    /// Ecliptic coordinate system for the FK5 ecliptic (of J2000.0).
    case eclipticFK5 = "ecl_FK5"

    /// Initialize a ReferenceFrame from a string as used in the IVOA Reference Frame Vocabulary.
    ///
    /// - Parameters:
    ///   - rawValue: The string to initialize the reference frame from as used in the
    ///     COOSYS element of a VOTable file.
    public init(rawValue: String) {
        Logger.parser.debug("Initializing ReferenceFrame from \(rawValue, privacy: .public)")
        for type in ReferenceFrame.allCases where type.rawValue == rawValue {
            self = type
            return
        }
        Logger.parser.debug("Testing deprecated types for ReferenceFrame from \(rawValue, privacy: .public)")
        // Deprecated types that have been replaced by new types
        if rawValue == "barycentric" {
            self = .icrs
        } else if rawValue == "eq_FK4" {
            self = .fk4
        } else if rawValue == "eq_FK5" {
            self = .fk5
        } else if rawValue == "galactic" {
            self = .galactic
        } else if rawValue == "supergalactic" {
            self = .superGalactic
        } else {
            self = .unknown
        }
    }

    /// Parent coordinate system of the reference frame.
    public var parent: ReferenceFrame? {
        switch self {
        case .fk4, .fk5, .icrs:
            .equatorial
        case .eclipticFK4, .eclipticFK5:
            .ecliptic
        case .galactic, .oldGalactic:
            .genericGalactic
        default:
            nil
        }
    }
}

/// Reference position of the coordinate system.
///
/// This enum is based on the IVOA Reference Position Vocabulary.
/// See https://www.ivoa.net/rdf/refposition/2019-03-15/refposition.html
public enum ReferencePosition: String, CaseIterable {
    /// The barycenter of the solar system.
    ///
    /// The center of mass of the solar system.
    case solarSystemBarycenter = "BARYCENTER"

    /// The barycenter of the Earth-Moon system.
    ///
    /// The center of mass of the Earth-Moon system.
    case earthMoonBarycenter = "EMBARYCENTER"

    /// The center of the Earth.
    case geocenter = "GEOCENTER"

    /// The center of the Sun.
    case heliocenter = "HELIOCENTER"

    /// TThe location of the instrument that made the observation
    case topocenter = "TOPOCENTER"

    /// Unknown reference position.
    ///
    /// The times cannot be transformed to a different reference position reliably.
    /// This is to be used for simulated data or for data for which the reference position has been lost.
    case unknown = "UNKNOWN"

    /// Initialize a ReferencePosition from a string as used in the IVOA Reference Position Vocabulary.
    ///
    /// - Parameters:
    ///   - rawValue: The string to initialize the reference position from as used in the
    ///     COOSYS element of a VOTable file.
    public init(rawValue: String) {
        for type in ReferencePosition.allCases where type.rawValue == rawValue {
            self = type
            return
        }
        self = .unknown
    }
}

/// This structure defines a celestial coordinate system, to which the components of a position on the
/// celestial sphere refer.
public struct VOCoordinateSystem: CustomStringConvertible {
    /// The identifier of the coordinate system.
    public var id: String?

    /// The reference frame of the coordinate system.
    public var system: ReferenceFrame?

    /// The equinox of the coordinate system.
    public var equinox: Date?

    /// The epoch of the coordinate system.
    public var epoch: Date?

    /// The reference position of the coordinate system.
    public var referencePosition: ReferencePosition?

    public var description: String {
        """
        Coordinate system [\(id ?? "nil")]:
        - System:                  \(system?.rawValue ?? "nil")
        - Equinox:                 \(equinox?.description ?? "nil")
        - Epoch:                   \(epoch?.description ?? "nil")
        - Reference position:      \(referencePosition?.rawValue ?? "nil")
        """
    }
}
