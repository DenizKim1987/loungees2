// 앱 라우팅 관리
import 'package:flutter/material.dart';

import '../presentation/pages/home_page.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/profile_page.dart';
import '../presentation/pages/seller_page.dart';

class AppRoutes {
  // 라우트 경로 상수
  static const String home = '/';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String seller = '/seller';

  // 라우트 이름 상수
  static const String homeRoute = 'home';
  static const String loginRoute = 'login';
  static const String profileRoute = 'profile';
  static const String sellerRoute = 'seller';

  // 라우트 맵
  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomePage(),
    login: (context) => const LoginPage(),
    profile: (context) => const ProfilePage(),
    seller: (context) => const SellerPage(),
  };
}
