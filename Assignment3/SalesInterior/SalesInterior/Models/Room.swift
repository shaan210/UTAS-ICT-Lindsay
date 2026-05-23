import Foundation
import FirebaseFirestore

/// Room document - stored in subcollection: houses/{houseId}/rooms/{roomId}
/// Measurements are embedded as an array within each room document
struct Room: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var measurements: [Measurement]
    var imageData: String?

    enum CodingKeys: String, CodingKey {
        case id, name, measurements, imageData
    }

    init(name: String = "", measurements: [Measurement] = [], imageData: String? = nil) {
        self.name = name
        self.measurements = measurements
        self.imageData = imageData
    }
}
