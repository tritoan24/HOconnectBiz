import 'package:clbdoanhnhansg/models/is_join_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/auth_model.dart';
import '../models/rating_model.dart';
import '../repository/bo_repository.dart';
import '../models/bo_model.dart';
import '../models/apiresponse.dart';

class BoProvider with ChangeNotifier {
  final BoRepository _boRepository = BoRepository();

  final ApiClient _apiClient = ApiClient();

  List<Bo> _boList = [];
  List<Bo> _boListOut = [];
  Bo? _selectedBo;
  List<IsJoin> _members = [];
  List<IsJoin> _lists = [];
  List<Criteria> _listCriteriaRating = [];
  AuthorBusiness _author = AuthorBusiness.defaultAuthor();

  // Danh sách kết quả tìm kiếm doanh nghiệp
  List<Bo> _searchResults = [];
  bool _isSearching = false;

  bool _isLoading = false;
  bool _isLoadingBo = false;
  bool _isLoadingBoOut = false;
  bool _isLoadingBoDetail = false;
  bool _isLoadingRating = false;

  String _errorMessageBo = '';
  String _errorMessageBoOut = '';
  String _errorMessageBoDetail = '';
  String? _errorMessage;
  String? _errorMessageRating;
  String _searchErrorMessage = '';

  // Getters
  bool get isLoading => _isLoading;

  bool get isLoadingBo => _isLoadingBo;

  bool get isLoadingBoOut => _isLoadingBoOut;

  bool get isLoadingBoDetail => _isLoadingBoDetail;

  bool get isLoadingRating => _isLoadingRating;

  bool get isSearching => _isSearching;

  List<Bo> get boList => _boList;

  List<Bo> get boListOut => _boListOut;

  List<Bo> get searchResults => _searchResults;

  Bo? get selectedBo => _selectedBo;

  List<IsJoin> get members => _members;

  List<IsJoin> get lists => _lists;

  List<Criteria> get listCriteriaRating => _listCriteriaRating;

  AuthorBusiness get author => _author;

  String get errorMessageBo => _errorMessageBo;

  String get errorMessageBoOut => _errorMessageBoOut;

  String get errorMessageBoDetail => _errorMessageBoDetail;

  String? get errorMessage => _errorMessage;

  String? get errorMessageRating => _errorMessageRating;

  String get searchErrorMessage => _searchErrorMessage;

  Rating? _userRating;
  List<Map<String, dynamic>> _ratingCriteria = [];

  Rating? get userRating => _userRating;

  List<Map<String, dynamic>> get ratingCriteria => _ratingCriteria;

  // 🟢 Fetch danh sách Bo
  Future<void> fetchBoData(BuildContext context) async {
    _isLoadingBo = true;
    _errorMessageBo = '';
    notifyListeners();

    try {
      final ApiResponse response = await _boRepository.getBoData(context);

      if (response.isSuccess && response.data is List) {
        List<Bo> newList = (response.data as List)
            .map((json) => Bo.fromJson(json as Map<String, dynamic>))
            .toList();

        if (!_listsEqual(_boList, newList)) {
          _boList = newList;
          notifyListeners();
        }
      } else {
        _errorMessageBo = response.message ?? 'Không có dữ liệu';
        _boList.clear();
      }
    } catch (e) {
      _errorMessageBo = "Lỗi khi tải dữ liệu: $e";
      _boList.clear();
    }

    _isLoadingBo = false;
    notifyListeners();
  }

  // 🟢 Fetch danh sách Bo ra ngoài
  Future<void> fetchBoDataOut(BuildContext context) async {
    _isLoadingBoOut = true;
    _errorMessageBoOut = '';
    notifyListeners();

    try {
      final ApiResponse response = await _boRepository.getBoDataOut(context);

      if (response.isSuccess && response.data is List) {
        List<Bo> newListOut = (response.data as List)
            .map((json) => Bo.fromJson(json as Map<String, dynamic>))
            .toList();

        if (!_listsEqual(_boListOut, newListOut)) {
          _boListOut = newListOut;
          notifyListeners();
        }
      } else {
        _errorMessageBoOut = response.message ?? 'Không có dữ liệu';
        _boListOut.clear();
      }
    } catch (e) {
      _errorMessageBoOut = "Lỗi khi tải dữ liệu: $e";
      _boListOut.clear();
    }

    _isLoadingBoOut = false;
    notifyListeners();
  }

