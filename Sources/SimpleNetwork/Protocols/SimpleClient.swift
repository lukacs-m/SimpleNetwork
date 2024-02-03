//
//  SimpleClient.swift
//
//
//  Created by Martin Lukacs on 15/01/2023.
//

import Combine
import Foundation
import SimpleKeychain

public protocol AuthentificationServicing<ReturnedType>: Sendable {
    associatedtype ReturnedType: Sendable

    func authentification() async throws -> ReturnedType

    func refresh() async throws -> ReturnedType
}

enum AuthError: Error {
    case missingToken
}
actor AuthManager: AuthentificationServicing {
    typealias ReturnedType = Sendable
    private let keychainService: any KeychainServicing

    init(keychainService: any KeychainServicing = SimpleKeychain()) {
        self.keychainService = keychainService
    }

//    private var currentToken: Token?
    private var refreshTask: Task<any ReturnedType, any Error>?

//    func validToken() async throws -> Token {
//
//    }
//
//    func refreshToken() async throws -> Token {
//
//    }

    func authentification<ReturnedType: Sendable>() async throws -> ReturnedType {
        if let handle = refreshTask {
            return try await handle.value as! ReturnedType
        }


            guard let token = currentToken else {
                throw AuthError.missingToken
            }

            if token.isValid {
                return token
            }

            return try await refresh()
    }

    func refresh<ReturnedType: Sendable>() async throws -> ReturnedType {
        if let refreshTask = refreshTask {
               return try await refreshTask.value
           }

           let task = Task { () throws -> ReturnedType in
               defer { refreshTask = nil }

               // Normally you'd make a network call here. Could look like this:
               // return await networking.refreshToken(withRefreshToken: token.refreshToken)

               // I'm just generating a dummy token
               let tokenExpiresAt = Date().addingTimeInterval(10)
               let newToken = Token(validUntil: tokenExpiresAt, id: UUID())
               currentToken = newToken

               return newToken
           }

           self.refreshTask = task

           return try await task.value
    }
}

if let existingTask = roverActiveTasks[rover.rawValue] {
    return try await existingTask.value
}

let task = Task<Rover, any Error> {
    if let cachedRover = await roverCache.value(forKey: rover.rawValue) {
        roverActiveTasks[rover.rawValue] = nil
        return cachedRover
    }

    do {
        let infos: RoverInfos = try await networkClient.request(endpoint: MarsMissionEndpoint.rover(id: rover.rawValue))
        await roverCache.insert(infos.rover, forKey: rover.rawValue)
        roverActiveTasks[rover.rawValue] = nil
        return infos.rover
    } catch {
        roverActiveTasks[rover.rawValue] = nil
        throw error
    }
}

roverActiveTasks[rover.rawValue] = task

return try await task.value


/**
 This protocol defines the basic functionality of a simple network client.
 
 Clients that conform to this protocol can make HTTP requests, decode the response into a specified `Decodable` type, or return non-decodable types, such as `Data` or `Void`.
 
 This protocol inherits from the `Sendable` protocol, which is used int the new swift structured concurrency.
 */
public protocol SimpleClient: AnyObject, Sendable {
//    /// The URL session used to make HTTP requests.
//    var session: URLSession { get }
//    /// The JSON decoder used to decode HTTP responses.
//    var decoder: JSONDecoder { get }
//

    /**
     Sends an HTTP request and decodes the response into the specified `Decodable` type.
     
     - Parameters:
        - endpoint: The endpoint to send the request to. It is of type ``Endpoint``
     
     - Returns: An instance of the specified `Decodable` type, parsed from the response data.
     - Throws: If the request fails or the response cannot be decoded into the specified type.
     */
    func request<ReturnedType: Decodable>(endpoint: any Endpoint) async throws -> ReturnedType
    
    /**
     Sends an HTTP request and returns a publisher that emits an instance of the specified `Decodable` type.
     
     - Parameters:
        - endpoint: The endpoint to send the request to. It is of type ``Endpoint``
     
     - Returns: A publisher that emits an instance of the specified `Decodable` type, parsed from the response data.
     */
    func request<ReturnedType: Decodable>(endpoint: any Endpoint) -> AnyPublisher<ReturnedType, any Error>
    
    /**
     Sends an HTTP request and returns the response data as a non-decodable type.
     
     - Parameters:
        - endpoint: The endpoint to send the request to. It is of type ``Endpoint``
     
     - Returns: The response data, returned as an instance of the specified non-decodable type.
     - Throws: If the request fails or the response cannot be parsed into the specified non-decodable type.
     */
    func requestNonDecodable<ReturnedType>(endpoint: any Endpoint) async throws -> ReturnedType
    
    /**
     Sends an HTTP request and returns a publisher that emits an instance of the specified non-decodable type.

     - Parameters:
        - endpoint: ``Endpoint``: The endpoint to send the request to.
     - Returns: A publisher that emits an instance of the specified non-decodable type, parsed from the response data.
     */
    func requestNonDecodable<ReturnedType>(endpoint: any Endpoint) -> AnyPublisher<ReturnedType, any Error>
}

/**
 An extension to the `SimpleClientImplementing` protocol that provides default implementations of the `request` and `requestNonDecadable` methods.
 */
