//
//  MovieService.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/16/25.
//

struct MovieListRespose: Decodable {
    let data: [MovieItem]
}

struct MovieItem: Decodable {
    let id: Int
    let title: String
    let poster: String
    let year: String
    let country: String
    let imdbRating: String
    let genres: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case imdbRating = "imdb_rating"
        case poster = "poster"
        case year = "year"
        case country = "country"
        case genres = "genres"
    }
}


struct MovieDetails: Codable {
    let id: Int
    let title: String
    let poster: String
    let year: String
    let rated: String
    let released: String
    let runtime: String
    let director: String
    let writer: String
    let actors: String
    let plot: String
    let country: String
    let awards: String
    let metascore: String
    let imdbRating: String
    let imdbVotes: String
    let imdbID: String
    let type: String
    let genres: [String]
    let images: [String]
    
    // Map JSON keys to Swift property names if needed
    enum CodingKeys: String, CodingKey {
        case id, title, poster, year, rated, released, runtime, director, writer, actors, plot, country, awards, metascore
        case imdbRating = "imdb_rating"
        case imdbVotes = "imdb_votes"
        case imdbID = "imdb_id"
        case type, genres, images
    }
}

struct Genre: Decodable {
    let id: Int
    let name: String
}

struct MovieService {
    let client: HttpClient
        
    init(client: HttpClient) {
        self.client = client
    }
    
    func fetchMovies(page: Int) async -> [MovieItem] {
        do {
            let movies: MovieListRespose = try await client.fetch(
                endpoint: "/api/v1/movies?page=\(page)",
                method: .get,
                headers: [:],
                body: nil
            ) { _ in }
            return movies.data
            
        } catch {
            return []
        }
    }
    
    func searchMovies(keyword: String, page: Int) async -> [MovieItem] {
        do {
            let movies: MovieListRespose = try await client.fetch(
                endpoint: "/api/v1/movies?q=\(keyword)&page=\(page)",
                method: .get,
                headers: [:],
                body: nil ) { _ in }
            return movies.data
        } catch {
            return []

        }
    }
    
    func getMovieById(_ id: Int) async -> MovieDetails? {
        do {
            let movie: MovieDetails = try await client.fetch(
                endpoint: "/api/v1/movies/\(id)",
                method: .get,
                headers: [:],
                body: nil
            ) { _ in }
            return movie
        } catch {
            return nil
        }
    }
    
    func getGenres() async throws -> [Genre] {
            let genres: [Genre] = try await client.fetch(
                endpoint: "/api/v1/genres",
                method: .get,
                headers: [:],
                body: nil
            ) { _ in }
            return genres
    }
    
    func getMoviesByGenre(genreId: String, page: Int, completion: @escaping (Result<MovieListRespose, NetworkError>) -> Void) async -> [MovieItem] {
        do {
            let movies: MovieListRespose = try await client.fetch(
                endpoint: "/api/v1/genres/\(genreId)/movies?page=\(page)",
                method: .get,
                headers: [:],
                body: nil,
                completion: completion
            )
            return movies.data
        } catch {
            return []
        }
    }
}
