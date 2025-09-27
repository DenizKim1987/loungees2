import 'package:intl/intl.dart';

/// 금액 포맷팅 유틸리티
class PriceFormatter {
  /// 천단위 쉼표가 포함된 가격 문자열을 반환합니다.
  ///
  /// 예시:
  /// - 29900 -> "29,900"
  /// - 500 -> "500"
  /// - 1234567 -> "1,234,567"
  static String format(int price) {
    return NumberFormat('#,###').format(price);
  }

  /// double 타입의 가격을 천단위 쉼표가 포함된 문자열로 반환합니다.
  ///
  /// 예시:
  /// - 29900.0 -> "29,900"
  /// - 500.5 -> "500"
  static String formatDouble(double price) {
    return NumberFormat('#,###').format(price.toInt());
  }

  /// 원화 기호와 함께 천단위 쉼표가 포함된 가격 문자열을 반환합니다.
  ///
  /// 예시:
  /// - 29900 -> "₩29,900"
  /// - 500 -> "₩500"
  static String formatWithWon(int price) {
    return '₩${format(price)}';
  }

  /// double 타입의 가격을 원화 기호와 함께 천단위 쉼표가 포함된 문자열로 반환합니다.
  ///
  /// 예시:
  /// - 29900.0 -> "₩29,900"
  /// - 500.5 -> "₩500"
  static String formatDoubleWithWon(double price) {
    return '₩${formatDouble(price)}';
  }
}
