// lib/widgets/image_picker_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'AddImage.dart';

class AddBackgroud extends StatefulWidget {
  final Function(String) onImageSelected;
  final String? initialImage;

  const AddBackgroud({
    super.key,
    required this.onImageSelected,
    this.initialImage,
  });

  @override
  State<AddBackgroud> createState() => _ImageBackgroud();
}

class _ImageBackgroud extends State<AddBackgroud> {
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImage;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
        widget.onImageSelected(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tiêu đề "Ảnh bìa"
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              'Ảnh bìa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        // Widget hình ảnh và biểu tượng camera
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: GestureDetector(
                onTap: _pickImage, // Hàm chọn ảnh
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _imagePath != ""
                      ? AddAvatarImage(
                          height: 224,
                          imagePath: _imagePath!,
                        )
                      : Image.network(
                          'https://i.pinimg.com/736x/4d/7f/55/4d7f5567e920f9d1b5ca4f1ebad36072.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 224,
                        ),
                ),
              ),
            ),
            // Đặt biểu tượng camera
            Positioned(
              bottom: -15, // Khoảng cách từ dưới lên
              right: 9, // Khoảng cách từ phải sang
              child: GestureDetector(
                onTap: _pickImage, // Hàm chọn ảnh
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                        8.0), // Căn chỉnh biểu tượng bên trong
                    child: Image.asset(
                      'assets/icons/camera.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), // Khoảng cách dưới ảnh
      ],
    );
  }
}
