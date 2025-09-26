// 파이어베이스 캠페인 데이터소스 구현
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/campaign.dart';
import 'campaign_data_source.dart';

class FirebaseCampaignDataSource implements CampaignDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'seller_campaigns';

  @override
  Future<void> createCampaign(Campaign campaign) async {
    await _firestore
        .collection(_collection)
        .doc(campaign.id)
        .set(campaign.toJson());
  }

  @override
  Future<Campaign?> getCampaignById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Campaign.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> updateCampaign(Campaign campaign) async {
    await _firestore
        .collection(_collection)
        .doc(campaign.id)
        .update(campaign.toJson());
  }

  @override
  Future<void> deleteCampaign(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<List<Campaign>> getAllCampaigns() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => Campaign.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Campaign>> getCampaignsBySeller(String sellerId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('sellerId', isEqualTo: sellerId)
        .get();
    return snapshot.docs.map((doc) => Campaign.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Campaign>> getActiveCampaigns() async {
    final today =
        DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD 형식
    final snapshot = await _firestore
        .collection(_collection)
        .where('recruitmentDate', isGreaterThanOrEqualTo: today)
        .get();
    return snapshot.docs.map((doc) => Campaign.fromJson(doc.data())).toList();
  }
}
