import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class MessageInputScreen extends StatefulWidget {
  final bool isComment;
  final Function(String message, List<String> images) onMessageChanged;
  final Function(String message, List<String> images) onSubmit;
  final VoidCallback? onKeyboardOpen;
  const MessageInputScreen({
    super.key,
    this.isComment = false,
    required this.onMessageChanged,
    required this.onSubmit,
    this.onKeyboardOpen,
  });

  @override
  _MessageInputScreenState createState() => _MessageInputScreenState();
}

class _MessageInputScreenState extends State<MessageInputScreen> {
  List<XFile> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự kiện focus để biết khi nào bàn phím hiện ra
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.onKeyboardOpen != null) {
        // Thêm độ trễ nhỏ để đảm bảo bàn phím đã hiện ra hoàn toàn
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _focusNode.hasFocus) {
            widget.onKeyboardOpen!();
            print('🔔 Callback onKeyboardOpen được gọi sau độ trễ');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Hàm chọn nhiều ảnh từ thư viện
  Future<void> pickImages() async {
    final List<XFile>? images =
        await _picker.pickMultiImage(); // Chọn nhiều ảnh
    if (images != null && images.isNotEmpty) {
      setState(() {
        selectedImages.addAll(images); // Thêm vào danh sách
      });
      _updateImages();
    }
  }

  void _updateImages() {
    List<String> imagePaths = selectedImages.map((img) => img.path).toList();
    widget.onMessageChanged(_controller.text, imagePaths);
  }

  void _handleSubmit() {
    if (_controller.text.trim().isEmpty && selectedImages.isEmpty) return;

    // Call onSubmit callback
    widget.onSubmit(
      _controller.text,
      selectedImages.map((img) => img.path).toList(),
    );

    // Clear input and images after submission
    setState(() {
      selectedImages = [];
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // **Display Selected Images**
        if (selectedImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedImages.map((image) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        // Rounded corners
                        child: Image.file(
                          File(image.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImages.remove(image);
                              _updateImages();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

        // **Input Field with Image Picker**
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: double.infinity,
          height: 66,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: widget.isComment
                                  ? 'viết phản hồi...'
                                  : 'Nhập tin nhắn...',
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.333,
                              color: const Color(0xff536471),
                            ),
                            maxLines: 1,
                            onChanged: (value) {
                              widget.onMessageChanged(
                                  value,
                                  selectedImages
                                      .map((img) => img.path)
                                      .toList());
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: IconButton(
                            icon: SvgPicture.asset(
                              "assets/icons/iconimage.svg",
                              fit: BoxFit.cover,
                            ),
                            onPressed: pickImages,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/send.svg",
                      fit: BoxFit.cover,
                    ),
                    onPressed: _handleSubmit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
