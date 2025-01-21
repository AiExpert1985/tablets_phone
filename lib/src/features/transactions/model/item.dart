import 'package:tablets/src/common/values/constants.dart';

class CartItem {
  int code;
  String name;
  String dbRef;
  double weight;
  List<String> imageUrls;
  double? sellingPrice;
  double? soldQuantity;
  double? giftQuantity;
  double? totalAmount;

  // Constructor
  CartItem({
    required this.code,
    required this.name,
    required this.dbRef,
    required this.weight,
    required this.imageUrls,
    this.sellingPrice,
    this.soldQuantity,
    this.giftQuantity,
    this.totalAmount,
  });

  String get coverImageUrl => imageUrls[imageUrls.length - 1];

  // Method to convert CartItem to a Map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'dbRef': dbRef,
      'weight': weight,
      'imageUrls': imageUrls,
      'sellingPrice': sellingPrice,
      'soldQuantity': soldQuantity,
      'giftQuantity': giftQuantity,
      'totalAmount': totalAmount,
    };
  }

  // Factory constructor to create a CartItem from a Map (for deserialization)
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      code: map['code'] ?? 0,
      name: map['name'] ?? 'unnamed',
      dbRef: map['dbRef'] ?? 'xxxx',
      weight: map['weight'] ?? 0,
      imageUrls: map['imageUrls'] ?? [defaultImageUrl],
      sellingPrice: map['sellingPrice'],
      soldQuantity: map['soldQuantity'],
      giftQuantity: map['giftQuantity'],
      totalAmount: map['totalAmount'],
    );
  }
}
