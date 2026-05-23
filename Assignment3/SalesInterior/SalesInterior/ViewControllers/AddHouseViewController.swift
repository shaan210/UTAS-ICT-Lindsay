import UIKit

class AddHouseViewController: UIViewController {

    // MARK: - IBOutlets (connected in storyboard)
    @IBOutlet weak var clientNameTextField: UITextField!
    @IBOutlet weak var projectCodeTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var postcodeTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add New House"
        styleUI()
        setupTextFieldDelegates()
        // Tap anywhere to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // MARK: - Setup

    func styleUI() {
        saveButton.layer.cornerRadius = 6
        saveButton.clipsToBounds = true
    }

    func setupTextFieldDelegates() {
        [clientNameTextField, projectCodeTextField, streetTextField,
         cityTextField, postcodeTextField].forEach { $0?.delegate = self }
    }

    // MARK: - Actions

    @IBAction func saveHouseTapped(_ sender: UIButton) {
        let clientName = clientNameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let projectCode = projectCodeTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let street = streetTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let city = cityTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let postcode = postcodeTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        let validation = ValidationManager.shared.validateAddHouseForm(
            clientName: clientName, projectCode: projectCode,
            street: street, city: city, postcode: postcode
        )
        guard validation.isValid else {
            showAlert(title: "Validation Error", message: validation.errorMessage)
            return
        }

        saveButton.isEnabled = false
        saveButton.setTitle("Saving…", for: .normal)

        print("🔵 Attempting to create house: \(clientName)")
        FirebaseManager.shared.addHouse(
            clientName: clientName,
            projectCode: projectCode,
            street: street,
            city: city,
            postcode: postcode
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.saveButton.isEnabled = true
                self?.saveButton.setTitle("Save House", for: .normal)
                switch result {
                case .success(let houseId):
                    print("✅ House created successfully!")
                    print("   House ID: \(houseId)")
                    print("   Client Name: \(clientName)")
                    print("   Path: houses/\(houseId)")
                    self?.dismiss(animated: true)
                case .failure(let error):
                    print("❌ Failed to create house: \(error.localizedDescription)")
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Helpers

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension AddHouseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case clientNameTextField:  projectCodeTextField.becomeFirstResponder()
        case projectCodeTextField: streetTextField.becomeFirstResponder()
        case streetTextField:      cityTextField.becomeFirstResponder()
        case cityTextField:        postcodeTextField.becomeFirstResponder()
        default:                   textField.resignFirstResponder()
        }
        return true
    }
}
