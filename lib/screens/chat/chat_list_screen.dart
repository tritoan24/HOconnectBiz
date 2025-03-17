import 'dart:math';

import 'package:clbdoanhnhansg/models/contact.dart';
import 'package:clbdoanhnhansg/utils/icons/app_icons.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../cart/cart_tab.dart';
import 'deltails_sales_article.dart';
import 'details_chat.dart';
import '../../providers/post_provider.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late String currentUserId = "";
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Đơn giản hóa khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // Reset số lượng tin nhắn mới
      try {
        final postProvider = Provider.of<PostProvider>(context, listen: false);
        postProvider.resetMessageCount();
      } catch (e) {
        print("Lỗi khi reset số lượng tin nhắn mới: $e");
      }

      // Lấy thông tin người dùng hiện tại
      currentUserId = (await authProvider.getuserID())!;

      // Kết nối socket cho danh sách liên hệ
      await chatProvider.initializeContactSocket(context);

      // Tải danh sách liên hệ
      chatProvider.getContacts(context);
    });
  }

  @override
  void dispose() {
    Provider.of<ChatProvider>(context, listen: false).leaveContactScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tin nhắn"),
        leading: IconButton(
          icon: AppIcons.arrowBackIos,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              final badgeCount = chatProvider.cartItemCount;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        "assets/icons/card.svg",
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Cart()));
                      },
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 26,
                          minHeight: 14,
                        ),
                        child: Text(
                          badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF4F5F6),
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            if (chatProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (chatProvider.contacts.isEmpty) {
              return const Center(child: Text("Không có tin nhắn nào"));
            }
            print("messages: ${chatProvider.contacts.length}");

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.contacts.length,
              itemBuilder: (context, index) {
                return MessageTile(
                  contact: chatProvider.contacts[index],
                  currentUserId: currentUserId,
                  idMessage: chatProvider.contacts[index].id,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final Contact contact;
  final String currentUserId;
  final String idMessage;

  const MessageTile({
    Key? key,
    required this.contact,
    required this.currentUserId,
    required this.idMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalMem = 0;
    if (contact.avatarImage is List) {
      totalMem = contact.avatarImage.length;
    }
    return GestureDetector(
      onTap: () {
        if (contact.type == "Group") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                currentUserId: currentUserId,
                idMessage: idMessage,
                groupId: contact.id,
                groupName: contact.displayName,
                quantityMember: totalMem,
              ),
            ),
          );
        } else {
          // Navigate to business/individual chat screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeltailsSalesArticle(
                currentUserId: currentUserId,
                idMessage: idMessage,
                idReceiver: contact.id,
                avatarImage: contact.avatarImage,
                displayName: contact.displayName,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: ListTile(
            leading: Align(
              alignment: Alignment.center, // This centers the avatar vertically
              widthFactor: 1, // Important to prevent horizontal stretching
              child: _buildAvatar(),
            ),
            title: Text(
              contact.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(
                  top: 4), // Adds 4px spacing above the subtitle
              child: Text(
                contact.lastMessage.content,
                style: const TextStyle(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  contact.getFormattedTime(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (contact.type == "Group") {
      // Get avatar URLs
      List<String> avatarUrls = [];

      // Handle avatar_image which could be a list or string
      if (contact.avatarImage is List) {
        avatarUrls = List<String>.from(contact.avatarImage);
      } else if (contact.avatarImage is String &&
          contact.avatarImage.isNotEmpty) {
        avatarUrls = [contact.avatarImage];
      }

      // If no avatars, show a default group icon
      if (avatarUrls.isEmpty) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.group,
              color: Colors.grey,
            ),
          ),
        );
      }

      // If we have only 1 avatar, show default group image
      if (avatarUrls.length <= 3) {
        return Container(
          width: 40, // Keep original container size
          height: 40, // Keep original container size
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200, // Background color for empty space
          ),
          child: Center(
            child: Container(
              width: 30, // Smaller image size
              height: 30, // Smaller image size
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(UrlImage.imageGroupDefault),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }

      // If we have multiple avatars (up to 3 visible, rest with counter)
      return Container(
        width: 40,
        height: 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // First avatar (top left)
            Positioned(
              left: -8,
              top: -6,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrls[0]),
                  radius: 12,
                ),
              ),
            ),

            // Second avatar (top right)
            if (avatarUrls.length > 1)
              Positioned(
                right: 0,
                top: -6,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(avatarUrls[1]),
                    radius: 12,
                  ),
                ),
              ),

            // Third avatar (bottom)
            if (avatarUrls.length > 2)
              Positioned(
                left: -8,
                bottom: -6,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(avatarUrls[2]),
                    radius: 12,
                  ),
                ),
              ),

            // Counter for additional avatars
            if (avatarUrls.length > 3)
              Positioned(
                right: 0,
                bottom: -6,
                child: Container(
                  width: 27, // Fixed width 24px
                  height: 27, // Fixed height 24px
                  decoration: BoxDecoration(
                    color: Color(0xffE9EBED),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+${avatarUrls.length - 3}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      return CircleAvatar(
        backgroundImage: contact.avatarImage.isNotEmpty
            ? NetworkImage(contact.avatarImage)
            : NetworkImage(contact.avatarImage),
        child: contact.avatarImage.isEmpty
            ? const Icon(
                Icons.person,
                color: Colors.grey,
              )
            : null,
      );
    }
  }
}
