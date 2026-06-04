import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/house.dart';
import '../models/room.dart';
import '../models/measurement.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String housesCollection = 'houses';
  static const String productsCollection = 'products';

  // Stream of all houses
  Stream<List<House>> housesStream() {
    return _db.collection(housesCollection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => House.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add a new house
  Future<void> addHouse(House house) async {
    await _db.collection(housesCollection).doc(house.id).set(house.toMap());
  }

  // Stream of rooms for a specific house
  Stream<List<Room>> roomsStream(String houseId) {
    return _db
        .collection(housesCollection)
        .doc(houseId)
        .collection('rooms')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Room.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add a room to a house
  Future<void> addRoom(String houseId, Room room) async {
    await _db
        .collection(housesCollection)
        .doc(houseId)
        .collection('rooms')
        .doc(room.id)
        .set(room.toMap());
  }

  // Add a measurement to a room (using transaction for array update)
  Future<void> addMeasurement(
    String houseId,
    String roomId,
    Measurement measurement,
  ) async {
    await _db.runTransaction((transaction) async {
      final roomRef = _db
          .collection(housesCollection)
          .doc(houseId)
          .collection('rooms')
          .doc(roomId);

      final roomDoc = await transaction.get(roomRef);

      if (roomDoc.exists) {
        final measurements = (roomDoc['measurements'] as List<dynamic>?) ?? [];
        measurements.add(measurement.toMap());
        transaction.update(roomRef, {'measurements': measurements});
      }
    });
  }

  // Link a product to a measurement (transaction)
  Future<void> linkProductToMeasurement(
    String houseId,
    String roomId,
    String measurementId,
    Product product,
  ) async {
    await _db.runTransaction((transaction) async {
      final roomRef = _db
          .collection(housesCollection)
          .doc(houseId)
          .collection('rooms')
          .doc(roomId);

      final roomDoc = await transaction.get(roomRef);

      if (roomDoc.exists) {
        final measurements = (roomDoc['measurements'] as List<dynamic>?) ?? [];
        
        // Find and update the matching measurement
        for (int i = 0; i < measurements.length; i++) {
          if (measurements[i]['id'] == measurementId) {
            measurements[i]['productId'] = product.id;
            measurements[i]['productName'] = product.name;
            measurements[i]['productPrice'] = product.price;
            break;
          }
        }
        
        transaction.update(roomRef, {'measurements': measurements});
      }
    });
  }

  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    final snapshot = await _db.collection(productsCollection).get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Seed initial products
  Future<void> seedProducts() async {
    final productsRef = _db.collection(productsCollection);
    
    final products = [
      Product(
        id: 'product_1',
        name: 'Premium Hardwood',
        description: 'High-quality hardwood flooring',
        category: 'WOOD',
        price: 45.0,
      ),
      Product(
        id: 'product_2',
        name: 'Durable Vinyl',
        description: 'Durable vinyl flooring option',
        category: 'VINYL',
        price: 25.0,
      ),
      Product(
        id: 'product_3',
        name: 'Double-Pane Glass',
        description: 'Energy-efficient double-pane windows',
        category: 'WINDOW',
        price: 150.0,
      ),
      Product(
        id: 'product_4',
        name: 'Single-Pane Glass',
        description: 'Standard single-pane windows',
        category: 'WINDOW',
        price: 85.0,
      ),
    ];

    for (final product in products) {
      await productsRef.doc(product.id).set(product.toMap());
    }
  }

  // Fetch rooms once (not as stream)
  Future<List<Room>> fetchRoomsOnce(String houseId) async {
    final snapshot = await _db
        .collection(housesCollection)
        .doc(houseId)
        .collection('rooms')
        .get();

    return snapshot.docs
        .map((doc) => Room.fromMap(doc.data(), doc.id))
        .toList();
  }
}
