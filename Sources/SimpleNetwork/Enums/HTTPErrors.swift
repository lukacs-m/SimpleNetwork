//
//  HTTPErrors.swift
//  
//
//  Created by Martin Lukacs on 15/01/2023.
//

import Foundation

/**
 The `HTTPErrors` enumeration is a Swift enumeration that conforms to the Error protocol.
 It is used to represent HTTP errors that can occur when making network calls.
 */
public enum HTTPErrors: Error {
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case internalServerError
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case unknown

    public var message: String {
        switch self {
        case .badRequest:
            return "Bad request."
        case .unauthorized:
            return "Unauthorized network call"
        case .forbidden:
            return "Fordidden network call"
        case .notFound:
            return "Endpoint not found"
        case .internalServerError:
            return "Serveur not recheable"
        case .badGateway:
            return "Bad gateway"
        case .serviceUnavailable:
            return "Service unavailable"
        case .gatewayTimeout:
            return "Gateway timeout"
        default:
            return "Unknown error"
        }
    }

    public static func error(for statusCode: Int) -> HTTPErrors {
        switch statusCode {
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 500:
            return .internalServerError
        case 502:
            return .badGateway
        case 503:
            return .serviceUnavailable
        case 504:
            return .gatewayTimeout
        default:
            return .unknown
        }
    }
}
