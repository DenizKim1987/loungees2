// 셀러 인증 페이지
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class SellerAuthPage extends StatefulWidget {
  const SellerAuthPage({super.key});

  @override
  State<SellerAuthPage> createState() => _SellerAuthPageState();
}

class _SellerAuthPageState extends State<SellerAuthPage> {
  final TextEditingController _authCodeController = TextEditingController();
  final String _correctAuthCode = '44007299';
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  @override
  void dispose() {
    _authCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('셀러 인증'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 인증 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.security,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),

            // 제목
            Text(
              '셀러 관리 페이지',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            // 설명
            Text(
              '관리자 인증코드를 입력해주세요',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // 인증코드 입력 필드
            TextField(
              controller: _authCodeController,
              decoration: InputDecoration(
                labelText: '인증코드',
                hintText: '인증코드를 입력하세요',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                errorText: _errorMessage,
              ),
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, letterSpacing: 2),
              onSubmitted: (_) => _verifyAuthCode(),
            ),
            const SizedBox(height: 24),

            // 인증 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyAuthCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          '인증하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),

            // 도움말
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '인증코드가 필요하신가요? 관리자에게 문의하세요.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 셀러 관리 섹션 (인증 후에만 표시)
            if (_isAuthenticated) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '인증 완료',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '캠페인과 상품을 관리하세요',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/seller/manage');
                          },
                          icon: const Icon(Icons.dashboard),
                          label: const Text('셀러 관리 페이지로 이동'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _verifyAuthCode() async {
    final inputCode = _authCodeController.text.trim();

    if (inputCode.isEmpty) {
      setState(() {
        _errorMessage = '인증코드를 입력해주세요';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 인증 처리 시뮬레이션 (1초 대기)
    await Future.delayed(const Duration(seconds: 1));

    if (inputCode == _correctAuthCode) {
      // 인증 성공 - AuthProvider 업데이트
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.authenticate(inputCode);

      setState(() {
        _isLoading = false;
        _isAuthenticated = true;
        _errorMessage = null;
      });
    } else {
      // 인증 실패
      setState(() {
        _isLoading = false;
        _errorMessage = '인증코드가 올바르지 않습니다';
      });
    }
  }
}
