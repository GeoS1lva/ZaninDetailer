import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("🌐 [API Request] ${options.method} ${options.path}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("✅ [API Response] ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("❌ [API Error] ${e.message}");
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String path) async => await _dio.get(path);
  Future<Response> post(String path, {dynamic data}) async =>
      await _dio.post(path, data: data);
}