  // 🟢 Fetch chi tiết Bo theo ID
  Future<void> fetchBoDataById(BuildContext context, String id) async {
    _isLoadingBoDetail = true;
    _errorMessageBoDetail = '';
    notifyListeners();

    try {
      final ApiResponse response =
          await _boRepository.getBoDataById(context, id);

      if (response.isSuccess && response.data is Map<String, dynamic>) {
        Map<String, dynamic> data = response.data as Map<String, dynamic>;

        _selectedBo = Bo.fromJson(data);
        _author =
            data.containsKey('author') && data['author'] is Map<String, dynamic>
                ? AuthorBusiness.fromJson(data['author'])
                : AuthorBusiness.defaultAuthor();

        _members = (data['is_join'] as List?)
                ?.map(
                    (member) => IsJoin.fromJson(member as Map<String, dynamic>))
                .toList() ??
            [];

        _lists = (data['list'] as List?)
                ?.map(
                    (member) => IsJoin.fromJson(member as Map<String, dynamic>))
                .toList() ??
            [];

        notifyListeners();
      } else {
        _errorMessageBoDetail = response.message ?? 'Không có dữ liệu chi tiết';
        _selectedBo = null;
        _members.clear();
        _lists.clear();
        _author = AuthorBusiness.defaultAuthor();
      }
    } catch (e) {
      _errorMessageBoDetail = "Lỗi khi tải dữ liệu: $e";
      _selectedBo = null;
      _members.clear();
      _lists.clear();
      _author = AuthorBusiness.defaultAuthor();
    }

    _isLoadingBoDetail = false;
    notifyListeners();
  }

  // 🟢 Xóa Bo
  Future<void> deleteBoData(
      BuildContext context, String idPost, String idMember) async {
    try {
      final ApiResponse response =
          await _boRepository.deleteBoData(context, idPost, idMember);
      print(response.isSuccess
          ? "✅ Xóa thành công"
          : "❌ Lỗi: ${response.message}");

      if (response.isSuccess) {
        _lists.removeWhere((bo) => bo.id == idMember);
        notifyListeners();
      }
    } catch (e) {
      print("❌ Lỗi khi xóa: $e");
    }
  }

  // 🟢 Kết thúc Bo
  Future<void> endBoData(BuildContext context, String idPost) async {
    try {
      final ApiResponse response =
          await _boRepository.endBoData(context, idPost);
      print(response.isSuccess
          ? "✅ Kết thúc thành công"
          : "❌ Lỗi: ${response.message}");

      if (response.isSuccess) {
        _boList.removeWhere((bo) => bo.id == idPost);
        notifyListeners();
      }
    } catch (e) {
      print("❌ Lỗi khi kết thúc: $e");
    }
  }

  // 🟢 Roi Bo
  Future<void> leaveBo(BuildContext context, String idPost) async {
    try {
      final ApiResponse response = await _boRepository.leaveBo(context, idPost);
      print(response.isSuccess
          ? "✅ roi thành công"
          : "❌ Lỗi: ${response.message}");

      if (response.isSuccess) {
        _boList.removeWhere((bo) => bo.id == idPost);
        notifyListeners();
      }
    } catch (e) {
      print("❌ Lỗi khi roi: $e");
    }
  }

  // 🟢 So sánh danh sách tránh notifyListeners không cần thiết
  bool _listsEqual(List<Bo> oldList, List<Bo> newList) {
    if (oldList.length != newList.length) return false;
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].id != newList[i].id) return false;
    }
    return true;
  }

