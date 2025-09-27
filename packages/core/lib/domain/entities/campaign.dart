import 'package:core/core.dart';

// 캠페인 엔티티
class Campaign {
  final String id;
  final String shortId; // 짧은 캠페인 ID (모집 페이지용)
  final String sellerId;
  final String recruitmentDate; // YYYY-MM-DD 형식
  final Item item; // 선택된 상품 정보
  final String keywords;
  final String subKeywords;
  final bool showFilters;
  final int productPrice; // 수정 가능한 상품가

  // 리뷰 조건들
  final bool requireVideo;
  final bool requirePhotos;
  final bool requireText;
  final bool requireRating;
  final bool requirePurchase;

  // 각 조건별 세부 설정
  final int? photoCount; // 사진 장수
  final int? textLength; // 텍스트 길이

  // 각 조건별 모집 건수
  final int? videoRecruitCount;
  final int? photoRecruitCount;
  final int? textRecruitCount;
  final int? ratingRecruitCount;
  final int? purchaseRecruitCount;

  // 각 조건별 리뷰비
  final int? videoFee;
  final int? photoFee;
  final int? textFee;
  final int? ratingFee;
  final int? purchaseFee;

  // 쿠팡 파트너스 링크들
  final String? mainKeywordLink; // 메인 키워드 검색 링크
  final String? subKeywordLink; // 서브 키워드 검색 링크
  final String? productLink; // 상품 링크

  final DateTime createdAt;
  final DateTime updatedAt;

  const Campaign({
    required this.id,
    required this.shortId,
    required this.sellerId,
    required this.recruitmentDate,
    required this.item,
    required this.keywords,
    required this.subKeywords,
    required this.showFilters,
    required this.productPrice,
    required this.requireVideo,
    required this.requirePhotos,
    required this.requireText,
    required this.requireRating,
    required this.requirePurchase,
    this.photoCount,
    this.textLength,
    this.videoRecruitCount,
    this.photoRecruitCount,
    this.textRecruitCount,
    this.ratingRecruitCount,
    this.purchaseRecruitCount,
    this.videoFee,
    this.photoFee,
    this.textFee,
    this.ratingFee,
    this.purchaseFee,
    this.mainKeywordLink,
    this.subKeywordLink,
    this.productLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? '',
      shortId: json['shortId'] ?? '',
      sellerId: json['sellerId'] ?? '',
      recruitmentDate: json['recruitmentDate'] ?? '',
      item: Item.fromJson(json['item'] ?? {}),
      keywords: json['keywords'] ?? '',
      subKeywords: json['subKeywords'] ?? '',
      showFilters: json['showFilters'] ?? false,
      productPrice: json['productPrice'] ?? 0,
      requireVideo: json['requireVideo'] ?? false,
      requirePhotos: json['requirePhotos'] ?? false,
      requireText: json['requireText'] ?? false,
      requireRating: json['requireRating'] ?? false,
      requirePurchase: json['requirePurchase'] ?? false,
      photoCount: json['photoCount'],
      textLength: json['textLength'],
      videoRecruitCount: json['videoRecruitCount'],
      photoRecruitCount: json['photoRecruitCount'],
      textRecruitCount: json['textRecruitCount'],
      ratingRecruitCount: json['ratingRecruitCount'],
      purchaseRecruitCount: json['purchaseRecruitCount'],
      videoFee: json['videoFee'],
      photoFee: json['photoFee'],
      textFee: json['textFee'],
      ratingFee: json['ratingFee'],
      purchaseFee: json['purchaseFee'],
      mainKeywordLink: json['mainKeywordLink'],
      subKeywordLink: json['subKeywordLink'],
      productLink: json['productLink'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shortId': shortId,
      'sellerId': sellerId,
      'recruitmentDate': recruitmentDate,
      'item': item.toJson(),
      'keywords': keywords,
      'subKeywords': subKeywords,
      'showFilters': showFilters,
      'productPrice': productPrice,
      'requireVideo': requireVideo,
      'requirePhotos': requirePhotos,
      'requireText': requireText,
      'requireRating': requireRating,
      'requirePurchase': requirePurchase,
      'photoCount': photoCount,
      'textLength': textLength,
      'videoRecruitCount': videoRecruitCount,
      'photoRecruitCount': photoRecruitCount,
      'textRecruitCount': textRecruitCount,
      'ratingRecruitCount': ratingRecruitCount,
      'purchaseRecruitCount': purchaseRecruitCount,
      'videoFee': videoFee,
      'photoFee': photoFee,
      'textFee': textFee,
      'ratingFee': ratingFee,
      'purchaseFee': purchaseFee,
      'mainKeywordLink': mainKeywordLink,
      'subKeywordLink': subKeywordLink,
      'productLink': productLink,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Campaign copyWith({
    String? id,
    String? shortId,
    String? sellerId,
    String? recruitmentDate,
    Item? item,
    String? keywords,
    String? subKeywords,
    bool? showFilters,
    int? productPrice,
    bool? requireVideo,
    bool? requirePhotos,
    bool? requireText,
    bool? requireRating,
    bool? requirePurchase,
    int? photoCount,
    int? textLength,
    int? videoRecruitCount,
    int? photoRecruitCount,
    int? textRecruitCount,
    int? ratingRecruitCount,
    int? purchaseRecruitCount,
    int? videoFee,
    int? photoFee,
    int? textFee,
    int? ratingFee,
    int? purchaseFee,
    String? mainKeywordLink,
    String? subKeywordLink,
    String? productLink,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Campaign(
      id: id ?? this.id,
      shortId: shortId ?? this.shortId,
      sellerId: sellerId ?? this.sellerId,
      recruitmentDate: recruitmentDate ?? this.recruitmentDate,
      item: item ?? this.item,
      keywords: keywords ?? this.keywords,
      subKeywords: subKeywords ?? this.subKeywords,
      showFilters: showFilters ?? this.showFilters,
      productPrice: productPrice ?? this.productPrice,
      requireVideo: requireVideo ?? this.requireVideo,
      requirePhotos: requirePhotos ?? this.requirePhotos,
      requireText: requireText ?? this.requireText,
      requireRating: requireRating ?? this.requireRating,
      requirePurchase: requirePurchase ?? this.requirePurchase,
      photoCount: photoCount ?? this.photoCount,
      textLength: textLength ?? this.textLength,
      videoRecruitCount: videoRecruitCount ?? this.videoRecruitCount,
      photoRecruitCount: photoRecruitCount ?? this.photoRecruitCount,
      textRecruitCount: textRecruitCount ?? this.textRecruitCount,
      ratingRecruitCount: ratingRecruitCount ?? this.ratingRecruitCount,
      purchaseRecruitCount: purchaseRecruitCount ?? this.purchaseRecruitCount,
      videoFee: videoFee ?? this.videoFee,
      photoFee: photoFee ?? this.photoFee,
      textFee: textFee ?? this.textFee,
      ratingFee: ratingFee ?? this.ratingFee,
      purchaseFee: purchaseFee ?? this.purchaseFee,
      mainKeywordLink: mainKeywordLink ?? this.mainKeywordLink,
      subKeywordLink: subKeywordLink ?? this.subKeywordLink,
      productLink: productLink ?? this.productLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
