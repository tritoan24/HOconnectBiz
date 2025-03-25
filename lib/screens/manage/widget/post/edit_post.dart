import 'dart:convert';
import 'dart:io';

import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../models/business_model.dart';
import '../../../../models/create_post.dart';
import '../../../../models/product_model.dart';
import '../../../../providers/post_provider.dart';
import '../../../../utils/enum/loai_bai_dang.dart';
import '../../../post/widget/advertising_article/advertising_article.dart';
import '../../../post/widget/business_opportunity/business_opportunity.dart';

class EditPost extends StatefulWidget {
  final List<String> imageList;
  final int postType;
  final String description;
  final String postId;
  final String title;
  final bool isBusiness;
  final List<BusinessModel> business;
  final List<ProductModel> product;

  const EditPost({
    Key? key,
    required this.imageList,
    required this.postType,
    required this.description,
    required this.postId,
    required this.title,
    required this.isBusiness,
    required this.business,
    required this.product,
  }) : super(key: key);

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  bool get isBusiness => widget.postType == 1;

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<AdvertisingArticleState> advertisingArticleKey = GlobalKey();
  final GlobalKey<BusinessOpportunityState> businessOpportunityKey =
      GlobalKey();

  late String loaiBaiDang;
  List<String> selectedImages = [];
  List<ProductModel> selectedProductsList = [];
  List<Map<String, String>> selectedBusinesses = [];

  @override
  void initState() {
    super.initState();

    // Initialize values from passed data
    selectedImages = List.from(widget.imageList);

    // Set the post type
    loaiBaiDang = widget.isBusiness
        ? LoaiBaiDang.coHoiKinhDoanh.value
        : LoaiBaiDang.tinQuangCao.value;

    // Initialize products if this is a product post
    if (!widget.isBusiness) {
      selectedProductsList = List.from(widget.product);
    }

    // Initialize businesses if this is a business post
    if (widget.isBusiness) {
      selectedBusinesses =
          widget.business.map((b) => {'id': b.id, 'title': b.title}).toList();
    }
  }

  void _handleImagesChanged(List<String> images) {
    setState(() {
      // selectedImages = images;
      selectedImages = List.from(images);
    });
  }

  void _handleProductsChanged(List<ProductModel> products) {
    setState(() {
      selectedProductsList = products;
    });
  }

  void _handleBusinessesChanged(List<Map<String, String>> businesses) {
    setState(() {
      selectedBusinesses = businesses;
    });
  }

  void _updatePost(BuildContext context) {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    final title = _formKey.currentState?.value['tieuDe'];
    final content = _formKey.currentState?.value['noiDungBaiDang'];

    // Validate required fields
    if (title == null || title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề')),
      );
      return;
    }

    if (content == null || content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung bài đăng')),
      );
      return;
    }

    Map<String, dynamic> imageData;
    List<String> newImagePaths;
    List<String> deletedImages;
    List<String> currentImages;
    List<File> newImageFiles;

    // Get data based on post type
    if (widget.isBusiness) {
      // Business opportunity post
      imageData = businessOpportunityKey.currentState!.getImageData();

      // Format business IDs properly
      List<String> businessList = selectedBusinesses
          .map((business) => business['id'] ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      newImagePaths = imageData['newImages'];
      deletedImages = imageData['deletedImages'];
      currentImages = imageData['selectedImages'];

      //validate ảnh cũ
      if (currentImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ít nhất một ảnh')),
        );
        return;
      }
      // Chuẩn bị danh sách các file ảnh mới cần upload
      List<File> newImageFiles =
          newImagePaths.map((path) => File(path)).toList();

      // Create post data ONLY with business fields
      final Map<String, dynamic> postJson = {
        'title': title,
        'content': content,
        'category': 1,
        'business': businessList,
        'album': currentImages,
      };
      // DON'T include empty product field at all

      print('ảnh mới: $newImagePaths');
      print('ảnh cũ: $currentImages');

      context.read<PostProvider>().editPost(
            context,
            widget.postId,
            CreatePost.fromJson(postJson),
            files: newImageFiles,
            deletedImages: deletedImages,
          );
    } else {
      // Advertising article post
      imageData = advertisingArticleKey.currentState!.getImageData();

      // Extract product IDs
      List<String> productList = selectedProductsList
          .map((product) => product.id ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      newImagePaths = imageData['newImages'];
      deletedImages = imageData['deletedImages'];
      currentImages = imageData['selectedImages'];
      newImageFiles = newImagePaths.map((path) => File(path)).toList();

      if (currentImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ít nhất một ảnh')),
        );
        return;
      }
      // Create post data with ONLY product fields - don't include business field
      final Map<String, dynamic> postJson = {
        'title': title,
        'content': content,
        'category': 2,
        'product': productList,
        'album': currentImages,
      };

      final CreatePost postData = CreatePost.fromJson(postJson);
      print('🔄 EditPost: Post data:');
      print(jsonEncode(postJson));

      context.read<PostProvider>().editPost(
            context,
            widget.postId,
            postData,
            files: newImageFiles,
            deletedImages: deletedImages,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      initialValue: {
        'tieuDe': widget.title,
        'noiDungBaiDang': widget.description,
      },
      child: Scaffold(
        backgroundColor: AppColor.backgroundColorApp,
        appBar: AppBar(
          centerTitle: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: const Text('Sửa bài đăng'),
        ),
        bottomNavigationBar: Material(
          elevation: 10,
          color: Colors.white,
          child: GestureDetector(
            onTap: () => _updatePost(context),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'Cập nhật bài đăng',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Loại bài đăng",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Text(
                          loaiBaiDang,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isBusiness) ...[
                    BusinessOpportunity(
                      key: businessOpportunityKey,
                      formKey: _formKey,
                      onImagesChanged: _handleImagesChanged,
                      onBusinessChanged: _handleBusinessesChanged,
                      initialImages: selectedImages,
                      initialBusinesses: selectedBusinesses,
                    ),
                  ],
                  if (!widget.isBusiness) ...[
                    AdvertisingArticle(
                      key: advertisingArticleKey,
                      formKey: _formKey,
                      onImagesChanged: _handleImagesChanged,
                      onProductsChanged: _handleProductsChanged,
                      initialImages: selectedImages,
                      initialProducts: selectedProductsList,
                    )
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
