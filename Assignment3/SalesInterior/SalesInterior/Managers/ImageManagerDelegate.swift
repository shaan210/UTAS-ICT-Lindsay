import UIKit

protocol ImageManagerDelegate: AnyObject {
    func imageManager(_ manager: ImageManager, didSelectImage image: UIImage)
    func imageManagerDidCancel(_ manager: ImageManager)
}

class ImageManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: ImageManagerDelegate?
    var viewController: UIViewController?
    let imagePicker = UIImagePickerController()
    
    override init() {
        super.init()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
    }
    
    func presentImagePicker(from viewController: UIViewController) {
        self.viewController = viewController
        viewController.present(imagePicker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        defer {
            picker.dismiss(animated: true)
        }
        
        if let editedImage = info[.editedImage] as? UIImage {
            delegate?.imageManager(self, didSelectImage: editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            delegate?.imageManager(self, didSelectImage: originalImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        delegate?.imageManagerDidCancel(self)
    }
}