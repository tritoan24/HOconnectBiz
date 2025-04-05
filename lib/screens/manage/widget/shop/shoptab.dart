import 'dart:ffi';
import 'package:clbdoanhnhansg/screens/manage/widget/shop/product_manage.dart';
import 'package:clbdoanhnhansg/screens/manage/widget/shop/widget/button_add.dart';
import 'package:clbdoanhnhansg/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import '../../../../models/product_model.dart';
import 'add_product.dart';
import 'item_product.dart';
import 'package:provider/provider.dart';
import 'package:clbdoanhnhansg/providers/product_provider.dart';

class TabShop extends StatefulWidget {
  final bool isLeading;
  const TabShop({super.key, required this.isLeading});

  @override
  State<TabShop> createState() => _TabShopState();
}

class _TabShopState extends State<TabShop> {
  @override
  Future<void> _handleRefresh() async {
    await Provider.of<ProductProvider>(context, listen: false)
        .getListProduct(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
      // Hiển thị loading khi đang tải dữ liệu
      if (productProvider.isLoading) {
        return Center(
          child: Lottie.asset(
            'assets/lottie/loading.json',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
        );
      }

      // Use the already loaded products from provider instead of calling async methods
      final List<ProductModel> products = widget.isLeading
          ? productProvider.products
          : productProvider.productsByUser;
      // Lọc sản phẩm đã ghim và sản phẩm khác
      final sanPhamGhim = products.where((sp) => sp.isPin ?? false).toList();
      final sanPhamKhac = products.where((sp) => !(sp.isPin ?? false)).toList();

      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sản phẩm đã ghim
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset("assets/icons/pin.svg",
                            fit: BoxFit.cover),
                        const SizedBox(width: 8),
                        const Text('Sản phẩm đã ghim',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16))
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (widget.isLeading)
                      ButtonAdd(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProductManage(products: products)));
                        },
                        label: 'Chỉnh sửa sản phẩm đã ghim',
                      ),
                    if (widget.isLeading) const SizedBox(height: 18),
                    Container(
                      height: sanPhamGhim.isEmpty ? 30 : 268,
                      child: sanPhamGhim.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics:
                                  const AlwaysScrollableScrollPhysics(), // Keep horizontal scrolling
                              itemCount: sanPhamGhim.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 193,
                                  margin: const EdgeInsets.only(right: 10),
                                  child: ItemProduct(
                                    sanPham: sanPhamGhim[index],
                                    isProfile: widget.isLeading,
                                    isCheckbtn: true,
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text('Không có sản phẩm ghim',
                                  style: TextStyles.textStyleNormal12W400)),
                    )
                  ],
                ),
              ),
              sanPhamGhim.isEmpty
                  ? const SizedBox()
                  : const SizedBox(height: 28),

              Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: 140,
                ),
                child: CustomScrollView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sản phẩm khác',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          if (widget.isLeading)
                            ButtonAdd(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddProduct()));
                              },
                              label: 'Thêm sản phẩm',
                            ),
                          if (widget.isLeading) const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    sanPhamKhac.isNotEmpty
                        ? SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              mainAxisExtent: 268,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return ItemProduct(
                                  sanPham: sanPhamKhac[index],
                                  isProfile: widget.isLeading,
                                  isCheckbtn: true,
                                );
                              },
                              childCount: sanPhamKhac.length,
                            ),
                          )
                        : SliverToBoxAdapter(
                            child: Center(
                              child: Text('Không có sản phẩm nào',
                                  style: TextStyles.textStyleNormal12W400),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
