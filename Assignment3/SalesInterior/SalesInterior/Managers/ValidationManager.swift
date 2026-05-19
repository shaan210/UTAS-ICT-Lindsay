import Foundation

class ValidationManager {
    static let shared = ValidationManager()
    
    func isValidClientName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty && name.count >= 2
    }
    
    func isValidProjectCode(_ code: String) -> Bool {
        return !code.trimmingCharacters(in: .whitespaces).isEmpty && code.count >= 1
    }
    
    func isValidAddress(_ address: String) -> Bool {
        return !address.trimmingCharacters(in: .whitespaces).isEmpty && address.count >= 3
    }
    
    func isValidPostcode(_ postcode: String) -> Bool {
        return !postcode.trimmingCharacters(in: .whitespaces).isEmpty && postcode.count >= 4
    }
    
    func isValidRoomName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty && name.count >= 2
    }
    
    func isValidDecimal(_ value: String) -> Bool {
        guard let doubleValue = Double(value), doubleValue > 0 else { return false }
        return true
    }
    
    func isValidMeasurement(_ measurement: Measurement) -> Bool {
        return measurement.isValid()
    }
    
    func validateAddHouseForm(
        clientName: String,
        projectCode: String,
        street: String,
        city: String,
        postcode: String
    ) -> (isValid: Bool, errorMessage: String) {
        if !isValidClientName(clientName) {
            return (false, "Client name must be at least 2 characters")
        }
        if !isValidProjectCode(projectCode) {
            return (false, "Project code is required")
        }
        if !isValidAddress(street) {
            return (false, "Street address must be at least 3 characters")
        }
        if !isValidAddress(city) {
            return (false, "City must be at least 3 characters")
        }
        if !isValidPostcode(postcode) {
            return (false, "Postcode must be at least 4 characters")
        }
        return (true, "")
    }
    
    func validateAddRoomForm(roomName: String) -> (isValid: Bool, errorMessage: String) {
        if !isValidRoomName(roomName) {
            return (false, "Room name must be at least 2 characters")
        }
        return (true, "")
    }
    
    func validateWindowMeasurement(
        width: String,
        height: String
    ) -> (isValid: Bool, errorMessage: String) {
        guard isValidDecimal(width) else {
            return (false, "Width must be a valid number greater than 0")
        }
        guard isValidDecimal(height) else {
            return (false, "Height must be a valid number greater than 0")
        }
        return (true, "")
    }
    
    func validateFloorMeasurement(area: String) -> (isValid: Bool, errorMessage: String) {
        guard isValidDecimal(area) else {
            return (false, "Area must be a valid number greater than 0")
        }
        return (true, "")
    }
}