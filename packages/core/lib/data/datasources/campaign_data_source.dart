// 캠페인 데이터소스 인터페이스
import '../../domain/entities/campaign.dart';

abstract class CampaignDataSource {
  Future<void> createCampaign(Campaign campaign);
  Future<Campaign?> getCampaignById(String id);
  Future<void> updateCampaign(Campaign campaign);
  Future<void> deleteCampaign(String id);
  Future<List<Campaign>> getAllCampaigns();
  Future<List<Campaign>> getCampaignsBySeller(String sellerId);
  Future<List<Campaign>> getActiveCampaigns();
}
