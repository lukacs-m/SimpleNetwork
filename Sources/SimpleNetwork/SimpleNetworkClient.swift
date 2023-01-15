//
//  SimpleNetworkClient.swift
//  
//
//  Created by Martin Lukacs on 15/01/2023.
//

import Foundation

public final class SimpleNetworkClient: Sendable, SimpleClientImplementing {
    public let session: URLSession
    public let decoder: JSONDecoder

    public init(session: URLSession = URLSession.shared,
                decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
}
