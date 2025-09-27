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

class GetCampaignRecruitsByApplicantUseCase {
  final CampaignRecruitRepository repository;
  GetCampaignRecruitsByApplicantUseCase(this.repository);

  Future<List<CampaignRecruit>> call(String phoneNumber) {
    return repository.getRecruitsByApplicant(phoneNumber);
  }
}

class GetRecruitCountsByCampaignAndTypeUseCase {
  final CampaignRecruitRepository repository;
  GetRecruitCountsByCampaignAndTypeUseCase(this.repository);

  Future<Map<String, int>> call(String campaignId) {
    return repository.getRecruitCountsByCampaignAndType(campaignId);
  }
}

class CheckDuplicateApplicationUseCase {
  final CampaignRecruitRepository repository;
  CheckDuplicateApplicationUseCase(this.repository);

  Future<bool> call(
      String campaignId, String applicantPhone, String buyerPhone) async {
    // 신청자 전화번호로 중복 체크
    final applicantRecruits = await repository
        .getRecruitsByCampaignAndApplicant(campaignId, applicantPhone);
    if (applicantRecruits.isNotEmpty) {
      print(
          'CheckDuplicateApplicationUseCase: 신청자 중복 - applicantPhone=$applicantPhone, campaignId=$campaignId, foundRecruits=${applicantRecruits.length}');
      return true;
    }

    // 구매자 전화번호로 중복 체크 (신청자와 다른 경우)
    if (applicantPhone != buyerPhone) {
      final buyerRecruits = await repository.getRecruitsByCampaignAndApplicant(
          campaignId, buyerPhone);
      if (buyerRecruits.isNotEmpty) {
        print(
            'CheckDuplicateApplicationUseCase: 구매자 중복 - buyerPhone=$buyerPhone, campaignId=$campaignId, foundRecruits=${buyerRecruits.length}');
        return true;
      }
    }

    print(
        'CheckDuplicateApplicationUseCase: 중복 없음 - applicantPhone=$applicantPhone, buyerPhone=$buyerPhone, campaignId=$campaignId');
    return false;
  }
}

class CheckRecruitTypeClosedUseCase {
  final CampaignRecruitRepository repository;
  CheckRecruitTypeClosedUseCase(this.repository);

  Future<bool> call(String campaignId, String reviewType, int maxCount) async {
    final counts =
        await repository.getRecruitCountsByCampaignAndType(campaignId);
    final currentCount = counts[reviewType] ?? 0;
    print(
        'CheckRecruitTypeClosedUseCase: campaignId=$campaignId, reviewType=$reviewType, currentCount=$currentCount, maxCount=$maxCount, isClosed=${currentCount >= maxCount}');
    return currentCount >= maxCount;
  }
}

class ValidateAndCreateRecruitUseCase {
  final CampaignRecruitRepository repository;
  final CheckDuplicateApplicationUseCase checkDuplicateUseCase;
  final CheckRecruitTypeClosedUseCase checkClosedUseCase;

  ValidateAndCreateRecruitUseCase(
    this.repository,
    this.checkDuplicateUseCase,
    this.checkClosedUseCase,
  );

  Future<RecruitValidationResult> call({
    required String campaignId,
    required String applicantPhone,
    required String buyerPhone,
    required String reviewType,
    required int maxCount,
    required CampaignRecruit recruit,
  }) async {
    print(
        'ValidateAndCreateRecruitUseCase: 검증 시작 - campaignId=$campaignId, applicantPhone=$applicantPhone, buyerPhone=$buyerPhone, reviewType=$reviewType, maxCount=$maxCount');

    // 1. 중복 신청 체크
    final isDuplicate =
        await checkDuplicateUseCase(campaignId, applicantPhone, buyerPhone);
    print(
        'ValidateAndCreateRecruitUseCase: 중복 체크 결과 - isDuplicate=$isDuplicate');
    if (isDuplicate) {
      return RecruitValidationResult.duplicate();
    }

    // 2. 모집 마감 체크
    final isClosed = await checkClosedUseCase(campaignId, reviewType, maxCount);
    print('ValidateAndCreateRecruitUseCase: 마감 체크 결과 - isClosed=$isClosed');
    if (isClosed) {
      return RecruitValidationResult.closed();
    }

    // 3. 유효성 검사 통과 시 등록
    try {
      print('ValidateAndCreateRecruitUseCase: 유효성 검사 통과, 모집 등록 시작');
      await repository.createRecruit(recruit);
      print('ValidateAndCreateRecruitUseCase: 모집 등록 완료');
      return RecruitValidationResult.success();
    } catch (e) {
      print('ValidateAndCreateRecruitUseCase: 모집 등록 실패 - $e');
      return RecruitValidationResult.error(e.toString());
    }
  }
}

class RecruitValidationResult {
  final bool isValid;
  final String? errorMessage;
  final RecruitValidationError? errorType;

  RecruitValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.errorType,
  });

  factory RecruitValidationResult.success() {
    return RecruitValidationResult._(isValid: true);
  }

  factory RecruitValidationResult.duplicate() {
    return RecruitValidationResult._(
      isValid: false,
      errorMessage: '이미 신청하신 캠페인입니다.',
      errorType: RecruitValidationError.duplicate,
    );
  }

  factory RecruitValidationResult.closed() {
    return RecruitValidationResult._(
      isValid: false,
      errorMessage: '해당 리뷰 타입의 모집이 마감되었습니다.',
      errorType: RecruitValidationError.closed,
    );
  }

  factory RecruitValidationResult.error(String message) {
    return RecruitValidationResult._(
      isValid: false,
      errorMessage: message,
      errorType: RecruitValidationError.system,
    );
  }
}

enum RecruitValidationError {
  duplicate,
  closed,
  system,
}
