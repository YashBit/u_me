//
//  NetworkService.swift
//  U&Me
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

final class NetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Generic Request (Encodable body)
    
    func request<T: Decodable, B: Encodable>(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String]? = nil,
        body: B? = nil
    ) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = APIConfig.timeout
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // Encode body if present
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
            
            if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 Request body: \(bodyString)")
            }
        }
        
        print("📤 \(method.rawValue) \(endpoint)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("📥 Response status: \(httpResponse.statusCode)")
        
        // Handle 404 as nil for optional responses
        if httpResponse.statusCode == 404 {
            throw NetworkError.notFound
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Error response: \(errorString)")
            }
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        // Log response
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response: \(responseString.prefix(500))...")
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Dictionary Body Request (for simple JSON)
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String]? = nil,
        body: [String: Any]? = nil
    ) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = APIConfig.timeout
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // Encode body if present
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 Request body: \(bodyString)")
            }
        }
        
        print("📤 \(method.rawValue) \(endpoint)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("📥 Response status: \(httpResponse.statusCode)")
        
        // Handle 404 as nil for optional responses
        if httpResponse.statusCode == 404 {
            throw NetworkError.notFound
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Error response: \(errorString)")
            }
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        // Log response
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response: \(responseString.prefix(500))...")
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Request without body
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String]? = nil
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: method,
            headers: headers,
            body: nil as [String: Any]?
        )
    }
}

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case notFound
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .notFound:
            return "Resource not found"
        case .httpError(let code):
            return "HTTP error with status code: \(code)"
        }
    }
}