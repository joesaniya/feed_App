import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import '../models/post_model.dart';

class PostRepository {
  final ApiClient _client;

  PostRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<PostsPage> getLatestPosts({
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    final data = await _client.get(
      ApiEndpoints.latestPosts,
      query: {'page_no': page, 'limit': limit},
      cancelToken: cancelToken,
    );
    if (data is Map<String, dynamic>) return PostsPage.fromJson(data);
    if (data is Map) {
      return PostsPage.fromJson(
        data.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    throw ApiException('The server returned an invalid posts response.');
  }
}
