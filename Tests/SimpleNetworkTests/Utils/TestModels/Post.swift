//
//  Post.swift
//  
//
//  Created by Martin Lukacs on 06/03/2023.
//

import Foundation

// MARK: - Post
struct Post: Codable {
    let id: Int
    let title, body: String
    let userID: Int

    enum CodingKeys: String, CodingKey {
        case id, title, body
        case userID = "userId"
    }
}

typealias Posts = [Post]
