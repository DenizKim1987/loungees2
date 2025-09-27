// 캠페인 리포지토리 인터페이스
import '../entities/campaign.dart';

abstract class CampaignRepository {
  Future<void> createCampaign(Campaign campaign);
  Future<Campaign?> getCampaignById(String id);
  Future<Campaign?> getCampaignByShortId(String shortId);
  Future<void> updateCampaign(Campaign campaign);
  Future<void> deleteCampaign(String id);
  Future<List<Campaign>> getAllCampaigns();
  Future<List<Campaign>> getCampaignsBySeller(String sellerId);
  Future<List<Campaign>> getActiveCampaigns(); // 활성 캠페인들 (모집날짜가 오늘 이후)
}
