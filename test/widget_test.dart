// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/core/api/api_client.dart';
import 'package:simple_app/core/api/api_exception.dart';
import 'package:simple_app/core/api/api_endpoints.dart';
import 'package:simple_app/features/post/models/post_model.dart';
import 'package:simple_app/features/post/provider/post_provider.dart';
import 'package:simple_app/features/post/repository/post_repository.dart';
import 'package:simple_app/features/post/views/post_screen.dart';

void main() {
  testWidgets('initial feed exposes an accessible loading skeleton', (
    tester,
  ) async {
    final provider = PostProvider(repository: _PendingPostRepository());
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: PostScreen()),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Loading post'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    semantics.dispose();
    provider.dispose();
  });

  test(
    'repository sends paging parameters and parses the API response',
    () async {
      final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
      final client = ApiClient(dio: dio, authToken: 'test-token');
      RequestOptions? capturedRequest;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedRequest = options;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                data: {
                  'data': {
                    'data': {'rows': [], 'count': 0},
                  },
                },
              ),
            );
          },
        ),
      );
      final repository = PostRepository(client: client);

      final page = await repository.getLatestPosts(page: 3, limit: 5);

      expect(page.posts, isEmpty);
      expect(page.totalCount, 0);
      expect(capturedRequest?.queryParameters, {'page_no': 3, 'limit': 5});
      expect(capturedRequest?.headers['Authorization'], 'Bearer test-token');
    },
  );

  test('connection errors map to an offline-friendly message', () {
    final exception = ApiException.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      ),
    );

    expect(exception.message, 'No internet connection.');
  });

  test('posts exposes a stable unmodifiable view', () async {
    final provider = PostProvider(
      repository: _FakePostRepository([
        _page([_post(1)], count: 1),
      ]),
    );

    final postsBeforeFetch = provider.posts;
    expect(identical(postsBeforeFetch, provider.posts), isTrue);

    await provider.fetchPosts();

    expect(identical(provider.posts, provider.posts), isTrue);
    expect(() => provider.posts.add(_post(2)), throwsUnsupportedError);
  });

  test('empty response enters the empty state', () async {
    final repository = _FakePostRepository([_page(const [], count: 0)]);
    final provider = PostProvider(repository: repository);

    await provider.fetchPosts();

    expect(provider.state, ViewState.empty);
    expect(provider.posts, isEmpty);
    expect(provider.hasMore, isFalse);
  });

  test('refresh cancels an in-flight pagination request', () async {
    final repository = _BlockingPostRepository();
    final provider = PostProvider(repository: repository);

    await provider.fetchPosts();
    final pagination = provider.loadMore();
    final paginationToken = repository.lastCancelToken;
    await provider.fetchPosts();

    expect(paginationToken?.isCancelled, isTrue);
    expect(repository.requestedPages, [1, 2, 1]);
    await pagination;
    expect(provider.state, ViewState.loaded);
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
  Future<PostsPage> getLatestPosts({
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    requestedPages.add(page);
    lastCancelToken = cancelToken;
    final response = _responses.removeAt(0);
    if (response is ApiException) throw response;
    return response as PostsPage;
  }

  CancelToken? lastCancelToken;
}

class _BlockingPostRepository extends PostRepository {
  final requestedPages = <int>[];
  CancelToken? lastCancelToken;
  bool _initialRequest = true;

  @override
  Future<PostsPage> getLatestPosts({
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    requestedPages.add(page);
    lastCancelToken = cancelToken;
    if (page == 1) {
      if (_initialRequest) {
        _initialRequest = false;
        return _page([_post(1)], count: 2);
      }
      return _page([_post(1)], count: 2);
    }
    final completer = Completer<PostsPage>();
    cancelToken!.whenCancel.then(
      (_) => completer.completeError(
        DioException.requestCancelled(
          requestOptions: RequestOptions(path: '/posts'),
          reason: 'cancelled',
        ),
      ),
    );
    return completer.future;
  }
}

class _PendingPostRepository extends PostRepository {
  final _response = Completer<PostsPage>();

  @override
  Future<PostsPage> getLatestPosts({
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) {
    cancelToken?.whenCancel.then((cancel) {
      if (!_response.isCompleted) {
        _response.completeError(
          DioException.requestCancelled(
            requestOptions: RequestOptions(path: '/posts'),
            reason: cancel.message,
          ),
        );
      }
    });
    return _response.future;
  }
}
