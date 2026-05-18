import Foundation
import FirebaseFirestore

/// Room document - stored in subcollection: houses/{houseId}/rooms/{roomId}
/// Measurements are embedded as an array within each room document
struct Room: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var measurements: [Measurement]

    enum CodingKeys: String, CodingKey {
        case id, name, measurements
    }

    init(name: String = "", measurements: [Measurement] = []) {
        self.name = name
        self.measurements = measurements
    }
    
    // Remove custom decoder - let @DocumentID and Codable handle it automatically
}
