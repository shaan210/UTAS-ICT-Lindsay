import 'measurement.dart';

class Room {
  final String id;
  final String name;
  final List<Measurement> measurements;

  Room({
    required this.id,
    required this.name,
    this.measurements = const [],
  });

  factory Room.fromMap(Map<String, dynamic> map, String id) {
    final measurementsList = map['measurements'] as List<dynamic>? ?? [];
    final measurements = measurementsList
        .map((m) => Measurement.fromMap(m as Map<String, dynamic>))
        .toList();

    return Room(
      id: id,
      name: map['name'] as String? ?? '',
      measurements: measurements,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'measurements': measurements.map((m) => m.toMap()).toList(),
    };
  }

  Room copyWith({
    String? id,
    String? name,
    List<Measurement>? measurements,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      measurements: measurements ?? this.measurements,
    );
  }

  @override
  String toString() {
    return 'Room(id: $id, name: $name, measurements: $measurements)';
  }
}
