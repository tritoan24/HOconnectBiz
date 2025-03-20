import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/socket_service.dart';
import '../models/apiresponse.dart';
import '../models/contact.dart';
import '../models/message_model.dart';
import '../models/auth_model.dart';
import '../repository/chat_repository.dart';
import '../screens/chat/deltails_sales_article.dart';
import 'auth_provider.dart';
import 'post_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatProvider with ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final SocketService _socketService = SocketService();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<Message> _messages = [];
  List<Contact> _contacts = [];
  String? _currentUserId;
  String? _currentChatReceiverId;
  String? _currentGroupChatId;
  int _cartItemCount = 0;
  int _currentPage = 1;
  bool _hasMoreMessages = true;
  int _totalMessageCount = 0;
  static const int _limit = 10;
  final _storage = const FlutterSecureStorage();

  ChatProvider();

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreMessages => _hasMoreMessages;
  List<Message> get messages => _messages;
  List<Contact> get contacts => _contacts;
  bool get isSocketConnected => _socketService.isConnected;
  int get cartItemCount => _cartItemCount;

  /// Khởi tạo socket cho màn hình chat
  Future<void> initializeSocket(
      BuildContext context, String idReceiverId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Lấy id người gửi
    final userId = await authProvider.getuserID();
    _currentUserId = userId;
    _currentChatReceiverId = idReceiverId;

    debugPrint('id người gửi $userId');
    debugPrint('id người nhận $idReceiverId');

    if (_currentUserId != null) {
      // Kết nối tới socket với ID người dùng
      _socketService.connectToChat(userId!, idReceiverId);

      // Cài đặt các listener cho cập nhật tin nhắn thời gian thực
      _setupSocketListeners();
    }
  }

  /// Khởi tạo socket cho màn hình chat
  Future<void> initializeSocketChatGroup(
      BuildContext context, String idGroup) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Lấy id người gửi
    final userId = await authProvider.getuserID();

    _currentGroupChatId = idGroup;

    if (_currentUserId != null) {
      // Kết nối tới socket với ID người dùng
      _socketService.connectToChat(userId!, idGroup);

      // Cài đặt các listener cho cập nhật tin nhắn thời gian thực
      _setupSocketListenersChatGroup();
    }
  }

  /// Khởi tạo socket cho màn hình danh bạ
  Future<void> initializeContactSocket(
      BuildContext context, String UserID) async {
    _currentUserId = await UserID;

    if (_currentUserId != null) {
      _socketService.connectToContact(_currentUserId!);
      _setupSocketListenersContact();
    }
  }

  /// Thiết lập các listener lắng nghe sự kiện socket
  void _setupSocketListenersContact() {
    // Lắng nghe cập nhật danh bạ
    _socketService.on('notification', (data) {
      print("👥 Cập nhật danh bạ từ socket: $data");
      _refreshContacts();
    });
  }

  /// Thiết lập các listener lắng nghe sự kiện socket
  void _setupSocketListeners() {
    // Lắng nghe tin nhắn mới
    _socketService.on('new_message', (data) {
      print("📥 Nhận tin nhắn mới từ socket: $data");
      handleNotificationData(data);

      // Cập nhật PostProvider khi có tin nhắn mới
      _updatePostProviderMessageCount();
    });
  }

  /// Thiết lập các listener lắng nghe sự kiện socket
  void _setupSocketListenersChatGroup() {
    // Hủy đăng ký listener cũ nếu có
    _socketService.off('new_message_group');
    
    // Lắng nghe tin nhắn mới
    _socketService.on('new_message_group', (data) {
      if (data != null && data is Map<String, dynamic>) {
        print("📥 Nhận tin nhắn mới từ socket group");
        handleNotificationDataGroup(data);
        _updatePostProviderMessageCount();
      }
    });
  }

  /// Xử lý dữ liệu thông báo từ socket
  void handleNotificationDataGroup(Map<String, dynamic> data) {
    try {
      if (data['data'] != null && data['data'] is Map<String, dynamic>) {
        var responseData = data['data'];
        
        // Kiểm tra status thành công
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          var messagesData = responseData['data'];
          
          // Lặp qua từng conversationId và danh sách tin nhắn
          messagesData.forEach((conversationId, messages) {
            if (messages is List) {
              for (var msgData in messages) {
                if (msgData is Map<String, dynamic>) {
                  // Chuyển đổi cấu trúc dữ liệu để phù hợp với Message model
                  var formattedMsgData = {
                    '_id': msgData['_id'],
                    'sender': {
                      '_id': msgData['sender']['_id'],
                      'username': msgData['sender']['username'],
                      'displayName': msgData['sender']['displayName'],
                      'avatar_image': msgData['sender']['avatar_image'] ?? '',
                      'description': msgData['sender']['description'] ?? '',
                      'company_name': msgData['sender']['company_name'] ?? '',
                      'level': 0,
                      'registerType': '',
                      'coverImage': '',
                      'business': [],
                      'address': '',
                      'companyDescription': '',
                      'email': '',
                      'gender': '',
                      'status': '',
                      'phone': '',
                      'roleCode': 0,
                      'type': '',
                      'userId': ''
                    },
                    'receiver': null,
                    'content': msgData['content'],
                    'album': msgData['album'],
                    'read': msgData['read'] ?? false,
                    'timestamp': msgData['timestamp'],
                    'conversationId': conversationId,
                    'status': MessageStatus.sent
                  };

                  // Tạo message mới từ dữ liệu đã format
                  final message = Message.fromJson(formattedMsgData);
                  
                  // Kiểm tra xem tin nhắn có thuộc về group hiện tại không
                  if (_currentGroupChatId != null && 
                      message.conversationId == _currentGroupChatId) {
                    // Thêm vào danh sách nếu chưa có
                    if (!_messages.any((m) => m.id == message.id)) {
                      _messages.add(message);
                      notifyListeners();
                    }
                  }
                }
              }
            }
          });
        }
      }
    } catch (e) {
      print("❌ Lỗi xử lý tin nhắn group: $e");
    }
  }

  /// Xử lý dữ liệu thông báo từ socket
  void handleNotificationData(Map<String, dynamic> data) {
    try {
      if (data['data'] != null && data['data'] is Map<String, dynamic>) {
        var innerData = data['data'];

        // Xử lý danh sách tin nhắn
        if (innerData['data'] != null && innerData['data'] is List) {
          // Lặp qua từng tin nhắn trong danh sách và xử lý
          for (var msgData in innerData['data']) {
            if (msgData is Map<String, dynamic>) {
              _processSingleMessage(msgData);
            }
          }
        }
        // Xử lý tin nhắn đơn
        else if (innerData['data'] != null &&
            innerData['data'] is Map<String, dynamic>) {
          _processSingleMessage(innerData['data']);
        }
      }
    } catch (e) {
      print("❌ Lỗi xử lý dữ liệu thông báo: $e");
    }
  }

  /// Xử lý một tin nhắn đơn lẻ từ socket
  void _processSingleMessage(Map<String, dynamic> messageData) {
    try {
      final message = Message.fromJson(messageData);

      // Kiểm tra nếu tin nhắn thuộc về cuộc trò chuyện hiện tại
      if (_currentChatReceiverId != null) {
        final senderId = message.sender?.id;
        final receiverId = message.receiver?.id;

        if ((senderId == _currentUserId &&
                receiverId == _currentChatReceiverId) ||
            (senderId == _currentChatReceiverId &&
                receiverId == _currentUserId)) {
          // Thêm vào danh sách nếu chưa có
          if (!_messages.any((m) => m.id == message.id)) {
            // Thêm tin nhắn mới vào cuối danh sách
            _messages.add(message);
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print("❌ Lỗi xử lý tin nhắn đơn: $e");
    }
  }

  /// Xử lý một tin nhắn group từ socket
  void _processGroupMessage(Map<String, dynamic> messageData) {
    try {
      final message = Message.fromJson(messageData);

      // Kiểm tra nếu tin nhắn thuộc về cuộc trò chuyện hiện tại
      if (_currentGroupChatId != null) {
        final idGroup = message.id;

        if (idGroup == _currentGroupChatId) {
          // Thêm vào danh sách nếu chưa có
          if (!_messages.any((m) => m.id == message.id)) {
            // Thêm tin nhắn mới vào cuối danh sách
            _messages.add(message);
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print("❌ Lỗi xử lý tin nhắn đơn: $e");
    }
  }

  Future<void> sendMessageBuyNow(
      String receiverId, String productId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chatRepository.sendMessageBuyNow(
          receiverId, productId, context);
      if (response.isSuccess) {
        String currentUserId;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        currentUserId = (await authProvider.getuserID())!;
        print('id message: ${response.data['_id']}');
        //chuyeenr man
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DeltailsSalesArticle(
                      isCreate: true,
                      currentUserId: currentUserId,
                      idReceiver: receiverId,
                      idMessage: receiverId,
                      avatarImage: '',
                      displayName: '',
                    )));
      }
    } catch (e) {
      print("Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Lấy danh sách tin nhắn trong một phòng chat
  Future<void> getListDetailChat(BuildContext context, String idUser,
      {bool loadMore = false}) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMoreMessages = true;
      _messages = [];
      _totalMessageCount = 0; // Reset biến đếm khi tải mới
    }

    if (!_hasMoreMessages || _isLoadingMore) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      print(
          "🔄 Đang tải tin nhắn, trang: $_currentPage, ID người dùng: $idUser");

      final response = await _chatRepository.getListDetailChat(
        context,
        idUser,
        page: _currentPage,
        limit: _limit,
      );

      if (response.isSuccess && response.data is List) {
        final newMessages = (response.data as List)
            .map((item) => Message.fromJson(item))
            .toList();

        print("📥 Nhận được ${newMessages.length} tin nhắn mới");

        // Cập nhật tổng số tin nhắn đã tải
        _totalMessageCount += newMessages.length;

        // Lấy tổng số tin nhắn từ response nếu có
        final totalAvailable = response.total ?? -1;

        if (totalAvailable > 0) {
          // Nếu API trả về tổng số tin nhắn, kiểm tra xem đã tải hết chưa
          _hasMoreMessages = _totalMessageCount < totalAvailable;
          print("📊 Đã tải $_totalMessageCount/$totalAvailable tin nhắn");
        } else {
          // Nếu API không trả về tổng số, kiểm tra dựa trên số lượng tin nhắn nhận được
          _hasMoreMessages = newMessages.length == _limit;
        }

        print("📄 Còn tin nhắn để tải: $_hasMoreMessages");

        if (loadMore) {
          // Thêm tin nhắn cũ vào đầu danh sách
          _messages.insertAll(0, newMessages);
          print("⬆️ Đã thêm tin nhắn cũ vào đầu danh sách");
        } else {
          // Thêm tin nhắn vào danh sách
          _messages.addAll(newMessages);
          print("✅ Đã thêm tin nhắn mới vào danh sách");
        }

        _currentPage++;
        notifyListeners();
      } else {
        print("❌ Lỗi khi tải tin nhắn: ${response.message}");
        _hasMoreMessages = false;
      }
    } catch (e) {
      print("❌ Lỗi khi tải danh sách chat: $e");
      _hasMoreMessages = false;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load thêm tin nhắn cũ
  Future<void> loadMoreMessages(BuildContext context) async {
    print("🔄 Đang tải thêm tin nhắn cũ...");
    if (_currentChatReceiverId != null) {
      print("📩 ID người nhận: $_currentChatReceiverId, Trang: $_currentPage");
      return await getListDetailChat(context, _currentChatReceiverId!,
          loadMore: true);
    } else {
      print("❌ ID người nhận không tồn tại!");
      return Future
          .value(); // Trả về Promise đã hoàn thành nếu không có người nhận
    }
  }

  /// Reset trạng thái phân trang
  void resetPagination() {
    _currentPage = 1;
    _hasMoreMessages = true;
    _messages = [];
  }

  /// **Xóa danh sách tin nhắn khi cần reset**
  void clearState() {
    _messages = [];
    notifyListeners();
  }

  /// lay danh sach tin nhan
  Future<void> getContacts(BuildContext context,
      [String? userId = null]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final ApiResponse response = await _chatRepository.getContacts(context);

      if (response.isSuccess) {
        _contacts = response.data is List
            ? (response.data as List)
                .map((item) => Contact.fromJson(item))
                .toList()
            : [];

        // Lưu total từ API response
        _cartItemCount = response.total ?? 0;
        print("Số lượng sản phẩm trong giỏ hàng: $_cartItemCount");
      }

      if (_currentUserId == null) {
        _socketService.connectToContact(_currentUserId!);
        // _setupContactSocketListeners();
      }
    } catch (e) {
      print("Error fetching contacts: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  //send message
  Future<void> sendMessage(
      String content, String idReceiver, String messageID, BuildContext context,
      {List<File>? files}) async {
    print("🔹 Bắt đầu gửi tin nhắn...");
    print("📩 Nội dung tin nhắn: $content");
    print("👤 Người nhận ID: $idReceiver");
    print("🖼 Số lượng ảnh đính kèm: ${files?.length ?? 0}");

    // Tạo ID tạm thời cho tin nhắn
    final localId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    // Tạo tin nhắn tạm thời với trạng thái "đang gửi"
    final tempMessage = Message(
      id: localId,
      content: content.isNotEmpty ? content : "[Hình ảnh]",
      timestamp: DateTime.now(),
      sender: Author(
          id: _currentUserId ?? "",
          username: "",
          displayName: "",
          level: 0,
          registerType: "",
          avatarImage: "",
          coverImage: "",
          description: "",
          business: [],
          companyName: "",
          address: "",
          companyDescription: "",
          email: "",
          gender: "",
          status: "",
          phone: "",
          roleCode: 0,
          type: "",
          userId: ""),
      receiver: Author(
          id: idReceiver,
          username: "",
          displayName: "",
          level: 0,
          registerType: "",
          avatarImage: "",
          coverImage: "",
          description: "",
          business: [],
          companyName: "",
          address: "",
          companyDescription: "",
          email: "",
          gender: "",
          status: "",
          phone: "",
          roleCode: 0,
          type: "",
          userId: ""),
      album: [],
    );

    // Đặt trạng thái tin nhắn là đang gửi
    tempMessage.status = MessageStatus.sending;

    // Hiển thị tin nhắn trên UI ngay lập tức
    addOptimisticMessage(tempMessage);

    try {
      final response = await _chatRepository.sendMessage(
          Message(content: content.isNotEmpty ? content : "[Hình ảnh]"),
          idReceiver,
          context,
          files: files);

      if (response.isSuccess) {
        print("✅ Tin nhắn đã gửi thành công!");
        // Cập nhật trạng thái tin nhắn thành công và ID từ server
        updateMessageStatus(localId, MessageStatus.sent,
            serverId: response.data?['_id']?.toString());
        print("📡 Phản hồi từ server: ${response.toString()}");
      } else {
        print("⚠️ Gửi tin nhắn thất bại: ${response.message}");
        // Cập nhật trạng thái tin nhắn thất bại
        updateMessageStatus(localId, MessageStatus.error,
            errorMessage: response.message ?? "Không gửi được tin nhắn");
      }
    } on SocketException catch (e) {
      print("❌ Lỗi kết nối mạng: $e");
      updateMessageStatus(localId, MessageStatus.error,
          errorMessage:
              "Không thể kết nối đến máy chủ. Kiểm tra kết nối mạng!");
    } on HttpException catch (e) {
      print("❌ Lỗi HTTP: $e");
      updateMessageStatus(localId, MessageStatus.error,
          errorMessage: "Lỗi phản hồi từ máy chủ. Vui lòng thử lại.");
    } catch (e) {
      print("❌ Lỗi không xác định: $e");
      updateMessageStatus(localId, MessageStatus.error,
          errorMessage: "Đã xảy ra lỗi. Vui lòng thử lại sau.");
    }

    _isLoading = false;
    notifyListeners();
    print("🔹 Kết thúc quá trình gửi tin nhắn.");
  }

  void addTempMessage(Message message) {
    messages.add(message);
    notifyListeners();
  }

  //delete message
  /// **Xóa tin nhắn**
  Future<void> deleteMessage(
      String messageId, String chatId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final ApiResponse response =
          await _chatRepository.deleteMessage(messageId, context);

      if (response.isSuccess) {
        print("✅ Tin nhắn đã xóa thành công!");

        // Cập nhật danh sách tin nhắn sau khi xóa
        _messages.removeWhere((message) => message.id.toString() == messageId);

        // Sắp xếp lại danh sách tin nhắn để đảm bảo thứ tự đúng
        _messages.sort((a, b) {
          final timeCompare = a.timestamp.compareTo(b.timestamp);
          if (timeCompare != 0) return timeCompare;
          return (a.id ?? "").compareTo(b.id ?? "");
        });

        notifyListeners();
      } else {
        print("⚠️ Xóa tin nhắn thất bại: ${response.message}");
      }
    } catch (e) {
      print("❌ Lỗi khi xóa tin nhắn: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ngắt kết nối socket cho màn hình chat
  void leaveChatRoom() {
    if (_currentChatReceiverId != null && _currentUserId != null) {
      _socketService.leaveChatRoom(_currentChatReceiverId!);
      _currentChatReceiverId = null;
    }
  }

  /// Cập nhật danh sách liên hệ
  Future<void> _refreshContacts() async {
    if (_currentUserId == null) return;

    try {
      final ApiResponse response = await _chatRepository.getContacts(
        GlobalKey<NavigatorState>().currentContext!,
      );

      if (response.isSuccess) {
        // Xử lý dữ liệu từ response
        _contacts = response.data is List
            ? (response.data as List)
                .map((item) => Contact.fromJson(item))
                .toList()
            : [];

        // Cập nhật số lượng giỏ hàng
        _cartItemCount = response.total ?? 0;

        notifyListeners();
      }
    } catch (e) {
      print("❌ Lỗi cập nhật danh sách liên hệ: $e");
    }
  }

  /// Ngắt kết nối socket cho màn hình danh bạ
  void leaveContactScreen() {
    if (_currentUserId != null) {
      _socketService.leaveContactChannel();
    }
  }

  /// Ngắt kết nối socket
  void disconnectContactSocket() {
    if (_currentUserId != null) {
      // Chỉ ngắt kết nối khỏi kênh danh bạ, không ngắt hoàn toàn
      _socketService.leaveContactChannel();
    }
  }

  /// Cập nhật trạng thái loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Xóa dữ liệu và ngắt kết nối socket
  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  /// Cập nhật số lượng tin nhắn mới trong PostProvider
  void _updatePostProviderMessageCount() {
    // Cần đảm bảo context có sẵn, nên dùng GlobalKey
    final context = GlobalKey<NavigatorState>().currentContext;
    if (context != null) {
      try {
        // Tìm PostProvider trong context
        final postProvider = Provider.of<PostProvider>(context, listen: false);
        if (postProvider != null) {
          // Tăng số lượng tin nhắn mới
          postProvider.updateMessageCount();
        }
      } catch (e) {
        print("❌ Lỗi khi cập nhật số lượng tin nhắn mới: $e");
      }
    }
  }

  // Cập nhật trạng thái tin nhắn
  void updateMessageStatus(String messageId, MessageStatus status,
      {String? errorMessage, String? serverId}) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      // Tạo bản sao của tin nhắn với trạng thái đã cập nhật
      final updatedMessage = Message(
        id: serverId ?? _messages[index].id,
        sender: _messages[index].sender,
        receiver: _messages[index].receiver,
        content: _messages[index].content ?? "",
        album: _messages[index].album ?? [],
        read: _messages[index].read ?? false,
        data: _messages[index].data,
        timestamp: _messages[index].timestamp,
      );

      // Cập nhật trạng thái và thông báo lỗi
      updatedMessage.status = status;
      if (errorMessage != null) {
        updatedMessage.errorMessage = errorMessage;
        print(
            "⚠️ Cập nhật thông báo lỗi cho tin nhắn $messageId: $errorMessage");
      }

      // Thay thế tin nhắn cũ bằng tin nhắn đã cập nhật
      _messages[index] = updatedMessage;
      notifyListeners();
    } else {
      print("⚠️ Không tìm thấy tin nhắn với ID: $messageId");
    }
  }

  // Thêm tin nhắn tạm thời vào danh sách
  void addOptimisticMessage(Message message) {
    // Thêm tin nhắn mới vào cuối danh sách (tin nhắn mới nhất)
    _messages.add(message);

    // Sắp xếp tin nhắn theo thời gian
    // _messages.sort((a, b) {
    //   final timeCompare = a.timestamp.compareTo(b.timestamp);
    //   if (timeCompare != 0) return timeCompare;
    //   return (a.id ?? "").compareTo(b.id ?? "");
    // });

    notifyListeners();
  }

  // // Đánh dấu tất cả tin nhắn là đã đọc
  // Future<void> markAllMessagesAsRead(String conversationId, BuildContext context) async {
  //   try {
  //     final token = await _storage.read(key: 'token');
  //     if (token == null) {
  //       throw Exception('Token không tồn tại');
  //     }
  //
  //     final url = Uri.parse('$baseUrl/api/mark-messages-read/$conversationId');
  //     final response = await http.put(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       notifyListeners();
  //       print('📖 Đã đánh dấu tất cả tin nhắn là đã đọc');
  //     } else {
  //       print('❌ Lỗi đánh dấu tin nhắn đã đọc: ${response.statusCode}');
  //       print('Body: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('❌ Lỗi đánh dấu tin nhắn đã đọc: $e');
  //   }
  // }
}
