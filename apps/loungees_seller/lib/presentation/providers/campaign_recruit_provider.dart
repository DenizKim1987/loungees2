import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class CampaignRecruitProvider with ChangeNotifier {
  final UpdateCampaignRecruitUseCase _updateRecruitUseCase;
  final DeleteCampaignRecruitUseCase _deleteRecruitUseCase;
  final GetAllCampaignRecruitsUseCase _getAllRecruitsUseCase;
  final GetCampaignRecruitsByCampaignUseCase _getRecruitsByCampaignUseCase;
  final GetCampaignRecruitsBySellerUseCase _getRecruitsBySellerUseCase;
  final GetCampaignRecruitsByApplicantUseCase _getRecruitsByApplicantUseCase;
  final ValidateAndCreateRecruitUseCase _validateAndCreateRecruitUseCase;

  CampaignRecruitProvider({
    required UpdateCampaignRecruitUseCase updateRecruitUseCase,
    required DeleteCampaignRecruitUseCase deleteRecruitUseCase,
    required GetAllCampaignRecruitsUseCase getAllRecruitsUseCase,
    required GetCampaignRecruitsByCampaignUseCase getRecruitsByCampaignUseCase,
    required GetCampaignRecruitsBySellerUseCase getRecruitsBySellerUseCase,
    required GetCampaignRecruitsByApplicantUseCase
    getRecruitsByApplicantUseCase,
    required ValidateAndCreateRecruitUseCase validateAndCreateRecruitUseCase,
  }) : _updateRecruitUseCase = updateRecruitUseCase,
       _deleteRecruitUseCase = deleteRecruitUseCase,
       _getAllRecruitsUseCase = getAllRecruitsUseCase,
       _getRecruitsByCampaignUseCase = getRecruitsByCampaignUseCase,
       _getRecruitsBySellerUseCase = getRecruitsBySellerUseCase,
       _getRecruitsByApplicantUseCase = getRecruitsByApplicantUseCase,
       _validateAndCreateRecruitUseCase = validateAndCreateRecruitUseCase;

  final List<CampaignRecruit> _recruits = [];
  bool _isLoading = false;
  String? _error;

  List<CampaignRecruit> get recruits => List.unmodifiable(_recruits);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 캠페인 모집 생성
  Future<void> createRecruit({
    required String campaignId,
    required String campaignFullId,
    required String sellerId,
    required String applicantName,
    required String applicantPhone,
    required String applicantAccountNumber,
    required String buyerName,
    required String buyerPhone,
    required String reviewNickname,
    required String buyerAccountNumber,
    required bool isAccountUnified,
    required String reviewType,
    required int maxCount,
    int? reviewFee,
    String? campaignItemName,
    String? campaignItemImageUrl,
    double? campaignItemPrice,
    String? campaignRecruitmentDate,
    int? photoCount,
    int? textLength,
  }) async {
    try {
      print('CampaignRecruitProvider: 모집 생성 시작');
      _isLoading = true;
      _error = null;
      notifyListeners();

      final recruit = CampaignRecruit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        campaignId: campaignId,
        campaignFullId: campaignFullId,
        sellerId: sellerId,
        applicantName: applicantName,
        applicantPhone: applicantPhone,
        applicantAccountNumber: applicantAccountNumber,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
        reviewNickname: reviewNickname,
        buyerAccountNumber: buyerAccountNumber,
        isAccountUnified: isAccountUnified,
        reviewType: reviewType,
        reviewFee: reviewFee,
        campaignItemName: campaignItemName,
        campaignItemImageUrl: campaignItemImageUrl,
        campaignItemPrice: campaignItemPrice,
        campaignRecruitmentDate: campaignRecruitmentDate,
        photoCount: photoCount,
        textLength: textLength,
        isPurchased: false,
        isReviewCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _validateAndCreateRecruitUseCase(
        campaignId: campaignId,
        applicantPhone: applicantPhone,
        buyerPhone: buyerPhone,
        reviewType: reviewType,
        maxCount: maxCount, // 실제 maxCount 사용
        recruit: recruit,
      );

      if (result.isValid) {
        print('CampaignRecruitProvider: 모집 생성 완료, 목록 다시 로드 시작');
        await loadRecruits(); // 전체 모집 다시 로드
        print('CampaignRecruitProvider: 모집 목록 로드 완료 - 총 ${_recruits.length}개');
      } else {
        print('CampaignRecruitProvider: 모집 생성 실패 - ${result.errorMessage}');
        _error = result.errorMessage;
        // Exception: 접두사 없이 자연스러운 메시지 전달
        throw Exception(result.errorMessage ?? '신청 처리 중 문제가 발생했습니다.');
      }
    } catch (e) {
      print('CampaignRecruitProvider: 모집 생성 오류 - $e');
      _error = e.toString();
      // Exception: 접두사 제거하여 자연스러운 메시지 전달
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      throw Exception(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 캠페인 모집 수정
  Future<void> updateRecruit(CampaignRecruit recruit) async {
    try {
      print('CampaignRecruitProvider: 모집 수정 시작 - ${recruit.id}');
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _updateRecruitUseCase(recruit);
      print('CampaignRecruitProvider: 모집 수정 완료, 목록 다시 로드 시작');
      await loadRecruits(); // 전체 모집 다시 로드
      print('CampaignRecruitProvider: 모집 목록 로드 완료 - 총 ${_recruits.length}개');
    } catch (e) {
      print('CampaignRecruitProvider: 모집 수정 오류 - $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 캠페인 모집 구매완료 상태 업데이트
  Future<void> updatePurchaseStatus(String recruitId, bool isPurchased) async {
    try {
      print(
        'CampaignRecruitProvider: 구매완료 상태 업데이트 시작 - $recruitId -> $isPurchased',
      );
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 해당 recruit 찾기
      final recruit = _recruits.firstWhere(
        (r) => r.id == recruitId,
        orElse: () => throw Exception('해당 모집을 찾을 수 없습니다'),
      );

      // 상태 업데이트된 recruit 생성
      final updatedRecruit = recruit.copyWith(
        isPurchased: isPurchased,
        updatedAt: DateTime.now(),
      );

      await _updateRecruitUseCase(updatedRecruit);
      print('CampaignRecruitProvider: 모집 상태 업데이트 완료, 목록 다시 로드 시작');
      await loadRecruits(); // 전체 모집 다시 로드
      print('CampaignRecruitProvider: 모집 목록 로드 완료 - 총 ${_recruits.length}개');
    } catch (e) {
      print('CampaignRecruitProvider: 모집 상태 업데이트 오류 - $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 캠페인 모집 리뷰완료 상태 업데이트
  Future<void> updateReviewStatus(
    String recruitId,
    bool isReviewCompleted,
  ) async {
    try {
      print(
        'CampaignRecruitProvider: 리뷰완료 상태 업데이트 시작 - $recruitId -> $isReviewCompleted',
      );
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 해당 recruit 찾기
      final recruit = _recruits.firstWhere(
        (r) => r.id == recruitId,
        orElse: () => throw Exception('해당 모집을 찾을 수 없습니다'),
      );

      // 상태 업데이트된 recruit 생성
      final updatedRecruit = recruit.copyWith(
        isReviewCompleted: isReviewCompleted,
        updatedAt: DateTime.now(),
      );

      await _updateRecruitUseCase(updatedRecruit);
      print('CampaignRecruitProvider: 리뷰완료 상태 업데이트 완료, 목록 다시 로드 시작');
      await loadRecruits(); // 전체 모집 다시 로드
      print('CampaignRecruitProvider: 모집 목록 로드 완료 - 총 ${_recruits.length}개');
    } catch (e) {
      print('CampaignRecruitProvider: 리뷰완료 상태 업데이트 오류 - $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 캠페인 모집 삭제
  Future<void> deleteRecruit(String id) async {
    try {
      print('CampaignRecruitProvider: 모집 삭제 시작 - $id');
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _deleteRecruitUseCase(id);
      print('CampaignRecruitProvider: 모집 삭제 완료, 목록 다시 로드 시작');
      await loadRecruits(); // 전체 모집 다시 로드
      print('CampaignRecruitProvider: 모집 목록 로드 완료 - 총 ${_recruits.length}개');
    } catch (e) {
      print('CampaignRecruitProvider: 모집 삭제 오류 - $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 전체 모집 목록 로드
  Future<void> loadRecruits() async {
    try {
      print('CampaignRecruitProvider: 모집 목록 로드 시작');
      _isLoading = true;
      _error = null;
      notifyListeners();

      _recruits.clear();
      final loadedRecruits = await _getAllRecruitsUseCase();
      _recruits.addAll(loadedRecruits);
      print(
        'CampaignRecruitProvider: 모집 목록 로드 완료 - ${loadedRecruits.length}개 로드됨',
      );
    } catch (e) {
      print('CampaignRecruitProvider: 모집 목록 로드 오류 - $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 캠페인별 모집 로드
  Future<void> loadRecruitsByCampaign(String campaignId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _recruits.clear();
      _recruits.addAll(await _getRecruitsByCampaignUseCase(campaignId));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 셀러별 모집 로드
  Future<void> loadRecruitsBySeller(String sellerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _recruits.clear();
      _recruits.addAll(await _getRecruitsBySellerUseCase(sellerId));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 모집자별 모집 로드
  Future<void> loadRecruitsByApplicant(String phoneNumber) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _recruits.clear();
      _recruits.addAll(await _getRecruitsByApplicantUseCase(phoneNumber));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ID로 모집 찾기
  CampaignRecruit? getRecruitById(String id) {
    try {
      return _recruits.firstWhere((recruit) => recruit.id == id);
    } catch (e) {
      return null;
    }
  }

  // 모집 개수
  // 특정 캠페인의 특정 리뷰 타입별 신청자 수 조회
  Future<Map<String, int>> getRecruitCountsByCampaignAndType(
    String campaignId,
  ) async {
    try {
      print('CampaignRecruitProvider: 캠페인별 리뷰 타입 신청자 수 조회 시작 - $campaignId');
      _isLoading = true;
      notifyListeners();

      final recruits = await _getRecruitsByCampaignUseCase(campaignId);

      // 리뷰 타입별로 카운트
      final Map<String, int> counts = {};
      for (final recruit in recruits) {
        counts[recruit.reviewType] = (counts[recruit.reviewType] ?? 0) + 1;
      }

      print('CampaignRecruitProvider: 캠페인별 리뷰 타입 신청자 수 조회 완료 - $counts');
      return counts;
    } catch (e) {
      print('CampaignRecruitProvider: 캠페인별 리뷰 타입 신청자 수 조회 오류 - $e');
      _error = e.toString();
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 특정 캠페인의 특정 리뷰 타입별 신청자 수 조회 (캐시된 데이터 사용)
  Map<String, int> getRecruitCountsByCampaignAndTypeCached(String campaignId) {
    final recruits =
        _recruits.where((recruit) => recruit.campaignId == campaignId).toList();

    // 리뷰 타입별로 카운트
    final Map<String, int> counts = {};
    for (final recruit in recruits) {
      counts[recruit.reviewType] = (counts[recruit.reviewType] ?? 0) + 1;
    }

    print(
      'CampaignRecruitProvider: getRecruitCountsByCampaignAndTypeCached - campaignId=$campaignId, counts=$counts',
    );
    return counts;
  }

  // 모집 개수
  int get recruitCount => _recruits.length;
}
