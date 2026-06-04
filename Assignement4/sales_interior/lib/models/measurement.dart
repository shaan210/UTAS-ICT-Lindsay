import 'package:uuid/uuid.dart';

class Measurement {
  final String id;
  final String type; // "WINDOW" or "FLOOR_SPACE"
  final double? width;
  final double? height;
  final double? area;
  final String productId;
  final String productName;
  final double productPrice;

  Measurement({
    String? id,
    required this.type,
    this.width,
    this.height,
    this.area,
    this.productId = '',
    this.productName = '',
    this.productPrice = 0.0,
  }) : id = id ?? const Uuid().v4();

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      id: map['id'] as String? ?? const Uuid().v4(),
      type: map['type'] as String? ?? '',
      width: (map['width'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      area: (map['area'] as num?)?.toDouble(),
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      productPrice: (map['productPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'width': width,
      'height': height,
      'area': area,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
    };
  }

  bool isValid() {
    if (type == 'WINDOW') {
      return width != null && width! > 0 && height != null && height! > 0;
    } else if (type == 'FLOOR_SPACE') {
      return area != null && area! > 0;
    }
    return false;
  }

  Measurement copyWith({
    String? id,
    String? type,
    double? width,
    double? height,
    double? area,
    String? productId,
    String? productName,
    double? productPrice,
  }) {
    return Measurement(
      id: id ?? this.id,
      type: type ?? this.type,
      width: width ?? this.width,
      height: height ?? this.height,
      area: area ?? this.area,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
    );
  }

  @override
  String toString() {
    return 'Measurement(id: $id, type: $type, width: $width, height: $height, area: $area, productId: $productId, productName: $productName, productPrice: $productPrice)';
  }
}
