import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import 'storage_service.dart';

/// Dio-based HTTP client; Bearer JWT; 401 → refresh or clear.
class ApiService {
  ApiService._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      // Do not force a global Content-Type. Multipart requests (FormData) must
      // be able to set `multipart/form-data; boundary=...` automatically.
      headers: {'Accept': 'application/json'},
    ),
  );

  static void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = StorageService.token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            StorageService.clearAuth();
            // Could trigger logout / redirect to login here
          }
          return handler.next(e);
        },
      ),
    );
  }

  static Dio get dio => _dio;

  static Future<Response<T>> get<T>(String path, {Map<String, dynamic>? params}) =>
      _dio.get<T>(path, queryParameters: params);

  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Duration? receiveTimeout,
  }) {
    final options = receiveTimeout != null
        ? Options(receiveTimeout: receiveTimeout)
        : null;
    return _dio.post<T>(path, data: data, options: options);
  }

  static Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  static Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);

  static Future<Response<T>> postMultipart<T>(
    String path, {
    required FormData formData,
  }) =>
      _dio.post<T>(path, data: formData);
}
