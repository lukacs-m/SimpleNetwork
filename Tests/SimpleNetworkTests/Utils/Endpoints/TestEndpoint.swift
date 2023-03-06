//
//  TestEndpoint.swift
//  
//
//  Created by Martin Lukacs on 06/03/2023.
//

import Foundation
@testable import SimpleNetwork

enum TestEndpoint {
    case getPosts
    case createPost
    case updatePost
    case patchPost
    case deletePost
}

extension TestEndpoint: Endpoint {
    var baseUrl: String? {
        "https://jsonplaceholder.typicode.com"
    }
    
    var path: String {
        switch self {
        case .getPosts, .createPost:
            return "/posts"
        case .updatePost, .patchPost, .deletePost:
            return "/posts/1"
        }
    }
    
    var method: CRUDRequestMethod {
        switch self {
        case .getPosts:
            return .get
        case .createPost:
            return .post
        case .updatePost:
            return .put
        case .patchPost:
            return .patch
        case .deletePost:
            return .delete
        }
    }
    
    var header: [String: String]? {
        switch self {
        default:
            return [
                "Content-type": "application/json; charset=UTF-8"
            ]
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .createPost:
            return [
                "title": "Title test",
                "body": "this is the body test",
                "userId": 42,
            ]
        case .updatePost:
            return [
                "id": "1",
                "title": "Title is test updated",
                "body": "this is the body test updated",
                "userId": 45,
            ]
        case .patchPost:
            return [
                "title": "Title test new",
            ]
        default:
            return nil
        }
    }
}
