import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';

class InputFileImages extends StatefulWidget {
  final GlobalKey<FormBuilderState> formKey;
  final Function(List<String>) onImagesChanged;
  final List<String>? initialImages;

  const InputFileImages({
    super.key,
    required this.formKey,
    required this.onImagesChanged,
    this.initialImages,
  });

  @override
  State<InputFileImages> createState() => _InputFileImagesState();
}

class _InputFileImagesState extends State<InputFileImages> {
  late List<XFile> selectedImages;
  final ImagePicker _picker = ImagePicker();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    selectedImages = [];
    // Sẽ xử lý initialImages trong didChangeDependencies để tránh lỗi
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      if (widget.initialImages != null && widget.initialImages!.isNotEmpty) {
        try {
          List<XFile> validFiles = [];
          for (String path in widget.initialImages!) {
            // Xử lý cả URL và file local
            if (path.startsWith('http://') || path.startsWith('https://')) {
              // URL - thêm vào như là
              validFiles.add(XFile(path));
            } else if (File(path).existsSync()) {
              // File local - kiểm tra tồn tại
              validFiles.add(XFile(path));
            }
          }
          if (validFiles.isNotEmpty) {
            setState(() {
              selectedImages = validFiles;
            });
            // Gọi _updateImages sau khi build hoàn tất
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateImages();
            });
          }
        } catch (e) {
          print("Lỗi khi khởi tạo ảnh: $e");
        }
      }
    }
  }

  // Thêm hàm _updateImages
  void _updateImages() {
    List<String> imagePaths = selectedImages.map((img) => img.path).toList();
    widget.onImagesChanged(imagePaths);
  }

  // Hàm kiểm tra file có hợp lệ không
  bool isValidImageFile(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return true; // URL hợp lệ
    }
    return File(path).existsSync(); // Kiểm tra file local
  }

  // Hàm chọn nhiều ảnh từ thư viện
  Future<void> pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        setState(() {
          selectedImages.addAll(images);
        });
        _updateImages();
      }
    } catch (e) {
      print("Lỗi khi chọn ảnh: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return selectedImages.isEmpty
        ? GestureDetector(
            onTap: pickImages,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icons/iPhoto.png",
                    width: 32,
                  ),
                  const Text('Đăng ảnh sản phẩm'),
                ],
              ),
            ),
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: pickImages,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffEBF4FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: 100,
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/icons/iPhoto.png", width: 32),
                        const SizedBox(height: 6),
                        const Text('Thêm ảnh'),
                      ],
                    ),
                  ),
                ),
                ...selectedImages.map((image) {
                  bool isNetworkImage = isValidImageFile(image.path) &&
                      (image.path.startsWith('http://') ||
                          image.path.startsWith('https://'));

                  return Row(
                    children: [
                      const SizedBox(width: 7), // 5px horizontal spacing
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: !isNetworkImage
                                ? Image.file(
                                    File(image.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey,
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                  )
                                : Image.network(
                                    image.path,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImages.remove(image);
                                });
                                _updateImages();
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: const Icon(Icons.close,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
  }
}
