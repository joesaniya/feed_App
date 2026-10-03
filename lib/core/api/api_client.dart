import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({Dio? dio, String? authToken})
    : _dio = dio ?? _createDio(),
      _authToken = authToken ?? AppConfig.authToken {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $_authToken';
          if (kDebugMode) {
            debugPrint('[api] ${options.method} ${options.uri.path}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              '[api] ${response.statusCode} '
              '${response.requestOptions.uri.path}',
            );
          }
          handler.next(response);
        },
        onError: (e, handler) {
          if (kDebugMode && e.type != DioExceptionType.cancel) {
            debugPrint(
              '[api] ${e.type.name} ${e.requestOptions.method} '
              '${e.requestOptions.uri.path}: ${e.message}',
            );
          }
          handler.next(e);
        },
      ),
    );
  }

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  static final ApiClient instance = ApiClient();
  final Dio _dio;
  final String _authToken;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.get(path, queryParameters: query, cancelToken: cancelToken),
  );

  Future<dynamic> post(String path, {dynamic data}) =>
      _request(() => _dio.post(path, data: data));

  Future<dynamic> put(String path, {dynamic data}) =>
      _request(() => _dio.put(path, data: data));

  Future<dynamic> delete(String path) => _request(() => _dio.delete(path));

  Future<dynamic> _request(Future<Response> Function() call) async {
    if (_authToken.isEmpty) {
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
