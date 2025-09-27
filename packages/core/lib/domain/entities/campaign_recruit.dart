// 캠페인 모집 엔티티
class CampaignRecruit {
  final String id;
  final String campaignId; // 캠페인의 shortId
  final String campaignFullId; // 캠페인의 전체 ID (날짜-아이템ID)
  final String sellerId;

  // 신청자 정보
  final String applicantName;
  final String applicantPhone;
  final String applicantAccountNumber;

  // 구매자 정보
  final String buyerName;
  final String buyerPhone;
  final String reviewNickname;
  final String buyerAccountNumber;

  // 계좌 통일 여부
  final bool isAccountUnified;

  // 모집한 리뷰 타입
  final String reviewType; // 'video', 'photos', 'text', 'rating', 'purchase'
  final int? reviewFee; // 해당 리뷰 타입의 리뷰비

  // 캠페인 정보 (스냅샷)
  final String? campaignItemName; // 제품명
  final String? campaignItemImageUrl; // 제품 썸네일 URL
  final double? campaignItemPrice; // 제품 가격
  final String? campaignRecruitmentDate; // 모집일

  // 리뷰 조건 정보 (스냅샷)
  final int? photoCount; // 사진 개수
  final int? textLength; // 텍스트 길이

  // 구매 및 리뷰 완료 상태
  final bool isPurchased; // 구매완료 여부
  final bool isReviewCompleted; // 리뷰완료 여부
  final String? rejectionReason; // 거절 사유

  // 메타데이터
  final DateTime createdAt;
  final DateTime updatedAt;

  const CampaignRecruit({
    required this.id,
    required this.campaignId,
    required this.campaignFullId,
    required this.sellerId,
    required this.applicantName,
    required this.applicantPhone,
    required this.applicantAccountNumber,
    required this.buyerName,
    required this.buyerPhone,
    required this.reviewNickname,
    required this.buyerAccountNumber,
    required this.isAccountUnified,
    required this.reviewType,
    this.reviewFee,
    this.campaignItemName,
    this.campaignItemImageUrl,
    this.campaignItemPrice,
    this.campaignRecruitmentDate,
    this.photoCount,
    this.textLength,
    required this.isPurchased,
    required this.isReviewCompleted,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CampaignRecruit.fromJson(Map<String, dynamic> json) {
    return CampaignRecruit(
      id: json['id'] ?? '',
      campaignId: json['campaignId'] ?? '',
      campaignFullId: json['campaignFullId'] ?? '',
      sellerId: json['sellerId'] ?? '',
      applicantName: json['applicantName'] ?? '',
      applicantPhone: json['applicantPhone'] ?? '',
      applicantAccountNumber: json['applicantAccountNumber'] ?? '',
      buyerName: json['buyerName'] ?? '',
      buyerPhone: json['buyerPhone'] ?? '',
      reviewNickname: json['reviewNickname'] ?? '',
      buyerAccountNumber: json['buyerAccountNumber'] ?? '',
      isAccountUnified: json['isAccountUnified'] ?? false,
      reviewType: json['reviewType'] ?? '',
      reviewFee: json['reviewFee'] as int?,
      campaignItemName: json['campaignItemName'] as String?,
      campaignItemImageUrl: json['campaignItemImageUrl'] as String?,
      campaignItemPrice: (json['campaignItemPrice'] as num?)?.toDouble(),
      campaignRecruitmentDate: json['campaignRecruitmentDate'] as String?,
      photoCount: json['photoCount'] as int?,
      textLength: json['textLength'] as int?,
      isPurchased: json['isPurchased'] ?? false,
      isReviewCompleted: json['isReviewCompleted'] ?? false,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignId': campaignId,
      'campaignFullId': campaignFullId,
      'sellerId': sellerId,
      'applicantName': applicantName,
      'applicantPhone': applicantPhone,
      'applicantAccountNumber': applicantAccountNumber,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'reviewNickname': reviewNickname,
      'buyerAccountNumber': buyerAccountNumber,
      'isAccountUnified': isAccountUnified,
      'reviewType': reviewType,
      'reviewFee': reviewFee,
      'campaignItemName': campaignItemName,
      'campaignItemImageUrl': campaignItemImageUrl,
      'campaignItemPrice': campaignItemPrice,
      'campaignRecruitmentDate': campaignRecruitmentDate,
      'photoCount': photoCount,
      'textLength': textLength,
      'isPurchased': isPurchased,
      'isReviewCompleted': isReviewCompleted,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CampaignRecruit copyWith({
    String? id,
    String? campaignId,
    String? campaignFullId,
    String? sellerId,
    String? applicantName,
    String? applicantPhone,
    String? applicantAccountNumber,
    String? buyerName,
    String? buyerPhone,
    String? reviewNickname,
    String? buyerAccountNumber,
    bool? isAccountUnified,
    String? reviewType,
    int? reviewFee,
    String? campaignItemName,
    String? campaignItemImageUrl,
    double? campaignItemPrice,
    String? campaignRecruitmentDate,
    int? photoCount,
    int? textLength,
    bool? isPurchased,
    bool? isReviewCompleted,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CampaignRecruit(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      campaignFullId: campaignFullId ?? this.campaignFullId,
      sellerId: sellerId ?? this.sellerId,
      applicantName: applicantName ?? this.applicantName,
      applicantPhone: applicantPhone ?? this.applicantPhone,
      applicantAccountNumber:
          applicantAccountNumber ?? this.applicantAccountNumber,
      buyerName: buyerName ?? this.buyerName,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      reviewNickname: reviewNickname ?? this.reviewNickname,
      buyerAccountNumber: buyerAccountNumber ?? this.buyerAccountNumber,
      isAccountUnified: isAccountUnified ?? this.isAccountUnified,
      reviewType: reviewType ?? this.reviewType,
      reviewFee: reviewFee ?? this.reviewFee,
      campaignItemName: campaignItemName ?? this.campaignItemName,
      campaignItemImageUrl: campaignItemImageUrl ?? this.campaignItemImageUrl,
      campaignItemPrice: campaignItemPrice ?? this.campaignItemPrice,
      campaignRecruitmentDate:
          campaignRecruitmentDate ?? this.campaignRecruitmentDate,
      photoCount: photoCount ?? this.photoCount,
      textLength: textLength ?? this.textLength,
      isPurchased: isPurchased ?? this.isPurchased,
      isReviewCompleted: isReviewCompleted ?? this.isReviewCompleted,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
