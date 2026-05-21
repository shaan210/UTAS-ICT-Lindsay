import UIKit

class ProductDetailViewController: UIViewController {

    // MARK: - IBOutlets (connected in storyboard)
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    // MARK: - Properties
    var product: Product?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let product = product else { return }
        title = product.name
        productNameLabel.text = product.name
        priceLabel.text = product.displayPrice
        priceLabel.textColor = .systemGreen
        categoryLabel.text = "Category: \(product.category)"
        descriptionLabel.text = product.description
    }
}
