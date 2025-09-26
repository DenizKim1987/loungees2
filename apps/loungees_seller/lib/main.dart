// 앱 초기화 및 의존성 주입 설정
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'presentation/app_shell.dart';
import 'presentation/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 파이어베이스 초기화 (옵션 파일 사용)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const LoungeesSellerApp());
}

class LoungeesSellerApp extends StatelessWidget {
  const LoungeesSellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers.cast<ChangeNotifierProvider>(),
      child: const AppShell(),
    );
  }
}
