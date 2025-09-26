// 파이어베이스 아이템 데이터소스 구현
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/item.dart';
import 'item_data_source.dart';

class FirebaseItemDataSource implements ItemDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'seller_items';

  @override
  Future<void> createItem(Item item) async {
    await _firestore.collection(_collection).doc(item.id).set(item.toJson());
  }

  @override
  Future<Item?> getItemById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Item.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> updateItem(Item item) async {
    await _firestore.collection(_collection).doc(item.id).update(item.toJson());
  }

  @override
  Future<void> deleteItem(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<List<Item>> getAllItems() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => Item.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Item>> getItemsBySeller(String sellerId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('sellerCompany', isEqualTo: sellerId)
        .get();
    return snapshot.docs.map((doc) => Item.fromJson(doc.data())).toList();
  }

  @override
  Future<bool> existsByProductNumber(String productNumber) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('productNumber', isEqualTo: productNumber)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
