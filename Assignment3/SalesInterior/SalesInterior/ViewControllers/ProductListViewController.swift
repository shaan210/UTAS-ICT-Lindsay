import UIKit
import FirebaseFirestore

class ProductListViewController: UITableViewController {

    var products: [Product] = []
    private var listener: ListenerRegistration?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Products"
        fetchProducts()
    }

    deinit { listener?.remove() }

    // MARK: - Firebase

    func fetchProducts() {
        listener = FirebaseManager.shared.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    self?.products = products
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - TableView Data Source

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let product = products[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = product.name
        content.secondaryText = "\(product.category)  |  \(product.displayPrice)"
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat { 56 }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        // NOTE: Do NOT call performSegue here.
        // The prototype cell already has "showProductDetail" segue connected in the storyboard.
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductDetail",
           let detailVC = segue.destination as? ProductDetailViewController,
           let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            detailVC.product = products[indexPath.row]
        }
    }

    // MARK: - Helpers

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
