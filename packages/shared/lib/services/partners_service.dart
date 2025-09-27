import 'dart:convert';

import 'package:http/http.dart' as http;

class PartnersService {
  static const String functionsBaseUrl =
      'https://us-central1-loungees-49897.cloudfunctions.net';
  static const String channelId = 'loungees';

  // 공통 HTTP POST 요청 메서드
  Future<String> _createLink(
    Map<String, dynamic> payload,
    String errorMessage,
  ) async {
    try {
      print('PartnersService: 요청 시작 - $payload');

      final response = await http.post(
        Uri.parse('$functionsBaseUrl/generateCoupangLinks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('PartnersService: 응답 상태 코드 - ${response.statusCode}');
      print('PartnersService: 응답 본문 - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 응답 데이터에 데이터 배열과 shortenUrl 필드가 제대로 있는지 확인
        if (data['data'] != null &&
            data['data'] is List &&
            data['data'].isNotEmpty &&
            data['data'][0]['shortenUrl'] != null) {
          return data['data'][0]['shortenUrl'];
        } else {
          throw Exception('응답 데이터 형식 오류');
        }
      } else {
        throw Exception('$errorMessage: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$errorMessage: $e');
    }
  }

  // 웹용 홈 링크 생성
  Future<String> createHomeLink() async {
    return _createLink({
      'coupangUrls': ['https://www.coupang.com/'],
      'subId': channelId,
    }, '홈 링크 생성 실패');
  }

  // 웹용 검색 링크 생성
  Future<String> createSearchLink(String keyword) async {
    return _createLink({
      'coupangUrls': [
        'https://www.coupang.com/np/search?component=&q=$keyword&channel=user',
      ],
      'subId': channelId,
    }, '검색 링크 생성 실패');
  }

  // 웹용 상품 링크 생성
  Future<String> createProductLink(String productUrl) async {
    return _createLink({
      'coupangUrls': [productUrl],
      'subId': channelId,
    }, '상품 링크 생성 실패');
  }

  // PWA용 홈 딥링크 생성
  Future<String> createHomeDeepLink() async {
    return _createLink({
      'coupangUrls': ['coupang://www.coupang.com/'],
      'subId': channelId,
    }, '홈 딥링크 생성 실패');
  }

  // PWA용 검색 딥링크 생성
  Future<String> createSearchDeepLink(String keyword) async {
    return _createLink({
      'coupangUrls': [
        'coupang://www.coupang.com/np/search?component=&q=$keyword&channel=user',
      ],
      'subId': channelId,
    }, '검색 딥링크 생성 실패');
  }

  // PWA용 상품 딥링크 생성
  Future<String> createProductDeepLink(String productUrl) async {
    final deepLink = productUrl.replaceFirst('https://', 'coupang://');
    return _createLink({
      'coupangUrls': [deepLink],
      'subId': channelId,
    }, '상품 딥링크 생성 실패');
  }

  // 검색 링크 생성 (웹 + 딥링크)
  Future<Map<String, String>> generateSearchLinks(String keyword) async {
    try {
      final webLink = await createSearchLink(keyword);
      final deepLink = await createSearchDeepLink(keyword);
      return {'web': webLink, 'deep': deepLink};
    } catch (e) {
      print('검색 링크 생성 실패: $e');
      // 실패 시 기본 웹 링크 생성
      final fallbackWebLink =
          'https://www.coupang.com/np/search?component=&q=$keyword&channel=user&subId=$channelId';
      return {'web': fallbackWebLink, 'deep': fallbackWebLink};
    }
  }

  // 상품 링크 생성 (웹 + 딥링크)
  Future<Map<String, String>> generateProductLinks(String productUrl) async {
    try {
      final webLink = await createProductLink(productUrl);
      final deepLink = await createProductDeepLink(productUrl);
      return {'web': webLink, 'deep': deepLink};
    } catch (e) {
      print('상품 링크 생성 실패: $e');
      // 실패 시 기본 웹 링크 생성
      final separator = productUrl.contains('?') ? '&' : '?';
      final fallbackWebLink = '$productUrl${separator}subId=$channelId';
      return {'web': fallbackWebLink, 'deep': fallbackWebLink};
    }
  }
}
