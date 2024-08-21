//
//  File.swift
//  
//
//  Created by Batuhan Küçükyıldız on 10.08.2024.
//

import Foundation

public struct ErrorResponse: Decodable {
    let message: String
    let statusCode: Int
    let priority: Int
    let code: Int
}

public struct RatingErrorResponse: Decodable {
    let status: Bool
    let remainingTries: Int
    let error: RatingErrorDetail
}

struct RatingErrorDetail: Decodable {
    let message: String
    let statusCode: Int
    let priority: Int
    let code: Int
}
