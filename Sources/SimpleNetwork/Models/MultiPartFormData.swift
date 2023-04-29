//
//  MultiPartFormData.swift
//  
//
//  Created by Martin Lukacs on 05/03/2023.
//

import Foundation

public struct MultiPartFormData: Sendable {
    public let data: Data
    public let name: String
    public let mimeType: String
    public let fileName: String
    
    public init(data: Data, name: String, mimeType: String, fileName: String) {
        self.data = data
        self.name = name
        self.mimeType = mimeType
        self.fileName = fileName
    }
}
