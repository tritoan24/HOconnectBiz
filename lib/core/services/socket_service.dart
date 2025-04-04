import 'package:clbdoanhnhansg/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../providers/send_error_log.dart';

/// Service quản lý kết nối socket cho ứng dụng
class SocketService extends ChangeNotifier {
  // Các loại event socket
  static const String EVENT_CONNECT = 'connect_device';
  static const String EVENT_DISCONNECT = 'disconnect_device';

  // Các tiền tố cho kênh socket
  static const String PREFIX_NOTIFICATION = 'notification_';
  static const String PREFIX_INBOX = 'inbox_';
  static const String PREFIX_CONTACT = 'contact_';
  static const String PREFIX_USER = 'user_status';

  // Singleton pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  // Socket instance
  IO.Socket? _socket;

  // Server URL from environment variables
  final String _serverUrl = AppConfig.socketServerUrl;

  // Track connection states for different rooms
  final Map<String, bool> _connectionStates = {};

  // Track current user
  String? _currentUserId;

  SocketService._internal();

  /// Trạng thái kết nối socket
  bool get isConnected => _socket != null && _socket!.connected;

  /// Lấy ID người dùng hiện tại
  String? get currentUserId => _currentUserId;

  /// Khởi tạo kết nối socket cơ bản
  void initializeSocket(String userId) {
    _currentUserId = userId;

    if (_socket != null && _socket!.connected) {
      debugPrint('Socket đã được kết nối');
      return;
    }

    _setupSocket();
  }

  bool _isReconnecting = false;

  /// Thiết lập kết nối socket
  void _setupSocket() {
    // Build socket options
    final options = IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .enableReconnection()
        .setTimeout(20000)
        .setReconnectionAttempts(5)
        .setReconnectionDelay(2000)
        .build();

    // Create socket instance
    try {
      _socket = IO.io(_serverUrl, options);

      // Set up event handlers
      _socket!.onConnect((_) {
        debugPrint('📱 Kết nối thành công với Socket.IO server');
        _isReconnecting = false;
        notifyListeners();
      });

      _socket!.onDisconnect((_) {
        debugPrint('📴 Ngắt kết nối với Socket.IO server');
        _isReconnecting = false;
        // Reset connection states
        _connectionStates.clear();
        notifyListeners();
      });

      _socket!.onError((error) {
        debugPrint('❌ Socket.IO lỗi: $error');
        sendErrorLog(
          level: 2,
          message: "Socket.IO lỗi kết nối",
          additionalInfo: "$error - userId: $_currentUserId",
        );
      });

      _socket!.onReconnect((attempt) {
        debugPrint('🔄 Kết nối lại lần $attempt');
        if (_isReconnecting) return;
        _isReconnecting = true;
        // Nếu kết nối lại thất bại nhiều lần, báo cáo lỗi
        if (attempt > 3) {
          sendErrorLog(
            level: 1,
            message: "Socket.IO đang thử kết nối lại nhiều lần",
            additionalInfo: "Lần thử: $attempt - userId: $_currentUserId",
          );
        }
      });

      _socket!.onReconnectAttempt(
          (attempt) => debugPrint('⏳ Đang thử kết nối lại lần #$attempt'));

      _socket!.onReconnectFailed((_) {
        debugPrint('❌ Kết nối lại thất bại');
        sendErrorLog(
          level: 2,
          message: "Socket.IO kết nối lại thất bại",
          additionalInfo: "Máy chủ: $_serverUrl - userId: $_currentUserId",
        );
      });
    } catch (e, stackTrace) {
      sendErrorLog(
        level: 3,
        message: "Lỗi nghiêm trọng khi thiết lập Socket.IO",
        additionalInfo: "${e.toString()} - Stack: $stackTrace",
      );
    }
  }

  /// Kết nối tới thông báo chung của người dùng
  void connect(String userId) {
    _currentUserId = userId;

    if (_socket == null || !_socket!.connected) {
      _setupSocket();
    }

    if (_socket!.connected) {
      final deviceId = '$PREFIX_NOTIFICATION$userId';
      _socket!.emit(EVENT_CONNECT, {'deviceId': deviceId});
      _connectionStates[deviceId] = true;
      debugPrint('🔔 Kết nối tới kênh thông báo: $deviceId');
      notifyListeners();
    }
  }

  /// Kết nối UserStatus
  void connectUserStatus() {
    if (_socket == null || !_socket!.connected) {
      _setupSocket();
    }

    if (_socket!.connected) {
      final statusuerID = '$PREFIX_USER';
      _socket!.emit(EVENT_CONNECT);
      _connectionStates[statusuerID] = true;
      debugPrint('👤kết nối với status user');
      notifyListeners();
    }
  }

