import 'package:clbdoanhnhansg/models/comment_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../widgets/galleryphotoview.dart';
import '../comments_screen.dart';
import 'package:clbdoanhnhansg/core/utils/date_time_utils.dart';

class BinhLuanItem extends StatelessWidget {
  final CommentModel binhLuan;

  const BinhLuanItem({super.key, required this.binhLuan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar người dùng
          ClipOval(
            child: Image.network(
              binhLuan.userId!.avatarImage,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              // Xử lý khi đang tải ảnh
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              },
              // Xử lý khi ảnh bị lỗi
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          // Phần nội dung bình luận
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        binhLuan.userId!.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      binhLuan.content == ""
                          ? Container()
                          : Text(
                              binhLuan.content,
                              style: const TextStyle(fontSize: 14),
                            ),
                    ],
                  ),
                ),
                // Hiển thị hình ảnh nếu có
                if (binhLuan.album != null && binhLuan.album!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(binhLuan.album!.length, (index) {
                      final imageUrl = binhLuan.album![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GalleryPhotoViewWrapper(
                                galleryItems: binhLuan.album!,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: imageUrl,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              // Xử lý khi đang tải ảnh
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEEEEE),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              // Xử lý khi ảnh bị lỗi
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEEEEE),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],

                const SizedBox(height: 4),
                Text(
                  binhLuan.createdAt != null
                      ? DateTimeUtils.formatDateTime(
                          DateTimeUtils.toLocalTime(binhLuan.createdAt!),
                          format: 'dd/MM/yyyy HH:mm'
                        )
                      : 'No date',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

