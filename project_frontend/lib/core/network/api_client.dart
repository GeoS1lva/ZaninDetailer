import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage _storage;

  static const String baseUrl =
      'https://lashaun-unbumped-squarely.ngrok-free.dev/api/v1/';

  ApiClient({required FlutterSecureStorage storage}) : _storage = storage {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
      receiveTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
      contentType: 'application/json',
      headers: {
        'ngrok-skip-browser-warning': 'true',
      },
    ));

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: StoreKeys.accessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            if (e.requestOptions.path.contains('/auth/login')) {
              return handler.next(e);
            }

            final refreshToken =
                await _storage.read(key: StoreKeys.refreshToken);
            if (refreshToken != null) {
              try {
                final refreshResponse = await dio.post(
                  '/auth/refresh',
                  data: {'refresh_token': refreshToken},
                );

                final newAccessToken = refreshResponse.data['access_token'];
                final newRefreshToken = refreshResponse.data['refresh_token'];

                await _storage.write(
                    key: StoreKeys.accessToken, value: newAccessToken);
                await _storage.write(
                    key: StoreKeys.refreshToken, value: newRefreshToken);

                e.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final retryResponse = await dio.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              } catch (refreshError) {
                await _storage.deleteAll();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}
