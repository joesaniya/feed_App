import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/post_model.dart';

class PostRepository {
  final ApiClient _client;

  PostRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<PostsPage> getLatestPosts({int page = 1, int limit = 20}) async {
    final data = await _client.get(
      ApiEndpoints.latestPosts,
      query: {'page_no': page, 'limit': limit},
    );
    return PostsPage.fromJson(data as Map<String, dynamic>);
  }
}