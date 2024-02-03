//
//  SimpleNetworkClient.swift
//  
//
//  Created by Martin Lukacs on 15/01/2023.
//

import Combine
import Foundation

public final class SimpleNetworkClient: SimpleClient {

    private let authService: (any AuthentificationServicing)?
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = URLSession.shared,
                decoder: JSONDecoder = JSONDecoder(),
                authService: (any AuthentificationServicing)? = nil) {
        self.session = session
        self.decoder = decoder
        self.authService = authService
    }

    /**
     Sends an HTTP request and decodes the response into the specified `Decodable` type.

     - Parameters:
        - endpoint: The endpoint to send the request to. It is of type ``Endpoint``

     - Returns: An instance of the specified `Decodable` type, parsed from the response data.
     - Throws: If the request fails or the response cannot be decoded into the specified type.
     */
    public func request<ReturnedType: Decodable>(endpoint: any Endpoint) async throws -> ReturnedType {
        guard let request = endpoint.request else {
            throw RequestErrors.invalidURL
        }
        do {
            let (data, response) = try await session.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                throw RequestErrors.noResponse
            }

            guard 200...299 ~= response.statusCode else {
                throw HTTPErrors.error(for: response.statusCode)
            }

            guard let decodedResponse = try? decoder.decode(ReturnedType.self, from: data) else {
                throw RequestErrors.decode
            }

            return decodedResponse
        } catch {
            throw error
        }
    }

    /**
     Sends an HTTP request and returns a publisher that emits an instance of the specified `Decodable` type.

     - Parameters:
        - endpoint: The endpoint to send the request to. It is of type ``Endpoint``

     - Returns: A publisher that emits an instance of the specified `Decodable` type, parsed from the response data.
     */
    public func request<ReturnedType: Decodable & Sendable>(endpoint: any Endpoint) -> AnyPublisher<ReturnedType, any Error> {
        Deferred {
            Future { promise in
                Task { [weak self] in
                    guard let self else {
                        promise(.failure(RequestErrors.unknown))
                        return
                    }
                    do {
                        let result: ReturnedType = try await self.request(endpoint: endpoint)
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    // MARK: - Non decodable reponse
    /**
     Sends an HTTP request and returns the response data as a non-decodable type.

     - Parameters:
        - endpoint: The endpoint to send the request to. It is of type ``Endpoint``

     - Returns: The response data, returned as an instance of the specified non-decodable type.
     - Throws: If the request fails or the response cannot be parsed into the specified non-decodable type.
     */
    public func requestNonDecodable<ReturnedType>(endpoint: any Endpoint) async throws -> ReturnedType {
        guard let request = endpoint.request else {
            throw RequestErrors.invalidURL
        }
        do {
            let (data, response) = try await session.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                throw RequestErrors.noResponse
            }
            guard 200...299 ~= response.statusCode else {
                throw HTTPErrors.error(for: response.statusCode)
            }

            if ReturnedType.self is Void.Type {
                return Void() as! ReturnedType
            } else if ReturnedType.self is Data.Type {
                return data as! ReturnedType
            }

            guard let returnObject = try JSONSerialization.jsonObject(with: data, options: []) as? ReturnedType else {
                throw RequestErrors.mismatchErrorInReturnType
            }

            return returnObject
        } catch {
            throw error
        }
    }

    /**
     Sends an HTTP request and returns a publisher that emits an instance of the specified non-decodable type.

     - Parameters:
        - endpoint: ``Endpoint`: The endpoint to send the request to.
     - Returns: A publisher that emits an instance of the specified non-decodable type, parsed from the response data.
     */
    public func requestNonDecodable<ReturnedType>(endpoint: any Endpoint) -> AnyPublisher<ReturnedType, any Error> {
        Deferred {
            Future { promise in
                Task { [weak self] in
                    guard let self else {
                        promise(.failure(RequestErrors.unknown))
                        return
                    }
                    do {
                        let result: ReturnedType = try await self.requestNonDecodable(endpoint: endpoint)
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
