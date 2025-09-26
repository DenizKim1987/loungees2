// 앱 쉘 - 실제 앱 실행 및 테마, 라우팅 관리
import 'package:flutter/material.dart';
import 'package:loungees_theme/loungees_theme.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import 'pages/campaign_recruit_page.dart';
import 'pages/item_register_page.dart';
import 'providers/item_provider.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loungees Seller',
      debugShowCheckedModeBanner: false,

      // 테마 설정
      theme: LoungeesTheme.lightTheme,
      darkTheme: LoungeesTheme.darkTheme,
      themeMode: ThemeMode.system,

      // 라우팅 설정
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,

      // 동적 라우팅 처리
      onGenerateRoute: (settings) {
        // /campaign/shortId 형태의 라우트 처리 (캠페인 신청)
        if (settings.name?.startsWith('/campaign/') == true) {
          final shortId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => CampaignRecruitPage(shortId: shortId),
            settings: settings,
          );
        }

        // /item-add/sellerId 형태의 라우트 처리 (새 등록)
        if (settings.name?.startsWith('/item-add/') == true) {
          final sellerId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => ItemRegisterPage(sellerId: sellerId),
            settings: settings,
          );
        }

        // /item-edit/itemId 형태의 라우트 처리 (수정)
        if (settings.name?.startsWith('/item-edit/') == true) {
          final itemId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) {
              final itemProvider = Provider.of<ItemProvider>(
                context,
                listen: false,
              );
              final itemToEdit = itemProvider.getItemById(itemId);

              return ItemRegisterPage(
                sellerId: 'seller_001', // 임시 셀러 ID
                itemToEdit: itemToEdit,
              );
            },
            settings: settings,
          );
        }

        return null; // 다른 라우트는 기본 처리
      },

      // 기본 라우트 핸들러
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const NotFoundPage());
      },
    );
  }
}

// 404 페이지
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('페이지를 찾을 수 없습니다')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('요청하신 페이지를 찾을 수 없습니다.', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
