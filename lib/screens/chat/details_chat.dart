import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:clbdoanhnhansg/providers/chat_provider.dart';
import 'package:clbdoanhnhansg/screens/chat/widget/message_input.dart';
import '../../models/message_model.dart';
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

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Khởi tạo socket và kết nối tới phòng chat
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      print("🚀 Khởi tạo socket và kết nối tới phòng chat");

      // 1. Kết nối socket
      chatProvider.initializeSocket(context, widget.groupId).then((_) {
        // 2. Kết nối đến phòng chat cụ thể
        _connectToSpecificChatRoom();
        print("🚀 Kết nối socket thành công");

        // 3. Lấy tin nhắn cũ
        chatProvider.getListDetailChat(context, widget.idMessage).then((_) {
          _scrollToBottom();
          print("🚀 Lấy tin nhắn cũ thành công");
        });
      });
    });
  }

  void _connectToSpecificChatRoom() {
    // Kết nối tới phòng chat giữa 2 người dùng
    // _socketService.connect(widget.currentUserId);
    _socketService.connectToChat(widget.currentUserId, widget.groupId);

    // Đăng ký lắng nghe tin nhắn mới
    _socketService.on('new_message', (data) {
      print("📱 Nhận tin nhắn mới từ socket: $data");
      if (data != null && data is Map<String, dynamic>) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.getListDetailChat(context, widget.idMessage);
      }
    });
  }

  @override
  void dispose() {
    // Không ngắt kết nối socket khi thoát màn hình
    // vì chúng ta muốn tiếp tục nhận thông báo
    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     Provider.of<ChatProvider>(context, listen: false)
  //         .getListDetailChat(context, widget.idMessage);
  //     _scrollToBottom();
  //   });
  // }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 50,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
        ],
      ),
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
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    bool isMe = message.sender?.id == widget.currentUserId;

    return Dismissible(
      key: ObjectKey(message.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteMessage(message.id!);
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
                      backgroundImage:
                          NetworkImage(message.sender?.avatarImage ?? ""),
                      radius: 12,
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
                        message.sender?.displayName ?? "Unknown",
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
                    message.content.toString(),
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: const Color(0xFF141415),
                    ),
                  ),
                  if (message.album != null && message.album!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GalleryPhotoViewWrapper(
                                galleryItems: message.album!,
                                initialIndex: 0,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: message.album!.first,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  message.album!.first,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Hiển thị hình ảnh thay thế khi gặp lỗi
                                    return Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline,
                                              size: 50, color: Colors.red),
                                          SizedBox(height: 8),
                                          Text(
                                            "Không thể tải ảnh",
                                            style: TextStyle(
                                                color: Colors.grey[800]),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
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
              child: Text(
                message.getFormattedTime(),
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: const Color(0xFF767A7F),
                ),
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
}
