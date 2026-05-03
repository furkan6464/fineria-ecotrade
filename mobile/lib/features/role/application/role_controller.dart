import 'package:flutter/foundation.dart';

/// Uygulamanın hangi profille çalıştığını tutar (üretici / tüketici / seçilmedi).
/// Auth tamamen kaldırıldı; menüden "Çıkış yap" denilince [clear] çağrılır.
enum UserRole { none, producer, consumer }

class RoleController extends ChangeNotifier {
  UserRole _role = UserRole.none;

  UserRole get role => _role;

  bool get hasSelected => _role != UserRole.none;

  void selectProducer() {
    if (_role == UserRole.producer) return;
    _role = UserRole.producer;
    notifyListeners();
  }

  void selectConsumer() {
    if (_role == UserRole.consumer) return;
    _role = UserRole.consumer;
    notifyListeners();
  }

  void clear() {
    if (_role == UserRole.none) return;
    _role = UserRole.none;
    notifyListeners();
  }
}
