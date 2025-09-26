// 캠페인 유즈케이스
import '../entities/campaign.dart';
import '../repositories/campaign_repository.dart';

// 캠페인 생성 유즈케이스
class CreateCampaignUseCase {
  final CampaignRepository repository;

  CreateCampaignUseCase(this.repository);

  Future<void> call(Campaign campaign) {
    return repository.createCampaign(campaign);
  }
}

// 캠페인 수정 유즈케이스
class UpdateCampaignUseCase {
  final CampaignRepository repository;

  UpdateCampaignUseCase(this.repository);

  Future<void> call(Campaign campaign) {
    return repository.updateCampaign(campaign);
  }
}

// 캠페인 삭제 유즈케이스
class DeleteCampaignUseCase {
  final CampaignRepository repository;

  DeleteCampaignUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteCampaign(id);
  }
}

// 모든 캠페인 조회 유즈케이스
class GetAllCampaignsUseCase {
  final CampaignRepository repository;

  GetAllCampaignsUseCase(this.repository);

  Future<List<Campaign>> call() {
    return repository.getAllCampaigns();
  }
}

// 셀러별 캠페인 조회 유즈케이스
class GetCampaignsBySellerUseCase {
  final CampaignRepository repository;

  GetCampaignsBySellerUseCase(this.repository);

  Future<List<Campaign>> call(String sellerId) {
    return repository.getCampaignsBySeller(sellerId);
  }
}

// 활성 캠페인 조회 유즈케이스
class GetActiveCampaignsUseCase {
  final CampaignRepository repository;

  GetActiveCampaignsUseCase(this.repository);

  Future<List<Campaign>> call() {
    return repository.getActiveCampaigns();
  }
}

// ID로 캠페인 조회 유즈케이스
class GetCampaignByIdUseCase {
  final CampaignRepository repository;

  GetCampaignByIdUseCase(this.repository);

  Future<Campaign?> call(String id) {
    return repository.getCampaignById(id);
  }
}
