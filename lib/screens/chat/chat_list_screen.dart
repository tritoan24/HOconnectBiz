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

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late String currentUserId = "";
  final int badgeCount = 13;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Đơn giản hóa khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

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
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: SvgPicture.asset(
                    "assets/icons/card.svg",
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Cart()));
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
                quantityMember: 0, // Set appropriate value or make optional
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
            leading: _buildAvatar(),
            title: Text(
              contact.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              contact.lastMessage.content,
              style: const TextStyle(color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  contact.getFormattedTime(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (contact.type == "Group") const SizedBox(height: 4),
                // if (contact.type == "Group")
                //   Container(
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                //     decoration: BoxDecoration(
                //       color: Colors.blue.shade100,
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: const Text(
                //       "Nhóm",
                //       style: TextStyle(
                //         color: Colors.blue,
                //         fontSize: 10,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
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
      if (avatarUrls.length == 1) {
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
          children: [
            // Show the first 3 avatars
            for (int i = 0; i < min(3, avatarUrls.length); i++)
              Positioned(
                left: i * 10.0,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrls[i]),
                  radius: 12,
                ),
              ),

            // If there are more than 3 avatars, show the count
            if (avatarUrls.length > 3)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '+${avatarUrls.length - 3}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