//public extension SimpleClient {
//    /**
//     Sends an HTTP request and decodes the response into the specified `Decodable` type.
//     
//     - Parameters:
//        - endpoint: The endpoint to send the request to. It is of type ``Endpoint``
//     
//     - Returns: An instance of the specified `Decodable` type, parsed from the response data.
//     - Throws: If the request fails or the response cannot be decoded into the specified type.
//     */
//    func request<ReturnedType: Decodable>(endpoint: any Endpoint) async throws -> ReturnedType {
//        guard let request = endpoint.request else {
//            throw RequestErrors.invalidURL
//        }
//        do {
//            let (data, response) = try await session.data(for: request, delegate: nil)
//            guard let response = response as? HTTPURLResponse else {
//                throw RequestErrors.noResponse
//            }
//            
//            guard 200...299 ~= response.statusCode else {
//                throw HTTPErrors.error(for: response.statusCode)
//            }
//            
//            guard let decodedResponse = try? decoder.decode(ReturnedType.self, from: data) else {
//                throw RequestErrors.decode
//            }
//            
//            return decodedResponse
//        } catch {
//            throw error
//        }
//    }
//    
//    /**
//     Sends an HTTP request and returns a publisher that emits an instance of the specified `Decodable` type.
//     
//     - Parameters:
//        - endpoint: The endpoint to send the request to. It is of type ``Endpoint``
//     
//     - Returns: A publisher that emits an instance of the specified `Decodable` type, parsed from the response data.
//     */
//    func request<ReturnedType: Decodable & Sendable>(endpoint: any Endpoint) -> AnyPublisher<ReturnedType, any Error> {
//        Deferred {
//            Future { promise in
//                Task { [weak self] in
//                    guard let self else {
//                        promise(.failure(RequestErrors.unknown))
//                        return
//                    }
//                    do {
//                        let result: ReturnedType = try await self.request(endpoint: endpoint)
//                        promise(.success(result))
//                    } catch {
//                        promise(.failure(error))
//                    }
//                }
//            }
//        }.eraseToAnyPublisher()
//    }
//    
//    // MARK: - Non decodable reponse
//    /**
//     Sends an HTTP request and returns the response data as a non-decodable type.
//     
//     - Parameters:
//        - endpoint: The endpoint to send the request to. It is of type ``Endpoint``
//     
//     - Returns: The response data, returned as an instance of the specified non-decodable type.
//     - Throws: If the request fails or the response cannot be parsed into the specified non-decodable type.
//     */
//    func requestNonDecodable<ReturnedType>(endpoint: any Endpoint) async throws -> ReturnedType {
//        guard let request = endpoint.request else {
//            throw RequestErrors.invalidURL
//        }
//        do {
//            let (data, response) = try await session.data(for: request, delegate: nil)
//            guard let response = response as? HTTPURLResponse else {
//                throw RequestErrors.noResponse
//            }
//            guard 200...299 ~= response.statusCode else {
//                throw HTTPErrors.error(for: response.statusCode)
//            }
//            
//            if ReturnedType.self is Void.Type {
//                return Void() as! ReturnedType
//            } else if ReturnedType.self is Data.Type {
//                return data as! ReturnedType
//            }
//            
//            guard let returnObject = try JSONSerialization.jsonObject(with: data, options: []) as? ReturnedType else {
//                throw RequestErrors.mismatchErrorInReturnType
//            }
//            
//            return returnObject
//        } catch {
//            throw error
//        }
//    }
//    
//    /**
//     Sends an HTTP request and returns a publisher that emits an instance of the specified non-decodable type.
//
//     - Parameters:
//        - endpoint: ``Endpoint`: The endpoint to send the request to.
//     - Returns: A publisher that emits an instance of the specified non-decodable type, parsed from the response data.
//     */
//    func requestNonDecodable<ReturnedType>(endpoint: any Endpoint) -> AnyPublisher<ReturnedType, any Error> {
//        Deferred {
//            Future { promise in
//                Task { [weak self] in
//                    guard let self else {
//                        promise(.failure(RequestErrors.unknown))
//                        return
//                    }
//                    do {
//                        let result: ReturnedType = try await self.requestNonDecodable(endpoint: endpoint)
//                        promise(.success(result))
//                    } catch {
//                        promise(.failure(error))
//                    }
//                }
//            }
//        }.eraseToAnyPublisher()
//    }
//}

private func authorizedRequest(from url: URL) async throws -> URLRequest {
       var urlRequest = URLRequest(url: url)
       let token = try await authManager.validToken()
       urlRequest.setValue("Bearer \(token.value)", forHTTPHeaderField: "Authorization")
       return urlRequest
   }

func loadAuthorized<T: Decodable>(_ url: URL, allowRetry: Bool = true) async throws -> T {
    let request = try await authorizedRequest(from: url)
    let (data, urlResponse) = try await URLSession.shared.data(for: request)

    // check the http status code and refresh + retry if we received 401 Unauthorized
    if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 401 {
        if allowRetry {
            _ = try await authManager.refreshToken()
            return try await loadAuthorized(url, allowRetry: false)
        }

        throw AuthError.invalidToken
    }

    let decoder = JSONDecoder()
    let response = try decoder.decode(T.self, from: data)

    return response
}
