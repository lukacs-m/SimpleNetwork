//
//  RequestErrors.swift
//
//
//  Created by Martin Lukacs on 15/01/2023.
//

/**
 The `RequestErrors` enumeration is a Swift enumeration that conforms to the Error protocol.
 It is used to represent errors that can occur when making network requests.
 */
public enum RequestErrors: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode
    case unknown
    case mismatchErrorInReturnType

    public var customMessage: String {
        switch self {
        case .decode:
            return "Decode error"
        case .unauthorized:
            return "Session expired"
        default:
            return "Unknown error"
        }
    }
}
