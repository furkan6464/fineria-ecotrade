import 'package:dio/dio.dart';
import 'package:mobile/core/storage/secure_token_storage.dart';

/// Login/register hariç isteklere `Authorization: Bearer` ekler.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens);

  final SecureTokenStorage _tokens;

  static bool _isAnonymousPath(String path) {
    final p = path.toLowerCase();
    if (p.contains('/auth/login') || p.contains('/auth/register')) {
      return true;
    }
    // Sunucuda JWT doğrulaması yoksa bile gereksiz Bearer göndermeyelim (bazı proxy’ler bozulabilir).
    if (p.startsWith('/api/predictions/') ||
        p.startsWith('/api/ai/')) {
      return true;
    }
    // Python uvicorn — Bearer gönderme
    if (p == '/ai/chat' || p.endsWith('/ai/chat')) {
      return true;
    }
    return false;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isAnonymousPath(options.uri.path)) {
      return handler.next(options);
    }
    final token = await _tokens.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
