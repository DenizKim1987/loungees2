// 캠페인 등록 페이지
import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/campaign_provider.dart';
import '../providers/item_provider.dart';

class CampaignRegisterPage extends StatefulWidget {
  final String sellerId;
  final Campaign? campaignToEdit; // 수정할 캠페인 (null이면 새로 등록)

  const CampaignRegisterPage({
    super.key,
    required this.sellerId,
    this.campaignToEdit,
  });

  @override
  State<CampaignRegisterPage> createState() => _CampaignRegisterPageState();
}

class _CampaignRegisterPageState extends State<CampaignRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // 기본 정보
  final _recruitmentDateController = TextEditingController();

  // 상품 정보
  Item? _selectedItem;
  final _keywordsController = TextEditingController();
  final _subKeywordsController = TextEditingController();
  bool _showFilters = false;
  final _productPriceController = TextEditingController();

  // 리뷰 조건
  bool _requireVideo = false;
  bool _requirePhotos = false;
  bool _requireText = false;
  bool _requireRating = false;
  bool _requirePurchase = false;
  final _photoCountController = TextEditingController();
  final _textLengthController = TextEditingController();
  final _videoRecruitCountController = TextEditingController();
  final _photoRecruitCountController = TextEditingController();
  final _textRecruitCountController = TextEditingController();
  final _ratingRecruitCountController = TextEditingController();
  final _purchaseRecruitCountController = TextEditingController();

  // 보상 (각 조건별)
  final _videoFeeController = TextEditingController();
  final _photoFeeController = TextEditingController();
  final _textFeeController = TextEditingController();
  final _ratingFeeController = TextEditingController();
  final _purchaseFeeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 수정 모드일 때 기존 데이터로 폼 채우기
    if (widget.campaignToEdit != null) {
      final campaign = widget.campaignToEdit!;
      _recruitmentDateController.text = campaign.recruitmentDate;
      _selectedItem = campaign.item;
      _productPriceController.text = campaign.productPrice.toString();
      _keywordsController.text = campaign.keywords;
      _subKeywordsController.text = campaign.subKeywords;
      _showFilters = campaign.showFilters;

      // 리뷰 조건들
      _requireVideo = campaign.requireVideo;
      _requirePhotos = campaign.requirePhotos;
      _requireText = campaign.requireText;
      _requireRating = campaign.requireRating;
      _requirePurchase = campaign.requirePurchase;

      // 세부 설정들
      if (campaign.photoCount != null) {
        _photoCountController.text = campaign.photoCount.toString();
      }
      if (campaign.textLength != null) {
        _textLengthController.text = campaign.textLength.toString();
      }

      // 모집 건수들
      if (campaign.videoRecruitCount != null) {
        _videoRecruitCountController.text =
            campaign.videoRecruitCount.toString();
      }
      if (campaign.photoRecruitCount != null) {
        _photoRecruitCountController.text =
            campaign.photoRecruitCount.toString();
      }
      if (campaign.textRecruitCount != null) {
        _textRecruitCountController.text = campaign.textRecruitCount.toString();
      }
      if (campaign.ratingRecruitCount != null) {
        _ratingRecruitCountController.text =
            campaign.ratingRecruitCount.toString();
      }
      if (campaign.purchaseRecruitCount != null) {
        _purchaseRecruitCountController.text =
            campaign.purchaseRecruitCount.toString();
      }

      // 리뷰비들
      if (campaign.videoFee != null) {
        _videoFeeController.text = campaign.videoFee.toString();
      }
      if (campaign.photoFee != null) {
        _photoFeeController.text = campaign.photoFee.toString();
      }
      if (campaign.textFee != null) {
        _textFeeController.text = campaign.textFee.toString();
      }
      if (campaign.ratingFee != null) {
        _ratingFeeController.text = campaign.ratingFee.toString();
      }
      if (campaign.purchaseFee != null) {
        _purchaseFeeController.text = campaign.purchaseFee.toString();
      }
    } else {
      // 새 등록 모드일 때 오늘 날짜로 초기화
      final today = DateTime.now();
      _recruitmentDateController.text =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _recruitmentDateController.dispose();
    _keywordsController.dispose();
    _subKeywordsController.dispose();
    _productPriceController.dispose();
    _photoCountController.dispose();
    _textLengthController.dispose();
    _videoRecruitCountController.dispose();
    _photoRecruitCountController.dispose();
    _textRecruitCountController.dispose();
    _ratingRecruitCountController.dispose();
    _purchaseRecruitCountController.dispose();
    _videoFeeController.dispose();
    _photoFeeController.dispose();
    _textFeeController.dispose();
    _ratingFeeController.dispose();
    _purchaseFeeController.dispose();
    super.dispose();
  }

  void _selectProduct() {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final items = itemProvider.items;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('등록된 아이템이 없습니다. 먼저 아이템을 등록해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '상품 선택',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: ListTile(
                          leading:
                              item.imageUrl != null && item.imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _getCorsProxyUrl(item.imageUrl!),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: 50,
                                          height: 50,
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
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                  : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                          title: Text(item.name),
                          subtitle: Text(
                            '₩${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          ),
                          onTap: () {
                            setState(() {
                              _selectedItem = item;
                              _productPriceController.text =
                                  item.price.toString();
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // CORS 프록시 URL 생성
  String _getCorsProxyUrl(String originalUrl) {
    // 여러 CORS 프록시 옵션 제공
    final proxyUrls = [
      'https://api.allorigins.win/raw?url=${Uri.encodeComponent(originalUrl)}',
      'https://cors-anywhere.herokuapp.com/$originalUrl',
      'https://thingproxy.freeboard.io/fetch/$originalUrl',
    ];

    // 첫 번째 프록시 사용 (가장 안정적)
    return proxyUrls.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.campaignToEdit != null ? '캠페인 수정' : '캠페인 등록'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 모집날짜
              TextFormField(
                controller: _recruitmentDateController,
                decoration: const InputDecoration(
                  labelText: '모집날짜',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    _recruitmentDateController.text =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
              ),
              const SizedBox(height: 16),

              // 상품 추가
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '상품 정보',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _selectProduct,
                            icon: const Icon(Icons.add),
                            label: const Text('상품 추가'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_selectedItem != null) ...[
                        // 선택된 상품 정보
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (_selectedItem!.imageUrl != null &&
                                  _selectedItem!.imageUrl!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _getCorsProxyUrl(_selectedItem!.imageUrl!),
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
                                      _selectedItem!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '상품번호: ${_selectedItem!.productNumber}',
                                    ),
                                    Text(
                                      '판매업체: ${_selectedItem!.sellerCompany}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 상품가 (수정 가능)
                        TextFormField(
                          controller: _productPriceController,
                          decoration: const InputDecoration(
                            labelText: '상품가',
                            border: OutlineInputBorder(),
                            prefixText: '₩ ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        // 키워드
                        TextFormField(
                          controller: _keywordsController,
                          decoration: const InputDecoration(
                            labelText: '키워드',
                            hintText: '예: 스킨케어, 미백, 안티에이징',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 서브키워드
                        TextFormField(
                          controller: _subKeywordsController,
                          decoration: const InputDecoration(
                            labelText: '서브키워드',
                            hintText: '예: 민감성피부, 건성피부',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 필터 공개 여부
                        SwitchListTile(
                          title: const Text('필터 공개'),
                          subtitle: const Text('상품의 필터 정보를 공개할지 선택하세요'),
                          value: _showFilters,
                          onChanged: (value) {
                            setState(() {
                              _showFilters = value;
                            });
                          },
                        ),
                        if (_showFilters &&
                            _selectedItem!.filters.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children:
                                _selectedItem!.filters.map<Widget>((filter) {
                                  return Chip(
                                    label: Text(
                                      filter,
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
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ] else ...[
                        const Text(
                          '상품을 선택해주세요',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 리뷰 조건
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '리뷰 조건',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 동영상
                      CheckboxListTile(
                        title: const Text('동영상'),
                        value: _requireVideo,
                        onChanged: (value) {
                          setState(() {
                            _requireVideo = value ?? false;
                          });
                        },
                      ),
                      if (_requireVideo) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _videoRecruitCountController,
                                  decoration: const InputDecoration(
                                    labelText: '모집 건수',
                                    border: OutlineInputBorder(),
                                    suffixText: '건',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _videoFeeController,
                                  decoration: const InputDecoration(
                                    labelText: '리뷰비',
                                    border: OutlineInputBorder(),
                                    prefixText: '₩ ',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 사진
                      CheckboxListTile(
                        title: const Text('사진'),
                        value: _requirePhotos,
                        onChanged: (value) {
                          setState(() {
                            _requirePhotos = value ?? false;
                          });
                        },
                      ),
                      if (_requirePhotos) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _photoCountController,
                                decoration: const InputDecoration(
                                  labelText: '사진 장수',
                                  border: OutlineInputBorder(),
                                  suffixText: '장',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _photoRecruitCountController,
                                      decoration: const InputDecoration(
                                        labelText: '모집 건수',
                                        border: OutlineInputBorder(),
                                        suffixText: '건',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _photoFeeController,
                                      decoration: const InputDecoration(
                                        labelText: '리뷰비',
                                        border: OutlineInputBorder(),
                                        prefixText: '₩ ',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 텍스트
                      CheckboxListTile(
                        title: const Text('텍스트'),
                        value: _requireText,
                        onChanged: (value) {
                          setState(() {
                            _requireText = value ?? false;
                          });
                        },
                      ),
                      if (_requireText) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _textLengthController,
                                decoration: const InputDecoration(
                                  labelText: '텍스트 길이',
                                  border: OutlineInputBorder(),
                                  suffixText: '자',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _textRecruitCountController,
                                      decoration: const InputDecoration(
                                        labelText: '모집 건수',
                                        border: OutlineInputBorder(),
                                        suffixText: '건',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _textFeeController,
                                      decoration: const InputDecoration(
                                        labelText: '리뷰비',
                                        border: OutlineInputBorder(),
                                        prefixText: '₩ ',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 별점
                      CheckboxListTile(
                        title: const Text('별점'),
                        value: _requireRating,
                        onChanged: (value) {
                          setState(() {
                            _requireRating = value ?? false;
                          });
                        },
                      ),
                      if (_requireRating) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _ratingRecruitCountController,
                                  decoration: const InputDecoration(
                                    labelText: '모집 건수',
                                    border: OutlineInputBorder(),
                                    suffixText: '건',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _ratingFeeController,
                                  decoration: const InputDecoration(
                                    labelText: '리뷰비',
                                    border: OutlineInputBorder(),
                                    prefixText: '₩ ',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 구매확정
                      CheckboxListTile(
                        title: const Text('구매확정'),
                        value: _requirePurchase,
                        onChanged: (value) {
                          setState(() {
                            _requirePurchase = value ?? false;
                          });
                        },
                      ),
                      if (_requirePurchase) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _purchaseRecruitCountController,
                                  decoration: const InputDecoration(
                                    labelText: '모집 건수',
                                    border: OutlineInputBorder(),
                                    suffixText: '건',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _purchaseFeeController,
                                  decoration: const InputDecoration(
                                    labelText: '리뷰비',
                                    border: OutlineInputBorder(),
                                    prefixText: '₩ ',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 등록 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedItem == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('상품을 선택해주세요'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      final campaignProvider = Provider.of<CampaignProvider>(
                        context,
                        listen: false,
                      );

                      // 캠페인 생성
                      final today = DateTime.now();
                      final dateString =
                          '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
                      final campaignId = '$dateString-${_selectedItem!.id}';

                      // 짧은 캠페인 ID 생성 (수정 모드에서는 기존 ID 유지)
                      final shortId =
                          widget.campaignToEdit?.shortId ??
                          String.fromCharCodes(
                            Iterable.generate(
                              6,
                              (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
                                  .codeUnitAt(Random().nextInt(36)),
                            ),
                          );

                      final campaign = Campaign(
                        id: campaignId,
                        shortId: shortId,
                        sellerId: widget.sellerId,
                        recruitmentDate: _recruitmentDateController.text,
                        item: _selectedItem!,
                        keywords: _keywordsController.text.trim(),
                        subKeywords: _subKeywordsController.text.trim(),
                        showFilters: _showFilters,
                        productPrice: int.parse(
                          _productPriceController.text.trim(),
                        ),
                        requireVideo: _requireVideo,
                        requirePhotos: _requirePhotos,
                        requireText: _requireText,
                        requireRating: _requireRating,
                        requirePurchase: _requirePurchase,
                        photoCount:
                            _requirePhotos &&
                                    _photoCountController.text.isNotEmpty
                                ? int.tryParse(
                                  _photoCountController.text.trim(),
                                )
                                : null,
                        textLength:
                            _requireText &&
                                    _textLengthController.text.isNotEmpty
                                ? int.tryParse(
                                  _textLengthController.text.trim(),
                                )
                                : null,
                        videoRecruitCount:
                            _requireVideo &&
                                    _videoRecruitCountController.text.isNotEmpty
                                ? int.tryParse(
                                  _videoRecruitCountController.text.trim(),
                                )
                                : null,
                        photoRecruitCount:
                            _requirePhotos &&
                                    _photoRecruitCountController.text.isNotEmpty
                                ? int.tryParse(
                                  _photoRecruitCountController.text.trim(),
                                )
                                : null,
                        textRecruitCount:
                            _requireText &&
                                    _textRecruitCountController.text.isNotEmpty
                                ? int.tryParse(
                                  _textRecruitCountController.text.trim(),
                                )
                                : null,
                        ratingRecruitCount:
                            _requireRating &&
                                    _ratingRecruitCountController
                                        .text
                                        .isNotEmpty
                                ? int.tryParse(
                                  _ratingRecruitCountController.text.trim(),
                                )
                                : null,
                        purchaseRecruitCount:
                            _requirePurchase &&
                                    _purchaseRecruitCountController
                                        .text
                                        .isNotEmpty
                                ? int.tryParse(
                                  _purchaseRecruitCountController.text.trim(),
                                )
                                : null,
                        videoFee:
                            _requireVideo && _videoFeeController.text.isNotEmpty
                                ? int.tryParse(_videoFeeController.text.trim())
                                : null,
                        photoFee:
                            _requirePhotos &&
                                    _photoFeeController.text.isNotEmpty
                                ? int.tryParse(_photoFeeController.text.trim())
                                : null,
                        textFee:
                            _requireText && _textFeeController.text.isNotEmpty
                                ? int.tryParse(_textFeeController.text.trim())
                                : null,
                        ratingFee:
                            _requireRating &&
                                    _ratingFeeController.text.isNotEmpty
                                ? int.tryParse(_ratingFeeController.text.trim())
                                : null,
                        purchaseFee:
                            _requirePurchase &&
                                    _purchaseFeeController.text.isNotEmpty
                                ? int.tryParse(
                                  _purchaseFeeController.text.trim(),
                                )
                                : null,
                        createdAt:
                            widget.campaignToEdit?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      try {
                        final isEditMode = widget.campaignToEdit != null;
                        print(
                          '캠페인 ${isEditMode ? "수정" : "등록"} 시작: ${campaign.id}',
                        );

                        // 캠페인 저장 (등록/수정 모두 동일한 로직)
                        await campaignProvider.addCampaign(campaign);
                        print(
                          '캠페인 ${widget.campaignToEdit != null ? "수정" : "등록"} 완료: ${campaign.id}',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '캠페인이 성공적으로 ${widget.campaignToEdit != null ? "수정" : "등록"}되었습니다!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        print(
                          '캠페인 ${widget.campaignToEdit != null ? "수정" : "등록"} 오류: $e',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '캠페인 ${widget.campaignToEdit != null ? "수정" : "등록"} 중 오류가 발생했습니다: $e',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.campaignToEdit != null ? '캠페인 수정' : '캠페인 등록',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
