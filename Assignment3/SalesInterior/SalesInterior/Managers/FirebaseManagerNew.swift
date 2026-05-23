import Foundation
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    let db = Firestore.firestore()
    
    private init() {}

    // MARK: - HOUSES CRUD

    func addHouse(
        clientName: String,
        projectCode: String,
        street: String,
        city: String,
        postcode: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let house = House(
            clientName: clientName,
            projectCode: projectCode,
            street: street,
            city: city,
            postcode: postcode
        )
        do {
            let ref = try db.collection("houses").addDocument(from: house)
            completion(.success(ref.documentID))
        } catch {
            completion(.failure(error))
        }
    }

    @discardableResult
    func fetchHouses(completion: @escaping (Result<[House], Error>) -> Void) -> ListenerRegistration {
        return db.collection("houses").addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                let houses = try snapshot?.documents.compactMap { try $0.data(as: House.self) } ?? []
                completion(.success(houses))
            } catch {
                completion(.failure(error))
            }
        }
    }

    @discardableResult
    func observeHouse(
        id: String,
        completion: @escaping (Result<House, Error>) -> Void
    ) -> ListenerRegistration {
        return db.collection("houses").document(id).addSnapshotListener { snapshot, error in
            if let error = error { completion(.failure(error)); return }
            guard let snapshot = snapshot, snapshot.exists else { return }
            do {
                let house = try snapshot.data(as: House.self)
                completion(.success(house))
            } catch {
                print("⚠️ observeHouse decode error: \(error)")
                completion(.failure(error))
            }
        }
    }

    func deleteHouse(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // First delete all rooms in subcollection
        db.collection("houses").document(id).collection("rooms").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let batch = self.db.batch()
            snapshot?.documents.forEach { doc in
                batch.deleteDocument(doc.reference)
            }
            
            batch.commit { batchError in
                if let batchError = batchError {
                    completion(.failure(batchError))
                    return
                }
                
                // Then delete house document
                self.db.collection("houses").document(id).delete { deleteError in
                    if let deleteError = deleteError {
                        completion(.failure(deleteError))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }

    func updateHouseFields(
        id: String,
        data: [String: Any],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("houses").document(id).updateData(data) { error in
            if let error = error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }

    // MARK: - ROOMS (Subcollection: houses/{houseId}/rooms)

    func addRoom(
        toHouseId houseId: String,
        name: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let newRoom = Room(name: name)
        do {
            let ref = try db.collection("houses").document(houseId)
                .collection("rooms")
                .addDocument(from: newRoom)
            completion(.success(ref.documentID))
        } catch {
            completion(.failure(error))
        }
    }

    @discardableResult
    func fetchRooms(
        forHouseId houseId: String,
        completion: @escaping (Result<[Room], Error>) -> Void
    ) -> ListenerRegistration {
        return db.collection("houses").document(houseId)
            .collection("rooms")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                do {
                    let rooms = try snapshot?.documents.compactMap {
                        try $0.data(as: Room.self)
                    } ?? []
                    completion(.success(rooms))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    @discardableResult
    func observeRoom(
        houseId: String,
        roomId: String,
        completion: @escaping (Result<Room, Error>) -> Void
    ) -> ListenerRegistration {
        return db.collection("houses").document(houseId)
            .collection("rooms").document(roomId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let snapshot = snapshot, snapshot.exists else {
                    completion(.failure(NSError(
                        domain: "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Room not found"]
                    )))
                    return
                }
                do {
                    let room = try snapshot.data(as: Room.self)
                    completion(.success(room))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    func deleteRoom(
        fromHouseId houseId: String,
        roomId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("houses").document(houseId)
            .collection("rooms").document(roomId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func updateRoomName(
        houseId: String,
        roomId: String,
        newName: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("houses").document(houseId)
            .collection("rooms").document(roomId)
            .updateData(["name": newName]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func updateRoomImage(
        houseId: String,
        roomId: String,
        imageData: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("houses").document(houseId)
            .collection("rooms").document(roomId)
            .updateData(["imageData": imageData]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    // MARK: - MEASUREMENTS (Embedded in Room document)

    func addMeasurement(
        toHouseId houseId: String,
        roomId: String,
        measurement: Measurement,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let roomRef = db.collection("houses").document(houseId)
            .collection("rooms").document(roomId)
        
        roomRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                guard var room = try snapshot?.data(as: Room.self) else {
                    completion(.failure(NSError(
                        domain: "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Room not found"]
                    )))
                    return
                }
                room.measurements.append(measurement)
                try roomRef.setData(from: room)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteMeasurement(
        fromHouseId houseId: String,
        roomId: String,
        measurementId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let roomRef = db.collection("houses").document(houseId)
            .collection("rooms").document(roomId)
        
        roomRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                guard var room = try snapshot?.data(as: Room.self) else {
                    completion(.failure(NSError(
                        domain: "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Room not found"]
                    )))
                    return
                }
                room.measurements.removeAll { $0.id == measurementId }
                try roomRef.setData(from: room)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func updateMeasurement(
        fromHouseId houseId: String,
        roomId: String,
        measurementId: String,
        updatedMeasurement: Measurement,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let roomRef = db.collection("houses").document(houseId)
            .collection("rooms").document(roomId)
        
        roomRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                guard var room = try snapshot?.data(as: Room.self) else {
                    completion(.failure(NSError(
                        domain: "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Room not found"]
                    )))
                    return
                }
                guard let index = room.measurements.firstIndex(where: { $0.id == measurementId }) else {
                    completion(.failure(NSError(
                        domain: "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Measurement not found"]
                    )))
                    return
                }
                room.measurements[index] = updatedMeasurement
                try roomRef.setData(from: room)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func linkProductToMeasurement(
        houseId: String,
        roomId: String,
        measurementId: String,
        product: Product,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let roomRef = db.collection("houses").document(houseId)
            .collection("rooms").document(roomId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let roomDocument: DocumentSnapshot
            
            do {
                try roomDocument = transaction.getDocument(roomRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var room = try? roomDocument.data(as: Room.self) else {
                let error = NSError(
                    domain: "app.firestore",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Unable to decode room"]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            guard let index = room.measurements.firstIndex(where: { $0.id == measurementId }) else {
                let error = NSError(
                    domain: "app.firestore",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Measurement not found"]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            // Update measurement with product information
            room.measurements[index].productId = product.id ?? ""
            room.measurements[index].productName = product.name
            room.measurements[index].productPrice = product.price
            
            // Write updated room back
            do {
                try transaction.setData(from: room, forDocument: roomRef)
            } catch let writeError as NSError {
                errorPointer?.pointee = writeError
                return nil
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - PRODUCTS (Top-level collection)

    @discardableResult
    func fetchProducts(
        completion: @escaping (Result<[Product], Error>) -> Void
    ) -> ListenerRegistration {
        return db.collection("products").addSnapshotListener { snapshot, error in
            if let error = error { completion(.failure(error)); return }
            do {
                let products = try snapshot?.documents.compactMap {
                    try $0.data(as: Product.self)
                } ?? []
                completion(.success(products))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func addProduct(
        name: String,
        description: String,
        category: String,
        price: Double,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let product = Product(name: name, description: description, category: category, price: price)
        do {
            let ref = try db.collection("products").addDocument(from: product)
            completion(.success(ref.documentID))
        } catch {
            completion(.failure(error))
        }
    }

    func deleteProduct(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("products").document(id).delete { error in
            if let error = error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
    }

    func seedProductsIfNeeded() {
        db.collection("products").getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents, docs.isEmpty else { return }
            let seeds: [(String, String, String, Double)] = [
                ("Oak Hardwood",      "Premium solid oak flooring",        "Flooring", 85.00),
                ("Bamboo Flooring",   "Eco-friendly bamboo planks",        "Flooring", 65.00),
                ("Ceramic Tile",      "Classic ceramic floor tile",        "Flooring", 45.00),
                ("Vinyl Plank",       "Waterproof click-lock vinyl",       "Flooring", 35.00),
                ("Double Pane Glass", "Insulated double-glazed window",    "Window",   120.00),
                ("Frosted Glass",     "Privacy frosted window glass",      "Window",   150.00),
                ("Tinted Glass",      "UV-blocking tinted window glass",   "Window",   135.00),
                ("Laminated Glass",   "Safety laminated window glass",     "Window",   180.00),
            ]
            for (name, desc, cat, price) in seeds {
                self.addProduct(name: name, description: desc, category: cat, price: price) { _ in }
            }
        }
    }
}
