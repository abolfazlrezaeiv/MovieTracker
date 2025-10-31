import SwiftData
import Foundation

@Model
class FavoriteMovie {
    @Attribute(.unique) var id: UUID
    var title: String
    @Attribute(.externalStorage) var poster: Data?
    var timestamp: Date
    
    init(id: UUID = UUID(), title: String, poster: Data? = nil, timestamp: Date = Date()) {
        self.id = id
        self.title = title
        self.poster = poster
        self.timestamp = timestamp
    }
}
