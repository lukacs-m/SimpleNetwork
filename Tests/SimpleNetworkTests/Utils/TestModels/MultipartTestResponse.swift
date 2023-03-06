//
//  MultipartTestResponse.swift
//  
//
//  Created by Martin Lukacs on 06/03/2023.
//

import Foundation

// MARK: - TestResponse
struct MultipartTestResponse: Codable {
    let data: String
    let files: Files

    enum CodingKeys: String, CodingKey {
        case data, files
    }
}

// MARK: - Files
struct Files: Codable {
    let testFile: String
}
