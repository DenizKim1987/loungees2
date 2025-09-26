import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/campaign_recruit.dart';
import 'campaign_recruit_data_source.dart';

class FirebaseCampaignRecruitDataSource implements CampaignRecruitDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'seller_campaign_recruits';

  @override
  Future<void> createRecruit(CampaignRecruit recruit) async {
    await _firestore.collection(_collection).doc(recruit.id).set(recruit.toJson());
  }

  @override
  Future<CampaignRecruit?> getRecruitById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return CampaignRecruit.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> updateRecruit(CampaignRecruit recruit) async {
    await _firestore.collection(_collection).doc(recruit.id).update(recruit.toJson());
  }

  @override
  Future<void> deleteRecruit(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<List<CampaignRecruit>> getAllRecruits() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => CampaignRecruit.fromJson(doc.data())).toList();
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsByCampaign(String campaignId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('campaignId', isEqualTo: campaignId)
        .get();
    return snapshot.docs.map((doc) => CampaignRecruit.fromJson(doc.data())).toList();
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsBySeller(String sellerId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('sellerId', isEqualTo: sellerId)
        .get();
    return snapshot.docs.map((doc) => CampaignRecruit.fromJson(doc.data())).toList();
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsByStatus(RecruitStatus status) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.name)
        .get();
    return snapshot.docs.map((doc) => CampaignRecruit.fromJson(doc.data())).toList();
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsByApplicant(String phoneNumber) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();
    return snapshot.docs.map((doc) => CampaignRecruit.fromJson(doc.data())).toList();
  }
}
