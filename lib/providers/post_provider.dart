import 'dart:io';
import 'package:clbdoanhnhansg/models/create_post.dart';
import 'package:flutter/cupertino.dart';
import 'package:clbdoanhnhansg/repository/post_repository.dart';
import 'package:flutter/material.dart';
import '../core/base/base_provider.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/posts.dart';
import '../widgets/loading_overlay.dart';

class PostProvider extends BaseProvider {
  final PostRepository _postRepository = PostRepository();
  List<Posts> _posts = [];
  List<Posts> get posts => _posts;

  List<Posts> _listPostMe = [];
  List<Posts> get listPostMe => _listPostMe;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Posts> _listPostFeatured = [];
  List<Posts> get listPostFeatured => _listPostFeatured;

  List<Posts> _listtByID = [];
  List<Posts> get listtByID => _listtByID;
  bool _isLoadingByID = false;
  bool get isLoadingByID => _isLoadingByID;

  //tìm kiếm bài viết
  String _lastSearchKeyword = '';
  int _lastSearchCategory = 1;

  String get lastSearchKeyword => _lastSearchKeyword;
  int get lastSearchCategory => _lastSearchCategory;

  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMorePosts = true;
  bool _isLoadingMore = false;
  String _errorMessage = '';

  // Getter for the new properties
  bool get hasMorePosts => _hasMorePosts;
  bool get isLoadingMore => _isLoadingMore;
  String get errorMessage => _errorMessage;

  // Reset pagination state
  void resetPagination() {
    _currentPage = 1;
    _hasMorePosts = true;
    _posts = [];
    _errorMessage = '';
    notifyListeners();
  }

  //lưu trạng thái like của bài viết
  final Map<String, bool> _likedPosts = {};

  Future<void> createPostAD(Map<String, dynamic> postData, BuildContext context,
      {List<File>? files}) async {
    LoadingOverlay.show(context);

    // Chuyển đổi dữ liệu sang model Posts
    CreatePost post = CreatePost.fromJson(postData);

    await executeApiCall(
      apiCall: () async {
        var response =
            await _postRepository.createPostAD(post, context, files: files);

        return response;
      },
      context: context,
      onSuccess: () async {
        // await (context);
        Navigator.of(context).pop();
      },
      successMessage: 'Tạo bài viết thành công!',
    );

    LoadingOverlay.hide();
  }

