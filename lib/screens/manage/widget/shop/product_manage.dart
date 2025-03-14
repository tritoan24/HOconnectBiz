import 'dart:math';

import 'package:clbdoanhnhansg/screens/manage/widget/shop/widget/product_edit_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../models/product_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../models/product_model.dart';
import '../../../../providers/product_provider.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';

class ProductManage extends StatefulWidget {
  final List<ProductModel> products;

  const ProductManage({super.key, required this.products});

  @override
  State<ProductManage> createState() => _ProductManageState();
}

class _ProductManageState extends State<ProductManage> {
  late List<ProductModel> _products;

  @override
  void initState() {
    super.initState();
    // Sao chép danh sách sản phẩm để theo dõi trạng thái
    _products = List.from(widget.products);
  }

  // Hàm gửi dữ liệu lên server
  Future<void> _saveToServer() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    // Convert the product list to a list of JSON objects
    final List<Map<String, dynamic>> payload =
        _products.map((product) => product.toJsonEditPin()).toList();

    print("📡 API Request Payload: ${jsonEncode(payload)}");

    // Send the correct list format
    await productProvider.editPinProduct(context, payload);
  }

  // void _updatePinStatus(String productId, bool isPinned) {
  //   setState(() {
  //     final productIndex = _products.indexWhere((p) => p.id == productId);
  //     if (productIndex != -1) {
  //       _products[productIndex] =
  //           _products[productIndex].copyWith(isPin: isPinned);
  //     }
  //   });
  // }
  // Fix: Phương thức cập nhật trạng thái pin đã được sửa
  void _updatePinStatus(String? productId, bool isPinned) {
    if (productId == null) return;

    setState(() {
      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        // Tạo một bản sao của danh sách để đảm bảo widget được rebuild
        final updatedProducts = List<ProductModel>.from(_products);
        updatedProducts[productIndex] =
            updatedProducts[productIndex].copyWith(isPin: isPinned);
        _products = updatedProducts;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pinnedProducts = _products.where((sp) => sp.isPin == true).toList();
    final unpinnedProducts = _products.where((sp) => sp.isPin != true).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý sản phẩm"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryBlue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _saveToServer, // Gọi hàm gửi dữ liệu
            child: Text(
              "Lưu",
              style: GoogleFonts.roboto(fontSize: 12, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.secondaryBlue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(), // Hủy và quay lại
            child: Text(
              "Hủy",
              style: GoogleFonts.roboto(
                  fontSize: 12, color: const Color(0xff006AF5)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/pin.svg",
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sản phẩm đã ghim',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 300,
              child: pinnedProducts.isEmpty
                  ? const Center(child: Text('Chưa có sản phẩm nào được ghim'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pinnedProducts.length,
                      itemBuilder: (context, index) {
                        final product = pinnedProducts[index];
                        return Container(
                          width: 193,
                          margin: const EdgeInsets.only(right: 10),
                          child: ProductEditItem(
                            key: ValueKey('pinned-${product.id}'),
                            sanPham: product,
                            onPinToggle: (isPinned) {
                              _updatePinStatus(product.id, isPinned);
                            },
                          ),
                        );
                      },
                    ),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Sản phẩm khác',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(
              height: unpinnedProducts.isEmpty ? 100 : 280,
              child: unpinnedProducts.isEmpty
                  ? const Center(child: Text('Tất cả sản phẩm đã được ghim'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        mainAxisExtent: 268,
                      ),
                      itemCount: unpinnedProducts.length,
                      itemBuilder: (context, index) {
                        final product = unpinnedProducts[index];
                        return ProductEditItem(
                          key: ValueKey('unpinned-${product.id}'),
                          sanPham: product,
                          onPinToggle: (isPinned) {
                            _updatePinStatus(product.id, isPinned);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

