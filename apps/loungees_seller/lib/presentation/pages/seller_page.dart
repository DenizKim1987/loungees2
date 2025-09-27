// 셀러 페이지 - 캠페인보기와 아이템보기 탭
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

import '../providers/campaign_provider.dart';
import '../providers/item_provider.dart';
import 'campaign_register_page.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isCardView = true; // true: 카드형식, false: 썸네일형식

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 탭 변경 시 AppBar 액션 버튼 업데이트
    _tabController.addListener(() {
      setState(() {});
    });

    // 앱 시작 시 아이템, 캠페인 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('SellerPage: 아이템 로드 시작');
      Provider.of<ItemProvider>(context, listen: false).loadItems();
      print('SellerPage: 캠페인 로드 시작');
      Provider.of<CampaignProvider>(context, listen: false).loadCampaigns();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // CORS 프록시 URL 생성
  String _getCorsProxyUrl(String originalUrl) {
    final proxyUrls = [
      'https://api.allorigins.win/raw?url=${Uri.encodeComponent(originalUrl)}',
      'https://cors-anywhere.herokuapp.com/$originalUrl',
      'https://thingproxy.freeboard.io/fetch/$originalUrl',
    ];
    return proxyUrls.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('셀러 관리'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.campaign), text: '캠페인보기'),
            Tab(icon: Icon(Icons.inventory_2), text: '아이템보기'),
          ],
        ),
        actions: [
          // 보기 모드 전환 버튼 (아이템보기 탭에서만 표시)
          if (_tabController.index == 1) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _isCardView = !_isCardView;
                });
              },
              icon: Icon(_isCardView ? Icons.grid_view : Icons.view_list),
              tooltip: _isCardView ? '썸네일 보기' : '카드 보기',
            ),
          ],
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 모집보기 탭
          _buildRecruitmentTab(),
          // 아이템보기 탭
          _buildItemTab(),
        ],
      ),
    );
  }

  // 모집보기 탭 구성
  Widget _buildRecruitmentTab() {
    return Column(
      children: [
        // 모집 추가 버튼
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                const sellerId = 'seller_001';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CampaignRegisterPage(sellerId: sellerId),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle),
              label: const Text('캠페인 추가'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        // 캠페인 목록
        Expanded(
          child: Consumer<CampaignProvider>(
            builder: (context, campaignProvider, child) {
              final campaigns = campaignProvider.campaigns;

              if (campaignProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (campaignProvider.error != null) {
                return Center(
                  child: Text(
                    '오류 발생: ${campaignProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (campaigns.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '등록된 캠페인이 없습니다',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '캠페인 추가 버튼을 눌러 첫 번째 캠페인을 등록해보세요!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: campaigns.length,
                itemBuilder: (context, index) {
                  final campaign = campaigns[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 캠페인 기본 정보
                          Row(
                            children: [
                              // 상품 이미지
                              if (campaign.item.imageUrl != null &&
                                  campaign.item.imageUrl!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _getCorsProxyUrl(campaign.item.imageUrl!),
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
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
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
                                      campaign.item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/campaign/${campaign.shortId}',
                                            );
                                          },
                                          child: Text(
                                            '캠페인 ID: ${campaign.shortId}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            // 클립보드에 복사
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '캠페인 ID "${campaign.shortId}"가 복사되었습니다',
                                                ),
                                                backgroundColor: Colors.green,
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Icon(
                                            Icons.copy,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '모집날짜: ${campaign.recruitmentDate}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '상품가: ${PriceFormatter.formatWithWon(campaign.productPrice)}',
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
                          const SizedBox(height: 12),

                          // 리뷰 조건들
                          FutureBuilder<Map<String, int>>(
                            future: Provider.of<CampaignProvider>(
                              context,
                              listen: false,
                            ).getRecruitCountsByCampaignAndType(
                              campaign.shortId,
                            ),
                            builder: (context, snapshot) {
                              final recruitCounts = snapshot.data ?? {};

                              return Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  if (campaign.requireVideo)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '동영상 ${recruitCounts['video'] ?? 0}/${campaign.videoRecruitCount ?? 0}건',
                                        style: TextStyle(
                                          color: Colors.blue.shade800,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  if (campaign.requirePhotos)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '사진${campaign.photoCount != null ? ' (${campaign.photoCount}장)' : ''} ${recruitCounts['photos'] ?? 0}/${campaign.photoRecruitCount ?? 0}건',
                                        style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  if (campaign.requireText)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.orange.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '텍스트${campaign.textLength != null ? ' (${campaign.textLength}자)' : ''} ${recruitCounts['text'] ?? 0}/${campaign.textRecruitCount ?? 0}건',
                                        style: TextStyle(
                                          color: Colors.orange.shade800,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  if (campaign.requireRating)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.purple.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '별점 ${recruitCounts['rating'] ?? 0}/${campaign.ratingRecruitCount ?? 0}건',
                                        style: TextStyle(
                                          color: Colors.purple.shade800,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  if (campaign.requirePurchase)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.red.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '구매확정 ${recruitCounts['purchase'] ?? 0}/${campaign.purchaseRecruitCount ?? 0}건',
                                        style: TextStyle(
                                          color: Colors.red.shade800,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          // 액션 버튼들
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  // 디테일 페이지로 이동
                                  Navigator.pushNamed(
                                    context,
                                    '/campaign-detail/${campaign.shortId}',
                                  );
                                },
                                icon: const Icon(Icons.visibility, size: 16),
                                label: const Text('상세'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  // 수정 페이지로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => CampaignRegisterPage(
                                            sellerId: 'seller_001', // 임시 셀러 ID
                                            campaignToEdit: campaign,
                                          ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('수정'),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  Provider.of<CampaignProvider>(
                                    context,
                                    listen: false,
                                  ).deleteCampaign(campaign.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('캠페인이 삭제되었습니다'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text('삭제'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
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
            },
          ),
        ),
      ],
    );
  }

  // 아이템보기 탭 구성
  Widget _buildItemTab() {
    return Column(
      children: [
        // 아이템 등록 버튼
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                const sellerId = 'seller_001';
                Navigator.pushNamed(context, '/item-add/$sellerId');
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('아이템 등록'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        // 아이템 목록
        Expanded(
          child: Consumer<ItemProvider>(
            builder: (context, itemProvider, child) {
              final items = itemProvider.items;

              if (items.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '등록된 아이템이 없습니다',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '아이템 등록 버튼을 눌러 첫 번째 아이템을 등록해보세요!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              // 카드 보기 모드
              if (_isCardView) {
                return _buildCardView(items);
              }
              // 썸네일 보기 모드
              else {
                return _buildThumbnailView(items);
              }
            },
          ),
        ),
      ],
    );
  }

  // 카드 보기 모드
  Widget _buildCardView(items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지+금액 컬럼과 아이템 정보 로우
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지와 금액 컬럼
                    Column(
                      children: [
                        // 이미지
                        if (item.imageUrl != null &&
                            item.imageUrl!.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _getCorsProxyUrl(item.imageUrl!),
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
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                        ] else ...[
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        // 금액
                        Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            PriceFormatter.formatWithWon(item.price),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // 아이템 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 아이템 이름
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 상품번호와 판매업체
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.qr_code,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '상품번호: ${item.productNumber}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.business,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.sellerCompany,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 필터 태그들
                if (item.filters.isNotEmpty) ...[
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children:
                        item.filters.map<Widget>((filter) {
                          return Chip(
                            label: Text(
                              filter,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.blue.shade50,
                            labelStyle: TextStyle(color: Colors.blue.shade700),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                // 액션 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/item-edit/${item.productNumber}',
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('수정'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        Provider.of<ItemProvider>(
                          context,
                          listen: false,
                        ).deleteItem(item.productNumber);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('아이템이 삭제되었습니다'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('삭제'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
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

  // 썸네일 보기 모드
  Widget _buildThumbnailView(items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/item-edit/${item.productNumber}');
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 썸네일 이미지
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child:
                          item.imageUrl != null && item.imageUrl!.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _getCorsProxyUrl(item.imageUrl!),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                              )
                              : const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 아이템 이름
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 가격
                  Text(
                    PriceFormatter.formatWithWon(item.price),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
