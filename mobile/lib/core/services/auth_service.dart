import 'package:dio/dio.dart';
import 'api_service.dart';
import '../constants/api_endpoints.dart';
import 'storage_service.dart';

class AuthService {
  AuthService._();

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiService.dio.post(
      ApiEndpoints.login,
      data: {
        'username': email,
        'password': password,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final data = res.data as Map<String, dynamic>;
    final token = data['access_token'] as String?;
    if (token == null) throw Exception('No token in response');
    StorageService.token = token;
    final me = await meProfile();
    StorageService.userId = me['_id'] ?? me['id'] ?? me['user_id']?.toString();
    return me;
  }

  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await ApiService.dio.post(
      ApiEndpoints.signup,
      data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      },
    );
    final data = res.data as Map<String, dynamic>;
    final token = data['access_token'] as String?;
    if (token != null) {
      StorageService.token = token;
      final me = await meProfile();
      StorageService.userId = me['_id']?.toString() ?? me['id']?.toString() ?? me['user_id']?.toString();
      return me;
    }
    return login(email, password);
  }

  static Future<Map<String, dynamic>> meProfile() async {
    final res = await ApiService.get(ApiEndpoints.me);
    return res.data as Map<String, dynamic>;
  }

  static bool get isLoggedIn => StorageService.token != null;

  static Future<void> logout() async {
    await StorageService.clearAuth();
  }
}
