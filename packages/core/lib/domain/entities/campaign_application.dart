// 캠페인 모집 엔티티
class CampaignRecruit {
  final String id;
  final String campaignId; // 캠페인의 shortId
  final String campaignFullId; // 캠페인의 전체 ID (날짜-아이템ID)
  final String sellerId;

  // 모집자 정보
  final String recruitName;
  final String phoneNumber;
  final String reviewNickname;
  final String accountNumber;

  // 모집한 리뷰 타입
  final String reviewType; // 'video', 'photos', 'text', 'rating', 'purchase'
  final int? reviewFee; // 해당 리뷰 타입의 리뷰비

  // 모집 상태
  final RecruitStatus status;
  final String? rejectionReason; // 거절 사유

  // 메타데이터
  final DateTime createdAt;
  final DateTime updatedAt;

  const CampaignRecruit({
    required this.id,
    required this.campaignId,
    required this.campaignFullId,
    required this.sellerId,
    required this.recruitName,
    required this.phoneNumber,
    required this.reviewNickname,
    required this.accountNumber,
    required this.reviewType,
    this.reviewFee,
    required this.status,
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
      recruitName: json['recruitName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      reviewNickname: json['reviewNickname'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      reviewType: json['reviewType'] ?? '',
      reviewFee: json['reviewFee'] as int?,
      status: RecruitStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RecruitStatus.pending,
      ),
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
      'recruitName': recruitName,
      'phoneNumber': phoneNumber,
      'reviewNickname': reviewNickname,
      'accountNumber': accountNumber,
      'reviewType': reviewType,
      'reviewFee': reviewFee,
      'status': status.name,
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
    String? recruitName,
    String? phoneNumber,
    String? reviewNickname,
    String? accountNumber,
    String? reviewType,
    int? reviewFee,
    RecruitStatus? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CampaignRecruit(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      campaignFullId: campaignFullId ?? this.campaignFullId,
      sellerId: sellerId ?? this.sellerId,
      recruitName: recruitName ?? this.recruitName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      reviewNickname: reviewNickname ?? this.reviewNickname,
      accountNumber: accountNumber ?? this.accountNumber,
      reviewType: reviewType ?? this.reviewType,
      reviewFee: reviewFee ?? this.reviewFee,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// 모집 상태 열거형
enum RecruitStatus {
  pending, // 대기중
  approved, // 승인됨
  rejected, // 거절됨
  completed, // 완료됨 (리뷰 작성 완료)
  cancelled, // 취소됨
}
