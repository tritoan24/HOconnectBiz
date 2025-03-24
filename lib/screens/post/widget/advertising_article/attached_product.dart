import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:clbdoanhnhansg/providers/product_provider.dart';
import '../../../../models/product_model.dart';
import '../../../manage/widget/shop/widget/checkbox.dart';
import '../../../manage/widget/shop/widget/un_checkbox.dart';
import '../../../../utils/router/router.name.dart';

class ProductSelectionScreen extends StatefulWidget {
  final Function(bool)? choice;
  const ProductSelectionScreen({super.key, this.choice});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false)
          .getListProduct(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn sản phẩm đính kèm',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (BuildContext context) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
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
                            child: products.isEmpty
                                ? const Center(
                                    child:
                                        CircularProgressIndicator()) // Hiển thị loading khi chưa có dữ liệu
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: SanPhamDinhKem(
                                          sanPham: products[index],
                                          initialValue: false,
                                          choice: (isSelected) {
                                            // Xử lý khi người dùng chọn hoặc bỏ chọn sản phẩm
                                            print(
                                                '${products[index].title} đã chọn: $isSelected');
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
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
          ],
        ),
      ),
    );
  }
}

class SanPhamDinhKem extends StatefulWidget {
  final Function(bool?)? choice;
  final bool initialValue;
  final ProductModel sanPham;

  const SanPhamDinhKem({
    super.key,
    this.choice,
    required this.initialValue,
    required this.sanPham,
  });

  @override
  State<SanPhamDinhKem> createState() => _SanPhamDinhKemState();
}

class _SanPhamDinhKemState extends State<SanPhamDinhKem> {
  late bool isChoice;

  @override
  void initState() {
    super.initState();
    isChoice = widget.initialValue;
  }

  void _toggleChoice() {
    setState(() {
      isChoice = !isChoice;
    });
    widget.choice?.call(isChoice);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEBF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.sanPham.album.isNotEmpty
                    ? widget.sanPham.album.first
                    : UrlImage.defaultProductImage,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/image_error.jpg',
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sanPham.title,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Chiết khấu ${widget.sanPham.discount}% hội viên CLB',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.sanPham.price.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]}.',
                            )}đ',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleChoice,
                        child: Container(
                          child: isChoice ? const Check() : const UnCheck(),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
