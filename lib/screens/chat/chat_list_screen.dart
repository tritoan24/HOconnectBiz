import 'package:clbdoanhnhansg/models/contact.dart';
import 'package:clbdoanhnhansg/utils/icons/app_icons.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/transitions/custom_page_transition.dart';
import '../cart/cart_tab.dart';
import 'deltails_sales_article.dart';
import 'details_chat.dart';
import '../../providers/post_provider.dart';

class ChatListScreen extends StatefulWidget {
  final Map<String, String>? notificationId;

  const ChatListScreen({super.key, this.notificationId});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late String currentUserId = "";

  @override
  void initState() {
    super.initState();

    // Đơn giản hóa khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      chatProvider.changeNotificationId(value: widget.notificationId?["id"]);

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
      await chatProvider.initializeContactSocket(context, currentUserId);

      // Tải danh sách liên hệ
      chatProvider.getContacts(context, onSuccess: (contacts) {
        if (widget.notificationId != null) {
          Future.delayed(Duration.zero, () {
            for (var action in contacts) {
              if (action.id == widget.notificationId!['id']) {
                if (action.type == "Group") {
                  Navigator.push(
                    context,
                    CustomPageTransition(
                      page: ChatDetailScreen(
                        currentUserId: currentUserId,
                        idMessage: action.id,
                        groupId: action.id,
                        groupName: action.displayName,
                        quantityMember: action.avatarImage.length,
                      ),
                      type: TransitionType.slideRight,
                    ),
                  );
                } else {
                  // Navigate to business/individual chat screen
                  Navigator.push(
                    context,
                    CustomPageTransition(
                      page: DeltailsSalesArticle(
                        currentUserId: currentUserId,
                        idMessage: action.id,
                        idReceiver: action.id,
                        avatarImage: action.avatarImage,
                        displayName: action.displayName,
                      ),
                      type: TransitionType.slideRight,
                    ),
                  );
                }
              }
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    Provider.of<ChatProvider>(context, listen: false).leaveContactScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contacts = Provider.of<ChatProvider>(context, listen: false).contacts;
    void updateReadStatus(String contactId) {
      setState(() {
        for (int i = 0; i < contacts.length; i++) {
          if (contacts[i].id == contactId) {
            contacts[i].setReadStatus(true);
            break;
          }
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tin nhắn"),
        leading: IconButton(
          icon: AppIcons.arrowBackIos,
          onPressed: () {
            if (widget.notificationId != null) {
              GoRouter.of(context).go(AppRoutes.trangChu);
            } else {
              Navigator.pop(context);
            }
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
                            CustomPageTransition(
                              page: const Cart(),
                              type: TransitionType.slideRight,
                            ));
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
              return Center(
                  child: Center(
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ));
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
                  onReadStatusChanged: updateReadStatus,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MessageTile extends StatefulWidget {
  // Changed to StatefulWidget
  final Contact contact;
  final String currentUserId;
  final String idMessage;
  final Function(String)?
      onReadStatusChanged; // Callback for read status changes

  const MessageTile({
    Key? key,
    required this.contact,
    required this.currentUserId,
    required this.idMessage,
    this.onReadStatusChanged,
  }) : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  // Local copy of isRead status to handle immediate UI updates
  bool? _isRead;

  @override
  void initState() {
    super.initState();
    _isRead = widget.contact.lastMessage.isRead;
  }

  @override
  void didUpdateWidget(MessageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state if the contact's read status changes externally
    if (oldWidget.contact.lastMessage.isRead !=
        widget.contact.lastMessage.isRead) {
      _isRead = widget.contact.lastMessage.isRead;
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalMem = 0;
    if (widget.contact.avatarImage is List) {
      totalMem = widget.contact.avatarImage.length;
    }
    return GestureDetector(
      onTap: () {
        // Update local state immediately
        setState(() {
          _isRead = true;
        });

        // Notify parent to update the data model
        if (widget.onReadStatusChanged != null) {
          widget.onReadStatusChanged!(widget.contact.id);
        }

        if (widget.contact.type == "Group") {
          Navigator.push(
            context,
            CustomPageTransition(
              page: ChatDetailScreen(
                currentUserId: widget.currentUserId,
                idMessage: widget.idMessage,
                groupId: widget.contact.id,
                groupName: widget.contact.displayName,
                quantityMember: totalMem,
              ),
              type: TransitionType.slideRight,
            ),
          );
        } else {
          // Navigate to business/individual chat screen
          Navigator.push(
            context,
            CustomPageTransition(
              page: DeltailsSalesArticle(
                currentUserId: widget.currentUserId,
                idMessage: widget.idMessage,
                idReceiver: widget.contact.id,
                avatarImage: widget.contact.avatarImage,
                displayName: widget.contact.displayName,
              ),
              type: TransitionType.slideRight,
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
              alignment: Alignment.center,
              widthFactor: 1,
              child: _buildAvatar(),
            ),
            title: Text(
              widget.contact.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.contact.lastMessage.content,
                style: TextStyle(
                  // Use local _isRead state for immediate UI feedback
                  color: _isRead ?? false ? Colors.grey : Colors.black,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.contact.getFormattedTime(),
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
    if (widget.contact.type == "Group") {
      // Get avatar URLs
      List<String> avatarUrls = [];

      // Handle avatar_image which could be a list or string
      if (widget.contact.avatarImage is List) {
        avatarUrls = List<String>.from(widget.contact.avatarImage);
      } else if (widget.contact.avatarImage is String &&
          widget.contact.avatarImage.isNotEmpty) {
        avatarUrls = [widget.contact.avatarImage];
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
          ),
          child: Center(
            child: Container(
              width: 30,
              height: 30,
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
                child: _buildSafeAvatar(avatarUrls[0], 12),
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
                  child: _buildSafeAvatar(avatarUrls[1], 12),
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
                  child: _buildSafeAvatar(avatarUrls[2], 12),
                ),
              ),

            // Counter for additional avatars
            if (avatarUrls.length > 3)
              Positioned(
                right: 0,
                bottom: -6,
                child: Container(
                  width: 27,
                  height: 27,
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
      return _buildSafeAvatar(widget.contact.avatarImage, 20);
    }
  }

  Widget _buildSafeAvatar(String imageUrl, double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    UrlImage.imageUserDefault,
                    fit: BoxFit.cover,
                  );
                },
              )
            : Image.asset(
                UrlImage.imageUserDefault,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
