import '../entities/campaign_recruit.dart';
import '../repositories/campaign_recruit_repository.dart';

class CreateCampaignRecruitUseCase {
  final CampaignRecruitRepository repository;
  CreateCampaignRecruitUseCase(this.repository);
  
  Future<void> call(CampaignRecruit recruit) {
    return repository.createRecruit(recruit);
  }
}

class UpdateCampaignRecruitUseCase {
  final CampaignRecruitRepository repository;
  UpdateCampaignRecruitUseCase(this.repository);
  
  Future<void> call(CampaignRecruit recruit) {
    return repository.updateRecruit(recruit);
  }
}

class DeleteCampaignRecruitUseCase {
  final CampaignRecruitRepository repository;
  DeleteCampaignRecruitUseCase(this.repository);
  
  Future<void> call(String id) {
    return repository.deleteRecruit(id);
  }
}

class GetCampaignRecruitByIdUseCase {
  final CampaignRecruitRepository repository;
  GetCampaignRecruitByIdUseCase(this.repository);
  
  Future<CampaignRecruit?> call(String id) {
    return repository.getRecruitById(id);
  }
}

class GetAllCampaignRecruitsUseCase {
  final CampaignRecruitRepository repository;
  GetAllCampaignRecruitsUseCase(this.repository);
  
  Future<List<CampaignRecruit>> call() {
    return repository.getAllRecruits();
  }
}

class GetCampaignRecruitsByCampaignUseCase {
  final CampaignRecruitRepository repository;
  GetCampaignRecruitsByCampaignUseCase(this.repository);
  
  Future<List<CampaignRecruit>> call(String campaignId) {
    return repository.getRecruitsByCampaign(campaignId);
  }
}

class GetCampaignRecruitsBySellerUseCase {
  final CampaignRecruitRepository repository;
  GetCampaignRecruitsBySellerUseCase(this.repository);
  
  Future<List<CampaignRecruit>> call(String sellerId) {
    return repository.getRecruitsBySeller(sellerId);
  }
}

class GetCampaignRecruitsByStatusUseCase {
  final CampaignRecruitRepository repository;
  GetCampaignRecruitsByStatusUseCase(this.repository);
  
  Future<List<CampaignRecruit>> call(RecruitStatus status) {
    return repository.getRecruitsByStatus(status);
  }
}

class GetCampaignRecruitsByApplicantUseCase {
  final CampaignRecruitRepository repository;
  GetCampaignRecruitsByApplicantUseCase(this.repository);
  
  Future<List<CampaignRecruit>> call(String phoneNumber) {
    return repository.getRecruitsByApplicant(phoneNumber);
  }
}
