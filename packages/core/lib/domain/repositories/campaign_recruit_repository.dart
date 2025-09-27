import '../entities/campaign_recruit.dart';

abstract class CampaignRecruitRepository {
  Future<void> createRecruit(CampaignRecruit recruit);
  Future<CampaignRecruit?> getRecruitById(String id);
  Future<void> updateRecruit(CampaignRecruit recruit);
  Future<void> deleteRecruit(String id);
  Future<List<CampaignRecruit>> getAllRecruits();
  Future<List<CampaignRecruit>> getRecruitsByCampaign(String campaignId);
  Future<List<CampaignRecruit>> getRecruitsBySeller(String sellerId);
  Future<List<CampaignRecruit>> getRecruitsByApplicant(String phoneNumber);
  Future<List<CampaignRecruit>> getRecruitsByCampaignAndApplicant(
      String campaignId, String phoneNumber);
  Future<Map<String, int>> getRecruitCountsByCampaignAndType(String campaignId);
}
