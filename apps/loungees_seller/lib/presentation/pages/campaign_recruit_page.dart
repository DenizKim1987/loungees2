// 캠페인 신청 페이지
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/campaign_provider.dart';

class CampaignRecruitPage extends StatefulWidget {
  final String shortId;

  const CampaignRecruitPage({super.key, required this.shortId});

  @override
  State<CampaignRecruitPage> createState() => _CampaignRecruitPageState();
}

class _CampaignRecruitPageState extends State<CampaignRecruitPage> {
  final _formKey = GlobalKey<FormState>();

  // 신청자 정보
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reviewNicknameController = TextEditingController();
  final _accountNumberController = TextEditingController();

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

      // 캠페인 목록 로드
      await campaignProvider.loadCampaigns();

      // 디버깅: 로드된 캠페인 목록 확인
      final campaigns = campaignProvider.campaigns;
      print('CampaignRecruitPage: 로드된 캠페인 수: ${campaigns.length}');
      for (final campaign in campaigns) {
        print(
          'CampaignRecruitPage: 캠페인 ID: ${campaign.id}, Short ID: ${campaign.shortId}',
        );
      }

      // shortId로 캠페인 찾기
      _campaign = campaignProvider.getCampaignByShortId(widget.shortId);

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
                                  '상품가: ₩${_campaign!.productPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
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
              _buildReviewTypeSelection(),
              const SizedBox(height: 24),

              // 신청자 정보
              Text('신청자 정보', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '전화번호를 입력해주세요';
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
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: '계좌번호',
                  border: OutlineInputBorder(),
                  hintText: '예: 123-456-789012',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '계좌번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

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

  Widget _buildReviewTypeSelection() {
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
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<String>(
                title: Row(
                  children: [
                    Text(entry.value),
                    const SizedBox(width: 8),
                    _buildReviewFeeBadge(entry.key),
                  ],
                ),
                subtitle: _buildReviewTypeSubtitle(entry.key),
                value: entry.key,
                groupValue: _selectedReviewType,
                onChanged: (value) {
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '₩${fee ?? 0}',
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

  void _submitApplication() {
    if (_formKey.currentState!.validate()) {
      if (_selectedReviewType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('리뷰 타입을 선택해주세요'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // TODO: 실제 신청 로직 구현
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('신청이 완료되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  String _getCorsProxyUrl(String url) {
    return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _reviewNicknameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }
}