  Future<void> fetchPosts(BuildContext context) async {
    resetPagination();
    _isLoading = true;
    notifyListeners();
    try {
      await _loadPostsPage(context);
    } catch (e) {
      _errorMessage = 'Không thể tải bài viết: ${e.toString()}';
      print('Lỗi khi lấy bài đăng: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load more posts when scrolling
  Future<void> loadMorePosts(BuildContext context) async {
    if (_isLoadingMore || !_hasMorePosts) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      await _loadPostsPage(context);
    } catch (e) {
      _errorMessage = 'Không thể tải thêm bài viết: ${e.toString()}';
      print('Lỗi khi tải thêm bài viết: $e');
    }

    _isLoadingMore = false;
    notifyListeners();
  }

// Internal method to load a page of posts
  Future<void> _loadPostsPage(BuildContext context) async {
    Map<String, dynamic> body = {"page": _currentPage, "limit": _pageSize};

    final response = await ApiClient().postRequest(
      ApiEndpoints.postNew,
      body,
      context,
    );

    if (response != null && response.containsKey('posts')) {
      List postsData = response['posts'];

      if (postsData.isEmpty) {
        _hasMorePosts = false;
      } else {
        List<Posts> newPosts =
            postsData.map((post) => Posts.fromJson(post)).toList();

        if (_currentPage == 1) {
          _posts = newPosts;
        } else {
          _posts.addAll(newPosts);
        }

        _currentPage++;
      }
    } else {
      _hasMorePosts = false;
    }
  }

  Future<void> fetchPostsByUser(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Tạo dữ liệu body cần gửi
      Map<String, dynamic> body = {};

      // Gửi yêu cầu POST đến API
      final response = await ApiClient().postRequest(
        ApiEndpoints.post,
        body,
        context,
      );

      if (response != null) {
        List postsData = response['posts'];

        // Chuyển đổi dữ liệu từ JSON sang các đối tượng Posts
        _listPostMe = postsData.map((post) => Posts.fromJson(post)).toList();

        // Thông báo cho UI cập nhật lại (notifyListeners)
        notifyListeners();

        print('Danh sách bài đăng của user: $_posts');
      }
    } catch (e) {
      print('Lỗi khi lấy bài đăng: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPostsFeatured(BuildContext context) async {
    notifyListeners();
    try {
      // Tạo dữ liệu body cần gửi
      Map<String, dynamic> body = {'is_featured': true};

      // Gửi yêu cầu POST đến API
      final response = await ApiClient().postRequest(
        ApiEndpoints.postNew,
        body,
        context,
      );

      List postsData = response['posts'];

      // Chuyển đổi dữ liệu từ JSON sang các đối tượng Posts
      _listPostFeatured =
          postsData.map((post) => Posts.fromJson(post)).toList();

      // Thông báo cho UI cập nhật lại (notifyListeners)
      notifyListeners();
    } catch (e) {
      print('Lỗi khi lấy bài đăng: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchPost(BuildContext context, int category, String keyword,
      {bool showLoading = true}) async {
    // Don't search if keyword is empty
    if (keyword.trim().isEmpty) {
      _posts = [];
      notifyListeners();
      return;
    }

    // Save the search parameters
    _lastSearchKeyword = keyword;
    _lastSearchCategory = category;

    // Only show loading if requested (allows for silent background refreshes)
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      // Create request body
      Map<String, dynamic> body = {
        'category': category,
        'keyword': keyword,
      };

      // Send POST request to API
      final response = await ApiClient().postRequest(
        ApiEndpoints.postNew,
        body,
        context,
      );

      if (response != null) {
        List postsData = response['posts'] ?? [];

        // Convert JSON data to Posts objects
        _posts = postsData.map((post) => Posts.fromJson(post)).toList();

        // Notify UI to update
        notifyListeners();

        print(
            'Search results for "$keyword" (category: $category): ${_posts.length} posts found');
      }
    } catch (e) {
      print('Error fetching search results: $e');
      // Add error handling here, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi tìm kiếm: $e')),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // Clear search results
  void clearSearchResults() {
    _posts = [];
    notifyListeners();
  }

  Future<void> fethPostByCategory(BuildContext context, int category,
      {bool showLoading = true}) async {
    // Only show loading if requested (allows for silent background refreshes)
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      // Create request body
      Map<String, dynamic> body = {
        'category': category,
      };

      // Send POST request to API
      final response = await ApiClient().postRequest(
        ApiEndpoints.postNew,
        body,
        context,
      );
      if (response != null) {
        List postsData = response['posts'] ?? [];
        // Convert JSON data to Posts objects
        _posts = postsData.map((post) => Posts.fromJson(post)).toList();
        // Notify UI to update
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching search results: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike(String postId, BuildContext context) async {
    setLoading(true);

    await executeApiCall(
      apiCall: () => _postRepository.toggleLikePost(postId, context),
      context: context,
      onSuccess: () {
        // Kiểm tra xem bài viết đã được thả tim chưa
        if (_likedPosts.containsKey(postId)) {
          _likedPosts[postId] = !_likedPosts[postId]!;
        } else {
          _likedPosts[postId] = true;
        }
        notifyListeners();
      },
      successMessage: "Cập nhật lượt thích thành công!",
    );

    setLoading(false);
  }

  Future<void> fetchListPostByUser(BuildContext context, String id) async {
    _isLoadingByID = true;
    notifyListeners();

    try {
      // Gửi request POST đến API để lấy danh sách bài đăng theo User ID
      final response = await ApiClient().getRequest(
        '${ApiEndpoints.postByUser}/$id',
        context,
      );

      // Check if response contains posts and it's not null
      if (response.containsKey('posts') && response['posts'] != null) {
        List postsData = response['posts'];
        // Chuyển đổi danh sách JSON thành danh sách các đối tượng Posts
        _listtByID = postsData.map((post) => Posts.fromJson(post)).toList();
      } else {
        // If there are no posts, set to empty list
        _listtByID = [];
        print('No posts found for user $id');
      }

      // Thông báo UI cập nhật lại dữ liệu
      notifyListeners();
    } catch (e) {
      print('Lỗi khi lấy danh sách bài đăng của user: $e');
      // Set to empty list in case of error
      _listtByID = [];
    }

    _isLoadingByID = false;
    notifyListeners();
  }
}

