// 아이템 엔티티
class Item {
  final String id; // 상품번호로 사용
  final String name;
  final int price;
  final String productNumber; // 상품번호 (id와 동일한 값)
  final String sellerCompany;
  final List<String> filters;
  final String? imageUrl; // 이미지 URL 추가
  final DateTime createdAt;
  final DateTime updatedAt;

  const Item({
    required this.id, // 상품번호
    required this.name,
    required this.price,
    required this.productNumber, // id와 동일한 값
    required this.sellerCompany,
    required this.filters,
    this.imageUrl, // 이미지 URL 추가
    required this.createdAt,
    required this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      productNumber: json['productNumber'] ?? '',
      sellerCompany: json['sellerCompany'] ?? '',
      filters: List<String>.from(json['filters'] ?? []),
      imageUrl: json['imageUrl'], // 이미지 URL 추가
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'productNumber': productNumber,
      'sellerCompany': sellerCompany,
      'filters': filters,
      'imageUrl': imageUrl, // 이미지 URL 추가
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Item copyWith({
    String? id,
    String? name,
    int? price,
    String? productNumber,
    String? sellerCompany,
    List<String>? filters,
    String? imageUrl, // 이미지 URL 추가
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      productNumber: productNumber ?? this.productNumber,
      sellerCompany: sellerCompany ?? this.sellerCompany,
      filters: filters ?? this.filters,
      imageUrl: imageUrl ?? this.imageUrl, // 이미지 URL 추가
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
