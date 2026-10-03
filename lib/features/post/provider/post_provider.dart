import 'dart:developer';

import 'package:flutter/foundation.dart';
import '../../../core/api/api_exception.dart';
import '../models/post_model.dart';
import '../repository/post_repository.dart';

enum ViewState { idle, loading, success, error }

class PostProvider extends ChangeNotifier {
  final PostRepository _repository;
  static const int _limit = 20;

  PostProvider({PostRepository? repository})
    : _repository = repository ?? PostRepository();

  ViewState _state = ViewState.idle;
  List<PostModel> _posts = [];
  String? _errorMessage;

  int _page = 1;
  int _totalCount = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  ViewState get state => _state;
  List<PostModel> get posts => List.unmodifiable(_posts);
  String? get errorMessage => _errorMessage;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoading => _state == ViewState.loading;


  Future<void> fetchPosts() async {
    _page = 1;
    _hasMore = true;
    _state = ViewState.loading;
    notifyListeners();

    try {
      final result = await _repository.getLatestPosts(page: 1, limit: _limit);
      
      _posts = result.posts;
      _totalCount = result.totalCount;
      _hasMore = result.posts.length >= _limit;
      _state = ViewState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _state != ViewState.success) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final next = _page + 1;
      final result = await _repository.getLatestPosts(
        page: next,
        limit: _limit,
      );
      _page = next;
      _posts = [..._posts, ...result.posts];
      _hasMore = result.posts.length >= _limit;
    } on ApiException catch (e) {
      _errorMessage =
          e.message; 
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
