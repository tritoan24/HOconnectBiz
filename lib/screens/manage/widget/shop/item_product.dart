import 'package:clbdoanhnhansg/screens/manage/widget/shop/edit_product.dart';
import 'package:clbdoanhnhansg/widgets/confirmdialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/product_model.dart';
import '../../../../providers/product_provider.dart';
import '../../../../utils/router/router.name.dart';
import '../../../home/widget/buy_product.dart';

final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

class ItemProduct extends StatelessWidget {
  final ProductModel sanPham;
  final bool isProfile;
  final bool? isCheckbtn;
  const ItemProduct(
      {super.key,
      required this.sanPham,
      required this.isProfile,
      this.isCheckbtn = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyProduct(
              product: sanPham,
              idUser: "",
              avatar_image: "",
              displayName: "",
              isMe: isProfile,
              checkBtn: isCheckbtn,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Tránh lỗi tràn
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                sanPham.album.isNotEmpty
                    ? sanPham.album.first
                    : UrlImage.defaultProductImage,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/image_error.jpg',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Expanded(
              // Để tránh lỗi tràn nội dung
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Cân bằng nội dung
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sanPham.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Chiết khấu ${sanPham.discount}% cho hội viên CLB",
                      style: const TextStyle(
                          color: Color(0xFFF1645F), fontSize: 12),
                    ),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            formatCurrency.format(sanPham.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        !isProfile
                            ? const SizedBox()
                            : PopupMenuButton<String>(
                                color: Colors.white,
                                shadowColor: Colors.black,
                                splashRadius: 10,
                                icon: SvgPicture.asset(
                                  "assets/icons/more.svg",
                                  fit: BoxFit.cover,
                                ),
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomConfirmDialog(
                                          content:
                                              'Bạn có chắc chắn muốn xóa sản phẩm không?',
                                          titleButtonLeft: 'Quay lại',
                                          titleButtonRight: 'Xóa',
                                          onConfirm: () {
                                            final productProvider =
                                                Provider.of<ProductProvider>(
                                                    context,
                                                    listen: false);
                                            productProvider.deleteProduct(
                                                context, sanPham.id.toString());
                                          },
                                        );
                                      },
                                    );
                                  } else if (value == "edit") {
                                    // Điều hướng sang màn hình chỉnh sửa với sản phẩm hiện tại
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProduct(
                                          product: sanPham,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text(
                                      'Sửa sản phẩm',
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Xóa sản phẩm',
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
