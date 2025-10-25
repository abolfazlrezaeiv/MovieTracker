//
//  UserService.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/17/25.
//
import Security
import Foundation

struct RegisterRequest: Encodable {
    let username: String
    let passowrd: String
    let email: String
}

struct RegisterResponse: Decodable {
    let name: String
    let email: String
}

struct LoginResponse : Decodable {
    let tokenType : String
    let accessToken: String
    let expiresIn: Int
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}

struct LoginRequest: Encodable {
    let grantType: String
    let username: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case username
        case password
    }
    
    init(grantType: String, username: String, password: String) {
        self.grantType = grantType
        self.username = username
        self.password = password
    }
}

struct UserService {
    let client: HttpClient
    
    let registerEndpoint = "/api/v1/register"
    let loginEndpoint = "/oauth/token"
    
    init(client: HttpClient) {
        self.client = client
    }
    
    func register(user: RegisterRequest,completion : @escaping (Result<RegisterResponse, any Error>) -> Void ) async -> RegisterResponse? {
        do {
            let registerResult: RegisterResponse = try await client.fetch(
                endpoint: registerEndpoint,
                method: .post,
                headers: ["Accept": "application/json"],
                body: user,
                completion:completion
            )
            return registerResult
        } catch {
            return nil
        }
    }
    
    
    func login(credentials: LoginRequest, completion : @escaping (Result<LoginResponse, any Error>) -> Void ) async -> LoginResponse? {
        do {
            let loginResult: LoginResponse = try await client.fetch(
                endpoint: loginEndpoint,
                method: .post,
                headers: ["Content-Type": "application/json"],
                body: credentials,
                completion: completion
            )
                
            
            saveUser(credentials.username)
            saveToken(loginResult.accessToken, for: "accessToken")
            saveToken(loginResult.refreshToken, for: "refreshToken")
            return loginResult
        } catch {
            return nil
        }
    }
    
    func isLoggedIn() -> Bool {
        return loadToken(for: "accessToken") != nil
    }
    
    func saveToken(_ token: String, for key: String) {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func saveUser(_ username: String) {
        UserDefaults.standard.set(username, forKey: "username")
    }
    
    func getUser() -> String? {
        UserDefaults.standard.string(forKey: "username")
    }
    
    func loadToken(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func removeToken() {
        let keys: [String] = ["accessToken","refreshToken"]
        keys.forEach { key in
            SecItemDelete(
                [kSecClass as String: kSecClassGenericPassword,
                           kSecAttrAccount as String: key] as CFDictionary
            )
        }
    }

}
