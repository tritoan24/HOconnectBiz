import 'dart:io';
import 'package:clbdoanhnhansg/models/create_post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:clbdoanhnhansg/repository/post_repository.dart';
import 'package:flutter/material.dart';
import '../core/base/base_provider.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/posts.dart';
import '../widgets/loading_overlay.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
        await fetchPostsByUser(context);
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
      debugPrint('Lỗi khi lấy bài đăng: $e');
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
      debugPrint('Lỗi khi tải thêm bài viết: $e');
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

        debugPrint('Danh sách bài đăng của user: $_posts');
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy bài đăng: $e');
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
      debugPrint('Lỗi khi lấy bài đăng: $e');
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

        debugPrint(
            'Search results for "$keyword" (category: $category): ${_posts.length} posts found');
      }
    } catch (e) {
      debugPrint('Error fetching search results: $e');
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
      debugPrint('Error fetching search results: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike(String postId, BuildContext context) async {
    setLoading(true);
    debugPrint("🔍 DEBUG: toggleLike bắt đầu cho postId: $postId");

    await executeApiCall(
      apiCall: () => _postRepository.toggleLikePost(postId, context),
      context: context,
      onSuccess: () async {
        // Kiểm tra xem bài viết đã được thả tim chưa
        bool oldValue = _likedPosts.containsKey(postId) ? _likedPosts[postId]! : false;
        
        if (_likedPosts.containsKey(postId)) {
          _likedPosts[postId] = !_likedPosts[postId]!;
        } else {
          _likedPosts[postId] = true;
        }
        
        debugPrint("🔍 DEBUG: Trạng thái like thay đổi từ $oldValue thành ${_likedPosts[postId]} cho postId: $postId");
        
        // Cập nhật bài viết cục bộ
        await updatePostLikeStatus(postId);
        
        notifyListeners();
        debugPrint("🔍 DEBUG: toggleLike đã gọi notifyListeners() cho postId: $postId");
      },
      successMessage: "Cập nhật lượt thích thành công!",
    );

    setLoading(false);
  }
  
  // Phương thức cập nhật trạng thái like cho bài viết cục bộ
  Future<void> updatePostLikeStatus(String postId) async {
    debugPrint("🔍 DEBUG: updatePostLikeStatus bắt đầu cho postId: $postId");
    
    // Lấy ID người dùng hiện tại
    String? userId = await _getCurrentUserId();
    
    if (userId == null || userId.isEmpty) {
      debugPrint("⚠️ WARNING: Không thể lấy userId hiện tại");
      return;
    }
    
    debugPrint("🔍 DEBUG: Lấy được userId: $userId");
    bool shouldLike = _likedPosts.containsKey(postId) ? _likedPosts[postId]! : false;
    debugPrint("🔍 DEBUG: Trạng thái like hiện tại: $shouldLike");
    
    // Cập nhật trong danh sách bài viết chính
    bool updatedMainList = false;
    bool updatedFeaturedList = false;
    bool updatedMyList = false;
    bool updatedListById = false;
    
    // Cập nhật trong danh sách bài viết chính
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].id == postId) {
        debugPrint("🔍 DEBUG: Tìm thấy bài viết trong _posts với index $i");
        _posts[i].like ??= [];
        
        if (shouldLike) {
          // Thêm userId vào danh sách like nếu chưa có
          if (!_posts[i].like!.contains(userId)) {
            _posts[i].like!.add(userId);
            debugPrint("🔍 DEBUG: Đã thêm userId vào danh sách like, count mới: ${_posts[i].like?.length}");
          }
        } else {
          // Xóa userId khỏi danh sách like nếu có
          if (_posts[i].like!.contains(userId)) {
            _posts[i].like!.remove(userId);
            debugPrint("🔍 DEBUG: Đã xóa userId khỏi danh sách like, count mới: ${_posts[i].like?.length}");
          }
        }
        updatedMainList = true;
        break;
      }
    }
    
    // Cập nhật trong danh sách bài viết nổi bật
    for (int i = 0; i < _listPostFeatured.length; i++) {
      if (_listPostFeatured[i].id == postId) {
        debugPrint("🔍 DEBUG: Tìm thấy bài viết trong _listPostFeatured với index $i");
        _listPostFeatured[i].like ??= [];
        
        if (shouldLike) {
          if (!_listPostFeatured[i].like!.contains(userId)) {
            _listPostFeatured[i].like!.add(userId);
            debugPrint("🔍 DEBUG: Đã thêm userId vào danh sách like của featured, count mới: ${_listPostFeatured[i].like?.length}");
          }
        } else {
          if (_listPostFeatured[i].like!.contains(userId)) {
            _listPostFeatured[i].like!.remove(userId);
            debugPrint("🔍 DEBUG: Đã xóa userId khỏi danh sách like của featured, count mới: ${_listPostFeatured[i].like?.length}");
          }
        }
        updatedFeaturedList = true;
        break;
      }
    }
    
    // Cập nhật trong danh sách bài viết của người dùng
    for (int i = 0; i < _listPostMe.length; i++) {
      if (_listPostMe[i].id == postId) {
        debugPrint("🔍 DEBUG: Tìm thấy bài viết trong _listPostMe với index $i");
        _listPostMe[i].like ??= [];
        
        if (shouldLike) {
          if (!_listPostMe[i].like!.contains(userId)) {
            _listPostMe[i].like!.add(userId);
            debugPrint("🔍 DEBUG: Đã thêm userId vào danh sách like của my posts, count mới: ${_listPostMe[i].like?.length}");
          }
        } else {
          if (_listPostMe[i].like!.contains(userId)) {
            _listPostMe[i].like!.remove(userId);
            debugPrint("🔍 DEBUG: Đã xóa userId khỏi danh sách like của my posts, count mới: ${_listPostMe[i].like?.length}");
          }
        }
        updatedMyList = true;
        break;
      }
    }
    
    // Cập nhật trong danh sách bài viết by ID
    for (int i = 0; i < _listtByID.length; i++) {
      if (_listtByID[i].id == postId) {
        debugPrint("🔍 DEBUG: Tìm thấy bài viết trong _listtByID với index $i");
        _listtByID[i].like ??= [];
        
        if (shouldLike) {
          if (!_listtByID[i].like!.contains(userId)) {
            _listtByID[i].like!.add(userId);
            debugPrint("🔍 DEBUG: Đã thêm userId vào danh sách like by ID, count mới: ${_listtByID[i].like?.length}");
          }
        } else {
          if (_listtByID[i].like!.contains(userId)) {
            _listtByID[i].like!.remove(userId);
            debugPrint("🔍 DEBUG: Đã xóa userId khỏi danh sách like by ID, count mới: ${_listtByID[i].like?.length}");
          }
        }
        updatedListById = true;
        break;
      }
    }
    
    debugPrint("🔍 DEBUG: Kết quả cập nhật: main list: $updatedMainList, featured list: $updatedFeaturedList, my list: $updatedMyList, list by ID: $updatedListById");
    debugPrint("🔍 DEBUG: updatePostLikeStatus hoàn tất cho postId: $postId");
    
    notifyListeners();
    debugPrint("🔍 DEBUG: updatePostLikeStatus đã gọi notifyListeners() cho postId: $postId");
  }
  
  // Phương thức cập nhật tổng số comment của bài viết
  void updatePostCommentCount(String postId, int newCommentCount) {
    // Cập nhật trong danh sách bài viết chính
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].id == postId) {
        _posts[i].totalComment = newCommentCount;
        break;
      }
    }
    
    // Cập nhật trong danh sách bài viết nổi bật
    for (int i = 0; i < _listPostFeatured.length; i++) {
      if (_listPostFeatured[i].id == postId) {
        _listPostFeatured[i].totalComment = newCommentCount;
        break;
      }
    }
    
    // Cập nhật trong danh sách bài viết của người dùng
    for (int i = 0; i < _listPostMe.length; i++) {
      if (_listPostMe[i].id == postId) {
        _listPostMe[i].totalComment = newCommentCount;
        break;
      }
    }
    
    notifyListeners();
  }
  
  // Lấy ID người dùng hiện tại
  Future<String?> _getCurrentUserId() async {
    // Sử dụng FlutterSecureStorage để lấy ID người dùng
    final storage = const FlutterSecureStorage();
    return await storage.read(key: 'user_id');
  }

  // Phương thức lấy bài đăng theo ID
  Posts? getPostById(String postId) {
    debugPrint("🔍 DEBUG: getPostById đang tìm bài đăng có ID: $postId");
    
    // Tìm trong danh sách bài viết chính
    for (var post in _posts) {
      if (post.id == postId) {
        debugPrint("🔍 DEBUG: Đã tìm thấy bài đăng trong _posts với ID: $postId");
        return post;
      }
    }
    
    // Tìm trong danh sách bài viết nổi bật
    for (var post in _listPostFeatured) {
      if (post.id == postId) {
        debugPrint("🔍 DEBUG: Đã tìm thấy bài đăng trong _listPostFeatured với ID: $postId");
        return post;
      }
    }
    
    // Tìm trong danh sách bài viết của tôi
    for (var post in _listPostMe) {
      if (post.id == postId) {
        debugPrint("🔍 DEBUG: Đã tìm thấy bài đăng trong _listPostMe với ID: $postId");
        return post;
      }
    }
    
    // Tìm trong danh sách bài viết theo ID
    for (var post in _listtByID) {
      if (post.id == postId) {
        debugPrint("🔍 DEBUG: Đã tìm thấy bài đăng trong _listtByID với ID: $postId");
        return post;
      }
    }
    
    debugPrint("⚠️ WARNING: Không tìm thấy bài đăng nào có ID: $postId");
    return null;
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
        debugPrint('No posts found for user $id');
      }

      // Thông báo UI cập nhật lại dữ liệu
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách bài đăng của user: $e');
      // Set to empty list in case of error
      _listtByID = [];
    }

    _isLoadingByID = false;
    notifyListeners();
  }
}

