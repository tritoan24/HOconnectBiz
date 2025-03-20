import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:clbdoanhnhansg/providers/chat_provider.dart';
import 'package:clbdoanhnhansg/screens/chat/widget/message_input.dart';
import '../../models/message_model.dart';
import '../../widgets/confirmdialog.dart';
import '../../widgets/galleryphotoview.dart';
import '../../utils/router/router.name.dart';

import '../../core/services/socket_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String currentUserId;
  final String idMessage;
  final String groupId;
  final String groupName;
  final int quantityMember;

  const ChatDetailScreen({
    super.key,
    required this.currentUserId,
    required this.idMessage,
    required this.groupId,
    required this.groupName,
    this.quantityMember = 0,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> selectedImages = [];

  late SocketService _socketService;
  bool _isLoadingAtTop = false; // Biến theo dõi trạng thái tải ở đầu danh sách
  DateTime _lastLoadTime = DateTime.now(); // Thời điểm tải tin nhắn cuối cùng

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Khởi tạo socket và kết nối tới phòng chat
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      print("🚀 Khởi tạo socket và kết nối tới phòng chat");

      // 1. Kết nối socket
      chatProvider.initializeSocketChatGroup(context, widget.groupId).then((_) {
        // 2. Kết nối đến phòng chat cụ thể
        // _connectToSpecificChatRoom();
        print("🚀 Kết nối socket thành công");

        // 3. Lấy tin nhắn cũ
        chatProvider.getListDetailChat(context, widget.idMessage).then((_) {
          _scrollToBottom();
          print("🚀 Lấy tin nhắn cũ thành công");

          // 4. Đánh dấu tất cả tin nhắn là đã đọc
          // chatProvider.markAllMessagesAsRead(widget.idMessage, context);
        });
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addListener(() {
      // Chỉ cuộn xuống cuối khi có tin nhắn mới và không đang loadmore
      if (chatProvider.messages.isNotEmpty && !chatProvider.isLoadingMore) {
        // Chỉ cuộn xuống khi nhận tin nhắn từ socket hoặc gửi đi, không cuộn khi đang nhập
        _scrollToBottom();
        print('🔄 Tin nhắn mới được cập nhật');
      }
    });
  }

  // void _connectToSpecificChatRoom() {
  //   // Đăng ký lắng nghe tin nhắn mới
  //   _socketService.on('new_message_group', (data) {
  //     print("📱 Nhận tin nhắn mới từ socket: $data");
  //     if (data != null && data is Map<String, dynamic>) {
  //       // Kiểm tra widget còn mounted không trước khi sử dụng context
  //       if (mounted) {
  //         final chatProvider =
  //             Provider.of<ChatProvider>(context, listen: false);
  //         // Trực tiếp xử lý dữ liệu tin nhắn từ socket thay vì gọi lại API
  //         chatProvider.handleNotificationData(data);
  //
  //         // Cuộn xuống khi nhận tin nhắn mới từ socket
  //         _scrollToBottom();
  //       } else {
  //         print("⚠️ Widget đã unmounted, không thể xử lý tin nhắn");
  //       }
  //     }
  //   });
  // }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    // Hủy đăng ký listener socket để tránh lỗi khi widget đã unmounted
    _socketService.off('new_message');
    super.dispose();
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollToBottomWithInput() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent +
              500, // Padding lớn hơn cho bàn phím
          duration: const Duration(milliseconds: 100), // Thời gian ngắn hơn
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onScroll() {
    // Nếu vị trí cuộn ở trên đầu danh sách (trong khoảng 5 pixel đầu tiên)
    // và đã qua ít nhất 500ms kể từ lần tải tin nhắn cuối cùng để tránh tải nhiều lần
    if (_scrollController.position.pixels <= 5.0 &&
        !_isLoadingAtTop &&
        DateTime.now().difference(_lastLoadTime).inMilliseconds > 500) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      if (chatProvider.hasMoreMessages && !chatProvider.isLoadingMore) {
        _isLoadingAtTop = true; // Đánh dấu đang tải
        _lastLoadTime = DateTime.now(); // Cập nhật thời điểm tải

        chatProvider.loadMoreMessages(context).then((_) {
          // Đảm bảo vị trí cuộn không bị nhảy khi tải thêm tin nhắn
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(10.0);
          }
          _isLoadingAtTop = false; // Đánh dấu đã hoàn thành tải
        });

        print("📜 Tải thêm tin nhắn cũ...");
      }
    }
  }

  void _deleteMessage(String messageId) async {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.deleteMessage(messageId, widget.idMessage, context);
    } catch (e) {
      print("Lỗi khi xóa tin nhắn: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xóa tin nhắn thất bại: $e")),
      );
    }
  }

  void _sendMessage(String message, List<String> images) async {
    if (message.trim().isEmpty && images.isEmpty) {
      print('Không có gì để gửi');
      return;
    }

    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      List<File>? album;
      if (selectedImages.isNotEmpty) {
        album = selectedImages.map((path) => File(path)).toList();
      }

      // Sử dụng phương thức gửi tin nhắn nhóm
      await chatProvider.sendMessage(
        message,
        widget.groupId,
        widget.idMessage,
        context,
        files: album,
        // isGroup: true, // Thêm flag để xử lý tin nhắn nhóm
      );

      _messageController.clear();
      setState(() {
        selectedImages = [];
      });

      // Cuộn xuống sau khi gửi tin nhắn mới
      _scrollToBottom();
    } catch (e) {
      print("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gửi tin nhắn thất bại: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.groupName,
              style: const TextStyle(
                color: Color(0xFF141415),
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            Text(
              "${widget.quantityMember} thành viên",
              style: const TextStyle(
                color: Color(0xFF747474),
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.333,
              ),
            ),
          ],
        ),
        titleSpacing: 0.8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.messages;
                if (messages.isEmpty) {
                  return const Center(child: Text("Chưa có tin nhắn nào"));
                }

                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                        bottom: 100,
                      ),
                      itemCount: messages.length +
                          (chatProvider.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == 0 && chatProvider.isLoadingMore) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          );
                        }

                        final actualIndex =
                            chatProvider.isLoadingMore ? index - 1 : index;
                        if (actualIndex < 0 || actualIndex >= messages.length) {
                          return const SizedBox.shrink();
                        }

                        final message = messages[actualIndex];
                        return _buildMessageBubble(message);
                      },
                    ),
                    // Hiển thị thanh tiến trình khi kéo đến đầu danh sách
                    if (_scrollController.hasClients &&
                        _scrollController.position.pixels <= 0 &&
                        chatProvider.hasMoreMessages)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          child: const LinearProgressIndicator(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Màu nền
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Màu đổ bóng
              blurRadius: 6, // Độ mờ
              spreadRadius: 1, // Độ lan
              offset: Offset(0, -3), // Hướng bóng (âm nghĩa là lên trên)
            ),
          ],
        ),
        child: MessageInputScreen(
          onMessageChanged: (message, images) {
            setState(() {
              selectedImages = images;
            });
          },
          onSubmit: _sendMessage,
          onKeyboardOpen: () {
            // Cuộn xuống khi bàn phím mở ra với padding lớn hơn
            _scrollToBottomWithInput();
            print('⌨️ Bàn phím hiện ra - cuộn xuống với padding lớn');
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    bool isMe = message.sender?.id == widget.currentUserId;

    return Dismissible(
      key: ObjectKey(message.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => CustomConfirmDialog(
                content: "Bạn có chắc chắn muốn xóa tin nhắn này?",
                titleButtonRight: "Xóa",
                titleButtonLeft: "Hủy",
                onConfirm: () {
                  _deleteMessage(message.id!);
                },
              ),
            ) ??
            false;
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: (message.sender?.avatarImage != null &&
                              message.sender!.avatarImage.isNotEmpty)
                          ? NetworkImage(message.sender!.avatarImage)
                          : null,
                      radius: 12,
                      child: (message.sender?.avatarImage == null ||
                              message.sender!.avatarImage.isEmpty)
                          ? const Icon(Icons.person, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        message.sender?.displayName ?? "Người dùng",
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.333,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(10),
              width: 290,
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFD6E9FF) : const Color(0xFFE9EBED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isMe ? const Color(0xFFD6D9DC) : const Color(0xFF006AF5),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content?.toString() ?? "",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: const Color(0xFF141415),
                    ),
                  ),
                  if (message.album != null &&
                      message.album!.isNotEmpty &&
                      message.album!.first.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () {
                          // Không mở xem ảnh khi đang gửi
                          if (message.status != MessageStatus.sending) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GalleryPhotoViewWrapper(
                                  galleryItems: message.album!,
                                  initialIndex: 0,
                                ),
                              ),
                            );
                          }
                        },
                        child: Hero(
                          tag: message.album!.first,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: _buildImageWidget(message),
                              ),
                              if (message.album!.length > 1)
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.black.withOpacity(0.5),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "+${message.album!.length - 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (message.status == MessageStatus.sending && isMe)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Đang gửi...",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (message.status == MessageStatus.error && isMe)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 12, color: Colors.red),
                          const SizedBox(width: 4),
                          Text(
                            message.errorMessage ?? "Không gửi được",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _retryMessage(message);
                            },
                            child: Text(
                              "Thử lại",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    () {
                      try {
                        return message.getFormattedTime();
                      } catch (e) {
                        return _getFormattedTime(message);
                      }
                    }(),
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: const Color(0xFF767A7F),
                    ),
                  ),
                  if (isMe && message.read == true)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.done_all,
                        size: 14,
                        color: Colors.blue,
                      ),
                    ),
                  if (isMe && message.read != true)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.done,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _retryMessage(Message message) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.updateMessageStatus(message.id!, MessageStatus.sending);

    _sendMessage(message.content ?? "", []);
  }

  // Phương thức hỗ trợ trong trường hợp getFormattedTime chưa được định nghĩa trong Message class
  String _getFormattedTime(Message message) {
    if (message.timestamp == null) {
      return "";
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(
        message.timestamp.year, message.timestamp.month, message.timestamp.day);

    if (messageDate == today) {
      return "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}";
    } else if (messageDate == yesterday) {
      return "Hôm qua";
    } else {
      return "${message.timestamp.day}/${message.timestamp.month}/${message.timestamp.year}";
    }
  }

  // Phương thức mới để xử lý hiển thị ảnh (local hoặc remote)
  Widget _buildImageWidget(Message message) {
    final String imageUrl = message.album!.first;

    // Kiểm tra nếu là đường dẫn local
    if (imageUrl.startsWith('file://')) {
      return Image.file(
        File(imageUrl.replaceFirst('file://', '')),
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("❌ Lỗi tải ảnh local: $error");
          return _buildErrorImageWidget();
        },
      );
    } else {
      // Ảnh từ máy chủ
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("❌ Lỗi tải ảnh từ server: $error");
          return _buildErrorImageWidget();
        },
      );
    }
  }

  Widget _buildErrorImageWidget() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red),
          SizedBox(height: 8),
          Text(
            "Không thể tải ảnh",
            style: TextStyle(color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
