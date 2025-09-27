// 내 캠페인 리스트 페이지
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

import '../providers/campaign_provider.dart';
import '../providers/campaign_recruit_provider.dart';
import 'campaign_guide_page.dart';

class MyCampaignListPage extends StatefulWidget {
  final String phoneNumber;

  const MyCampaignListPage({super.key, required this.phoneNumber});

  @override
  State<MyCampaignListPage> createState() => _MyCampaignListPageState();
}

class _MyCampaignListPageState extends State<MyCampaignListPage> {
  List<CampaignRecruit> _myRecruits = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyRecruits();
  }

  Future<void> _loadMyRecruits() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final recruitProvider = Provider.of<CampaignRecruitProvider>(
        context,
        listen: false,
      );

      // 전화번호로 내 신청한 캠페인들 조회
      await recruitProvider.loadRecruitsByApplicant(widget.phoneNumber);
      _myRecruits = recruitProvider.recruits;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 캠페인 리스트'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('오류가 발생했습니다', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMyRecruits,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_myRecruits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '신청한 캠페인이 없습니다',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '캠페인에 신청하면 여기에 표시됩니다',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home),
              label: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyRecruits,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myRecruits.length,
        itemBuilder: (context, index) {
          final recruit = _myRecruits[index];
          return _buildRecruitCard(recruit);
        },
      ),
    );
  }

  Widget _buildRecruitCard(CampaignRecruit recruit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 캠페인 썸네일과 ID
            Row(
              children: [
                // 썸네일
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child:
                        recruit.campaignItemImageUrl != null
                            ? Image.network(
                              _getCorsProxyUrl(recruit.campaignItemImageUrl!),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.image,
                                    size: 30,
                                    color: Colors.grey.shade400,
                                  ),
                                );
                              },
                            )
                            : Icon(
                              Icons.image,
                              size: 30,
                              color: Colors.grey.shade400,
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recruit.campaignItemName ?? '제품명 없음',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (recruit.campaignItemPrice != null)
                        Text(
                          PriceFormatter.formatDoubleWithWon(
                            recruit.campaignItemPrice!,
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        '신청일: ${_formatDate(recruit.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 리뷰 조건
            Container(
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
                  Icon(
                    _getReviewTypeIcon(recruit.reviewType),
                    size: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getReviewTypeTextWithDetails(recruit),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      PriceFormatter.formatWithWon(recruit.reviewFee ?? 0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 상태 카드들
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    '구매완료',
                    Icons.shopping_cart_checkout,
                    Colors.blue,
                    recruit.isPurchased, // 실제 구매완료 상태
                    onTap: () {
                      _showPurchaseToggleDialog(recruit);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildStatusCard(
                    '리뷰완료',
                    Icons.rate_review,
                    Colors.green,
                    recruit.isReviewCompleted, // 실제 리뷰완료 상태
                    onTap: () {
                      if (recruit.isReviewCompleted) {
                        _showReviewCancelDialog(recruit);
                      } else {
                        _showReviewCompleteDialog(recruit);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 구매 가이드보기 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showPurchaseGuide(recruit),
                icon: const Icon(Icons.help_outline, size: 16),
                label: const Text('구매 가이드보기'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    IconData icon,
    Color color,
    bool isCompleted, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isCompleted ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isCompleted ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isCompleted ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: isCompleted ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseToggleDialog(CampaignRecruit recruit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(recruit.isPurchased ? '구매완료 취소' : '구매완료 확인'),
          content: Text(
            '캠페인 ID: ${recruit.campaignId}\n'
            '리뷰 타입: ${_getReviewTypeText(recruit.reviewType)}\n\n'
            '${recruit.isPurchased ? '구매완료를 취소하시겠습니까?' : '구매를 완료하셨나요?'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _togglePurchaseStatus(recruit);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: recruit.isPurchased ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(recruit.isPurchased ? '취소' : '확인'),
            ),
          ],
        );
      },
    );
  }

  void _showReviewCompleteDialog(CampaignRecruit recruit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('리뷰 완료 확인'),
          content: Text(
            '캠페인 ID: ${recruit.campaignId}\n'
            '리뷰 타입: ${_getReviewTypeText(recruit.reviewType)}\n\n'
            '리뷰를 완료하셨나요?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _toggleReviewStatus(recruit);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showReviewCancelDialog(CampaignRecruit recruit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('리뷰 완료 취소'),
          content: Text(
            '캠페인 ID: ${recruit.campaignId}\n'
            '리뷰 타입: ${_getReviewTypeText(recruit.reviewType)}\n\n'
            '리뷰 완료를 취소하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _toggleReviewStatus(recruit);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  IconData _getReviewTypeIcon(String reviewType) {
    switch (reviewType) {
      case 'video':
        return Icons.videocam;
      case 'photos':
        return Icons.photo_camera;
      case 'text':
        return Icons.text_fields;
      case 'rating':
        return Icons.star;
      case 'purchase':
        return Icons.shopping_cart;
      default:
        return Icons.help_outline;
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
        return '구매확정 리뷰';
      default:
        return '알 수 없음';
    }
  }

  String _getReviewTypeTextWithDetails(CampaignRecruit recruit) {
    switch (recruit.reviewType) {
      case 'video':
        return '동영상 리뷰';
      case 'photos':
        if (recruit.photoCount != null) {
          return '사진 리뷰 (${recruit.photoCount}장)';
        }
        return '사진 리뷰';
      case 'text':
        if (recruit.textLength != null) {
          return '텍스트 리뷰 (${recruit.textLength}자)';
        }
        return '텍스트 리뷰';
      case 'rating':
        return '별점 리뷰';
      case 'purchase':
        return '구매확정 리뷰';
      default:
        return '알 수 없음';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  Future<void> _togglePurchaseStatus(CampaignRecruit recruit) async {
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
            content: Text('구매 상태가 ${!recruit.isPurchased ? '완료' : '취소'}되었습니다'),
            backgroundColor:
                !recruit.isPurchased ? Colors.green : Colors.orange,
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

  Future<void> _toggleReviewStatus(CampaignRecruit recruit) async {
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
              '리뷰 상태가 ${!recruit.isReviewCompleted ? '완료' : '취소'}되었습니다',
            ),
            backgroundColor:
                !recruit.isReviewCompleted ? Colors.green : Colors.orange,
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

  Future<void> _showPurchaseGuide(CampaignRecruit recruit) async {
    try {
      final campaignProvider = Provider.of<CampaignProvider>(
        context,
        listen: false,
      );

      // 캠페인 정보 가져오기
      final campaign = await campaignProvider.getCampaignByShortId(
        recruit.campaignId,
      );

      if (campaign != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => CampaignGuidePage(
                  campaign: campaign,
                  selectedReviewType: recruit.reviewType,
                ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('캠페인 정보를 찾을 수 없습니다'),
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

  String _getCorsProxyUrl(String originalUrl) {
    // CORS 프록시 URL 생성
    return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(originalUrl)}';
  }
}
