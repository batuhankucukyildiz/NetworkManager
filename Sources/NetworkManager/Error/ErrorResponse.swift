//
//  File.swift
//  
//
//  Created by Batuhan Küçükyıldız on 10.08.2024.
//

import Foundation

public struct ErrorResponse: Decodable, Error {
    public let code: String
    public let status: Int
    public let priority: String
    public let success: Bool
    public let message: String
}
