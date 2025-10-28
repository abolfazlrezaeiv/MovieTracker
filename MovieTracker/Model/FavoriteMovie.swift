import SwiftData
import Foundation

@Model
class FavoriteMovie {
    @Attribute(.unique) var id: UUID
    var title: String
    var poster: Data?
    var timestamp: Date
    
    init(id: UUID, title: String, poster: Data? = nil, timestamp: Date) {
        self.id = id
        self.title = title
        self.poster = poster
        self.timestamp = timestamp
    }
}
