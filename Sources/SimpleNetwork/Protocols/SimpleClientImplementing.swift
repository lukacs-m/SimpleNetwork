//
//  SimpleClientImplementing.swift
//  
//
//  Created by Martin Lukacs on 15/01/2023.
//

import Combine
import Foundation

public protocol SimpleClientImplementing: AnyObject, Sendable {
    var session: URLSession { get }
    var decoder: JSONDecoder { get }
    
    func request<ReturnedType: Decodable>(endpoint: Endpoint) async throws -> ReturnedType
    func request<ReturnedType: Decodable>(endpoint: Endpoint) -> AnyPublisher<ReturnedType, Error>
    func requestNonDecadable<ReturnedType>(endpoint: Endpoint) async throws -> ReturnedType
}

public extension SimpleClientImplementing {
    func request<ReturnedType: Decodable>(endpoint: Endpoint) async throws -> ReturnedType {
        guard let request = endpoint.request else {
            throw RequestError.invalidURL
        }
        do {
            let (data, response) = try await session.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                throw RequestError.noResponse
            }
            switch response.statusCode {
            case 200...299:
                guard let decodedResponse = try? decoder.decode(ReturnedType.self, from: data) else {
                    throw RequestError.decode
                }
                return decodedResponse
            default:
                throw HTTPErrors.error(for: response.statusCode)
            }
        } catch {
            throw error
        }
    }

    func request<ReturnedType: Decodable>(endpoint: Endpoint) -> AnyPublisher<ReturnedType, Error> {
        Deferred {
            Future { promise in
                Task { [weak self] in
                    guard let self else {
                        promise(.failure(RequestError.unknown))
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
    
    func requestNonDecadable<ReturnedType>(endpoint: Endpoint) async throws -> ReturnedType {
        guard let request = endpoint.request else {
            throw RequestError.invalidURL
        }
        do {
            let (data, response) = try await session.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                throw RequestError.noResponse
            }
            switch response.statusCode {
            case 200...299:
                if ReturnedType.self is Void.Type {
                    return Void() as! ReturnedType
                } else if ReturnedType.self is Data.Type {
                    return data as! ReturnedType
                }
                guard let returnObject = try JSONSerialization.jsonObject(with: data, options: []) as? ReturnedType else {
                    throw RequestError.mismatchErrorInReturnType
                }
                
                return returnObject
            default:
                throw HTTPErrors.error(for: response.statusCode)
            }
        } catch {
            throw error
        }
    }
}
