import 'dart:io';

import 'package:clbdoanhnhansg/screens/chat/create_order.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/socket_service.dart';
import '../../models/message_model.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/confirmdialog.dart';
import '../../widgets/galleryphotoview.dart';
import '../tin_mua_hang/widgets/item_san_pham_mess.dart';
import 'widget/message_input.dart';

class DeltailsSalesArticle extends StatefulWidget {
  final bool isCreate;
  final String currentUserId;
  final String idReceiver;
  final String idMessage;
  final String avatarImage;
  final String displayName;

  const DeltailsSalesArticle({
    super.key,
    this.isCreate = false,
    required this.currentUserId,
    required this.idReceiver,
    required this.idMessage,
    required this.avatarImage,
    required this.displayName,
  });

  @override
  State<DeltailsSalesArticle> createState() => _DeltailsSalesArticleState();
}

class _DeltailsSalesArticleState extends State<DeltailsSalesArticle> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> selectedImages = [];
  late SocketService _socketService;

  // Trong DeltailsSalesArticle
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Sử dụng ChatProvider để xử lý socket
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // Khởi tạo socket một cách rõ ràng
      chatProvider.initializeSocket(context, widget.idReceiver).then((_) {
        // Lấy dữ liệu tin nhắn
        chatProvider.getListDetailChat(context, widget.idMessage);
        _scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    // Ghi chú: không ngắt kết nối toàn bộ socket mà chỉ thoát phòng
    // ChatProvider sẽ quản lý việc này
    super.dispose();
  }

  void _connectToSpecificChatRoom() {
    // Kết nối tới phòng chat giữa 2 người dùng
    // _socketService.connect(widget.currentUserId);
    _socketService.connectToChat(widget.currentUserId, widget.idReceiver);

    // Đăng ký lắng nghe tin nhắn mới
    _socketService.on('new_message', (data) {
      print("📱 Nhận tin nhắn mới từ socket: $data");
      if (data != null && data is Map<String, dynamic>) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.getListDetailChat(context, widget.idMessage);
      }
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final chatProvider = Provider.of<ChatProvider>(context, listen: false);
  //     chatProvider.getListDetailChat(context, widget.idMessage).then((_) {
  //       _scrollToBottom();
  //     });
  //   });
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addListener(() {
      if (chatProvider.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
    print("Xóa tin nhắn: $messageId");
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

      // Gửi tin nhắn thông qua ChatProvider
      await chatProvider.sendMessage(
        message,
        widget.idReceiver,
        widget.idMessage,
        context,
        files: album,
      );

      // Xóa nội dung nhập sau khi gửi
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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.messages;
                if (messages.isEmpty) {
                  return const Center(child: Text("Chưa có tin nhắn nào"));
                }
                // Cuộn xuống khi có tin nhắn mới
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(
                      top: 16, left: 16, right: 16, bottom: 80),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          MessageInputScreen(
            onMessageChanged: (message, images) {
              setState(() {
                selectedImages = images;
              });
            },
            onSubmit: _sendMessage,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
      ),
      title: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final messages = chatProvider.messages;
          if (messages.isEmpty) {
            return const Text(
              "Tin nhắn",
              style: TextStyle(color: Colors.black, fontSize: 16),
            );
          }
          return Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.avatarImage,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      UrlImage.imageUserDefault,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.displayName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: const BoxDecoration(
            color: Color(0xFFEBF4FF),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            iconSize: 24,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreateOrder(idRecive: widget.idReceiver)));
            },
          ),
        ),
      ],
    );
  }

  /// **Bubble Chat - Hiển thị tin nhắn**
  Widget _buildMessageBubble(Message message) {
    bool isMe = message.sender?.id == widget.currentUserId;
    print("Message ID: ${message.id}, Has data: ${message.data != null}");
    return Dismissible(
      key: Key(message.id.toString()), // Mỗi tin nhắn cần có một key duy nhất
      direction: DismissDirection.endToStart, // Vuốt từ phải sang trái
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: Colors.red, // Màu nền đỏ
          borderRadius: BorderRadius.circular(12), // Bo góc mềm mại
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Đổ bóng nhẹ
              blurRadius: 10, // Làm mờ bóng
              offset: Offset(2, 2), // Vị trí bóng
            ),
          ],
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30, // Kích thước icon
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
                  _deleteMessage(message.id.toString());
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
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      message.sender!.avatarImage,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          UrlImage.imageUserDefault,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      message.sender!.displayName,
                      textAlign: TextAlign.justify,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.333,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
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
                  if (message.album.isNotEmpty)
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
            if (message.data != null)
              OrderCard(
                data: OrderCardData.fromOrderModel(message.data!),
                donHang: message.data!,
              ),
          ],
        ),
      ),
    );
  }
}

