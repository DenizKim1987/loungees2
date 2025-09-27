// 인증 상태 관리 Provider
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _authCode;

  bool get isAuthenticated => _isAuthenticated;
  String? get authCode => _authCode;

  // 인증 성공
  void authenticate(String authCode) {
    _isAuthenticated = true;
    _authCode = authCode;
    notifyListeners();
  }

  // 로그아웃
  void logout() {
    _isAuthenticated = false;
    _authCode = null;
    notifyListeners();
  }

  // 인증 상태 초기화
  void reset() {
    _isAuthenticated = false;
    _authCode = null;
    notifyListeners();
  }
}
