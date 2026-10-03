// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_app/core/api/api_exception.dart';
import 'package:simple_app/features/post/models/post_model.dart';
import 'package:simple_app/features/post/provider/post_provider.dart';
import 'package:simple_app/features/post/repository/post_repository.dart';

void main() {
  test('empty response enters the empty state', () async {
    final repository = _FakePostRepository([_page(const [], count: 0)]);
    final provider = PostProvider(repository: repository);

    await provider.fetchPosts();

    expect(provider.state, ViewState.empty);
    expect(provider.posts, isEmpty);
    expect(provider.hasMore, isFalse);
  });

  test(
    'pagination appends unique posts and stops at the reported total',
    () async {
      final firstPage = List.generate(20, (index) => _post(index));
      final repository = _FakePostRepository([
        _page(firstPage, count: 21),
        _page([_post(19), _post(20)], count: 21),
      ]);
      final provider = PostProvider(repository: repository);

      await provider.fetchPosts();
      await Future.wait([provider.loadMore(), provider.loadMore()]);

      expect(repository.requestedPages, [1, 2]);
      expect(provider.posts, hasLength(21));
      expect(provider.hasMore, isFalse);
      expect(provider.state, ViewState.loaded);
    },
  );

  test(
    'refresh failure preserves existing posts and exposes a retry message',
    () async {
      final repository = _FakePostRepository([
        _page([_post(1)], count: 1),
        ApiException('Service unavailable.'),
      ]);
      final provider = PostProvider(repository: repository);

      await provider.fetchPosts();
      await provider.fetchPosts();

      expect(provider.state, ViewState.loaded);
      expect(provider.posts, hasLength(1));
      expect(provider.errorMessage, 'Service unavailable.');
    },
  );

  test('malformed optional API values parse to safe defaults', () {
    final page = PostsPage.fromJson({
      'data': {
        'data': {
          'rows': [
            null,
            3,
            {
              'id': 7,
              'profile': {'first_name': 12},
              'files': 'not-a-list',
              'post_type_category': false,
            },
          ],
        },
      },
    });

    expect(page.posts, hasLength(1));
    expect(page.posts.single.id, '7');
    expect(page.posts.single.profile.firstName, '12');
    expect(page.posts.single.files, isEmpty);
    expect(page.totalCount, 0);
  });
}

PostsPage _page(List<PostModel> posts, {required int count}) =>
    PostsPage(totalCount: count, posts: posts);

PostModel _post(int id) => PostModel(
  id: '$id',
  userId: 'user-$id',
  content: 'Post $id',
  user: PostUser(id: 'user-$id', username: 'user$id'),
  profile: PostProfile(firstName: 'User', lastName: '$id'),
);

class _FakePostRepository extends PostRepository {
  _FakePostRepository(this._responses);

  final List<Object> _responses;
  final requestedPages = <int>[];

  @override
  Future<PostsPage> getLatestPosts({int page = 1, int limit = 20}) async {
    requestedPages.add(page);
    final response = _responses.removeAt(0);
    if (response is ApiException) throw response;
    return response as PostsPage;
  }
}
