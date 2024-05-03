//
//  File.swift
//  
//
//  Created by Batuhan Küçükyıldız on 24.04.2024.
//

import Foundation

public enum NetworkError: LocalizedError {
    case jsonDecoderError(description: String)
    case authenticationError(description: String)
    case badRequest(description: String)
    case networkError(description: String)
    case invalidResponse(description: String)

    public var errorDescription: String? {
        switch self {
        case let .jsonDecoderError(description),
             let .authenticationError(description),
             let .badRequest(description),
             let .networkError(description),
             let .invalidResponse(description):
            return description
        }
    }
}
