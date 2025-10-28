//
//  HttpClient.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/16/25.
//
import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case invalidURL(String)
    case invalidResponse
    case statusCode(Int, data: Data?)
    case decoding(Error)
    case underlying(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server response was not valid."
        case .statusCode(let code, let data):
            if let data, let body = String(data: data, encoding: .utf8), !body.isEmpty {
                return "Server returned status \(code): \(body)"
            } else {
                return "Server returned status \(code)."
            }
        case .decoding(let err):
            return "Failed to decode server response: \(err.localizedDescription)"
        case .underlying(let err):
            return err.localizedDescription
        case .invalidURL(let err):
            return err
        }
    }
    
    var failureReason: String? {
        switch self {
        case .invalidResponse:
            return "Response did not match expected format."
        case .statusCode(let code, _):
            return "HTTP \(code)"
        case .decoding:
            return "JSON structure did not match expected model."
        case .underlying:
            return nil
        case .invalidURL:
            return "The url is unreachable"

        }
    }
}

class HttpClient {
    let baseURL = URL(string: "https://moviesapi.ir")!
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func fetch<T: Decodable>(
        endpoint: String,
        method: HttpMethod = .get,
        headers: [String: String] = [:],
        body: Encodable? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) async throws -> T {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw NetworkError.invalidURL(endpoint)
        }
        print(url.absoluteString)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let httpBody = request.httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            print("Request Body:", bodyString)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            completion(
                .failure(NetworkError.invalidResponse)
            )
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(http.statusCode) else {
            // Helpful: log body to understand server error
            _ = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            completion(
                .failure(
                    NetworkError.invalidResponse)
                
            )
            print(http.description)
            print("+++++++")
            throw NetworkError.invalidResponse
        }
        

        do {
            let deseializedData = try JSONDecoder().decode(T.self,from: data)
            completion(.success(deseializedData))
            return deseializedData
        } catch {
            print(error)
            completion(
                .failure(NetworkError.decoding(error))
            )
            throw NetworkError.decoding(error)
        }
    }
}
