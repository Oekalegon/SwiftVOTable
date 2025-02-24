import Foundation

public extension Date {
    /// The Julian Date of the epoch 1970-01-01 00:00:00, i.e. the
    /// time origin of the Swift Date type.
    private static let jdEpoch1970 = 2_440_587.500000
    private static let jd2000 = 2_451_545.0
    private static let jd1900 = 2_415_020.31352

    /// The duration of the Julian year in days.
    private static let julianYearDuration = 365.25

    /// The duration of the Besselian year in days.
    private static let besselianYearDuration = 365.242198781

    /// The Julian Date
    var julianDate: Double {
        timeIntervalSince1970 / 86400.0 + Date.jdEpoch1970
    }

    /// The Modified Julian Date
    var modifiedJulianDate: Double {
        julianDate - 2_400_000.5
    }

    /// The Besselian Epoch
    var besselianEpoch: Double {
        1900.0 + (self.julianDate - Date.jd1900) / Date.besselianYearDuration
    }

    /// The Julian Epoch
    var julianEpoch: Double {
        2000.0 + (self.julianDate - 2_451_545.0) / Date.julianYearDuration
    }

    /// Initialize a date from a Julian Date
    ///
    /// - Parameter julianDate: The Julian Date.
    init(julianDate: Double) {
        self.init(timeIntervalSince1970: (julianDate - Date.jdEpoch1970) * 86400.0)
    }

    /// Initialize a date from a Modified Julian Date
    ///
    /// - Parameter modifiedJulianDate: The Modified Julian Date.
    init(modifiedJulianDate: Double) {
        self.init(julianDate: modifiedJulianDate + 2_400_000.5)
    }

    /// Initialize a date from a Besselian Epoch
    ///
    /// - Parameter besselianEpoch: The Besselian Epoch in Besselian years.
    init(besselianEpoch: Double) {
        let juliandDate = Date.jd1900 + (besselianEpoch - 1900.0) * Date.besselianYearDuration
        self.init(timeIntervalSince1970: (juliandDate - Date.jdEpoch1970) * 86400.0)
    }

    /// Initialize a date from a Julian Epoch
    ///
    /// - Parameter julianEpoch: The Julian Epoch in Julian years.
    init(julianEpoch: Double) {
        let juliandDate = Date.jd2000 + (julianEpoch - 2000.0) * Date.julianYearDuration
        self.init(timeIntervalSince1970: (juliandDate - Date.jdEpoch1970) * 86400.0)
    }

    /// Initialize a date from an epoch string like "B1950.0" or "J2000.0".
    ///
    /// - Parameter epoch: The epoch string.
    /// - Throws: `DateError.invalidEpoch` if the epoch string is not valid.
    init(epoch: String) throws {
        if epoch.starts(with: "B") {
            guard let besselianEpoch = Double(epoch.dropFirst()) else {
                throw DateError.invalidEpoch(epoch)
            }
            self.init(besselianEpoch: besselianEpoch)
        } else if epoch.starts(with: "J") {
            guard let julianEpoch = Double(epoch.dropFirst()) else {
                throw DateError.invalidEpoch(epoch)
            }
            self.init(julianEpoch: julianEpoch)
        } else {
            throw DateError.invalidEpoch(epoch)
        }
    }
}
