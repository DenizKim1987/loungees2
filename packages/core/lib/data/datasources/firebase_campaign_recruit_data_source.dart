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
    print(
        'FirebaseCampaignRecruitDataSource: getRecruitsByCampaign 시작 - campaignId: $campaignId');
    final snapshot = await _firestore
        .collection(_collection)
        .where('campaignFullId', isEqualTo: campaignId)
        .get();

    print(
        'FirebaseCampaignRecruitDataSource: 쿼리 결과 - ${snapshot.docs.length}개 문서 발견');

    final recruits = snapshot.docs
        .map((doc) => CampaignRecruit.fromJson(doc.data()))
        .toList();

    print(
        'FirebaseCampaignRecruitDataSource: 변환된 모집 데이터 - ${recruits.length}개');

    return recruits;
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
    // 신청자 번호 기준으로 조회
    final snapshot = await _firestore
        .collection(_collection)
        .where('applicantPhone', isEqualTo: phoneNumber)
        .get();

    return snapshot.docs
        .map((doc) => CampaignRecruit.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsByCampaignAndApplicant(
      String campaignId, String phoneNumber) async {
    // 구매자 번호 기준으로만 중복 체크
    final snapshot = await _firestore
        .collection(_collection)
        .where('campaignId', isEqualTo: campaignId)
        .where('buyerPhone', isEqualTo: phoneNumber)
        .get();

    return snapshot.docs
        .map((doc) => CampaignRecruit.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<Map<String, int>> getRecruitCountsByCampaignAndType(
      String campaignId) async {
    print(
        'FirebaseCampaignRecruitDataSource: getRecruitCountsByCampaignAndType 시작 - campaignId: $campaignId');
    final snapshot = await _firestore
        .collection(_collection)
        .where('campaignFullId', isEqualTo: campaignId)
        .get();

    print(
        'FirebaseCampaignRecruitDataSource: getRecruitCountsByCampaignAndType 쿼리 결과 - ${snapshot.docs.length}개 문서 발견');

    final Map<String, int> counts = {};
    for (final doc in snapshot.docs) {
      final recruit = CampaignRecruit.fromJson(doc.data());
      counts[recruit.reviewType] = (counts[recruit.reviewType] ?? 0) + 1;
    }

    print(
        'FirebaseCampaignRecruitDataSource: getRecruitCountsByCampaignAndType 결과 - $counts');
    return counts;
  }
}
