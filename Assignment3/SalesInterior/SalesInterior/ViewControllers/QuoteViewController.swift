import UIKit

class QuoteViewController: UIViewController {

    // MARK: - IBOutlets (connected in storyboard)
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!

    // MARK: - Properties
    var house: House?
    var rooms: [Room] = []  // ✅ Added - passed from HouseDetailViewController
    private var quoteText: String = ""

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quote"
        quoteTextView.isEditable = false
        quoteTextView.isSelectable = true
        quoteTextView.font = UIFont(name: "Courier", size: 13) ?? UIFont.systemFont(ofSize: 13)
        shareButton.layer.cornerRadius = 6
        shareButton.clipsToBounds = true
        generateQuote()
    }

    // MARK: - Quote Generation

    func generateQuote() {
        guard let house = house else {
            quoteTextView.text = "No house data available."
            return
        }

        var text = "═══════════════════════════════════\n"
        text += "        SALES INTERIOR QUOTE\n"
        text += "═══════════════════════════════════\n\n"
        text += "CLIENT INFORMATION\n"
        text += "───────────────────────────────────\n"
        text += "Name      : \(house.clientName)\n"
        text += "Project   : \(house.projectCode)\n"
        text += "Street    : \(house.street)\n"
        text += "City      : \(house.city)\n"
        text += "Postcode  : \(house.postcode)\n\n"
        text += "ROOMS & MEASUREMENTS\n"
        text += "───────────────────────────────────\n"

        var grandTotal: Double = 0.0

        if rooms.isEmpty {
            text += "No rooms added yet.\n"
        } else {
            for (i, room) in rooms.enumerated() {
                text += "\n\(i + 1). \(room.name.uppercased())\n"
                if room.measurements.isEmpty {
                    text += "   (No measurements)\n"
                } else {
                    var roomTotal: Double = 0
                    for m in room.measurements {
                        if m.type == "WINDOW" {
                            let area = (m.width ?? 0) * (m.height ?? 0)
                            let cost = area * m.productPrice
                            text += "   🪟 Window  \(m.width ?? 0)m × \(m.height ?? 0)m\n"
                            text += "      Area: \(String(format: "%.2f", area)) m²\n"
                            text += "      Product: \(m.productName)\n"
                            text += "      Rate: $\(String(format: "%.2f", m.productPrice))/m²\n"
                            text += "      Cost: $\(String(format: "%.2f", cost))\n"
                            roomTotal += cost
                        } else {
                            let area = m.area ?? 0
                            let cost = area * m.productPrice
                            text += "   🏠 Floor   \(String(format: "%.2f", area)) m²\n"
                            text += "      Product: \(m.productName)\n"
                            text += "      Rate: $\(String(format: "%.2f", m.productPrice))/m²\n"
                            text += "      Cost: $\(String(format: "%.2f", cost))\n"
                            roomTotal += cost
                        }
                    }
                    text += "   Room Sub-Total: $\(String(format: "%.2f", roomTotal))\n"
                    grandTotal += roomTotal
                }
            }
        }

        text += "\n═══════════════════════════════════\n"
        text += "GRAND TOTAL  :  $\(String(format: "%.2f", grandTotal))\n"
        text += "═══════════════════════════════════\n"
        text += "\nGenerated: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))\n"

        quoteText = text
        quoteTextView.text = text
    }

    // MARK: - IBActions

    @IBAction func shareTapped(_ sender: UIButton) {
        guard !quoteText.isEmpty else { return }
        let activityVC = UIActivityViewController(
            activityItems: [quoteText],
            applicationActivities: nil
        )
        activityVC.popoverPresentationController?.sourceView = shareButton
        present(activityVC, animated: true)
    }
}
