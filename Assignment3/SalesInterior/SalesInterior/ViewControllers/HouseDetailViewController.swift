import UIKit
import FirebaseFirestore

class HouseDetailViewController: UITableViewController {

    var house: House?
    private var rooms: [Room] = []
    private var houseListener: ListenerRegistration?
    private var roomsListener: ListenerRegistration?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = house?.clientName ?? "House Detail"

        let addBtn   = UIBarButtonItem(barButtonSystemItem: .add,
                                       target: self, action: #selector(addNewRoom))
        let quoteBtn = UIBarButtonItem(title: "Quote", style: .plain,
                                       target: self, action: #selector(showQuoteTapped))
        navigationItem.rightBarButtonItems = [addBtn, quoteBtn]

        startHouseListener()
        startRoomsListener()
    }

    deinit {
        houseListener?.remove()
        roomsListener?.remove()
    }

    // MARK: - Real-time Listeners

    func startHouseListener() {
        guard let houseId = house?.id else {
            print("❌ No house ID found!")
            return
        }
        print("🔵 Starting house listener for ID: \(houseId)")
        houseListener = FirebaseManager.shared.observeHouse(id: houseId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedHouse):
                    print("✅ House loaded: \(updatedHouse.clientName)")
                    self?.house = updatedHouse
                    self?.title = updatedHouse.clientName
                case .failure(let error):
                    print("⚠️ Error observing house: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func startRoomsListener() {
        guard let houseId = house?.id else {
            print("❌ No house ID for rooms listener!")
            return
        }
        print("🔵 Starting rooms listener for house ID: \(houseId)")
        roomsListener = FirebaseManager.shared.fetchRooms(forHouseId: houseId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let rooms):
                    print("✅ Loaded \(rooms.count) rooms from Firebase")
                    if rooms.isEmpty {
                        print("📝 No rooms found. Add a room using the '+' button.")
                    } else {
                        for room in rooms {
                            print("   - Room: \(room.name) (ID: \(room.id ?? "no-id"))")
                        }
                    }
                    self?.rooms = rooms
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("❌ Error loading rooms: \(error.localizedDescription)")
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Actions

    @objc func addNewRoom() {
        let alert = UIAlertController(title: "New Room",
                                      message: "Enter a name for the room",
                                      preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "e.g. Living Room, Bedroom 1"
            tf.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let name = alert.textFields?.first?.text?
                    .trimmingCharacters(in: .whitespaces), !name.isEmpty else {
                self.showAlert(title: "Error", message: "Room name cannot be empty.")
                return
            }
            let validation = ValidationManager.shared.validateAddRoomForm(roomName: name)
            guard validation.isValid else {
                self.showAlert(title: "Validation Error", message: validation.errorMessage)
                return
            }
            guard let houseId = self.house?.id else {
                print("❌ No house ID found - cannot add room")
                self.showAlert(title: "Error", message: "House ID not found")
                return
            }

            print("🔵 Attempting to add room '\(name)' to house ID: \(houseId)")
            FirebaseManager.shared.addRoom(toHouseId: houseId, name: name) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let roomId):
                        print("✅ Room added successfully!")
                        print("   Room ID: \(roomId)")
                        print("   Room Name: \(name)")
                        print("   House ID: \(houseId)")
                        print("   Path: houses/\(houseId)/rooms/\(roomId)")
                        // Room will appear automatically via roomsListener
                    case .failure(let error):
                        print("❌ Failed to add room: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Failed to add room: \(error.localizedDescription)")
                    }
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc func showQuoteTapped() {
        performSegue(withIdentifier: "showQuote", sender: nil)
    }

    // MARK: - TableView Data Source

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath)
        let room = rooms[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = room.name
        let n = room.measurements.count
        content.secondaryText = n == 0 ? "No measurements yet"
                                       : "\(n) measurement\(n == 1 ? "" : "s")"
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    // MARK: - TableView Delegate (Delete)

    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool { true }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete,
              let houseId = house?.id else { return }
        let room = rooms[indexPath.row]
        
        FirebaseManager.shared.deleteRoom(fromHouseId: houseId, roomId: room.id ?? "") { [weak self] result in
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
            // Room will disappear automatically via roomsListener
        }
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoomDetail",
           let roomDetailVC = segue.destination as? RoomDetailViewController,
           let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            
            let room = rooms[indexPath.row]
            roomDetailVC.house = house
            roomDetailVC.room = room  // Pass the room object instead of index

        } else if segue.identifier == "showQuote",
                  let quoteVC = segue.destination as? QuoteViewController {
            quoteVC.house = house
            quoteVC.rooms = rooms  // Pass rooms array for quote calculation
        }
    }

    // MARK: - Helpers

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

