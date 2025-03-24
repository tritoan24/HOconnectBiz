import 'dart:convert';
import 'dart:io';

import 'package:clbdoanhnhansg/screens/post/widget/advertising_article/advertising_article.dart';
import 'package:clbdoanhnhansg/screens/post/widget/business_opportunity/business_opportunity.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/post_provider.dart';
import '../../utils/enum/loai_bai_dang.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  String loaiBaiDang = "";
  List<String> selectedImages = []; // ảnh bài đăng
  List<ProductModel> selectedProductsList = []; // sản phẩm
  List<Map<String, String>> selectedBusinesses = []; //ngành nghề

  void _handleImagesChanged(List<String> images) {
    setState(() {
      selectedImages = images;
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

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Scaffold(
        backgroundColor: AppColor.backgroundColorApp,
        appBar: AppBar(
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              context.go(AppRoutes.trangChu.replaceFirst(':index', '0'));
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: const Text('Đăng tin mới'),
        ),
        bottomNavigationBar: Material(
          elevation: 10,
          color: Colors.white,
          child: GestureDetector(
            onTap: () {
              // Kiểm tra nếu loại bài đăng đã được chọn, gọi API tạo bài đăng
              if (loaiBaiDang != "") {
                // Lấy dữ liệu từ form và gửi tới API
                _createPost(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Vui lòng chọn loại bài đăng')));
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: loaiBaiDang == "" ? Colors.grey : Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'Đăng bài',
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
                    "Bài đăng",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    hint: const Text(
                      'Chọn loại bài đăng',
                      style: TextStyle(fontSize: 14),
                    ),
                    items: LoaiBaiDang.values
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.value,
                            child: Text(item.value),
                          ),
                        )
                        .toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select gender.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        loaiBaiDang = value!;
                      });
                    },
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.only(right: 8),
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black45,
                      ),
                      iconSize: 24,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        // Add this line to set dropdown menu background to white
                        color: Colors.white,
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  if (loaiBaiDang == LoaiBaiDang.tinQuangCao.value) ...[
                    AdvertisingArticle(
                      formKey: _formKey,
                      onImagesChanged: _handleImagesChanged,
                      onProductsChanged: _handleProductsChanged,
                    ),
                  ],
                  if (loaiBaiDang == LoaiBaiDang.coHoiKinhDoanh.value) ...[
                    BusinessOpportunity(
                      formKey: _formKey,
                      onImagesChanged: _handleImagesChanged,
                      onBusinessChanged: _handleBusinessesChanged,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _createPost(BuildContext context) {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    final title = _formKey.currentState?.value['tieuDe'];
    final content = _formKey.currentState?.value['noiDungBaiDang'];

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

    if (loaiBaiDang == LoaiBaiDang.coHoiKinhDoanh.value &&
        selectedBusinesses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một ngành nghề')),
      );
      return;
    }

    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một ảnh')),
      );
      return;
    }

    if (loaiBaiDang == LoaiBaiDang.tinQuangCao.value &&
        selectedProductsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một sản phẩm')),
      );
      return;
    }

    List<String> productList = selectedProductsList
        .map((product) => product.id ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    List<String> businessList = selectedBusinesses
        .map((business) => business['id'] ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    final post = {
      'title': title,
      'content': content,
      'category': loaiBaiDang == LoaiBaiDang.tinQuangCao.value ? 2 : 1,
      'product': productList,
      'business': businessList,
      'album': selectedImages,
    };

    print(post);

    List<File> files = selectedImages.map((path) => File(path)).toList();

    context.read<PostProvider>().createPostAD(post, context, files: files);
  }
}
