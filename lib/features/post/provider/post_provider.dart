import 'dart:collection';

import 'package:flutter/foundation.dart';
import '../../../core/api/api_exception.dart';
import '../models/post_model.dart';
import '../repository/post_repository.dart';

enum ViewState { initial, loading, loaded, loadingMore, empty, error }

class PostProvider extends ChangeNotifier {
  final PostRepository _repository;
  static const int _limit = 20;

  PostProvider({PostRepository? repository})
    : _repository = repository ?? PostRepository();

  ViewState _state = ViewState.initial;
  List<PostModel> _posts = const [];
  UnmodifiableListView<PostModel> _postsView = UnmodifiableListView(
    const <PostModel>[],
  );
  String? _errorMessage;
  String? _paginationErrorMessage;

  int _page = 0;
  int _totalCount = 0;
  bool _hasMore = true;
  bool _isRefreshing = false;
  int _requestGeneration = 0;

  ViewState get state => _state;
  List<PostModel> get posts => _postsView;
  String? get errorMessage => _errorMessage;
  String? get paginationErrorMessage => _paginationErrorMessage;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _state == ViewState.loadingMore;
  bool get isLoading => _state == ViewState.loading;

  Future<void> fetchPosts() async {
    if (_isRefreshing) return;

    final generation = ++_requestGeneration;
    _isRefreshing = true;
    _paginationErrorMessage = null;
    _errorMessage = null;
    if (_posts.isEmpty) _state = ViewState.loading;
    notifyListeners();

    try {
      final result = await _repository.getLatestPosts(page: 1, limit: _limit);

      if (generation != _requestGeneration) return;
      _replacePosts(_uniquePosts(result.posts));
      _page = 1;
      _totalCount = result.totalCount;
      _hasMore = _canLoadMore(result.posts.length);
      _state = _posts.isEmpty ? ViewState.empty : ViewState.loaded;
    } on ApiException catch (e) {
      if (generation == _requestGeneration) {
        _errorMessage = e.message;
        _state = _posts.isEmpty ? ViewState.error : ViewState.loaded;
      }
    } catch (_) {
      if (generation == _requestGeneration) {
        _errorMessage = 'Unable to load posts. Please try again.';
        _state = _posts.isEmpty ? ViewState.error : ViewState.loaded;
      }
    } finally {
      if (generation == _requestGeneration) {
        _isRefreshing = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isRefreshing ||
        isLoadingMore ||
        !_hasMore ||
        _state != ViewState.loaded) {
      return;
    }

    final generation = _requestGeneration;
    _paginationErrorMessage = null;
    _state = ViewState.loadingMore;
    notifyListeners();

    try {
      final next = _page + 1;
      final result = await _repository.getLatestPosts(
        page: next,
        limit: _limit,
      );
      if (generation != _requestGeneration) return;
      _page = next;
      _appendUniquePosts(result.posts);
      if (result.totalCount > 0) _totalCount = result.totalCount;
      _hasMore = _canLoadMore(result.posts.length);
    } on ApiException catch (e) {
      if (generation == _requestGeneration) {
        _paginationErrorMessage = e.message;
      }
    } catch (_) {
      if (generation == _requestGeneration) {
        _paginationErrorMessage =
            'Unable to load more posts. Please try again.';
      }
    } finally {
      if (generation == _requestGeneration) {
        _state = ViewState.loaded;
        notifyListeners();
      }
    }
  }

  bool _canLoadMore(int lastPageLength) {
    if (_totalCount > 0) return _posts.length < _totalCount;
    return lastPageLength >= _limit;
  }

  void _replacePosts(List<PostModel> posts) {
    _posts = posts;
    _postsView = UnmodifiableListView(_posts);
  }

  void _appendUniquePosts(List<PostModel> incoming) {
    final seen = _posts.map((post) => post.uniqueKey).toSet();
    final merged = [..._posts];
    for (final post in incoming) {
      if (seen.add(post.uniqueKey)) merged.add(post);
    }
    _replacePosts(merged);
  }

  List<PostModel> _uniquePosts(List<PostModel> posts) {
    final unique = <String, PostModel>{};
    for (final post in posts) {
      unique.putIfAbsent(post.uniqueKey, () => post);
    }
    return unique.values.toList(growable: false);
  }
}
