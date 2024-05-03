//
//  EndpointProtocol.swift
//
//
//  Created by Batuhan Küçükyıldız on 24.04.2024.
//

import Foundation

public protocol EndpointProtocol {
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HttpMethods { get }
    var params: [String: Any]? { get }
    var headers: [String: Any]? { get }
    func request() throws -> URLRequest
}

public class MockEndpointProtocol: EndpointProtocol {
    
    public init(
        baseURL: String = "",
        path: String = "",
        httpMethod: HttpMethods,
        params: [String : Any]? = nil,
        headers: [String : Any]? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.httpMethod = httpMethod
        self.params = params
        self.headers = headers
    }
    
    public var baseURL: String
    
    public var path: String
    
    public var httpMethod: HttpMethods
    
    public var params: [String: Any]?
    
    public var headers: [String: Any]?
        
    public var body: Data?
    
    public func request() throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else { throw NetworkError.badRequest(description: "URL is not valid") }
        return URLRequest(url: url)
    }
    
}
