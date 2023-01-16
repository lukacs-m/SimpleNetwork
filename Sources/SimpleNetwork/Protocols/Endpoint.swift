//
//  Endpoint.swift
//  
//
//  Created by Martin Lukacs on 15/01/2023.
//

import Foundation

public protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var baseUrl: String? { get }
    var method: CRUDRequestMethod { get }
    var header: [String: String]? { get }
    var body: [String: String]? { get }
}

public extension Endpoint {
    var scheme: String {
        "https"
    }

    var request: URLRequest? {
        guard let url = endpointUrl else {
            return nil
        }

        let finalUrl = method != .get ? url : url.getURLWithParams(params: body)
        var request = URLRequest(url: finalUrl)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = header

        if let body = body, method != .get {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        return request
    }
    
    private var endpointUrl: URL? {
        if let baseUrl = baseUrl {
            return URL(string: "\(baseUrl)\(path)")
        }
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        return urlComponents.url
    }
}

private extension URL {
    func getURLWithParams(params: [String: Any]?) -> URL {
        guard let params else {
            return self
        }
        if var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            var queryItems = urlComponents.queryItems ?? [URLQueryItem]()
            params.forEach { param in
                if let array = param.value as? [CustomStringConvertible] {
                    array.forEach {
                        queryItems.append(URLQueryItem(name: "\(param.key)[]", value: "\($0)"))
                    }
                }
                queryItems.append(URLQueryItem(name: param.key, value: "\(param.value)"))
            }
            urlComponents.queryItems = queryItems
            return urlComponents.url ?? self
        }
        return self
    }
}
