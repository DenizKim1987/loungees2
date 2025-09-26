// 앱 프로바이더 설정 - 파이어베이스 연동
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'campaign_provider.dart';
import 'item_provider.dart';

class AppProviders {
  static List<Widget> get providers => [
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

        return CampaignProvider(
          createCampaignUseCase: createCampaignUseCase,
          updateCampaignUseCase: updateCampaignUseCase,
          deleteCampaignUseCase: deleteCampaignUseCase,
          getAllCampaignsUseCase: getAllCampaignsUseCase,
          getCampaignsBySellerUseCase: getCampaignsBySellerUseCase,
          getActiveCampaignsUseCase: getActiveCampaignsUseCase,
        );
      },
    ),

    // 필요시 앱 전용 프로바이더들을 여기에 추가
  ];
}
