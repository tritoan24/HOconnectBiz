import 'package:clbdoanhnhansg/models/product_model.dart';
import 'package:clbdoanhnhansg/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../utils/router/router.name.dart';
import '../../manage/manage.dart';

class BuyProduct extends StatefulWidget {
  final ProductModel product;
  final String avatar_image;
  final String displayName;

  const BuyProduct(
      {Key? key,
      required this.product,
      required this.avatar_image,
      required this.displayName})
      : super(key: key);

  @override
  State<BuyProduct> createState() => _BuyProductState();
}

class _BuyProductState extends State<BuyProduct> {
  static final formatCurrency =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F6),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F5F6),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị ảnh sản phẩm (nếu có ảnh trong album, dùng ảnh đầu tiên)
            widget.product.album.isNotEmpty
                ? Image.network(widget.product.album.first)
                : Container(),
            const SizedBox(height: 10),
            // Hiển thị thông tin sản phẩm
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.title,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    // Nếu có discount, hiển thị chiết khấu
                    Text("Chiết khấu ${widget.product.discount}% hội viên CLB",
                        style: TextStyles.textStyleNormal12W400Grey),
                    const SizedBox(height: 10),
                    Text(
                      formatCurrency.format(widget.product.price),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xffDC1F18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Phần hiển thị thông tin doanh nghiệp (có thể tĩnh hoặc dựa theo product nếu có)
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            widget.avatar_image.isNotEmpty
                                ? widget.avatar_image
                                : UrlImage.errorImage,
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(widget.displayName),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xff006AF5),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const QuanLyView(isLeading: true)));
                        },
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Text(
                            "Xem",
                            style: TextStyle(color: Color(0xff006AF5)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Mô tả chi tiết sản phẩm
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Mô tả chi tiết sản phẩm",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(widget.product.description ?? ""),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Material(
        elevation: 10,
        color: Colors.white,
        // onTap: () {
        //   Navigator.push(context,
        //       MaterialPageRoute(builder: (context) => const TinMuaHang()));
        // },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xff006AF5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: GestureDetector(
              onTap: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => const TinMuaHang()));
                Provider.of<ChatProvider>(context, listen: false)
                    .sendMessageBuyNow(widget.product.author.toString(),
                        widget.product.id.toString(), context);
                // GoRouter.of(context).go('/chat');
              },
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/i_lien_he.png",
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Liên hệ ngay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

