// 캠페인 디테일 페이지 - 모집 현황 관리
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

import '../providers/campaign_provider.dart';
import '../providers/campaign_recruit_provider.dart';

class CampaignDetailPage extends StatefulWidget {
  final String campaignId;

  const CampaignDetailPage({super.key, required this.campaignId});

  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  Campaign? _campaign;
  bool _isLoading = true;
  String? _error;

  // 검색 관련
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _searchType = 'all'; // 'all', 'applicant', 'buyer'

  @override
  void initState() {
    super.initState();
    _loadCampaign();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      final recruitProvider = Provider.of<CampaignRecruitProvider>(
        context,
        listen: false,
      );

      // 캠페인 정보 로드 (직접 쿼리)
      _campaign = await campaignProvider.getCampaignByShortId(
        widget.campaignId,
      );

      // 모집 데이터 로드
      await recruitProvider.loadRecruits();

      if (_campaign == null) {
        setState(() {
          _error = '캠페인을 찾을 수 없습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _error = '캠페인 로드 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('캠페인 상세'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('캠페인 상세'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCampaign,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_campaign == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('캠페인 상세'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: Text('캠페인을 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('캠페인 상세'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCampaign),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 캠페인 기본 정보
            _buildCampaignInfo(),
            const SizedBox(height: 24),

            // 모집 현황 요약
            _buildRecruitSummary(),
            const SizedBox(height: 24),

            // 검색 기능
            _buildSearchBar(),
            const SizedBox(height: 16),

            // 리뷰 타입별 모집 현황
            _buildRecruitDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_campaign!.item.imageUrl?.isNotEmpty == true)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _getCorsProxyUrl(_campaign!.item.imageUrl ?? ''),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 12),
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
                        '모집날짜: ${_campaign!.recruitmentDate}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '상품가: ${PriceFormatter.formatWithWon(_campaign!.productPrice)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecruitSummary() {
    return Consumer<CampaignRecruitProvider>(
      builder: (context, recruitProvider, child) {
        final recruits =
            recruitProvider.recruits
                .where((recruit) => recruit.campaignId == widget.campaignId)
                .toList();

        final totalRecruits = recruits.length;
        final purchasedRecruits =
            recruits.where((recruit) => recruit.isPurchased).length;
        final reviewCompletedRecruits =
            recruits.where((recruit) => recruit.isReviewCompleted).length;
        final pendingRecruits =
            recruits
                .where(
                  (recruit) =>
                      !recruit.isPurchased && !recruit.isReviewCompleted,
                )
                .length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '모집 현황 요약',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        '총 신청자',
                        totalRecruits.toString(),
                        Colors.blue,
                        Icons.people,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        '구매완료',
                        purchasedRecruits.toString(),
                        Colors.green,
                        Icons.shopping_cart_checkout,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        '리뷰완료',
                        reviewCompletedRecruits.toString(),
                        Colors.blue,
                        Icons.rate_review,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        '대기중',
                        pendingRecruits.toString(),
                        Colors.orange,
                        Icons.schedule,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '신청자 검색',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 검색 입력 필드
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '이름 또는 전화번호로 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 12),

            // 검색 타입 선택
            Row(
              children: [
                const Text('검색 범위: ', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      _buildSearchTypeChip('all', '전체'),
                      const SizedBox(width: 8),
                      _buildSearchTypeChip('applicant', '신청자'),
                      const SizedBox(width: 8),
                      _buildSearchTypeChip('buyer', '구매자'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTypeChip(String type, String label) {
    final isSelected = _searchType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade800 : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildRecruitDetails() {
    return Consumer<CampaignRecruitProvider>(
      builder: (context, recruitProvider, child) {
        final allRecruits =
            recruitProvider.recruits
                .where((recruit) => recruit.campaignId == widget.campaignId)
                .toList();

        // 검색 필터링
        final filteredRecruits = _filterRecruits(allRecruits);

        if (allRecruits.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '아직 신청자가 없습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        if (filteredRecruits.isEmpty && _searchQuery.isNotEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    '검색 결과가 없습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '다른 검색어를 시도해보세요',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '신청자 상세 현황',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_searchQuery.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredRecruits.length}명 검색됨',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...filteredRecruits.map((recruit) => _buildRecruitCard(recruit)),
          ],
        );
      },
    );
  }

  List<CampaignRecruit> _filterRecruits(List<CampaignRecruit> recruits) {
    if (_searchQuery.isEmpty) {
      return recruits;
    }

    return recruits.where((recruit) {
      switch (_searchType) {
        case 'applicant':
          return recruit.applicantName.toLowerCase().contains(_searchQuery) ||
              recruit.applicantPhone.contains(_searchQuery);
        case 'buyer':
          return recruit.buyerName.toLowerCase().contains(_searchQuery) ||
              recruit.buyerPhone.contains(_searchQuery);
        case 'all':
        default:
          return recruit.applicantName.toLowerCase().contains(_searchQuery) ||
              recruit.applicantPhone.contains(_searchQuery) ||
              recruit.buyerName.toLowerCase().contains(_searchQuery) ||
              recruit.buyerPhone.contains(_searchQuery) ||
              recruit.reviewNickname.toLowerCase().contains(_searchQuery);
      }
    }).toList();
  }

  Widget _buildRecruitCard(CampaignRecruit recruit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 신청자 기본 정보 (한 줄로)
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getStatusColor(recruit),
                  child: Text(
                    recruit.applicantName.isNotEmpty
                        ? recruit.applicantName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recruit.applicantName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        recruit.reviewNickname,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(recruit).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(recruit),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(recruit),
                    style: TextStyle(
                      color: _getStatusColor(recruit),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 리뷰 타입과 연락처 정보 (한 줄로)
            Row(
              children: [
                // 리뷰 타입
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getReviewTypeColor(
                      recruit.reviewType,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getReviewTypeColor(recruit.reviewType),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getReviewTypeText(recruit.reviewType),
                    style: TextStyle(
                      color: _getReviewTypeColor(recruit.reviewType),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 연락처 정보
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recruit.applicantPhone,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // 리뷰비
                if (recruit.reviewFee != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      PriceFormatter.formatWithWon(recruit.reviewFee ?? 0),
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // 액션 버튼들 (한 줄로)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: OutlinedButton.icon(
                      onPressed: () => _togglePurchaseStatus(recruit),
                      icon: Icon(
                        recruit.isPurchased
                            ? Icons.shopping_cart_checkout
                            : Icons.shopping_cart,
                        size: 12,
                      ),
                      label: Text(
                        recruit.isPurchased ? '구매완료' : '구매체크',
                        style: const TextStyle(fontSize: 10),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            recruit.isPurchased ? Colors.green : Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleReviewStatus(recruit),
                      icon: Icon(
                        recruit.isReviewCompleted
                            ? Icons.rate_review
                            : Icons.edit,
                        size: 12,
                      ),
                      label: Text(
                        recruit.isReviewCompleted ? '리뷰완료' : '리뷰체크',
                        style: const TextStyle(fontSize: 10),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            recruit.isReviewCompleted
                                ? Colors.blue
                                : Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(CampaignRecruit recruit) {
    if (recruit.isReviewCompleted) {
      return Colors.purple; // 리뷰완료
    } else if (recruit.isPurchased) {
      return Colors.blue; // 구매완료
    } else {
      return Colors.orange; // 대기중
    }
  }

  String _getStatusText(CampaignRecruit recruit) {
    if (recruit.isReviewCompleted) {
      return '리뷰완료';
    } else if (recruit.isPurchased) {
      return '구매완료';
    } else {
      return '대기중';
    }
  }

  Color _getReviewTypeColor(String reviewType) {
    switch (reviewType) {
      case 'video':
        return Colors.blue;
      case 'photos':
        return Colors.green;
      case 'text':
        return Colors.orange;
      case 'rating':
        return Colors.purple;
      case 'purchase':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getReviewTypeText(String reviewType) {
    switch (reviewType) {
      case 'video':
        return '동영상';
      case 'photos':
        return '사진';
      case 'text':
        return '텍스트';
      case 'rating':
        return '별점';
      case 'purchase':
        return '구매확정';
      default:
        return '알 수 없음';
    }
  }

  void _togglePurchaseStatus(CampaignRecruit recruit) async {
    try {
      final recruitProvider = Provider.of<CampaignRecruitProvider>(
        context,
        listen: false,
      );

      await recruitProvider.updatePurchaseStatus(
        recruit.id,
        !recruit.isPurchased,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${recruit.applicantName}님의 구매 상태를 ${!recruit.isPurchased ? '완료' : '취소'}했습니다.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleReviewStatus(CampaignRecruit recruit) async {
    try {
      final recruitProvider = Provider.of<CampaignRecruitProvider>(
        context,
        listen: false,
      );

      await recruitProvider.updateReviewStatus(
        recruit.id,
        !recruit.isReviewCompleted,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${recruit.applicantName}님의 리뷰 상태를 ${!recruit.isReviewCompleted ? '완료' : '취소'}했습니다.',
            ),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getCorsProxyUrl(String url) {
    return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
  }
}
