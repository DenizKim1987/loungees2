// 로그인 페이지 - 최소한의 구조
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: const Center(
        child: Text('로그인 페이지'),
      ),
    );
  }
}
