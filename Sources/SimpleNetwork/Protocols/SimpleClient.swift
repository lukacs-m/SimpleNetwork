//
//  SimpleClient.swift
//
//
//  Created by Martin Lukacs on 15/01/2023.
//

import Combine
import Foundation

/**
 This protocol defines the basic functionality of a simple network client.
 
 Clients that conform to this protocol can make HTTP requests, decode the response into a specified `Decodable` type, or return non-decodable types, such as `Data` or `Void`.
 
 This protocol inherits from the `Sendable` protocol, which is used int the new swift structured concurrency.
 */
public protocol SimpleClient: AnyObject, Sendable {
    /// The URL session used to make HTTP requests.
    var session: URLSession { get }
    /// The JSON decoder used to decode HTTP responses.
    var decoder: JSONDecoder { get }
    
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
    func request<ReturnedType: Decodable>(endpoint: any Endpoint) -> AnyPublisher<ReturnedType, Error>
    
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
    func requestNonDecodable<ReturnedType>(endpoint: any Endpoint) -> AnyPublisher<ReturnedType, Error>
}

/**
 An extension to the `SimpleClientImplementing` protocol that provides default implementations of the `request` and `requestNonDecadable` methods.
 */
public extension SimpleClient {
    /**
     Sends an HTTP request and decodes the response into the specified `Decodable` type.
     
     - Parameters:
        - endpoint: The endpoint to send the request to. It is of type ``Endpoint``
     
     - Returns: An instance of the specified `Decodable` type, parsed from the response data.
     - Throws: If the request fails or the response cannot be decoded into the specified type.
     */
    func request<ReturnedType: Decodable>(endpoint: any Endpoint) async throws -> ReturnedType {
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
    func request<ReturnedType: Decodable>(endpoint: any Endpoint) -> AnyPublisher<ReturnedType, Error> {
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
    func requestNonDecodable<ReturnedType>(endpoint: any Endpoint) async throws -> ReturnedType {
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
    func requestNonDecodable<ReturnedType>(endpoint: any Endpoint) -> AnyPublisher<ReturnedType, Error> {
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
