// 앱 프로바이더 설정 - 파이어베이스 연동
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'campaign_provider.dart';
import 'campaign_recruit_provider.dart';
import 'item_provider.dart';

class AppProviders {
  static List<Widget> get providers => [
    // 인증 프로바이더
    ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),

    // 아이템 프로바이더 (파이어베이스 연동)
    ChangeNotifierProvider<ItemProvider>(
      create: (_) {
        // 의존성 주입
        final itemDataSource = FirebaseItemDataSource();
        final itemRepository = ItemRepositoryImpl(itemDataSource);

        final createItemUseCase = CreateItemUseCase(itemRepository);
        final updateItemUseCase = UpdateItemUseCase(itemRepository);
        final deleteItemUseCase = DeleteItemUseCase(itemRepository);
        final getAllItemsUseCase = GetAllItemsUseCase(itemRepository);
        final checkProductNumberExistsUseCase = CheckProductNumberExistsUseCase(
          itemRepository,
        );

        return ItemProvider(
          itemRepository: itemRepository,
          createItemUseCase: createItemUseCase,
          updateItemUseCase: updateItemUseCase,
          deleteItemUseCase: deleteItemUseCase,
          getAllItemsUseCase: getAllItemsUseCase,
          checkProductNumberExistsUseCase: checkProductNumberExistsUseCase,
        );
      },
    ),

    // 캠페인 프로바이더 (파이어베이스 연동)
    ChangeNotifierProvider<CampaignProvider>(
      create: (_) {
        // 의존성 주입
        final campaignDataSource = FirebaseCampaignDataSource();
        final campaignRepository = CampaignRepositoryImpl(campaignDataSource);

        final createCampaignUseCase = CreateCampaignUseCase(campaignRepository);
        final updateCampaignUseCase = UpdateCampaignUseCase(campaignRepository);
        final deleteCampaignUseCase = DeleteCampaignUseCase(campaignRepository);
        final getAllCampaignsUseCase = GetAllCampaignsUseCase(
          campaignRepository,
        );
        final getCampaignsBySellerUseCase = GetCampaignsBySellerUseCase(
          campaignRepository,
        );
        final getActiveCampaignsUseCase = GetActiveCampaignsUseCase(
          campaignRepository,
        );
        final getCampaignByShortIdUseCase = GetCampaignByShortIdUseCase(
          campaignRepository,
        );

        // 캠페인 모집 관련 의존성
        final campaignRecruitDataSource = FirebaseCampaignRecruitDataSource();
        final campaignRecruitRepository = CampaignRecruitRepositoryImpl(
          campaignRecruitDataSource,
        );

        final getRecruitCountsByCampaignAndTypeUseCase =
            GetRecruitCountsByCampaignAndTypeUseCase(campaignRecruitRepository);

        return CampaignProvider(
          createCampaignUseCase: createCampaignUseCase,
          updateCampaignUseCase: updateCampaignUseCase,
          deleteCampaignUseCase: deleteCampaignUseCase,
          getAllCampaignsUseCase: getAllCampaignsUseCase,
          getCampaignsBySellerUseCase: getCampaignsBySellerUseCase,
          getActiveCampaignsUseCase: getActiveCampaignsUseCase,
          getCampaignByShortIdUseCase: getCampaignByShortIdUseCase,
          getRecruitCountsByCampaignAndTypeUseCase:
              getRecruitCountsByCampaignAndTypeUseCase,
        );
      },
    ),

    // 캠페인 모집 프로바이더 (파이어베이스 연동)
    ChangeNotifierProvider<CampaignRecruitProvider>(
      create: (_) {
        // 의존성 주입
        final campaignRecruitDataSource = FirebaseCampaignRecruitDataSource();
        final campaignRecruitRepository = CampaignRecruitRepositoryImpl(
          campaignRecruitDataSource,
        );

        final updateRecruitUseCase = UpdateCampaignRecruitUseCase(
          campaignRecruitRepository,
        );
        final deleteRecruitUseCase = DeleteCampaignRecruitUseCase(
          campaignRecruitRepository,
        );
        final getAllRecruitsUseCase = GetAllCampaignRecruitsUseCase(
          campaignRecruitRepository,
        );
        final getRecruitsByCampaignUseCase =
            GetCampaignRecruitsByCampaignUseCase(campaignRecruitRepository);
        final getRecruitsBySellerUseCase = GetCampaignRecruitsBySellerUseCase(
          campaignRecruitRepository,
        );
        final getRecruitsByApplicantUseCase =
            GetCampaignRecruitsByApplicantUseCase(campaignRecruitRepository);

        // 새로운 유즈케이스들
        final checkDuplicateApplicationUseCase =
            CheckDuplicateApplicationUseCase(campaignRecruitRepository);
        final checkRecruitTypeClosedUseCase = CheckRecruitTypeClosedUseCase(
          campaignRecruitRepository,
        );
        final validateAndCreateRecruitUseCase = ValidateAndCreateRecruitUseCase(
          campaignRecruitRepository,
          checkDuplicateApplicationUseCase,
          checkRecruitTypeClosedUseCase,
        );

        return CampaignRecruitProvider(
          updateRecruitUseCase: updateRecruitUseCase,
          deleteRecruitUseCase: deleteRecruitUseCase,
          getAllRecruitsUseCase: getAllRecruitsUseCase,
          getRecruitsByCampaignUseCase: getRecruitsByCampaignUseCase,
          getRecruitsBySellerUseCase: getRecruitsBySellerUseCase,
          getRecruitsByApplicantUseCase: getRecruitsByApplicantUseCase,
          validateAndCreateRecruitUseCase: validateAndCreateRecruitUseCase,
        );
      },
    ),

    // 필요시 앱 전용 프로바이더들을 여기에 추가
  ];
}
