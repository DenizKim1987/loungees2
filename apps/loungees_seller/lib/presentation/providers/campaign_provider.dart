// 캠페인 프로바이더 - 파이어베이스 연동
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class CampaignProvider with ChangeNotifier {
  final CreateCampaignUseCase _createCampaignUseCase;
  final UpdateCampaignUseCase _updateCampaignUseCase;
  final DeleteCampaignUseCase _deleteCampaignUseCase;
  final GetAllCampaignsUseCase _getAllCampaignsUseCase;
  final GetCampaignsBySellerUseCase _getCampaignsBySellerUseCase;
  final GetActiveCampaignsUseCase _getActiveCampaignsUseCase;

  CampaignProvider({
    required CreateCampaignUseCase createCampaignUseCase,
    required UpdateCampaignUseCase updateCampaignUseCase,
    required DeleteCampaignUseCase deleteCampaignUseCase,
    required GetAllCampaignsUseCase getAllCampaignsUseCase,
    required GetCampaignsBySellerUseCase getCampaignsBySellerUseCase,
    required GetActiveCampaignsUseCase getActiveCampaignsUseCase,
  }) : _createCampaignUseCase = createCampaignUseCase,
       _updateCampaignUseCase = updateCampaignUseCase,
       _deleteCampaignUseCase = deleteCampaignUseCase,
       _getAllCampaignsUseCase = getAllCampaignsUseCase,
       _getCampaignsBySellerUseCase = getCampaignsBySellerUseCase,
       _getActiveCampaignsUseCase = getActiveCampaignsUseCase;

  final List<Campaign> _campaigns = [];
  bool _isLoading = false;
  String? _error;

  List<Campaign> get campaigns => List.unmodifiable(_campaigns);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 캠페인 추가 (파이어베이스 연동)
  Future<void> addCampaign(Campaign campaign) async {
    try {
      print('CampaignProvider: 캠페인 추가 시작 - ${campaign.id}');
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _createCampaignUseCase(campaign);
      print('CampaignProvider: 캠페인 생성 완료, 목록 다시 로드 시작');
      await loadCampaigns(); // 전체 캠페인 다시 로드
      print('CampaignProvider: 캠페인 목록 로드 완료 - 총 ${_campaigns.length}개');
    } catch (e) {
      print('CampaignProvider: 캠페인 추가 오류 - $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 캠페인 수정 (파이어베이스 연동)
  Future<void> updateCampaign(String id, Campaign updatedCampaign) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _updateCampaignUseCase(updatedCampaign);
      await loadCampaigns(); // 전체 캠페인 다시 로드
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 캠페인 삭제 (파이어베이스 연동)
  Future<void> deleteCampaign(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _deleteCampaignUseCase(id);
      await loadCampaigns(); // 전체 캠페인 다시 로드
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 캠페인 목록 로드
  Future<void> loadCampaigns() async {
    try {
      print('CampaignProvider: 캠페인 목록 로드 시작');
      _isLoading = true;
      _error = null;
      notifyListeners();

      _campaigns.clear();
      final loadedCampaigns = await _getAllCampaignsUseCase();
      _campaigns.addAll(loadedCampaigns);
      print('CampaignProvider: 캠페인 목록 로드 완료 - ${loadedCampaigns.length}개 로드됨');
    } catch (e) {
      print('CampaignProvider: 캠페인 목록 로드 오류 - $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 셀러별 캠페인 로드
  Future<void> loadCampaignsBySeller(String sellerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _campaigns.clear();
      _campaigns.addAll(await _getCampaignsBySellerUseCase(sellerId));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 활성 캠페인 로드
  Future<void> loadActiveCampaigns() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _campaigns.clear();
      _campaigns.addAll(await _getActiveCampaignsUseCase());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ID로 캠페인 찾기
  Campaign? getCampaignById(String id) {
    try {
      return _campaigns.firstWhere((campaign) => campaign.id == id);
    } catch (e) {
      return null;
    }
  }

  // Short ID로 캠페인 찾기
  Campaign? getCampaignByShortId(String shortId) {
    try {
      return _campaigns.firstWhere((campaign) => campaign.shortId == shortId);
    } catch (e) {
      return null;
    }
  }

  // 셀러별 캠페인 조회
  List<Campaign> getCampaignsBySeller(String sellerId) {
    return _campaigns
        .where((campaign) => campaign.sellerId == sellerId)
        .toList();
  }

  // 활성 캠페인 조회 (오늘 이후 모집날짜)
  List<Campaign> getActiveCampaigns() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _campaigns
        .where((campaign) => campaign.recruitmentDate.compareTo(today) >= 0)
        .toList();
  }

  // 캠페인 개수
  int get campaignCount => _campaigns.length;

  // 특정 리뷰 조건이 있는 캠페인들 조회
  List<Campaign> getCampaignsByReviewType(String reviewType) {
    switch (reviewType.toLowerCase()) {
      case 'video':
        return _campaigns.where((campaign) => campaign.requireVideo).toList();
      case 'photo':
        return _campaigns.where((campaign) => campaign.requirePhotos).toList();
      case 'text':
        return _campaigns.where((campaign) => campaign.requireText).toList();
      case 'rating':
        return _campaigns.where((campaign) => campaign.requireRating).toList();
      case 'purchase':
        return _campaigns
            .where((campaign) => campaign.requirePurchase)
            .toList();
      default:
        return [];
    }
  }
}
