// 홈 페이지 - 최소한의 구조
import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _campaignIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loungees'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 메인 타이틀
            Text(
              'Loungees',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '리뷰 캠페인 플랫폼',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),

            // 캠페인 신청 섹션
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.campaign,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '캠페인 신청',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '캠페인 ID를 입력하여 리뷰 캠페인에 참여하세요',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _campaignIdController,
                      decoration: InputDecoration(
                        labelText: '캠페인 ID',
                        hintText: '예: A7B9C2',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.tag),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _campaignIdController.clear();
                          },
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (value) => _navigateToCampaign(value),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            () =>
                                _navigateToCampaign(_campaignIdController.text),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('캠페인 신청하기'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 셀러 관리 섹션
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
                          Icons.store,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '셀러 관리',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '캠페인과 상품을 관리하세요',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.seller);
                        },
                        icon: const Icon(Icons.dashboard),
                        label: const Text('셀러 관리 페이지로 이동'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCampaign(String campaignId) {
    final trimmedId = campaignId.trim().toUpperCase();

    if (trimmedId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('캠페인 ID를 입력해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (trimmedId.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('캠페인 ID는 6자리여야 합니다'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pushNamed(context, '/campaign/$trimmedId');
  }

  @override
  void dispose() {
    _campaignIdController.dispose();
    super.dispose();
  }
}
