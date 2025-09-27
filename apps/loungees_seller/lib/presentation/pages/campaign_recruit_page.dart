// 캠페인 신청 페이지
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

import '../providers/campaign_provider.dart';
import '../providers/campaign_recruit_provider.dart';
import 'campaign_guide_page.dart';

class CampaignRecruitPage extends StatefulWidget {
  final String shortId;

  const CampaignRecruitPage({super.key, required this.shortId});

  @override
  State<CampaignRecruitPage> createState() => _CampaignRecruitPageState();
}

class _CampaignRecruitPageState extends State<CampaignRecruitPage> {
  final _formKey = GlobalKey<FormState>();

  // 신청자 정보
  final _applicantNameController = TextEditingController();
  final _applicantPhoneController = TextEditingController();
  final _applicantAccountController = TextEditingController();

  // 구매자 정보
  final _buyerNameController = TextEditingController();
  final _buyerPhoneController = TextEditingController();
  final _reviewNicknameController = TextEditingController();
  final _buyerAccountController = TextEditingController();

  // 신청자와 동일 체크
  bool _isApplicantSame = false;

  // 계좌 통일 체크
  bool _isAccountUnified = false;

  // 리뷰 타입 선택
  String? _selectedReviewType;

  Campaign? _campaign;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCampaign();
  }

  Future<void> _loadCampaign() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final campaignProvider = Provider.of<CampaignProvider>(
        context,
        listen: false,
      );

      // shortId로 캠페인 찾기 (직접 쿼리)
      _campaign = await campaignProvider.getCampaignByShortId(widget.shortId);

      // CampaignRecruitProvider 데이터 로드
      final recruitProvider = Provider.of<CampaignRecruitProvider>(
        context,
        listen: false,
      );
      await recruitProvider.loadRecruits();

      if (_campaign == null) {
        throw Exception('캠페인을 찾을 수 없습니다 (ID: ${widget.shortId})');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('캠페인 신청'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('캠페인 신청'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '오류가 발생했습니다',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    if (_campaign == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('캠페인 신청'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: Text('캠페인을 찾을 수 없습니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('캠페인 신청'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 캠페인 정보 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '캠페인 정보',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (_campaign!.item.imageUrl != null &&
                              _campaign!.item.imageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _getCorsProxyUrl(_campaign!.item.imageUrl!),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _campaign!.item.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '캠페인 ID: ${_campaign!.shortId}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '상품가: ${PriceFormatter.formatWithWon(_campaign!.productPrice)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '모집날짜: ${_campaign!.recruitmentDate}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 리뷰 타입 선택
              Text('리뷰 타입 선택', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Consumer<CampaignRecruitProvider>(
                builder: (context, recruitProvider, child) {
                  return _buildReviewTypeSelection(recruitProvider);
                },
              ),
              const SizedBox(height: 24),

              // 신청자 정보
              Text('신청자 정보', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _applicantNameController,
                decoration: const InputDecoration(
                  labelText: '신청자 이름',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '신청자 이름을 입력해주세요';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_isApplicantSame) {
                    _buyerNameController.text = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _applicantPhoneController,
                decoration: const InputDecoration(
                  labelText: '신청자 전화번호',
                  hintText: '예: 01012345678',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '신청자 전화번호를 입력해주세요';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_isApplicantSame) {
                    _buyerPhoneController.text = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _applicantAccountController,
                decoration: const InputDecoration(
                  labelText: '신청자 계좌번호',
                  border: OutlineInputBorder(),
                  hintText: '예: 카카오뱅크 123-456-789012 홍길동',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '신청자 계좌번호를 입력해주세요';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_isAccountUnified) {
                    _buyerAccountController.text = value;
                  }
                },
              ),
              const SizedBox(height: 24),

              // 구매자 정보
              Row(
                children: [
                  Text('구매자 정보', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _isApplicantSame,
                        onChanged: (value) {
                          setState(() {
                            _isApplicantSame = value ?? false;
                            if (_isApplicantSame) {
                              // 신청자 정보를 구매자 정보에 자동 입력
                              _buyerNameController.text =
                                  _applicantNameController.text;
                              _buyerPhoneController.text =
                                  _applicantPhoneController.text;
                              _buyerAccountController.text =
                                  _applicantAccountController.text;
                            } else {
                              // 체크 해제 시 구매자 정보 초기화
                              _buyerNameController.clear();
                              _buyerPhoneController.clear();
                              _buyerAccountController.clear();
                            }
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      const Text('신청자와 동일'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _buyerNameController,
                decoration: InputDecoration(
                  labelText: '구매자 이름',
                  border: const OutlineInputBorder(),
                  suffixIcon:
                      _isApplicantSame
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                ),
                enabled: !_isApplicantSame,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '구매자 이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _buyerPhoneController,
                decoration: InputDecoration(
                  labelText: '구매자 전화번호',
                  hintText: '예: 01012345678',
                  border: const OutlineInputBorder(),
                  suffixIcon:
                      _isApplicantSame
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                ),
                enabled: !_isApplicantSame,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '구매자 전화번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reviewNicknameController,
                decoration: const InputDecoration(
                  labelText: '리뷰 닉네임',
                  border: OutlineInputBorder(),
                  hintText: '리뷰 작성 시 사용할 닉네임',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '리뷰 닉네임을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _buyerAccountController,
                decoration: InputDecoration(
                  labelText: '구매자 계좌번호',
                  border: const OutlineInputBorder(),
                  hintText: '예: 카카오뱅크 123-456-789012 홍길동',
                  suffixIcon:
                      _isApplicantSame
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                ),
                enabled: !_isApplicantSame,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '구매자 계좌번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 계좌 통일 체크
              CheckboxListTile(
                title: const Text('계좌 통일'),
                subtitle: const Text('신청자와 구매자 계좌번호가 동일합니다'),
                value: _isAccountUnified,
                enabled: !_isApplicantSame, // 신청자와 동일이 체크되면 비활성화
                onChanged:
                    _isApplicantSame
                        ? null
                        : (value) {
                          setState(() {
                            _isAccountUnified = value ?? false;
                            if (_isAccountUnified) {
                              _buyerAccountController.text =
                                  _applicantAccountController.text;
                            }
                          });
                        },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),

              // 신청 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitApplication,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text(
                    '캠페인 신청하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewTypeSelection(CampaignRecruitProvider recruitProvider) {
    // 데이터 로드는 initState에서만 한 번 실행

    final reviewTypes = <String, String>{};

    if (_campaign!.requireVideo) {
      reviewTypes['video'] = '동영상 리뷰';
    }
    if (_campaign!.requirePhotos) {
      reviewTypes['photos'] = '사진 리뷰';
    }
    if (_campaign!.requireText) {
      reviewTypes['text'] = '텍스트 리뷰';
    }
    if (_campaign!.requireRating) {
      reviewTypes['rating'] = '별점 리뷰';
    }
    if (_campaign!.requirePurchase) {
      reviewTypes['purchase'] = '구매확정 리뷰';
    }

    return Column(
      children:
          reviewTypes.entries.map((entry) {
            final currentCount = _getCurrentCount(recruitProvider, entry.key);
            final maxCount = _getMaxRecruitCount(entry.key);
            final isClosed = currentCount >= maxCount;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<String>(
                title: Row(
                  children: [
                    Text(entry.value),
                    const SizedBox(width: 8),
                    _buildRemainingCountBadge(currentCount, maxCount, isClosed),
                    const Spacer(),
                    _buildReviewFeeBadge(entry.key),
                  ],
                ),
                subtitle: _buildReviewTypeSubtitle(entry.key),
                value: entry.key,
                groupValue: _selectedReviewType,
                onChanged:
                    isClosed
                        ? null
                        : (value) {
                          setState(() {
                            _selectedReviewType = value;
                          });
                        },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildReviewFeeBadge(String reviewType) {
    int? fee;
    switch (reviewType) {
      case 'video':
        fee = _campaign!.videoFee;
        break;
      case 'photos':
        fee = _campaign!.photoFee;
        break;
      case 'text':
        fee = _campaign!.textFee;
        break;
      case 'rating':
        fee = _campaign!.ratingFee;
        break;
      case 'purchase':
        fee = _campaign!.purchaseFee;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        PriceFormatter.formatWithWon(fee ?? 0),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget? _buildReviewTypeSubtitle(String reviewType) {
    switch (reviewType) {
      case 'photos':
        return Text('사진 ${_campaign!.photoCount ?? 0}장 촬영');
      case 'text':
        return Text('텍스트 ${_campaign!.textLength ?? 0}자 작성');
      default:
        return null;
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedReviewType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('리뷰 타입을 선택해주세요.')));
      return;
    }

    try {
      final campaignRecruitProvider = Provider.of<CampaignRecruitProvider>(
        context,
        listen: false,
      );

      final maxCount = _getMaxRecruitCount(_selectedReviewType!);

      // 디버그: 입력값 확인
      print(
        'CampaignRecruitPage: 신청자 전화번호 = "${_applicantPhoneController.text}"',
      );
      print('CampaignRecruitPage: 구매자 전화번호 = "${_buyerPhoneController.text}"');
      print('CampaignRecruitPage: 신청자 이름 = "${_applicantNameController.text}"');

      await campaignRecruitProvider.createRecruit(
        campaignId: _campaign!.shortId,
        campaignFullId: _campaign!.id,
        sellerId: _campaign!.sellerId,
        applicantName: _applicantNameController.text,
        applicantPhone: _applicantPhoneController.text,
        applicantAccountNumber: _applicantAccountController.text,
        buyerName: _buyerNameController.text,
        buyerPhone: _buyerPhoneController.text,
        reviewNickname: _reviewNicknameController.text,
        buyerAccountNumber: _buyerAccountController.text,
        isAccountUnified: _isAccountUnified,
        reviewType: _selectedReviewType!,
        maxCount: maxCount,
        reviewFee: _getReviewFee(_selectedReviewType!),
        campaignItemName: _campaign!.item.name,
        campaignItemImageUrl: _campaign!.item.imageUrl,
        campaignItemPrice: _campaign!.item.price.toDouble(),
        campaignRecruitmentDate: _campaign!.recruitmentDate,
        photoCount: _getPhotoCount(_selectedReviewType!),
        textLength: _getTextLength(_selectedReviewType!),
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('캠페인 신청이 완료되었습니다!')));

        // 캠페인 가이드 페이지로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => CampaignGuidePage(
                  campaign: _campaign!,
                  selectedReviewType: _selectedReviewType!,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = '신청 중 문제가 발생했습니다.';

        // 구체적인 오류 메시지 처리
        if (e.toString().contains('이미 신청하신 캠페인입니다')) {
          errorMessage = '이미 신청하신 캠페인입니다.';
        } else if (e.toString().contains('해당 리뷰 타입의 모집이 마감되었습니다')) {
          errorMessage = '해당 리뷰 타입의 모집이 마감되었습니다.';
        } else if (e.toString().contains('Exception:')) {
          // Exception: 부분을 제거하고 자연스러운 메시지로 변환
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getCorsProxyUrl(String url) {
    return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
  }

  int? _getReviewFee(String reviewType) {
    switch (reviewType) {
      case 'video':
        return _campaign?.videoFee;
      case 'photos':
        return _campaign?.photoFee;
      case 'text':
        return _campaign?.textFee;
      case 'rating':
        return _campaign?.ratingFee;
      case 'purchase':
        return _campaign?.purchaseFee;
      default:
        return null;
    }
  }

  int? _getPhotoCount(String reviewType) {
    if (reviewType == 'photos') {
      return _campaign?.photoCount;
    }
    return null;
  }

  int? _getTextLength(String reviewType) {
    if (reviewType == 'text') {
      return _campaign?.textLength;
    }
    return null;
  }

  int _getMaxRecruitCount(String reviewType) {
    switch (reviewType) {
      case 'video':
        return _campaign?.videoRecruitCount ?? 0;
      case 'photos':
        return _campaign?.photoRecruitCount ?? 0;
      case 'text':
        return _campaign?.textRecruitCount ?? 0;
      case 'rating':
        return _campaign?.ratingRecruitCount ?? 0;
      case 'purchase':
        return _campaign?.purchaseRecruitCount ?? 0;
      default:
        return 0;
    }
  }

  int _getCurrentCount(
    CampaignRecruitProvider recruitProvider,
    String reviewType,
  ) {
    final counts = recruitProvider.getRecruitCountsByCampaignAndTypeCached(
      _campaign!.shortId,
    );
    final currentCount = counts[reviewType] ?? 0;
    print(
      'CampaignRecruitPage: _getCurrentCount - reviewType=$reviewType, currentCount=$currentCount, allCounts=$counts',
    );
    return currentCount;
  }

  Widget _buildRemainingCountBadge(
    int currentCount,
    int maxCount,
    bool isClosed,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isClosed ? Colors.red : Colors.blue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isClosed ? '마감' : '$currentCount/$maxCount',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _applicantNameController.dispose();
    _applicantPhoneController.dispose();
    _applicantAccountController.dispose();
    _buyerNameController.dispose();
    _buyerPhoneController.dispose();
    _reviewNicknameController.dispose();
    _buyerAccountController.dispose();
    super.dispose();
  }
}
