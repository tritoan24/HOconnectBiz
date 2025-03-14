// import 'package:clbdoanhnhansg/screens/cart/widget/sales_order_tab.dart';
// import 'package:clbdoanhnhansg/screens/chat/deltails_sales_article.dart';
// import 'package:clbdoanhnhansg/screens/tin_mua_hang/tin_mua_hang.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
//
// import '../cart/cart_tab.dart';
// import 'details_chat.dart';
//
// class ChatListScreen extends StatelessWidget {
//   int badgeCount = 13;
//
//   final List<Message> messages = [
//     Message(
//       title: "Công ty TNHH Fujiwa Việt Nam",
//       content:
//           "Bạn ơi mình đang muốn mua 12 Thùng Nước Uống I-ON Kiềm Cao Cấp Fujiwa Cái Loại 450ml",
//       time: "08:13",
//       avatar: [
//         "https://firebasestorage.googleapis.com/v0/b/reactnative-8e2ca.appspot.com/o/avatars%2FFrame%201000007431%20(1).png?alt=media&token=01e9b1a0-2b38-4c52-ac82-38a17fda4208"
//       ],
//       type: 'tin mua hang',
//     ),
//     Message(
//       title: "Công ty Dr Natro",
//       content: "Bạn ơi mình đang muốn mua Bộ bàn ghế gỗ gụ",
//       time: "08:13",
//       avatar: [
//         "https://firebasestorage.googleapis.com/v0/b/reactnative-8e2ca.appspot.com/o/avatars%2FFrame%201597883657%20(1).png?alt=media&token=bcd1b4ad-494b-476d-a801-1065ee855978"
//       ],
//       type: 'tin ban hang',
//     ),
//     Message(
//       title: "Group Đột Phá Doanh Thu Cùng Chiến Lược Đa Kênh - Phân Khúc!",
//       content:
//           "(Thêm) Nghe hay quá! Mình sẽ thử bắt đầu từ việc phân tích khách hàng trước.",
//       time: "08:13",
//       avatar: [
//         "https://firebasestorage.googleapis.com/v0/b/reactnative-8e2ca.appspot.com/o/avatars%2FFrame%201597883657%20(1).png?alt=media&token=bcd1b4ad-494b-476d-a801-1065ee855978",
//         "https://firebasestorage.googleapis.com/v0/b/reactnative-8e2ca.appspot.com/o/avatars%2FPhoto.png?alt=media&token=ba128dce-551d-4ebf-a868-cedbd7391910",
//         "https://firebasestorage.googleapis.com/v0/b/reactnative-8e2ca.appspot.com/o/avatars%2FPhoto2.png?alt=media&token=3887cd74-d8f5-4d9c-bcbb-89987b016b5b",
//         "https://firebasestorage.googleapis.com/v0/b/reactnative-8e2ca.appspot.com/o/avatars%2FAvatar.png?alt=media&token=ba8e4e76-d2b0-4f54-af2c-31366de54e34"
//       ],
//       type: 'group',
//     ),
//     Message(
//       title:
//           "Group Tối ưu hóa lợi nhuận, mở rộng thị trường: Cơ hội hợp tác không thể bỏ qua!",
//       content:
//           "(Xoá) Nghe hay quá! Mình sẽ thử bắt đầu từ việc phân tích khách hàng trước.",
//       time: "08:13",
//       avatar: [
//         "https://firebasestorage.googleapis.com/v0/b/reactnative-8e2ca.appspot.com/o/avatars%2FFrame%201597883657%20(1).png?alt=media&token=bcd1b4ad-494b-476d-a801-1065ee855978",
//         "https://firebasestorage.googleapis.com/v0/b/reactnative-8e2ca.appspot.com/o/avatars%2FPhoto.png?alt=media&token=ba128dce-551d-4ebf-a868-cedbd7391910",
//         "https://firebasestorage.googleapis.com/v0/b/reactnative-8e2ca.appspot.com/o/avatars%2FPhoto2.png?alt=media&token=3887cd74-d8f5-4d9c-bcbb-89987b016b5b",
//         "https://firebasestorage.googleapis.com/v0/b/reactnative-8e2ca.appspot.com/o/avatars%2FAvatar.png?alt=media&token=ba8e4e76-d2b0-4f54-af2c-31366de54e34"
//       ],
//       type: 'group',
//     ),
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Tin nhắn"),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         actions: [
//           Stack(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 8.0),
//                 child: IconButton(
//                   icon: SvgPicture.asset(
//                     "assets/icons/card.svg",
//                   ),
//                   onPressed: () {
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (context) => const Cart()));
//                   },
//                 ),
//               ),
//               if (badgeCount > 0)
//                 Positioned(
//                   right: 6,
//                   top: 6,
//                   child: Container(
//                     padding: const EdgeInsets.all(2),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     constraints: const BoxConstraints(
//                       minWidth: 26,
//                       minHeight: 14,
//                     ),
//                     child: Text(
//                       badgeCount.toString(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//       body: Container(
//         color: const Color(0xFFF4F5F6),
//         child: ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: messages.length,
//           itemBuilder: (context, index) {
//             return MessageTile(message: messages[index]);
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class Message {
//   final String title;
//   final String content;
//   final String time;
//   final List<String> avatar;
//   final String type;
//
//   Message(
//       {required this.title,
//       required this.content,
//       required this.time,
//       required this.avatar,
//       required this.type});
// }
//
// class MessageTile extends StatelessWidget {
//   final Message message;
//
//   const MessageTile({super.key, required this.message});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: Colors.white,
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(top: 8, bottom: 8),
//         child: ListTile(
//           leading: message.type == 'group'
//               ? SizedBox(
//                   width: 50, // Giới hạn chiều rộng để avatar xếp gọn
//                   child: Wrap(
//                     alignment: WrapAlignment.center,
//                     spacing: 2,
//                     runSpacing: 2,
//                     children: message.avatar.take(4).map((url) {
//                       return CircleAvatar(
//                         backgroundImage: NetworkImage(url),
//                         radius: 10, // Giảm kích thước để vừa 2x2
//                       );
//                     }).toList(),
//                   ),
//                 )
//               : CircleAvatar(
//                   backgroundImage: NetworkImage(message.avatar.first),
//                 ),
//           title: Text(
//             message.title,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           subtitle: Text(
//             message.content,
//             style: const TextStyle(color: Colors.grey),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           trailing: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 message.time,
//                 style: const TextStyle(color: Colors.grey),
//               )
//             ],
//           ),
//           onTap: () {
//             // Kiểm tra loại message và điều hướng tương ứng
//             String typeLowerCase = message.type.toLowerCase();
//
//             if (typeLowerCase == 'group') {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => ChatDetailScreen()),
//               );
//             } else if (typeLowerCase == 'tin mua hang') {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const TinMuaHang()),
//               );
//             } else if (typeLowerCase == 'tin ban hang') {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => const DeltailsSalesArticle()),
//               );
//             } else {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const SizedBox()),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:clbdoanhnhansg/models/contact.dart';
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
          icon: const Icon(Icons.arrow_back_ios),
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
                if (contact.type == "Group")
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Nhóm",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

      // If we have avatars, show up to 4 in a grid
      return SizedBox(
        width: 40,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 2,
          children: avatarUrls.take(4).map((url) {
            return CircleAvatar(
              backgroundImage: NetworkImage(url),
              radius: 10, // Small radius to fit in grid
            );
          }).toList(),
        ),
      );
    } else {
      // For Business or regular user
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

