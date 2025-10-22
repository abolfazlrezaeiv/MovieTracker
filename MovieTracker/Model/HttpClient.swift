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
    case invalidURL
    case invalidResponse
    case decodingError
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
        completion: @escaping (Result<T, Error>) -> Void
    ) async throws -> T {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        print(url.absoluteString)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data,response) = try await session.data(for: request)
        
        if let response = response as? HTTPURLResponse, !(200...299 ~= response.statusCode) {
            fatalError("Failed to fetch data, status code: \(response.statusCode)")
        }
        
        // 🧠 Handle empty or no-response case
        if T.self == Void.self || data.isEmpty {
            return () as! T // Force-cast safe here because T == Void
        }
        
        do {
            let deseializedData = try JSONDecoder().decode(T.self,from: data)
            completion(.success(deseializedData))
            return deseializedData
        } catch {
            print(error)
            completion(.failure(NetworkError.decodingError))
            throw NetworkError.decodingError
        }
    }
}
