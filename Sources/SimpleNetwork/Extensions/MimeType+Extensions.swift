//
//  MimeType+Extensions.swift
//  
//
//  Created by Martin Lukacs on 05/03/2023.
//

import Foundation
import UniformTypeIdentifiers

public extension NSURL {
    var mimeType: String {
        if let pathExt = self.pathExtension,
            let mimeType = UTType(filenameExtension: pathExt)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
}

public extension URL {
    var mimeType: String {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
}

public extension NSString {
    var mimeType: String  {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
}

public extension String {
    var mimeType: String  {
        return (self as NSString).mimeType
    }
}
