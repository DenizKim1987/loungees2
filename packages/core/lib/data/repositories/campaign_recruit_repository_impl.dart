import '../datasources/campaign_recruit_data_source.dart';
import '../../domain/entities/campaign_recruit.dart';
import '../../domain/repositories/campaign_recruit_repository.dart';

class CampaignRecruitRepositoryImpl implements CampaignRecruitRepository {
  final CampaignRecruitDataSource _dataSource;

  CampaignRecruitRepositoryImpl(this._dataSource);

  @override
  Future<void> createRecruit(CampaignRecruit recruit) {
    return _dataSource.createRecruit(recruit);
  }

  @override
  Future<CampaignRecruit?> getRecruitById(String id) {
    return _dataSource.getRecruitById(id);
  }

  @override
  Future<void> updateRecruit(CampaignRecruit recruit) {
    return _dataSource.updateRecruit(recruit);
  }

  @override
  Future<void> deleteRecruit(String id) {
    return _dataSource.deleteRecruit(id);
  }

  @override
  Future<List<CampaignRecruit>> getAllRecruits() {
    return _dataSource.getAllRecruits();
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsByCampaign(String campaignId) {
    return _dataSource.getRecruitsByCampaign(campaignId);
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsBySeller(String sellerId) {
    return _dataSource.getRecruitsBySeller(sellerId);
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsByStatus(RecruitStatus status) {
    return _dataSource.getRecruitsByStatus(status);
  }

  @override
  Future<List<CampaignRecruit>> getRecruitsByApplicant(String phoneNumber) {
    return _dataSource.getRecruitsByApplicant(phoneNumber);
  }
}
