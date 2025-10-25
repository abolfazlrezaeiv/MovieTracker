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
    case invalidResponse(String)
    case decodingError(String)
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
            completion(.failure(NetworkError.invalidResponse("Not a fancy response")))
            throw NetworkError.invalidResponse("Not a fancy response")
        }
        
        guard (200...299).contains(http.statusCode) else {
            // Helpful: log body to understand server error
            let bodyString = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            completion(
                .failure(
                    NetworkError.invalidResponse(String( http.description))
                )
            )
            throw NetworkError.invalidResponse(http.description)
        }
        

        do {
            let deseializedData = try JSONDecoder().decode(T.self,from: data)
            completion(.success(deseializedData))
            return deseializedData
        } catch {
            print(error)
            completion(
                .failure(NetworkError.decodingError(""))
            )
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
}
