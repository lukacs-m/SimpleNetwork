//
//  ComplexeEndpoint.swift
//  
//
//  Created by Martin Lukacs on 06/03/2023.
//

import Foundation
@testable import SimpleNetwork

enum ComplexeEndpoint {
    case multipart(data: [MultiPartFormData])
}

extension ComplexeEndpoint: Endpoint {
    var header: [String : String]? {
        nil
    }
    
    var body: [String : Any]? {
        nil
    }
    
    var baseUrl: String? {
        "https://httpbin.org"
    }
    
    var path: String {
        switch self {
        case .multipart:
            return "/post"
        }
    }
    
    var method: CRUDRequestMethod {
        switch self {
        case .multipart:
            return .post
        }
    }
    
    var multiPartData: [MultiPartFormData]? {
        switch self {
        case .multipart(let dataPath):
           return dataPath
        }
    }
}
