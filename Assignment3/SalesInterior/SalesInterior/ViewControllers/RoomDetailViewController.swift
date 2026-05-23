import UIKit
import FirebaseFirestore

/// RoomDetailViewController manages window & floor measurements for a single room.
/// It also supports photo gallery selection via ImageManager.
class RoomDetailViewController: UIViewController {

    // MARK: - IBOutlets (all connected in Main.storyboard)
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var windowWidthTextField: UITextField!
    @IBOutlet weak var windowHeightTextField: UITextField!
    @IBOutlet weak var floorAreaTextField: UITextField!
    @IBOutlet weak var btnAddWindow: UIButton!
    @IBOutlet weak var btnAddFloor: UIButton!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var measurementsTableView: UITableView!
    @IBOutlet weak var selectPhotoButton: UIButton!

    // MARK: - Properties
    var house: House?
    var room: Room?  // Changed from roomIndex to room object
    private let imageManager = ImageManager()
    private var roomListener: ListenerRegistration?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Room Details"
        roomNameLabel.text = room?.name ?? ""

        setupTableView()
        setupUI()
        setupImageManager()
        if let room = room { loadImageFromRoom(room) }
        startRoomListener()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        measurementsTableView.reloadData()
    }
    
    deinit {
        roomListener?.remove()
    }
    
    // MARK: - Real-time Listener
    
    func startRoomListener() {
        guard let houseId = house?.id, let roomId = room?.id else { return }
        roomListener = FirebaseManager.shared.observeRoom(houseId: houseId, roomId: roomId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let updatedRoom):
                    self.room = updatedRoom
                    self.roomNameLabel.text = updatedRoom.name
                    self.measurementsTableView.reloadData()
                    self.loadImageFromRoom(updatedRoom)
                    print("✅ Room updated - \(updatedRoom.measurements.count) measurements")
                case .failure(let error):
                    print("⚠️ Error observing room: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Setup

    func setupTableView() {
        measurementsTableView.delegate = self
        measurementsTableView.dataSource = self
        measurementsTableView.register(UITableViewCell.self,
                                       forCellReuseIdentifier: "MeasurementCell")
    }

    func setupUI() {
        [windowWidthTextField, windowHeightTextField, floorAreaTextField].forEach {
            $0?.keyboardType = .decimalPad
            $0?.delegate = self
        }
        btnAddWindow.layer.cornerRadius = 22
        btnAddFloor.layer.cornerRadius = 22
        selectPhotoButton.layer.cornerRadius = 22
        selectedImageView.layer.cornerRadius = 22
        selectedImageView.clipsToBounds = true
        selectedImageView.contentMode = .scaleAspectFit
        selectedImageView.backgroundColor = .systemGray6
        selectedImageView.image = UIImage(systemName: "photo.fill")
        selectedImageView.tintColor = .systemGray2
    }

    func setupImageManager() {
        imageManager.delegate = self
    }

    // MARK: - IBActions

    @IBAction func addWindowTapped(_ sender: UIButton) {
        let width = windowWidthTextField.text ?? ""
        let height = windowHeightTextField.text ?? ""
        let validation = ValidationManager.shared.validateWindowMeasurement(width: width, height: height)
        guard validation.isValid else {
            showAlert(title: "Validation Error", message: validation.errorMessage); return
        }
        guard let w = Double(width), let h = Double(height),
              let houseId = house?.id else { return }

        // Show product picker before saving
        showProductPicker(type: "WINDOW") { [weak self] product in
            guard let self = self, let product = product else { return }
            let measurement = Measurement(
                type: "WINDOW", width: w, height: h,
                productId: product.id ?? "",
                productName: product.name,
                productPrice: product.price
            )
            self.saveMeasurement(houseId: houseId, measurement: measurement)
            self.windowWidthTextField.text = ""
            self.windowHeightTextField.text = ""
        }
    }

    @IBAction func addFloorTapped(_ sender: UIButton) {
        let area = floorAreaTextField.text ?? ""
        let validation = ValidationManager.shared.validateFloorMeasurement(area: area)
        guard validation.isValid else {
            showAlert(title: "Validation Error", message: validation.errorMessage); return
        }
        guard let a = Double(area), let houseId = house?.id else { return }

        showProductPicker(type: "FLOOR_SPACE") { [weak self] product in
            guard let self = self, let product = product else { return }
            let measurement = Measurement(
                type: "FLOOR_SPACE", area: a,
                productId: product.id ?? "",
                productName: product.name,
                productPrice: product.price
            )
            self.saveMeasurement(houseId: houseId, measurement: measurement)
            self.floorAreaTextField.text = ""
        }
    }

    @IBAction func selectPhotoTapped(_ sender: UIButton) {
        imageManager.presentImagePicker(from: self)
    }

    // MARK: - Product Picker

    /// Presents an action sheet listing products matching the given type (WINDOW or FLOOR_SPACE category).
    func showProductPicker(type: String, completion: @escaping (Product?) -> Void) {
        FirebaseManager.shared.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    completion(nil)
                case .success(let allProducts):
                    // Filter by category matching type keyword
                    let keyword = type == "WINDOW" ? "Window" : "Flooring"
                    let filtered = allProducts.filter {
                        $0.category.lowercased().contains(keyword.lowercased())
                    }
                    let products = filtered.isEmpty ? allProducts : filtered

                    if products.isEmpty {
                        self.showAlert(title: "No Products",
                                       message: "No products found in Firestore. Please add products first.")
                        completion(nil)
                        return
                    }

                    let sheet = UIAlertController(title: "Select Product",
                                                  message: "Choose a product for this measurement",
                                                  preferredStyle: .actionSheet)
                    for product in products {
                        sheet.addAction(UIAlertAction(
                            title: "\(product.name)  –  \(product.displayPrice)",
                            style: .default) { _ in completion(product) })
                    }
                    sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                        completion(nil)
                    })
                    self.present(sheet, animated: true)
                }
            }
        }
    }

    // MARK: - Save Measurement

    func saveMeasurement(houseId: String, measurement: Measurement) {
        guard let roomId = room?.id else {
            showAlert(title: "Error", message: "Room ID not found")
            return
        }
        
        FirebaseManager.shared.addMeasurement(
            toHouseId: houseId,
            roomId: roomId,
            measurement: measurement
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Measurement added successfully")
                    // Real-time listener will update UI
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Helpers

    @objc func dismissKeyboard() { view.endEditing(true) }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension RoomDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return room?.measurements.count ?? 0
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeasurementCell", for: indexPath)
        guard let m = room?.measurements[indexPath.row] else { return cell }

        var content = cell.defaultContentConfiguration()
        if m.type == "WINDOW" {
            content.text = "🪟 WINDOW: \(m.width ?? 0) m × \(m.height ?? 0) m"
            let area = (m.width ?? 0) * (m.height ?? 0)
            content.secondaryText = "Area: \(String(format: "%.2f", area)) m²  |  \(m.productName)  –  $\(String(format: "%.2f", m.productPrice))/m²"
        } else {
            content.text = "🏠 FLOOR: \(m.area ?? 0) m²"
            content.secondaryText = "\(m.productName)  –  $\(String(format: "%.2f", m.productPrice))/m²"
        }
        cell.contentConfiguration = content
        cell.backgroundColor = .systemGray2
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool { true }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete,
              let m = room?.measurements[indexPath.row],
              let houseId = house?.id,
              let roomId = room?.id else { return }

        FirebaseManager.shared.deleteMeasurement(
            fromHouseId: houseId,
            roomId: roomId,
            measurementId: m.id
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Measurement deleted successfully")
                    // Real-time listener will update UI
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension RoomDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder(); return true
    }
}

// MARK: - ImageManagerDelegate

extension RoomDetailViewController: ImageManagerDelegate {
    func imageManager(_ manager: ImageManager, didSelectImage image: UIImage) {
        selectedImageView.image = image
        selectedImageView.contentMode = .scaleAspectFill
        uploadRoomImage(image)
    }
    func imageManagerDidCancel(_ manager: ImageManager) {
        // Nothing to do — picker already dismissed
    }
}

// MARK: - Image Upload / Display

extension RoomDetailViewController {

    func loadImageFromRoom(_ room: Room) {
        guard let base64 = room.imageData,
              let data = Data(base64Encoded: base64),
              let image = UIImage(data: data) else { return }
        selectedImageView.image = image
        selectedImageView.contentMode = .scaleAspectFill
    }

    func uploadRoomImage(_ image: UIImage) {
        guard let houseId = house?.id, let roomId = room?.id else { return }
        guard let data = compressImage(image) else {
            showAlert(title: "Image Error", message: "Could not compress image.")
            return
        }
        let base64 = data.base64EncodedString()
        // Firestore document max is 1 MiB. Base64 is ~33% larger than binary, so cap ~700KB binary.
        if base64.count > 900_000 {
            showAlert(title: "Image Too Large", message: "Please choose a smaller image.")
            return
        }
        FirebaseManager.shared.updateRoomImage(houseId: houseId, roomId: roomId, imageData: base64) { [weak self] result in
            DispatchQueue.main.async {
                if case .failure(let error) = result {
                    self?.showAlert(title: "Upload Error", message: error.localizedDescription)
                }
            }
        }
    }

    /// Resizes to max 800px on the longest side and compresses JPEG quality until under ~700KB.
    func compressImage(_ image: UIImage) -> Data? {
        let maxDimension: CGFloat = 800
        var working = image
        let size = image.size
        if max(size.width, size.height) > maxDimension {
            let aspect = size.width / size.height
            let newSize: CGSize = aspect > 1
                ? CGSize(width: maxDimension, height: maxDimension / aspect)
                : CGSize(width: maxDimension * aspect, height: maxDimension)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            if let resized = UIGraphicsGetImageFromCurrentImageContext() {
                working = resized
            }
            UIGraphicsEndImageContext()
        }

        var quality: CGFloat = 0.7
        var data = working.jpegData(compressionQuality: quality)
        while let d = data, d.count > 700_000, quality > 0.1 {
            quality -= 0.1
            data = working.jpegData(compressionQuality: quality)
        }
        return data
    }
}
