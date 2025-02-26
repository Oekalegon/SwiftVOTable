import Foundation
import OSLog

/// The time scale of the time system.
///
/// This enum is based on the IVOA Time Scale Vocabulary.
/// See https://www.ivoa.net/rdf/timescale/2019-03-15/timescale.html
public enum TimeScale: String, CaseIterable {
    /// Global Positioning System Time.
    ///
    /// Runs (approximately) synchronously with TAI
    case globalPositioningSystemTime = "GPS"

    /// International Atomic Time.
    ///
    /// Atomic time standard, TT-TAI = 32.184 s.
    case internationalAtomicTime = "TAI"

    /// Barycentric Coordinate Time.
    ///
    /// Derived from TCG, but taking into account the relativistic effects
    /// of the gravitational potential at the barycenter as well as velocity
    /// time dilation variations due to the eccentricity of the Earth’s orbit.
    /// See 1999A&A...348..642I for details.
    case barycentricCoordinateTime = "TCB"

    /// Geocentric Coordinate Time.
    ///
    /// Time measured by a clock moving with the Earth's center but not subject
    /// to the gavitational potential of the Earth.
    case geocentricCoordinateTime = "TCG"

    /// Barycentric Dynamical Time.
    ///
    /// Runs slower than TCB at a constant rate so as to remain approximately
    /// in step with TT.
    /// Therefore runs quasi-synchronously with TT, except for the relativistic effects
    /// introduced by variations in the Earth’s velocity relative to the barycenter.
    case barycentricDynamicalTime = "TDB"

    /// Terrestrial Time.
    ///
    /// Time measured by a continuous clock on the surface of an ideal Earth.
    /// Defined via TCG as having been idential on 1977-01-01 and since running
    /// slower than it by an empirically determined factor L_C. It is continuous
    /// with the ephemeris time ET widely used before 1984-01-01. The term TT should
    /// therefore be used for times in ET, too. (IAU standard)
    case terrestrialTime = "TT"

    /// Universal Time.
    ///
    /// We do not distinguish between UT0, UT1, and UT2. Applications requiring
    /// this level of precision need additional metadata. This should also be
    /// used to label GMT times in datasets covering dates between 1925-01-01
    /// and 1972-01-01. GMT in astronomical use before 1925 had a 12 hour offset
    /// and would require a new term.
    case universalTime = "UT"

    /// Universal Time Coordinated.
    ///
    /// This is TAI, with leap seconds inserted occasionally in order to keep UTC
    /// within 0.9 s of UT1 (a different convention was in use before 1972-01-01).
    case univesalTimeCoordinated = "UTC"

    /// Unknown time scale.
    case unknown = "UNKNOWN"
}

/// This structure defines metadata about the time system for temporal coordinates.
///
/// This structure is based on the IVOA TIMESYS element of the VOTable specification.
/// See https://www.ivoa.net/documents/VOTable/20250116/REC-VOTable-1.5.html#tth_sEc3.4
public struct VOTimeSystem: CustomStringConvertible {
    /// The identifier of the time system.
    public let id: String?

    /// The time origin of the time system.
    public let timeOrigin: Date?

    /// The time scale of the time system.
    public let timeScale: TimeScale?

    /// The reference position of the time system.
    public let referencePosition: ReferencePosition?

    /// A description of the time system.
    public var description: String {
        """
        Time system [\(id ?? "nil")]:
        - Time origin:      \(timeOrigin?.description ?? "nil")
        - Time scale:      \(timeScale?.rawValue ?? "nil")
        - Reference position:      \(referencePosition?.rawValue ?? "nil")
        """
    }
}
