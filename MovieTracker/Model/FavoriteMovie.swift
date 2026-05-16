import SwiftData
import Foundation

@Model
class FavoriteMovie {
    @Attribute(.unique) var id: UUID
    var movieId: Int = 0
    var title: String
    var posterURL: String = ""
    @Attribute(.externalStorage) var poster: Data?
    var timestamp: Date
    
    init(
        id: UUID = UUID(),
        movieId: Int,
        title: String,
        posterURL: String,
        poster: Data? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.movieId = movieId
        self.title = title
        self.posterURL = posterURL
        self.poster = poster
        self.timestamp = timestamp
    }
}
