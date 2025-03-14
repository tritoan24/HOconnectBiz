// lib/widgets/add_avatar_image.dart
import 'dart:io';
import 'package:flutter/material.dart';

class AddAvatarImage extends StatelessWidget {
  final double width;
  final double height;
  final String imagePath;

  const AddAvatarImage(
      {super.key,
      this.height = double.infinity,
      this.width = double.infinity,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    // Kiểm tra xem imagePath có phải là đường dẫn file cục bộ hay URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Nếu là URL, sử dụng Image.network
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Nếu tải URL thất bại, hiển thị ảnh mặc định hoặc lỗi
          return Image.network(
            imagePath,
            // Đường dẫn ảnh mặc định (thay bằng đường dẫn thực tế)
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // Nếu là đường dẫn file cục bộ, sử dụng Image.file
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Nếu tải file thất bại, hiển thị ảnh mặc định
          return Image.asset(
            'assets/images/default_avatar.png',
            fit: BoxFit.cover,
          );
        },
      );
    }
  }
}
