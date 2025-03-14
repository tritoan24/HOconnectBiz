import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:clbdoanhnhansg/providers/chat_provider.dart';
import 'package:clbdoanhnhansg/screens/chat/widget/message_input.dart';

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
                    bool isMe = message.sender?.id == widget.currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8, bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        message.sender?.avatarImage ?? ""),
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
                              color: isMe
                                  ? const Color(0xFFD6E9FF)
                                  : const Color(0xFFE9EBED),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMe
                                    ? const Color(0xFFD6D9DC)
                                    : const Color(0xFF006AF5),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              message.content ?? "",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                                color: const Color(0xFF141415),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, bottom: 8),
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
                    );
                  },
                );
              },
            ),
          ),
          MessageInputScreen(
            onMessageChanged: (message, images) {
              // setState(() {
              //   // selectedImages = images;
              //   // currentMessage = message;
              // });
            },
            onSubmit: _sendMessage,
          ),
        ],
      ),
    );
  }
}

