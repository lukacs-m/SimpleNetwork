//
//  CRUDRequestMethod.swift
//  
//
//  Created by Martin Lukacs on 15/01/2023.
//

/**
 The `CRUDRequestMethod` is an enumeration of the various HTTP methods that can be used for performing CRUD (Create, Read, Update, Delete) operations on a web server. It is defined as a public enumeration that conforms to the String protocol.
 
 This enumeration defines the following five cases:
 
 `delete`: Represents the HTTP DELETE method, which is used to delete a resource on the server.
 `get`: Represents the HTTP GET method, which is used to retrieve a resource from the server.
 `patch`: Represents the HTTP PATCH method, which is used to partially update a resource on the server.
 `post`: Represents the HTTP POST method, which is used to create a new resource on the server.
 `put`: Represents the HTTP PUT method, which is used to replace an existing resource on the server.
 
Each case is associated with a String value that represents the HTTP method it represents.
 */
public enum CRUDRequestMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}
