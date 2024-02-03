//
//  Endpoint.swift
//  
//
//  Created by Martin Lukacs on 15/01/2023.
//

import Foundation

/// The `Endpoint` protocol defines the properties and methods required to create an HTTP endpoint.
public protocol Endpoint: Sendable {
    /// The scheme of the endpoint, such as `http` or `https`.
    var scheme: String { get }

    /// The host of the endpoint, such as `example.com`.
    var host: String { get }

    /// The path of the endpoint, such as `/api/v1/users`.
    var path: String { get }

    /// Determines if the endpoint should be authenticated or not
    var isAuthencated: Bool { get }

    /// The base URL of the endpoint, such as `https://example.com`.
    var baseUrl: String? { get }
    
    /// The HTTP method used for the endpoint, such as `.get` or `.post`.
    var method: CRUDRequestMethod { get }
    
    /// The headers to be sent with the request.
    var header: [String: String]? { get }
    
    /// The body of the request, if any.
    var body: [String: Any]? { get }
    
    var multiPartData: [MultiPartFormData]? { get }
}

public extension Endpoint {
    /// The default scheme for the endpoint, which is `https`.
    var scheme: String {
        "https"
    }

    /// The default host for the endpoint, which is an empty string.
    var host: String {
        ""
    }

    var isAuthencated: Bool {
        false
    }

    /// The default base URL for the endpoint, which is `nil`.
    var baseUrl: String? {
        nil
    }
    
    var multiPartData: [MultiPartFormData]? {
        nil
    }
    
    var header: [String: String]? {
        nil
    }

    var body: [String: Any]?  {
        nil
    }
    
    /// The `URLRequest` object created from the endpoint.
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
        } else if let multiPartData = multiPartData, method != .get {
            let boundary = UUID().uuidString
            let httpBody = createMultiPartFormDataBody(with: multiPartData, boundary: boundary)
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
        }
        return request
    }
}

// MARK: - Utils
extension Endpoint {
    /// The URL created from the endpoint.
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
    
    private func createMultiPartFormDataBody(with formData: [MultiPartFormData], boundary: String) -> Data {
           var body = Data()
           
           for form in formData {
               body.appendString("--\(boundary)\r\n")
               body.appendString("Content-Disposition: \(form.contentDisposition)\r\n")
               body.appendString("Content-Type: \(form.mimeType)\r\n\r\n")
               body.append(form.data)
               body.appendString("\r\n")
           }
           
           body.appendString("--\(boundary)--\r\n")
           
           return body
       }
}

// MARK: - Utils Elements Extensions
private extension URL {
    /// Creates a URL with query parameters from the given dictionary.
    ///
    /// - Parameter params: The dictionary of query parameters to add to the URL.
    ///
    /// - Returns: A new URL object with the query parameters added.
    func getURLWithParams(params: [String: Any]?) -> URL {
        guard let params else {
            return self
        }
        if var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            var queryItems = urlComponents.queryItems ?? [URLQueryItem]()
            params.forEach { param in
                if let array = param.value as? [any CustomStringConvertible] {
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

private extension MultiPartFormData {
    var contentDisposition: String {
         return "form-data; name=\"\(name)\"; filename=\"\(fileName)\""
     }
}

private extension Data {
    mutating func appendString(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        append(data)
    }
}
