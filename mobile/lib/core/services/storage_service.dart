import 'package:hive_flutter/hive_flutter.dart';

/// Hive local storage for token and cache.
class StorageService {
  StorageService._();
  static const _boxName = 'morpheus';
  static const _keyToken = 'token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';

  static Box<dynamic>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  static String? get token => _box?.get(_keyToken) as String?;
  static set token(String? v) => _box?.put(_keyToken, v);

  static String? get refreshToken => _box?.get(_keyRefreshToken) as String?;
  static set refreshToken(String? v) => _box?.put(_keyRefreshToken, v);

  static String? get userId => _box?.get(_keyUserId) as String?;
  static set userId(String? v) => _box?.put(_keyUserId, v);

  static Future<void> clearAuth() async {
    token = null;
    refreshToken = null;
    userId = null;
  }
}
