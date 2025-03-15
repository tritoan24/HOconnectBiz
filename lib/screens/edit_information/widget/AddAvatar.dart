// lib/widgets/image_picker_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'AddImage.dart';
import '../../../utils/router/router.name.dart';

class Addavatar extends StatefulWidget {
  final Function(String) onImageSelected;
  final String? initialImage;

  const Addavatar({
    super.key,
    required this.onImageSelected,
    this.initialImage,
  });

  @override
  State<Addavatar> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<Addavatar> {
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
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text('Ảnh đại diện',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _imagePath != "" && _imagePath!.isNotEmpty
                    ? AddAvatarImage(
                        width: 120,
                        height: 120,
                        imagePath: _imagePath!,
                      )
                    : Image.network(
                        UrlImage.defaultAvatarImage,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Positioned(
              bottom: -6,
              right: -6,
              child: GestureDetector(
                onTap: _pickImage,
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
                  child: Image.asset(
                    'assets/icons/camera.png',
                    width: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
