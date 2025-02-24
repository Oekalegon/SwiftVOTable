import Foundation

public enum VOTableError: Error {
    case parsingFailed(String)
}

public enum DateError: Error {
    case invalidEpoch(String)
}
