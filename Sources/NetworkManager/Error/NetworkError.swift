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

    public var errorDescription: String? {
        switch self {
        case .jsonDecoderError(let description),
             .authenticationError(let description),
             .badRequest(let description),
             .networkError(let description):
            return description
        }
    }
}
