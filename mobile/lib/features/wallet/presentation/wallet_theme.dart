import 'package:flutter/material.dart';

/// Cüzdan ekranı — tasarım jetonları (#F5F1E8 gövde).
abstract final class WalletTheme {
  static const Color background = Color(0xFFF5F1E8);

  static const Color border = Color(0xFFD3D1C7);

  static const Color cardWhite = Color(0xFFFFFFFF);

  static const Color labelGray = Color(0xFF6B6A65);

  static const Color titleDark = Color(0xFF1A1A1A);

  /// Üretici / gelir
  static const Color incomeFill = Color(0xFFE1F5EE);
  static const Color incomeFg = Color(0xFF1D9E75);

  /// Tüketici / gider ikon alanı
  static const Color expenseFill = Color(0xFFE6F1FB);
  static const Color expenseFg = Color(0xFF378ADD);

  /// Bekleyen / destek — turuncu
  static const Color accentFill = Color(0xFFFAEEDA);
  static const Color accentFg = Color(0xFFEF9F27);

  /// Nötr / komisyon
  static const Color neutralFill = Color(0xFFF1EFE8);
  static const Color neutralFg = Color(0xFF5F5E5A);

  static const Color aiCardBg = Color(0xFFF1EFE8);

  static const Color aiStar = Color(0xFFC17A2D);

  static const Color amountNegative = Color(0xFF1A1A1A);
}
