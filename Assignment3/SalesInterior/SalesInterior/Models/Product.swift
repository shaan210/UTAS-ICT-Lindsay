import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var category: String
    var price: Double

    enum CodingKeys: String, CodingKey {
        case id, name, description, category, price
    }

    init(
        name: String = "",
        description: String = "",
        category: String = "",
        price: Double = 0.0
    ) {
        self.name = name
        self.description = description
        self.category = category
        self.price = price
    }

    var displayPrice: String {
        return String(format: "$%.2f / m²", price)
    }
}
