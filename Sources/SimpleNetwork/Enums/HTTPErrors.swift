//
//  HTTPErrors.swift
//  
//
//  Created by Martin Lukacs on 15/01/2023.
//

import Foundation

enum HTTPErrors: Error {
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case internalServerError
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case unknown

    var message: String {
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

    static func error(for statusCode: Int) -> HTTPErrors {
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
