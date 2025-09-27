// 캠페인 프로바이더 - 파이어베이스 연동
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class CampaignProvider with ChangeNotifier {
  final CreateCampaignUseCase _createCampaignUseCase;
  final UpdateCampaignUseCase _updateCampaignUseCase;
  final DeleteCampaignUseCase _deleteCampaignUseCase;
  final GetAllCampaignsUseCase _getAllCampaignsUseCase;
  final GetCampaignsBySellerUseCase _getCampaignsBySellerUseCase;
  final GetActiveCampaignsUseCase _getActiveCampaignsUseCase;
  final GetCampaignByShortIdUseCase _getCampaignByShortIdUseCase;
  final GetRecruitCountsByCampaignAndTypeUseCase
  _getRecruitCountsByCampaignAndTypeUseCase;

  final PartnersService _partnersService = PartnersService();

  CampaignProvider({
    required CreateCampaignUseCase createCampaignUseCase,
    required UpdateCampaignUseCase updateCampaignUseCase,
    required DeleteCampaignUseCase deleteCampaignUseCase,
    required GetAllCampaignsUseCase getAllCampaignsUseCase,
    required GetCampaignsBySellerUseCase getCampaignsBySellerUseCase,
    required GetActiveCampaignsUseCase getActiveCampaignsUseCase,
    required GetCampaignByShortIdUseCase getCampaignByShortIdUseCase,
    required GetRecruitCountsByCampaignAndTypeUseCase
    getRecruitCountsByCampaignAndTypeUseCase,
  }) : _createCampaignUseCase = createCampaignUseCase,
       _updateCampaignUseCase = updateCampaignUseCase,
       _deleteCampaignUseCase = deleteCampaignUseCase,
       _getAllCampaignsUseCase = getAllCampaignsUseCase,
       _getCampaignsBySellerUseCase = getCampaignsBySellerUseCase,
       _getActiveCampaignsUseCase = getActiveCampaignsUseCase,
       _getCampaignByShortIdUseCase = getCampaignByShortIdUseCase,
       _getRecruitCountsByCampaignAndTypeUseCase =
           getRecruitCountsByCampaignAndTypeUseCase;

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

      // 쿠팡 파트너스 링크 생성
      String? mainKeywordLink;
      String? subKeywordLink;
      String? productLink;

      try {
        // 메인 키워드 링크 생성 (웹 + 딥링크)
        if (campaign.keywords.isNotEmpty) {
          final searchLinks = await _partnersService.generateSearchLinks(
            campaign.keywords,
          );
          mainKeywordLink = searchLinks['web']; // 웹 링크 사용
          print('CampaignProvider: 메인 키워드 링크 생성 완료 - $mainKeywordLink');
        }

        // 서브 키워드 링크 생성 (웹 + 딥링크)
        if (campaign.subKeywords.isNotEmpty) {
          final searchLinks = await _partnersService.generateSearchLinks(
            campaign.subKeywords,
          );
          subKeywordLink = searchLinks['web']; // 웹 링크 사용
          print('CampaignProvider: 서브 키워드 링크 생성 완료 - $subKeywordLink');
        }

        // 상품 링크 생성 (웹 + 딥링크)
        if (campaign.item.productUrl != null &&
            campaign.item.productUrl!.isNotEmpty) {
          final productLinks = await _partnersService.generateProductLinks(
            campaign.item.productUrl!,
          );
          productLink = productLinks['web']; // 웹 링크 사용
          print('CampaignProvider: 상품 링크 생성 완료 - $productLink');
        }
      } catch (e) {
        print('CampaignProvider: 쿠팡 링크 생성 오류 - $e');
        // 링크 생성 실패해도 캠페인은 생성하도록 진행
      }

      // 쿠팡 링크가 포함된 캠페인 생성
      final campaignWithLinks = campaign.copyWith(
        mainKeywordLink: mainKeywordLink,
        subKeywordLink: subKeywordLink,
        productLink: productLink,
      );

      await _createCampaignUseCase(campaignWithLinks);
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
      print('CampaignProvider: 캠페인 수정 시작 - $id');
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 기존 캠페인 정보 가져오기
      final existingCampaign = _campaigns.firstWhere(
        (c) => c.id == id,
        orElse: () => updatedCampaign,
      );

      // 쿠팡 파트너스 링크 생성/업데이트
      String? mainKeywordLink = updatedCampaign.mainKeywordLink;
      String? subKeywordLink = updatedCampaign.subKeywordLink;
      String? productLink = updatedCampaign.productLink;

      try {
        // 메인 키워드가 변경되었거나 링크가 비어있는 경우 재생성
        if (updatedCampaign.keywords != existingCampaign.keywords ||
            updatedCampaign.mainKeywordLink == null ||
            updatedCampaign.mainKeywordLink!.isEmpty) {
          if (updatedCampaign.keywords.isNotEmpty) {
            final searchLinks = await _partnersService.generateSearchLinks(
              updatedCampaign.keywords,
            );
            mainKeywordLink = searchLinks['web'];
            print('CampaignProvider: 메인 키워드 링크 재생성 완료 - $mainKeywordLink');
          } else {
            mainKeywordLink = null;
            print('CampaignProvider: 메인 키워드가 비어있어 링크 제거');
          }
        }

        // 서브 키워드가 변경되었거나 링크가 비어있는 경우 재생성
        if (updatedCampaign.subKeywords != existingCampaign.subKeywords ||
            updatedCampaign.subKeywordLink == null ||
            updatedCampaign.subKeywordLink!.isEmpty) {
          if (updatedCampaign.subKeywords.isNotEmpty) {
            final searchLinks = await _partnersService.generateSearchLinks(
              updatedCampaign.subKeywords,
            );
            subKeywordLink = searchLinks['web'];
            print('CampaignProvider: 서브 키워드 링크 재생성 완료 - $subKeywordLink');
          } else {
            subKeywordLink = null;
            print('CampaignProvider: 서브 키워드가 비어있어 링크 제거');
          }
        }

        // 상품 URL이 변경되었거나 링크가 비어있는 경우 재생성
        if (updatedCampaign.item.productUrl !=
                existingCampaign.item.productUrl ||
            updatedCampaign.productLink == null ||
            updatedCampaign.productLink!.isEmpty) {
          if (updatedCampaign.item.productUrl != null &&
              updatedCampaign.item.productUrl!.isNotEmpty) {
            final productLinks = await _partnersService.generateProductLinks(
              updatedCampaign.item.productUrl!,
            );
            productLink = productLinks['web'];
            print('CampaignProvider: 상품 링크 재생성 완료 - $productLink');
          } else {
            productLink = null;
            print('CampaignProvider: 상품 URL이 비어있어 링크 제거');
          }
        }
      } catch (e) {
        print('CampaignProvider: 쿠팡 링크 생성 오류 - $e');
        // 링크 생성 실패해도 캠페인은 수정하도록 진행
      }

      // 쿠팡 링크가 포함된 캠페인으로 수정
      final campaignWithLinks = updatedCampaign.copyWith(
        mainKeywordLink: mainKeywordLink,
        subKeywordLink: subKeywordLink,
        productLink: productLink,
      );

      await _updateCampaignUseCase(campaignWithLinks);
      print('CampaignProvider: 캠페인 수정 완료, 목록 다시 로드 시작');
      await loadCampaigns(); // 전체 캠페인 다시 로드
      print('CampaignProvider: 캠페인 목록 로드 완료 - 총 ${_campaigns.length}개');
    } catch (e) {
      print('CampaignProvider: 캠페인 수정 오류 - $e');
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

  // Short ID로 캠페인 찾기 (직접 쿼리)
  Future<Campaign?> getCampaignByShortId(String shortId) async {
    try {
      final campaign = await _getCampaignByShortIdUseCase(shortId);
      return campaign;
    } catch (e) {
      print('CampaignProvider: getCampaignByShortId 에러 - $e');
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

  // 캠페인별 리뷰 타입별 등록인원 수 조회
  Future<Map<String, int>> getRecruitCountsByCampaignAndType(
    String campaignId,
  ) async {
    try {
      return await _getRecruitCountsByCampaignAndTypeUseCase(campaignId);
    } catch (e) {
      print('CampaignProvider: 등록인원 수 조회 오류 - $e');
      return {};
    }
  }
}
