import 'dart:io';

import 'package:clbdoanhnhansg/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:clbdoanhnhansg/providers/product_provider.dart';
import '../../../../models/product_model.dart';
import '../../../../widgets/input_file_images.dart';
import '../../../../widgets/input_text.dart';
import '../../../../widgets/input_text_area.dart';
import '../../../../widgets/text_styles.dart';
import '../../../chat/create_order.dart';
import 'attached_product.dart';
import 'package:provider/provider.dart';

class AdvertisingArticle extends StatefulWidget {
  final GlobalKey<FormBuilderState> formKey;
  final Function(List<String>) onImagesChanged;
  final Function(List<ProductModel>) onProductsChanged;
  final List<String>? initialImages;
  final List<ProductModel>? initialProducts;

  const AdvertisingArticle({
    super.key,
    required this.formKey,
    required this.onImagesChanged,
    required this.onProductsChanged,
    this.initialImages,
    this.initialProducts,
  });

  @override
  State<AdvertisingArticle> createState() => _AdvertisingArticleState();
}

class _AdvertisingArticleState extends State<AdvertisingArticle> {
  int content = 1;
  int category = 1;

  // Product tracking
  List<ProductModel> selectedProductsList = [];
  Map<ProductModel, bool> selectedProducts = {};
  Map<ProductModel, int> productQuantities = {};

  // Image tracking
  List<String> selectedImages = []; // Currently selected images
  List<String> deletedImages = []; // Images to be deleted
  List<String> originalImages = []; // Original images from product
  List<String> newImages = []; // New images added during edit

  final GlobalKey<_AdvertisingArticleState> _advertisingArticleKey =
      GlobalKey<_AdvertisingArticleState>();

  @override
  void initState() {
    super.initState();

    // Initialize selected images from props
    if (widget.initialImages != null && widget.initialImages!.isNotEmpty) {
      originalImages = List.from(widget.initialImages!);
      selectedImages = List.from(widget.initialImages!);
    }

    // Initialize selected products from props
    if (widget.initialProducts != null && widget.initialProducts!.isNotEmpty) {
      selectedProductsList = List.from(widget.initialProducts!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false)
          .getListProduct(context);
      final products =
          Provider.of<ProductProvider>(context, listen: false).products;

      // Initialize product selection maps
      for (var product in products) {
        // Check if product is in initial selected products
        bool isSelected = false;
        if (widget.initialProducts != null) {
          isSelected = widget.initialProducts!.any((p) => p.id == product.id);
        }
        selectedProducts[product] = isSelected;
        productQuantities[product] = 1;
      }

      // Update UI
      setState(() {});
    });
  }

  // Updated image handling method
  void _onImagesSelected(List<String> paths) {
    setState(() {
      // Determine which images are new (not in originalImages)
      newImages = paths
          .where((path) =>
              !path.startsWith('http') && !originalImages.contains(path))
          .toList();

      // Determine which original images were deleted
      deletedImages =
          originalImages.where((path) => !paths.contains(path)).toList();

      // Update main selected images list
      selectedImages = paths;
      widget.onImagesChanged(paths);
    });
  }

  // Get prepared data for API submission
  Map<String, dynamic> getPostData() {
    final title = widget.formKey.currentState?.value['tieuDe'];
    final content = widget.formKey.currentState?.value['noiDungBaiDang'];

    // Product IDs for submission
    List<String> productList = selectedProductsList
        .map((product) => product.id ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    // Determine which images to retain (URLs)
    List<String> retainedUrlImages =
        selectedImages.where((path) => path.startsWith('http')).toList();

    return {
      'title': title,
      'content': content,
      'category': 2, // Advertising post type
      'product': productList,
      'album': retainedUrlImages,
    };
  }

  // Get file objects from new images
  List<File> getNewImageFiles() {
    return newImages
        .where((path) => !path.startsWith('http'))
        .map((path) => File(path))
        .toList();
  }

  void updateSelectedProducts() {
    // Lấy danh sách sản phẩm từ provider
    final products =
        Provider.of<ProductProvider>(context, listen: false).products;
    setState(() {
      selectedProductsList = products
          .where((product) => selectedProducts[product] == true)
          .toList();
      widget.onProductsChanged(selectedProductsList);
    });
  }

  void updateQuantity(ProductModel product, int newQuantity) {
    setState(() {
      productQuantities[product] = newQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final productsList = productProvider.products;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        const InputText(
          name: 'tieuDe',
          title: "Tiêu đề",
          hintText: "Nhập tên sản phẩm",
        ),
        const SizedBox(
          height: 20,
        ),
        const InputTextArea(
          title: "Nội dung bài đăng",
          name: 'noiDungBaiDang',
          hintText: "Nhập mô tả chi tiết sản phẩm",
        ),
        const SizedBox(
          height: 20,
        ),
        const Text("Ảnh bài đăng",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            )),
        const SizedBox(
          height: 10,
        ),
        InputFileImages(
          formKey: widget.formKey,
          onImagesChanged: _onImagesSelected,
          initialImages: selectedImages,
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "Chọn sản phẩm đính kèm",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              isDismissible: false,
              context: context,
              enableDrag: false,
              builder: (BuildContext context) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Danh sách sản phẩm",
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    updateSelectedProducts();
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: productsList.isEmpty
                                ? Center(
                                    child: Text('Không có sản phẩm nào',
                                        style:
                                            TextStyles.textStyleNormal12W400))
                                : ListView.builder(
                                    itemCount: productsList.length,
                                    itemBuilder: (context, index) {
                                      final product = productsList[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: SanPhamDinhKem(
                                          sanPham: product,
                                          choice: (value) {
                                            setState(() {
                                              selectedProducts[product] =
                                                  value ?? false;
                                            });
                                          },
                                          initialValue:
                                              selectedProducts[product] ??
                                                  false,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFEBF4FF),
            ),
            child: Text(
              'Thêm sản phẩm',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: Colors.blueAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        // Hiển thị danh sách sản phẩm đã chọn
        if (selectedProductsList.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 300, // Chiều cao cố định của ListView
            child: ListView.separated(
              physics: AlwaysScrollableScrollPhysics(), // Cho phép cuộn
              itemCount: selectedProductsList.length,
              itemBuilder: (context, index) {
                final product = selectedProductsList[index];
                return ItemProductCreate(
                  sanPham: product,
                  quantity: productQuantities[product] ?? 1,
                  onQuantityChanged: (newQuantity) {
                    updateQuantity(product, newQuantity);
                  },
                );
              },
              separatorBuilder: (context, index) =>
                  SizedBox(height: 16), // Khoảng cách giữa item
            ),
          )
        ],
      ],
    );
  }
}
