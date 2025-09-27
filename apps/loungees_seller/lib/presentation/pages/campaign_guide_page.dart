// 캠페인 가이드 페이지
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

import '../providers/campaign_recruit_provider.dart';

class CampaignGuidePage extends StatefulWidget {
  final Campaign campaign;
  final String selectedReviewType;

  const CampaignGuidePage({
    super.key,
    required this.campaign,
    required this.selectedReviewType,
  });

  @override
  State<CampaignGuidePage> createState() => _CampaignGuidePageState();
}

class _CampaignGuidePageState extends State<CampaignGuidePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캠페인 가이드'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 캠페인 기본 정보
            _buildCampaignInfo(context),
            const SizedBox(height: 24),

            // 메인 키워드
            if (widget.campaign.keywords.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    '메인 키워드',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed:
                        () =>
                            _searchKeywords(context, widget.campaign.keywords),
                    icon: const Icon(Icons.search, size: 14),
                    label: const Text('키워드검색', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      widget.campaign.keywords
                          .split(',')
                          .map(
                            (keyword) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                keyword.trim(),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 서브 키워드
            if (widget.campaign.subKeywords.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    '서브 키워드',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed:
                        () => _searchKeywords(
                          context,
                          widget.campaign.subKeywords,
                        ),
                    icon: const Icon(Icons.search, size: 14),
                    label: const Text('키워드검색', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 키워드 안내 메시지
              Text(
                '해당 키워드 + 필터로 검색이 안될 시 서브 키워드로 검색하세요.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      widget.campaign.subKeywords
                          .split(',')
                          .map(
                            (keyword) => Chip(
                              label: Text(
                                keyword.trim(),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                              labelStyle: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer,
                                fontSize: 12,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 필터 정보
            _buildFiltersSection(context),
            const SizedBox(height: 24),

            // 리뷰 조건
            _buildReviewConditionsSection(context),
            const SizedBox(height: 24),

            // 입금 안내
            _buildPaymentInfoSection(context),
            const SizedBox(height: 24),

            // 비상 연락처
            _buildContactSection(context),
            const SizedBox(height: 32),

            // 완료 버튼
            _buildCompleteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '캠페인 정보',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // 상품 썸네일
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _getCorsProxyUrl(widget.campaign.item.imageUrl ?? ''),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // 상품 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.campaign.item.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        PriceFormatter.formatWithWon(
                          widget.campaign.item.price,
                        ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '모집일: ${_formatDate(DateTime.parse(widget.campaign.recruitmentDate))}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
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

  Widget _buildFiltersSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '필터',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (widget.campaign.item.filters.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      widget.campaign.item.filters
                          .map(
                            (filter) => Chip(
                              label: Text(
                                filter,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.tertiaryContainer,
                              labelStyle: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                fontSize: 12,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ] else ...[
              Text(
                '필터가 설정되지 않았습니다.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewConditionsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '리뷰 조건',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSelectedReviewCondition(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedReviewCondition(BuildContext context) {
    switch (widget.selectedReviewType) {
      case 'video':
        return _buildReviewConditionItem(
          context,
          '동영상 리뷰',
          true,
          widget.campaign.videoRecruitCount ?? 0,
          widget.campaign.videoFee ?? 0,
        );
      case 'photos':
        return _buildReviewConditionItem(
          context,
          '사진 리뷰',
          true,
          widget.campaign.photoRecruitCount ?? 0,
          widget.campaign.photoFee ?? 0,
          subtitle: '${widget.campaign.photoCount ?? 0}장',
        );
      case 'text':
        return _buildReviewConditionItem(
          context,
          '텍스트 리뷰',
          true,
          widget.campaign.textRecruitCount ?? 0,
          widget.campaign.textFee ?? 0,
          subtitle: '${widget.campaign.textLength ?? 0}자',
        );
      case 'rating':
        return _buildReviewConditionItem(
          context,
          '별점 리뷰',
          true,
          widget.campaign.ratingRecruitCount ?? 0,
          widget.campaign.ratingFee ?? 0,
        );
      case 'purchase':
        return _buildReviewConditionItem(
          context,
          '구매 확인',
          true,
          widget.campaign.purchaseRecruitCount ?? 0,
          widget.campaign.purchaseFee ?? 0,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReviewConditionItem(
    BuildContext context,
    String title,
    bool isRequired,
    int recruitCount,
    int? fee, {
    String? subtitle,
  }) {
    if (!isRequired) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (fee != null && fee > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${fee.toStringAsFixed(0)}원',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '비상 연락처',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone, color: Colors.red.shade600, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '방폭시 여기로 연락주세요',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '010-4484-7299',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '입금 안내',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 입금자명 정보
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.green.shade600, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '입금자명',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '오선애',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 입금 안내
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '입금은 리뷰제출 당일 밤 또는 새벽 중 입금됩니다.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showPurchaseCompleteDialog(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        child: const Text(
          '구매완료',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showPurchaseCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('구매완료 확인'),
          content: Text(
            '상품: ${widget.campaign.item.name}\n'
            '리뷰 타입: ${_getReviewTypeText(widget.selectedReviewType)}\n\n'
            '구매를 완료하셨나요?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updatePurchaseStatus(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePurchaseStatus(BuildContext context) async {
    try {
      final recruitProvider = Provider.of<CampaignRecruitProvider>(
        context,
        listen: false,
      );

      // 최근 신청한 recruit 찾기 (같은 캠페인, 같은 리뷰 타입)
      final recruits =
          recruitProvider.recruits
              .where(
                (recruit) =>
                    recruit.campaignId == widget.campaign.shortId &&
                    recruit.reviewType == widget.selectedReviewType,
              )
              .toList();

      if (recruits.isNotEmpty) {
        // 가장 최근 신청한 recruit 선택
        final latestRecruit = recruits.last;

        // 구매완료 상태로 업데이트
        await recruitProvider.updatePurchaseStatus(latestRecruit.id, true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('구매완료 처리되었습니다'),
              backgroundColor: Colors.green,
            ),
          );

          // 홈으로 돌아가기
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('해당 캠페인 신청 정보를 찾을 수 없습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
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

  String _getReviewTypeText(String reviewType) {
    switch (reviewType) {
      case 'video':
        return '동영상 리뷰';
      case 'photos':
        return '사진 리뷰';
      case 'text':
        return '텍스트 리뷰';
      case 'rating':
        return '별점 리뷰';
      case 'purchase':
        return '구매확정';
      default:
        return '알 수 없음';
    }
  }

  String _getCorsProxyUrl(String originalUrl) {
    const proxyUrls = [
      'https://api.allorigins.win/raw?url=',
      'https://cors-anywhere.herokuapp.com/',
      'https://thingproxy.freeboard.io/fetch/',
    ];
    return '${proxyUrls.first}${Uri.encodeComponent(originalUrl)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  void _searchKeywords(BuildContext context, String keywords) {
    // 키워드를 쉼표로 분리하여 검색어로 사용
    final searchTerms =
        keywords
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    if (searchTerms.isNotEmpty) {
      // 첫 번째 키워드를 메인 검색어로 사용
      final mainKeyword = searchTerms.first;

      // 검색 URL 생성 (예: 쿠팡 검색)
      final searchUrl =
          'https://www.coupang.com/np/search?q=${Uri.encodeComponent(mainKeyword)}';

      // 웹 브라우저에서 검색 실행
      // 실제 앱에서는 url_launcher 패키지를 사용할 수 있습니다
      print('검색 실행: $searchUrl');

      // 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$mainKeyword" 검색을 실행합니다'),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
