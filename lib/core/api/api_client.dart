import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer ${AppConfig.authToken}';
          if (kDebugMode) debugPrint(' ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              ' ${response.statusCode} ${response.requestOptions.uri}',
            );
          }
          handler.next(response);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            debugPrint(' ${e.response?.statusCode} ${e.message}');
          }
          handler.next(e);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _request(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {dynamic data}) =>
      _request(() => _dio.post(path, data: data));

  Future<dynamic> put(String path, {dynamic data}) =>
      _request(() => _dio.put(path, data: data));

  Future<dynamic> delete(String path) => _request(() => _dio.delete(path));

  Future<dynamic> _request(Future<Response> Function() call) async {
    if (AppConfig.authToken.isEmpty) {
      throw ApiException(
        'Authentication is not configured. Provide AUTH_TOKEN at launch.',
      );
    }

    try {
      final response = await call();
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (_) {
      throw ApiException('Unexpected error occurred.');
    }
  }
}
