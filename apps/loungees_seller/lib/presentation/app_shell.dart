// 앱 쉘 - 실제 앱 실행 및 테마, 라우팅 관리
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:loungees_theme/loungees_theme.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import 'pages/campaign_detail_page.dart';
import 'pages/campaign_guide_page.dart';
import 'pages/campaign_recruit_page.dart';
import 'pages/home_page.dart';
import 'pages/item_register_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/seller_auth_page.dart';
import 'pages/seller_page.dart';
import 'pages/unauthorized_page.dart';
import 'providers/auth_provider.dart';
import 'providers/campaign_provider.dart';
import 'providers/item_provider.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  // 권한이 필요한 라우트인지 체크
  bool _isProtectedRoute(String? routeName) {
    if (routeName == null) return false;

    // 셀러 관련 라우트들은 인증 후에만 접근 가능
    return routeName.startsWith('/seller/manage') ||
        routeName.startsWith('/item-add/') ||
        routeName.startsWith('/item-edit/') ||
        routeName.startsWith('/campaign-detail/');
  }

  // 설정에 따른 라우트 빌드
  Widget _buildRouteForSettings(BuildContext context, RouteSettings settings) {
    // 홈페이지 라우트 처리 (URL 파라미터 지원)
    if (settings.name == AppRoutes.home) {
      return const HomePage();
    }
    // /campaign/shortId 형태의 라우트 처리 (캠페인 신청)
    if (settings.name?.startsWith('/campaign/') == true) {
      final shortId = settings.name!.split('/').last;
      return CampaignRecruitPage(shortId: shortId);
    }

    // /item-add/sellerId 형태의 라우트 처리 (새 등록)
    if (settings.name?.startsWith('/item-add/') == true) {
      final sellerId = settings.name!.split('/').last;
      return ItemRegisterPage(sellerId: sellerId);
    }

    // /item-edit/itemId 형태의 라우트 처리 (수정)
    if (settings.name?.startsWith('/item-edit/') == true) {
      final itemId = settings.name!.split('/').last;
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      final itemToEdit = itemProvider.getItemById(itemId);

      return ItemRegisterPage(
        sellerId: 'seller_001', // 임시 셀러 ID
        itemToEdit: itemToEdit,
      );
    }

    // /campaign-detail/campaignId 형태의 라우트 처리 (캠페인 상세)
    if (settings.name?.startsWith('/campaign-detail/') == true) {
      final campaignId = settings.name!.split('/').last;
      return CampaignDetailPage(campaignId: campaignId);
    }

    // /campaign-guide/campaignId 형태의 라우트 처리 (캠페인 가이드)
    if (settings.name?.startsWith('/campaign-guide/') == true) {
      final campaignId = settings.name!.split('/').last;
      return FutureBuilder<Campaign?>(
        future: Provider.of<CampaignProvider>(
          context,
          listen: false,
        ).getCampaignByShortId(campaignId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: const Text('로딩 중...')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('오류')),
              body: const Center(child: Text('캠페인을 찾을 수 없습니다.')),
            );
          }

          return CampaignGuidePage(
            campaign: snapshot.data!,
            selectedReviewType: 'text', // 기본값으로 텍스트 리뷰 설정
          );
        },
      );
    }

    return const NotFoundPage();
  }

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
      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.profile: (context) => const ProfilePage(),
        AppRoutes.seller: (context) => const SellerAuthPage(),
        '/seller/manage': (context) => const SellerPage(),
        '/unauthorized': (context) => const UnauthorizedPage(),
      },

      // 동적 라우팅 처리
      onGenerateRoute: (settings) {
        // 권한이 필요한 라우트들 체크
        if (_isProtectedRoute(settings.name)) {
          return MaterialPageRoute(
            builder: (context) {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              if (!authProvider.isAuthenticated) {
                return const UnauthorizedPage();
              }
              // 인증된 경우 원래 라우트로 이동
              return _buildRouteForSettings(context, settings);
            },
            settings: settings,
          );
        }

        // 일반 라우트 처리
        return MaterialPageRoute(
          builder: (context) => _buildRouteForSettings(context, settings),
          settings: settings,
        );
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
