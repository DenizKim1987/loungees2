// 캠페인 리포지토리 구현체
import '../../data/datasources/campaign_data_source.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/repositories/campaign_repository.dart';

class CampaignRepositoryImpl implements CampaignRepository {
  final CampaignDataSource _dataSource;

  CampaignRepositoryImpl(this._dataSource);

  @override
  Future<void> createCampaign(Campaign campaign) {
    return _dataSource.createCampaign(campaign);
  }

  @override
  Future<Campaign?> getCampaignById(String id) {
    return _dataSource.getCampaignById(id);
  }

  @override
  Future<void> updateCampaign(Campaign campaign) {
    return _dataSource.updateCampaign(campaign);
  }

  @override
  Future<void> deleteCampaign(String id) {
    return _dataSource.deleteCampaign(id);
  }

  @override
  Future<List<Campaign>> getAllCampaigns() {
    return _dataSource.getAllCampaigns();
  }

  @override
  Future<List<Campaign>> getCampaignsBySeller(String sellerId) {
    return _dataSource.getCampaignsBySeller(sellerId);
  }

  @override
  Future<List<Campaign>> getActiveCampaigns() {
    return _dataSource.getActiveCampaigns();
  }
}
