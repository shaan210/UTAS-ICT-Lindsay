import UIKit
import FirebaseFirestore

class HouseListViewController: UITableViewController {

    var houses: [House] = []
    var listener: ListenerRegistration?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Client Houses"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewHouse)
        )
        fetchHouses()
    }

    deinit {
        listener?.remove()
    }

    // MARK: - Actions

    @objc func addNewHouse() {
        // Programmatic modal presentation — avoids the "Pushing a navigation
        // controller is not supported" crash that occurs when the storyboard
        // segue kind is "show" and the destination is a UINavigationController.
        guard let addVC = storyboard?.instantiateViewController(withIdentifier: "addHouseVC")
                as? AddHouseViewController else { return }
        let navController = UINavigationController(rootViewController: addVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }

    // MARK: - Firebase

    func fetchHouses() {
        print("🔵 Starting to fetch houses from Firebase...")
        listener = FirebaseManager.shared.fetchHouses { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let houses):
                    print("✅ Fetched \(houses.count) houses from Firebase")
                    if houses.isEmpty {
                        print("📝 No houses found in database. Add a house using the '+' button.")
                    } else {
                        for (index, house) in houses.enumerated() {
                            print("   \(index + 1). \(house.clientName) (ID: \(house.id ?? "no-id"))")
                        }
                    }
                    self?.houses = houses
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("❌ Error fetching houses: \(error.localizedDescription)")
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - TableView Data Source

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return houses.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HouseCell", for: indexPath)
        let house = houses[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = house.clientName
        content.secondaryText = "\(house.street), \(house.city) \(house.postcode)  |  \(house.projectCode)"
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat { 60 }

    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool { true }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete,
              let houseId = houses[indexPath.row].id else { return }
        FirebaseManager.shared.deleteHouse(id: houseId) { [weak self] result in
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Delete Error", message: error.localizedDescription)
                }
            }
            // Snapshot listener reloads the table automatically on success
        }
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        // NOTE: Do NOT call performSegue here.
        // The prototype cell in the storyboard already has the "showHouseDetail"
        // segue connected — tapping the cell fires it automatically.
        // Calling performSegue here would push a SECOND, blank HouseDetailViewController.
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHouseDetail",
           let destVC = segue.destination as? HouseDetailViewController,
           let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            let house = houses[indexPath.row]
            print("🔵 Navigating to house: \(house.clientName)")
            print("🔵 House ID: \(house.id ?? "NO ID")")
            destVC.house = house
        }
    }

    // MARK: - Helpers

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
