// 홈 페이지 - 최소한의 구조
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'my_campaign_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _campaignIdController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // didChangeDependencies에서 URL 파라미터 확인
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkUrlParameters();
  }

  void _checkUrlParameters() {
    // 웹에서 URL 파라미터 확인 (여러 방법 시도)
    String? campaignId;

    // 방법 1: ModalRoute에서 확인
    final routeSettings = ModalRoute.of(context)?.settings;
    if (routeSettings?.name != null) {
      final uri = Uri.parse(routeSettings!.name!);
      campaignId = uri.queryParameters['id'];
      print(
        'HomePage: ModalRoute 방법 - routeName: ${routeSettings.name}, campaignId: $campaignId',
      );
    }

    // 방법 2: 웹에서 직접 URL 확인 (웹 전용)
    if (campaignId == null || campaignId.isEmpty) {
      try {
        // 웹에서 현재 URL 직접 확인
        final currentUrl = Uri.base.toString();
        final uri = Uri.parse(currentUrl);
        campaignId = uri.queryParameters['id'];
        print(
          'HomePage: 직접 URL 방법 - currentUrl: $currentUrl, campaignId: $campaignId',
        );
      } catch (e) {
        print('HomePage: 직접 URL 확인 실패 - $e');
      }
    }

    if (campaignId != null && campaignId.isNotEmpty) {
      print('HomePage: 캠페인 ID 발견 - $campaignId');
      _campaignIdController.text = campaignId.toUpperCase();

      // 입력 필드에만 채우고 자동 이동하지 않음
      // 사용자가 직접 "캠페인 신청하기" 버튼을 클릭하도록 함
      print('HomePage: 캠페인 ID가 입력 필드에 채워짐');
    } else {
      print('HomePage: 캠페인 ID가 없거나 비어있음');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loungees'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
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

            // 내가 신청한 캠페인 섹션 (로그인 개념)
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
                          Icons.person,
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '내가 신청한 캠페인',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '전화번호로 내가 신청한 캠페인을 확인하세요',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: '전화번호',
                        hintText: '예: 01012345678',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (_phoneController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('전화번호를 입력해주세요'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => MyCampaignListPage(
                                    phoneNumber: _phoneController.text.trim(),
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('내 캠페인 확인하기'),
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
    _phoneController.dispose();
    super.dispose();
  }
}
