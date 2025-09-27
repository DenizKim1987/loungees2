import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/campaign_recruit.dart';
import 'campaign_recruit_data_source.dart';

class FirebaseCampaignRecruitDataSource implements CampaignRecruitDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'seller_campaign_recruits';

  @override
  Future<void> createRecruit(CampaignRecruit recruit) async {
    await _firestore
        .collection(_collection)
        .doc(recruit.id)
        .set(recruit.toJson());
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
    await _firestore
        .collection(_collection)
        .doc(recruit.id)
        .update(recruit.toJson());
  }

  @override
  Future<void> deleteRecruit(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<List<CampaignRecruit>> getAllRecruits() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => CampaignRecruit.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsByCampaign(String campaignId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('campaignId', isEqualTo: campaignId)
        .get();
    return snapshot.docs
        .map((doc) => CampaignRecruit.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsBySeller(String sellerId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('sellerId', isEqualTo: sellerId)
        .get();
    return snapshot.docs
        .map((doc) => CampaignRecruit.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsByApplicant(
      String phoneNumber) async {
    // applicantPhone 또는 buyerPhone으로 검색
    final applicantSnapshot = await _firestore
        .collection(_collection)
        .where('applicantPhone', isEqualTo: phoneNumber)
        .get();

    final buyerSnapshot = await _firestore
        .collection(_collection)
        .where('buyerPhone', isEqualTo: phoneNumber)
        .get();

    final allDocs = [...applicantSnapshot.docs, ...buyerSnapshot.docs];

    // 중복 제거 (같은 문서가 두 번 나올 수 있음)
    final uniqueDocs = allDocs
        .fold<Map<String, QueryDocumentSnapshot>>(
          {},
          (map, doc) {
            map[doc.id] = doc;
            return map;
          },
        )
        .values
        .toList();

    return uniqueDocs
        .map((doc) =>
            CampaignRecruit.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsByCampaignAndApplicant(
      String campaignId, String phoneNumber) async {
    // applicantPhone 또는 buyerPhone으로 검색
    final applicantSnapshot = await _firestore
        .collection(_collection)
        .where('campaignId', isEqualTo: campaignId)
        .where('applicantPhone', isEqualTo: phoneNumber)
        .get();

    final buyerSnapshot = await _firestore
        .collection(_collection)
        .where('campaignId', isEqualTo: campaignId)
        .where('buyerPhone', isEqualTo: phoneNumber)
        .get();

    final allDocs = [...applicantSnapshot.docs, ...buyerSnapshot.docs];

    // 중복 제거 (같은 문서가 두 번 나올 수 있음)
    final uniqueDocs = allDocs
        .fold<Map<String, QueryDocumentSnapshot>>(
          {},
          (map, doc) {
            map[doc.id] = doc;
            return map;
          },
        )
        .values
        .toList();

    return uniqueDocs
        .map((doc) =>
            CampaignRecruit.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, int>> getRecruitCountsByCampaignAndType(
      String campaignId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('campaignId', isEqualTo: campaignId)
        .get();

    final Map<String, int> counts = {};
    for (final doc in snapshot.docs) {
      final recruit = CampaignRecruit.fromJson(doc.data());
      counts[recruit.reviewType] = (counts[recruit.reviewType] ?? 0) + 1;
    }

    return counts;
  }
}
