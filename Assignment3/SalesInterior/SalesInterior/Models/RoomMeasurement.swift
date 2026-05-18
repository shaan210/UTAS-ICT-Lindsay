import Foundation

struct Measurement: Identifiable, Codable {
    var id: String
    var type: String // "WINDOW" or "FLOOR_SPACE"
    var width: Double?
    var height: Double?
    var area: Double?
    var productId: String
    var productName: String
    var productPrice: Double

    enum CodingKeys: String, CodingKey {
        case id, type, width, height, area, productId, productName, productPrice
    }

    init(
        type: String = "WINDOW",
        width: Double? = nil,
        height: Double? = nil,
        area: Double? = nil,
        productId: String = "",
        productName: String = "No Product",
        productPrice: Double = 0.0
    ) {
        self.id = UUID().uuidString
        self.type = type
        self.width = width
        self.height = height
        self.area = area
        self.productId = productId
        self.productName = productName
        self.productPrice = productPrice
    }

    func isValid() -> Bool {
        switch type {
        case "WINDOW":
            return (width ?? 0.0) > 0 && (height ?? 0.0) > 0
        case "FLOOR_SPACE":
            return (area ?? 0.0) > 0
        default:
            return false
        }
    }

    /// Computed area for quote calculations
    var calculatedArea: Double {
        if type == "WINDOW" {
            return (width ?? 0) * (height ?? 0)
        }
        return area ?? 0
    }

    /// Total cost for this measurement
    var totalCost: Double {
        return calculatedArea * productPrice
    }
}