//
// 🟢 Submit Rating
  Future<void> submitRating(
    String postId,
    List<String> picked,
    int star,
    String content,
    BuildContext context,
  ) async {
    try {
      final ApiResponse response = await _boRepository.createRating(
        postId,
        picked,
        star,
        content,
        context,
      );

      if (response.isSuccess) {
        print("✅ Đánh giá thành công: " + response.message.toString());

        // ✅ Gọi lại API để lấy dữ liệu mới
        await fetchBoDataById(context, postId);

        // ✅ Kiểm tra dữ liệu mới
        if (_lists.isNotEmpty) {
          print("📌 Danh sách mới cập nhật: ${_lists.length} mục.");
        } else {
          print("⚠️ Danh sách rỗng sau khi cập nhật.");
        }

        notifyListeners();

        // Navigator.pop(
        //     context, true);
      } else {
        print("❌ Lỗi khi gửi đánh giá: ${response.message}");
      }
    } catch (e) {
      print("❌ Lỗi hệ thống khi gửi đánh giá: $e");
    }
  }

  void clearRatingData() {
    _userRating = null;
    notifyListeners();
  }

// 🟢 Tải tiêu chí đánh giá
  Future<void> fetchListCriteria(BuildContext context) async {
    _isLoadingRating = true;
    _errorMessageRating = null;
    notifyListeners();

    try {
      final ApiResponse response = await _boRepository.getListRating(context);

      _isLoadingRating = false;

      if (response.isSuccess && response.data != null) {
        if (response.data is List) {
          _listCriteriaRating = (response.data as List)
              .map((item) => Criteria.fromJson(item))
              .toList();
        }
      } else {
        _errorMessageRating =
            response.message ?? 'Không tải được tiêu chí đánh giá';
      }
    } catch (e) {
      _isLoadingRating = false;
      _errorMessageRating = 'Đã xảy ra lỗi: ${e.toString()}';
    }

    notifyListeners();
  }

  //update revenue
  Future<void> updateRevenue(
    String postId,
    int status,
    int revenue,
    int deduction,
    BuildContext context,
  ) async {
    try {
      final ApiResponse response = await _boRepository.updateRevenue(
        postId,
        status,
        revenue,
        deduction,
        context,
      );

      if (response.isSuccess) {
        print("✅ Cập nhật thành công: " + response.message.toString());

        // Fetch new data but don't navigate here
        await fetchBoDataById(context, postId);

        notifyListeners();

        // Remove this line
        // Navigator.pop(context, true); // This causes problems
      } else {
        print("❌ Lỗi khi cập nhật: ${response.message}");
      }
    } catch (e) {
      print("❌ Lỗi hệ thống khi cập nhật: $e");
    }
  }

// 🟢 Tìm kiếm doanh nghiệp
  Future<void> searchBusinesses(BuildContext context, String keyword) async {
    if (keyword.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchErrorMessage = '';
    notifyListeners();

    try {
      Map<String, dynamic> body = {
        'keyword': keyword,
      };

      final response = await _apiClient.postRequest(
        ApiEndpoints.company,
        body,
        context,
      );

      if (response != null && response['data'] is List) {
        _searchResults = (response['data'] as List)
            .map((json) => Bo.fromJsonAlt(json as Map<String, dynamic>))
            .toList();
      } else {
        _searchResults = [];
        _searchErrorMessage = 'Không tìm thấy doanh nghiệp phù hợp';
      }
    } catch (e) {
      _searchResults = [];
      _searchErrorMessage = "Lỗi khi tìm kiếm: $e";
      debugPrint('Error searching businesses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi tìm kiếm: $e')),
      );
    }

    _isSearching = false;
    notifyListeners();
  }

  Future<void> fetchBusinessesSearch(BuildContext context) async {
    _isSearching = true;
    _searchErrorMessage = '';
    
    // Xóa dữ liệu cũ ngay lập tức để hiển thị loading
    _searchResults = [];
    notifyListeners();

    try {
      Map<String, dynamic> body = {
        'keyword': '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,  // Thêm timestamp để tránh cache
      };

      final response = await _apiClient.postRequest(
        ApiEndpoints.company,
        body,
        context,
      );

      if (response != null && response['data'] is List) {
        _searchResults = (response['data'] as List)
            .map((json) => Bo.fromJsonAlt(json as Map<String, dynamic>))
            .toList();
      } else {
        _searchResults = [];
        _searchErrorMessage = 'Không tìm thấy doanh nghiệp phù hợp';
      }
    } catch (e) {
      _searchResults = [];
      _searchErrorMessage = "Lỗi khi tìm kiếm: $e";
      debugPrint('Error searching businesses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi tìm kiếm: $e')),
      );
    }

    _isSearching = false;
    notifyListeners();
  }


}
