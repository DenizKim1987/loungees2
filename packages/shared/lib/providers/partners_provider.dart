import 'package:flutter/material.dart';

import '../services/partners_service.dart';

class PartnersProvider extends ChangeNotifier {
  final PartnersService _partnersService = PartnersService();

  // 검색 링크 생성 (웹 + 딥링크)
  Future<Map<String, String>> generateSearchLinks(String keyword) async {
    return await _partnersService.generateSearchLinks(keyword);
  }

  // 상품 링크 생성 (웹 + 딥링크)
  Future<Map<String, String>> generateProductLinks(String productUrl) async {
    return await _partnersService.generateProductLinks(productUrl);
  }

  // 홈 링크 생성
  Future<String> generateHomeLink() async {
    return await _partnersService.createHomeLink();
  }

  // 홈 딥링크 생성
  Future<String> generateHomeDeepLink() async {
    return await _partnersService.createHomeDeepLink();
  }
}
