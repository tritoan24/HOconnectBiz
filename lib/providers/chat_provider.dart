import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/socket_service.dart';
import '../models/apiresponse.dart';
import '../models/contact.dart';
import '../models/message_model.dart';
import '../repository/chat_repository.dart';
import '../screens/chat/deltails_sales_article.dart';
import 'auth_provider.dart';
import 'post_provider.dart';

class ChatProvider with ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final SocketService _socketService = SocketService();
  bool _isLoading = false;
  List<Message> _messages = [];
  List<Contact> _contacts = [];
  String? _currentUserId;
  String? _currentChatReceiverId;
  int _cartItemCount = 0;

  ChatProvider();

  bool get isLoading => _isLoading;

  List<Message> get messages => _messages;
  List<Contact> get contacts => _contacts;
  bool get isSocketConnected => _socketService.isConnected;
  int get cartItemCount => _cartItemCount;

  /// Khởi tạo socket cho màn hình chat
  Future<void> initializeSocket(
      BuildContext context, String idReceiverId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentUserId = await authProvider.getuserID();
    _currentChatReceiverId = idReceiverId;

    if (_currentUserId != null) {
      // Kết nối tới socket với ID người dùng
      _socketService.connectToChat(_currentUserId!, idReceiverId);

      // Cài đặt các listener cho cập nhật tin nhắn thời gian thực
      _setupSocketListeners();
    }
  }

  /// Khởi tạo socket cho màn hình danh bạ
  Future<void> initializeContactSocket(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentUserId = await authProvider.getuserID();

    if (_currentUserId != null) {
      _socketService.connectToContact(_currentUserId!);
      _setupSocketListeners();
    }
  }

  /// Thiết lập các listener lắng nghe sự kiện socket
  void _setupSocketListeners() {
    // Lắng nghe tin nhắn mới
    _socketService.on('new_message', (data) {
      print("📥 Nhận tin nhắn mới từ socket: $data");
      _handleNotificationData(data);
      
      // Cập nhật PostProvider khi có tin nhắn mới
      _updatePostProviderMessageCount();
    });

    // Lắng nghe cập nhật danh bạ
    _socketService.on('contact_update', (data) {
      print("👥 Cập nhật danh bạ từ socket: $data");
      _refreshContacts();
    });

    // Lắng nghe thông báo
    _socketService.on('notification', (data) {
      print("🔔 Nhận thông báo từ socket: $data");
      _handleNotificationData(data);
    });

    // Lắng nghe trạng thái tin nhắn đã đọc
    _socketService.on('message_read', (data) {
      print("👁️ Cập nhật trạng thái đọc tin nhắn: $data");
      _updateMessageReadStatus(data);
    });
  }

  /// Xử lý dữ liệu thông báo từ socket
  void _handleNotificationData(Map<String, dynamic> data) {
    try {
      if (data['data'] != null && data['data'] is Map<String, dynamic>) {
        var innerData = data['data'];

        // Xử lý danh sách tin nhắn
        if (innerData['data'] != null && innerData['data'] is List) {
          _processMessageList(innerData['data']);
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

  /// Xử lý danh sách tin nhắn từ socket
  void _processMessageList(List<dynamic> messageList) {
    try {
      List<Message> newMessages = [];

      for (var msgData in messageList) {
        if (msgData is Map<String, dynamic>) {
          try {
            final message = Message.fromJson(msgData);
            newMessages.add(message);
          } catch (e) {
            print("❌ Lỗi chuyển đổi tin nhắn: $e");
          }
        }
      }

      // Cập nhật danh sách tin nhắn nếu đang trong màn hình chat
      if (_currentChatReceiverId != null) {
        // Lọc tin nhắn liên quan đến cuộc trò chuyện hiện tại
        final relevantMessages = newMessages.where((msg) {
          final senderId = msg.sender?.id;
          final receiverId = msg.receiver?.id;
          return (senderId == _currentUserId &&
                  receiverId == _currentChatReceiverId) ||
              (senderId == _currentChatReceiverId &&
                  receiverId == _currentUserId);
        }).toList();

        if (relevantMessages.isNotEmpty) {
          // Thêm các tin nhắn mới
          for (var msg in relevantMessages) {
            if (!_messages.any((m) => m.id == msg.id)) {
              _messages.add(msg);
            }
          }

          // Sắp xếp tin nhắn theo thời gian
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          notifyListeners();
        }
      }
    } catch (e) {
      print("❌ Lỗi xử lý danh sách tin nhắn: $e");
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
            _messages.add(message);
            // Sắp xếp tin nhắn theo thời gian
            _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print("❌ Lỗi xử lý tin nhắn đơn: $e");
    }
  }

  /// Cập nhật trạng thái đọc của tin nhắn
  void _updateMessageReadStatus(Map<String, dynamic> data) {
    try {
      final String? messageId = data['messageId']?.toString();
      if (messageId != null) {
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          // Tạo bản sao của tin nhắn với trạng thái đã đọc
          final updatedMessage = Message(
            id: _messages[index].id,
            sender: _messages[index].sender,
            receiver: _messages[index].receiver,
            content: _messages[index].content,
            album: _messages[index].album,
            read: true,
            data: _messages[index].data,
            timestamp: _messages[index].timestamp,
          );

          _messages[index] = updatedMessage;
          notifyListeners();
        }
      }
    } catch (e) {
      print("❌ Lỗi cập nhật trạng thái đọc: $e");
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
  Future<void> getListDetailChat(BuildContext context, String idUser) async {
    try {
      final response = await _chatRepository.getListDetailChat(context, idUser);

      if (response.isSuccess && response.data is List) {
        _messages = (response.data as List)
            .map((item) => Message.fromJson(item))
            .toList();
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching chat list: $e");
    }
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

    final Message message = Message(
      content: content.isNotEmpty ? content : "[Hình ảnh]",
    );

    final Map<String, List<File>> fileFields = {
      'album': files ?? [],
    };

    _isLoading = true;
    notifyListeners();
    print("⏳ Đang gửi tin nhắn...");

    try {
      final response = await _chatRepository
          .sendMessage(message, idReceiver, context, files: files);

      if (response.isSuccess) {
        print("✅ Tin nhắn đã gửi thành công!");
        // getListDetailChat(context, messageID);
        print("📡 Phản hồi từ server: ${response.toString()}");
      } else {
        print("⚠️ Gửi tin nhắn thất bại: ${response.message}");
      }
    } catch (e) {
      print("❌ Lỗi khi gửi tin nhắn: $e");
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
            ? (response.data as List).map((item) => Contact.fromJson(item)).toList()
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
}
