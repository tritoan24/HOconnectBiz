import 'package:clbdoanhnhansg/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Service quản lý kết nối socket cho ứng dụng
class SocketService extends ChangeNotifier {
  // Các loại event socket
  static const String EVENT_CONNECT = 'connect_device';
  static const String EVENT_DISCONNECT = 'disconnect_device';
  
  // Các tiền tố cho kênh socket
  static const String PREFIX_NOTIFICATION = 'notification_';
  static const String PREFIX_INBOX = 'inbox_';
  static const String PREFIX_CONTACT = 'contact_';

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
      print('Socket đã được kết nối');
      return;
    }

    _setupSocket();
  }

  /// Thiết lập kết nối socket
  void _setupSocket() {
// Build socket options
    final options = IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .enableReconnection()
        .build();

// Create socket instance
    _socket = IO.io(_serverUrl, options);

// Set up event handlers
    _socket!.onConnect((_) {
      print('📱 Kết nối thành công với Socket.IO server');
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      print('📴 Ngắt kết nối với Socket.IO server');
// Reset connection states
      _connectionStates.clear();
      notifyListeners();
    });

    _socket!.onError((error) => print('❌ Socket.IO lỗi: $error'));
    _socket!.onReconnect((attempt) => print('🔄 Kết nối lại lần $attempt'));
    _socket!.onReconnectAttempt(
        (attempt) => print('⏳ Đang thử kết nối lại lần #$attempt'));
    _socket!.onReconnectFailed((_) => print('❌ Kết nối lại thất bại'));
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
      print('🔔 Kết nối tới kênh thông báo: $deviceId');
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
      // Tạo ID phòng chat nhất quán bằng cách sắp xếp IDs
      List<String> ids = [senderId, receiverId];
      ids.sort();
      final chatDeviceId = '$PREFIX_INBOX${ids[0]}_${ids[1]}';

      _socket!.emit(EVENT_CONNECT, {'deviceId': chatDeviceId});
      _connectionStates[chatDeviceId] = true;

      print('💬 Kết nối tới phòng chat: $chatDeviceId');
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

      print('👥 Kết nối tới kênh danh bạ: $contactDeviceId');
      notifyListeners();
    }
  }

  /// Ngắt kết nối khỏi một phòng cụ thể
  void leaveRoom(String roomId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(EVENT_DISCONNECT, {'deviceId': roomId});
      _connectionStates.remove(roomId);

      print('🚪 Rời khỏi phòng: $roomId');
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
        } catch (e) {
          print('❌ Lỗi xử lý sự kiện socket: $e');
        }
      });
    }
  }

  /// Gửi sự kiện và chờ phản hồi
  void emitWithAck(String event, dynamic data, {Function(dynamic)? ack}) {
    if (_socket != null && _socket!.connected) {
      _socket!.emitWithAck(event, data, ack: (data) {
        if (ack != null) {
          try {
            ack(data);
          } catch (e) {
            print('❌ Lỗi xử lý phản hồi socket: $e');
          }
        }
      });
    }
  }

  /// Gửi sự kiện đến server
  void emit(String event, dynamic data) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(event, data);
    } else {
      print('❌ Socket chưa kết nối. Không thể gửi sự kiện: $event');
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

    print('🔌 Đã ngắt kết nối socket hoàn toàn');
    notifyListeners();
  }
}
