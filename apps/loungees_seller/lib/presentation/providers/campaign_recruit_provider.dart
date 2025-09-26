import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class CampaignRecruitProvider with ChangeNotifier {
  final CreateCampaignRecruitUseCase _createRecruitUseCase;
  final UpdateCampaignRecruitUseCase _updateRecruitUseCase;
  final DeleteCampaignRecruitUseCase _deleteRecruitUseCase;
  final GetAllCampaignRecruitsUseCase _getAllRecruitsUseCase;
  final GetCampaignRecruitsByCampaignUseCase _getRecruitsByCampaignUseCase;
  final GetCampaignRecruitsBySellerUseCase _getRecruitsBySellerUseCase;
  final GetCampaignRecruitsByStatusUseCase _getRecruitsByStatusUseCase;
  final GetCampaignRecruitsByApplicantUseCase _getRecruitsByApplicantUseCase;

  CampaignRecruitProvider({
    required CreateCampaignRecruitUseCase createRecruitUseCase,
    required UpdateCampaignRecruitUseCase updateRecruitUseCase,
    required DeleteCampaignRecruitUseCase deleteRecruitUseCase,
    required GetAllCampaignRecruitsUseCase getAllRecruitsUseCase,
    required GetCampaignRecruitsByCampaignUseCase getRecruitsByCampaignUseCase,
    required GetCampaignRecruitsBySellerUseCase getRecruitsBySellerUseCase,
    required GetCampaignRecruitsByStatusUseCase getRecruitsByStatusUseCase,
    required GetCampaignRecruitsByApplicantUseCase
    getRecruitsByApplicantUseCase,
  }) : _createRecruitUseCase = createRecruitUseCase,
       _updateRecruitUseCase = updateRecruitUseCase,
       _deleteRecruitUseCase = deleteRecruitUseCase,
       _getAllRecruitsUseCase = getAllRecruitsUseCase,
       _getRecruitsByCampaignUseCase = getRecruitsByCampaignUseCase,
       _getRecruitsBySellerUseCase = getRecruitsBySellerUseCase,
       _getRecruitsByStatusUseCase = getRecruitsByStatusUseCase,
       _getRecruitsByApplicantUseCase = getRecruitsByApplicantUseCase;

  final List<CampaignRecruit> _recruits = [];
  bool _isLoading = false;
  String? _error;

  List<CampaignRecruit> get recruits => List.unmodifiable(_recruits);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 캠페인 모집 생성
  Future<void> createRecruit(CampaignRecruit recruit) async {
    try {
      print('CampaignRecruitProvider: 모집 생성 시작 - ${recruit.id}');
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _createRecruitUseCase(recruit);
      print('CampaignRecruitProvider: 모집 생성 완료, 목록 다시 로드 시작');
      await loadRecruits(); // 전체 모집 다시 로드
      print('CampaignRecruitProvider: 모집 목록 로드 완료 - 총 ${_recruits.length}개');
    } catch (e) {
      print('CampaignRecruitProvider: 모집 생성 오류 - $e');
      _error = e.toString();
      rethrow;
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

  // 상태별 모집 로드
  Future<void> loadRecruitsByStatus(RecruitStatus status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _recruits.clear();
      _recruits.addAll(await _getRecruitsByStatusUseCase(status));
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
  int get recruitCount => _recruits.length;
}
