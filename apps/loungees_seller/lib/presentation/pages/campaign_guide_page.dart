// 캠페인 가이드 페이지
import 'dart:html' as html;

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class CampaignGuidePage extends StatefulWidget {
  final Campaign campaign;

  const CampaignGuidePage({super.key, required this.campaign});

  @override
  State<CampaignGuidePage> createState() => _CampaignGuidePageState();
}

class _CampaignGuidePageState extends State<CampaignGuidePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('쿠팡 구매가이드'),
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 캠페인 기본 정보 (제목 없이)
            _buildCampaignInfo(context),
            const SizedBox(height: 8),

            // 메인 키워드 + 필터 카드
            _buildMainKeywordAndFilterCard(context),
            const SizedBox(height: 8),

            // 서브 키워드 + 경고 카드
            _buildSubKeywordAndWarningCard(context),
            const SizedBox(height: 8),

            // 리뷰 조건 (택1)
            _buildReviewConditionsSection(context),
            const SizedBox(height: 8),

            // 입금 안내
            _buildPaymentInfoSection(context),
            const SizedBox(height: 8),

            // 비상 연락처
            _buildContactSection(context),
            const SizedBox(height: 16),

            // 신청하기 버튼
            _buildApplyButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMainKeywordAndFilterCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 키워드
            if (widget.campaign.keywords.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    '메인 키워드',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade600,
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
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
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
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.shade600.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                keyword.trim(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // 필터 정보
            _buildFiltersSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSubKeywordAndWarningCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                  print('이미지 로딩 에러: $error');
                  return _buildFallbackImage();
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    PriceFormatter.formatWithWon(widget.campaign.item.price),
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
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    if (widget.campaign.item.filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '필터',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
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
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 12,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
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
              '리뷰 조건 (택1)',
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
    final List<Widget> reviewConditions = [];

    // 동영상 리뷰
    if ((widget.campaign.videoRecruitCount ?? 0) > 0) {
      reviewConditions.add(
        _buildReviewConditionItem(
          context,
          '동영상 리뷰',
          true,
          widget.campaign.videoRecruitCount ?? 0,
          widget.campaign.videoFee ?? 0,
        ),
      );
    }

    // 사진 리뷰
    if ((widget.campaign.photoRecruitCount ?? 0) > 0) {
      reviewConditions.add(
        _buildReviewConditionItem(
          context,
          '사진 리뷰',
          true,
          widget.campaign.photoRecruitCount ?? 0,
          widget.campaign.photoFee ?? 0,
          subtitle: '${widget.campaign.photoCount ?? 0}장',
        ),
      );
    }

    // 텍스트 리뷰
    if ((widget.campaign.textRecruitCount ?? 0) > 0) {
      reviewConditions.add(
        _buildReviewConditionItem(
          context,
          '텍스트 리뷰',
          true,
          widget.campaign.textRecruitCount ?? 0,
          widget.campaign.textFee ?? 0,
          subtitle: '${widget.campaign.textLength ?? 0}자',
        ),
      );
    }

    // 별점 리뷰
    if ((widget.campaign.ratingRecruitCount ?? 0) > 0) {
      reviewConditions.add(
        _buildReviewConditionItem(
          context,
          '별점 리뷰',
          true,
          widget.campaign.ratingRecruitCount ?? 0,
          widget.campaign.ratingFee ?? 0,
        ),
      );
    }

    // 구매 확인
    if ((widget.campaign.purchaseRecruitCount ?? 0) > 0) {
      reviewConditions.add(
        _buildReviewConditionItem(
          context,
          '구매 확인',
          true,
          widget.campaign.purchaseRecruitCount ?? 0,
          widget.campaign.purchaseFee ?? 0,
        ),
      );
    }

    if (reviewConditions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(children: reviewConditions);
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

            // 입금자명과 안내를 한 줄로 표시
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
                    child: Text(
                      '입금자명: 오선애',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
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

  Widget _buildApplyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showApplyDialog(context),
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

  void _showApplyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('구매완료'),
          content: Text(
            '상품: ${widget.campaign.item.name}\n\n'
            '구매를 완료하셨습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // 홈으로 이동
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('구매완료'),
            ),
          ],
        );
      },
    );
  }

  String _getCorsProxyUrl(String originalUrl) {
    // 더 안정적인 CORS 프록시 사용
    return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(originalUrl)}';
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 30,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  void _searchKeywords(BuildContext context, String keywords) async {
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

      // 캠페인에 저장된 쿠팡 링크 사용
      String? searchUrl;
      if (keywords == widget.campaign.keywords &&
          widget.campaign.mainKeywordLink != null) {
        searchUrl = widget.campaign.mainKeywordLink;
        print('메인 키워드 쿠팡 링크 사용: $searchUrl');
      } else if (keywords == widget.campaign.subKeywords &&
          widget.campaign.subKeywordLink != null) {
        searchUrl = widget.campaign.subKeywordLink;
        print('서브 키워드 쿠팡 링크 사용: $searchUrl');
      } else {
        // 쿠팡 링크가 없는 경우 기본 검색 URL 생성
        searchUrl =
            'https://www.coupang.com/np/search?q=${Uri.encodeComponent(mainKeyword)}';
        print('기본 검색 URL 사용: $searchUrl');
      }

      // 웹 브라우저에서 검색 실행
      if (searchUrl != null) {
        try {
          // 웹에서는 window.open을 사용
          if (kIsWeb) {
            // 웹 환경에서는 dart:html을 사용
            html.window.open(searchUrl, '_blank');
            print('웹에서 링크 열기 성공: $searchUrl');

            // 사용자에게 성공 알림
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"$mainKeyword" 검색 페이지를 새 탭에서 열었습니다'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            // 모바일/데스크톱에서는 url_launcher 사용
            final uri = Uri.parse(searchUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              print('링크 열기 성공: $searchUrl');

              // 사용자에게 성공 알림
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"$mainKeyword" 검색 페이지를 열었습니다'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              print('링크를 열 수 없습니다: $searchUrl');
              _showErrorSnackBar(context, '링크를 열 수 없습니다');
            }
          }
        } catch (e) {
          print('링크 열기 오류: $e');
          _showErrorSnackBar(context, '링크를 여는 중 오류가 발생했습니다: $e');
        }
      } else {
        _showErrorSnackBar(context, '검색 URL을 생성할 수 없습니다');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }
}
