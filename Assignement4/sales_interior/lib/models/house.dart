class House {
  final String id;
  final String clientName;
  final String projectCode;
  final String street;
  final String city;
  final String postcode;

  House({
    required this.id,
    required this.clientName,
    required this.projectCode,
    required this.street,
    required this.city,
    required this.postcode,
  });

  factory House.fromMap(Map<String, dynamic> map, String id) {
    return House(
      id: id,
      clientName: map['clientName'] as String? ?? '',
      projectCode: map['projectCode'] as String? ?? '',
      street: map['street'] as String? ?? '',
      city: map['city'] as String? ?? '',
      postcode: map['postcode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'projectCode': projectCode,
      'street': street,
      'city': city,
      'postcode': postcode,
    };
  }

  @override
  String toString() {
    return 'House(id: $id, clientName: $clientName, projectCode: $projectCode, street: $street, city: $city, postcode: $postcode)';
  }
}