  /// Kết nối tới phòng chat giữa hai người dùng
  void connectToChat(String senderId, String receiverId) {
    _currentUserId = senderId;

    if (_socket == null || !_socket!.connected) {
      _setupSocket();
    }

    if (_socket!.connected) {
      final chatDeviceId = '$PREFIX_INBOX${senderId}_$receiverId';
      _socket!.emit(EVENT_CONNECT, {'deviceId': chatDeviceId});
      _connectionStates[chatDeviceId] = true;

      debugPrint('💬 Kết nối tới phòng chat: $chatDeviceId');
      notifyListeners();
    }
  }

  /// Kết nối tới kênh danh bạ
  void connectToContact(String userId) {
    _currentUserId = userId;

    if (_socket == null || !_socket!.connected) {
      _setupSocket();
    }

    if (_socket!.connected) {
      final contactDeviceId = '$PREFIX_CONTACT$userId';
      _socket!.emit(EVENT_CONNECT, {'deviceId': contactDeviceId});
      _connectionStates[contactDeviceId] = true;

      debugPrint('👥 Kết nối tới kênh danh bạ: $contactDeviceId');
      notifyListeners();
    }
  }

  /// Ngắt kết nối khỏi một phòng cụ thể
  void leaveRoom(String roomId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(EVENT_DISCONNECT, {'deviceId': roomId});
      _connectionStates.remove(roomId);

      debugPrint('🚪 Rời khỏi phòng: $roomId');
      notifyListeners();
    }
  }

  /// Kiểm tra xem có đang kết nối tới phòng không
  bool isRoomConnected(String roomId) {
    return _connectionStates[roomId] ?? false;
  }

  /// Lắng nghe sự kiện từ socket server
  void on(String event, Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on(event, (data) {
        try {
          callback(data);
        } catch (e, stackTrace) {
          debugPrint('❌ Lỗi xử lý sự kiện socket: $e');
          sendErrorLog(
            level: 2,
            message: "Lỗi xử lý sự kiện socket: $event",
            additionalInfo: "${e.toString()} - Stack: $stackTrace",
          );
        }
      });
    }
  }

  /// Hủy đăng ký lắng nghe sự kiện
  void off(String event) {
    if (_socket != null) {
      _socket!.off(event);
      debugPrint('🔕 Đã hủy lắng nghe sự kiện: $event');
    }
  }

  /// Gửi sự kiện và chờ phản hồi
  void emitWithAck(String event, dynamic data, {Function(dynamic)? ack}) {
    if (_socket != null && _socket!.connected) {
      _socket!.emitWithAck(event, data, ack: (data) {
        if (ack != null) {
          try {
            ack(data);
          } catch (e, stackTrace) {
            debugPrint('❌ Lỗi xử lý phản hồi socket: $e');
            sendErrorLog(
              level: 2,
              message: "Lỗi xử lý phản hồi socket cho sự kiện: $event",
              additionalInfo: "${e.toString()} - Stack: $stackTrace",
            );
          }
        }
      });
    } else {
      sendErrorLog(
        level: 1,
        message: "Socket chưa kết nối khi gửi sự kiện: $event",
        additionalInfo: "userId: $_currentUserId",
      );
    }
  }

  /// Gửi sự kiện đến server
  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      try {
        _socket!.emit(event, data);
      } catch (e, stackTrace) {
        sendErrorLog(
          level: 2,
          message: "Lỗi khi emit sự kiện socket: $event",
          additionalInfo: "${e.toString()} - Stack: $stackTrace - Data: $data",
        );
      }
    } else {
      print('❌ Socket chưa kết nối. Không thể gửi sự kiện: $event');
      if (_socket == null) {
        sendErrorLog(
          level: 1,
          message: "Socket null khi gửi sự kiện: $event",
          additionalInfo: "userId: $_currentUserId",
        );
      }
    }
  }

  /// Ngắt kết nối khỏi phòng chat
  void leaveChatRoom(String receiverId) {
    if (_currentUserId == null) return;

    List<String> ids = [_currentUserId!, receiverId];
    ids.sort();
    final chatDeviceId = '$PREFIX_INBOX${ids[0]}_${ids[1]}';

    leaveRoom(chatDeviceId);
  }

  /// Ngắt kết nối khỏi kênh danh bạ
  void leaveContactChannel() {
    if (_currentUserId == null) return;
    final contactDeviceId = '$PREFIX_CONTACT$_currentUserId';
    leaveRoom(contactDeviceId);
  }

  /// Ngắt kết nối hoàn toàn
  void disconnect() {
    _connectionStates.clear();

    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    debugPrint('🔌 Đã ngắt kết nối socket hoàn toàn');
    notifyListeners();
  }
}
