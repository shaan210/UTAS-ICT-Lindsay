import Foundation
import FirebaseFirestore

/// House document - stored in "houses" collection
/// Rooms are stored in a subcollection: houses/{houseId}/rooms
struct House: Identifiable, Codable {
    @DocumentID var id: String?
    var clientName: String
    var projectCode: String
    var street: String
    var city: String
    var postcode: String

    enum CodingKeys: String, CodingKey {
        case id, clientName, projectCode, street, city, postcode
    }

    init(
        clientName: String = "",
        projectCode: String = "",
        street: String = "",
        city: String = "",
        postcode: String = ""
    ) {
        self.clientName = clientName
        self.projectCode = projectCode
        self.street = street
        self.city = city
        self.postcode = postcode
    }
    
    // Remove custom decoder - let @DocumentID handle it automatically
}
