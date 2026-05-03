import 'package:flutter/material.dart';

/// EcoTrade renk paleti — uygulama genelinde tek kaynak.
abstract final class AppColors {
  /// Arka plan (krem)
  static const Color background = Color(0xFFF8F3E1);

  /// İkincil / detay (bej)
  static const Color secondary = Color(0xFFE3DBBB);

  /// Vurgu / yumuşak yeşil
  static const Color accent = Color(0xFFAEB784);

  /// Ana koyu yeşil (alt navigasyon çubuğu)
  static const Color bottomBar = Color(0xFF41431B);

  /// Yazı ve ikincil metin detayı (siyah)
  static const Color text = Color(0xFF000000);

  /// Alt çubukta seçili öğe — krem/beyaza yakın okunaklılık
  static const Color bottomBarSelected = Color(0xFFF8F3E1);

  /// Alt çubukta seçili olmayan öğe
  static const Color bottomBarUnselected = Color(0xFFB8B59A);
}
