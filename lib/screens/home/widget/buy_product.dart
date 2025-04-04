import 'package:clbdoanhnhansg/models/product_model.dart';
import 'package:clbdoanhnhansg/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../utils/router/router.name.dart';
import '../../business_information/business_information.dart';
import '../../../utils/Color/app_color.dart';
import 'package:clbdoanhnhansg/utils/icons/app_icons.dart';

class BuyProduct extends StatefulWidget {
  final ProductModel product;
  final String idUser;
  final String avatar_image;
  final String displayName;
  final bool isMe;
  final bool? checkBtn;

  const BuyProduct({
    Key? key,
    required this.product,
    required this.idUser,
    required this.avatar_image,
    required this.displayName,
    this.isMe = false,
    this.checkBtn = false,
  }) : super(key: key);

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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị ảnh sản phẩm (nếu có ảnh trong album, dùng ảnh đầu tiên)
            widget.product.album.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: widget.product.album.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.product.album[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: AppIcons.getIcon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  )
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
                padding: const EdgeInsets.all(12.0),
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
                        color: AppColor.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Phần hiển thị thông tin doanh nghiệp (có thể tĩnh hoặc dựa theo product nếu có)

            widget.checkBtn == true
                ? Container()
                : Container(
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
                                      AppIcons.getBrokenImage(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(widget.displayName),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColor.primaryBlue,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BusinessInformation(
                                                idUser: widget.idUser)));
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: Text(
                                  "Xem",
                                  style: TextStyle(color: AppColor.primaryBlue),
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
      bottomNavigationBar: widget.isMe
          ? null // Empty container if isMe is true
          : Material(
              elevation: 10,
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    // Use a debounce mechanism to prevent multiple taps
                    HapticFeedback
                        .lightImpact(); // Optional: add a light vibration feedback

                    // Avoid using Provider.of directly in the build method
                    Future.microtask(() {
                      Provider.of<ChatProvider>(context, listen: false)
                          .sendMessageBuyNow(
                              widget.product.author.toString(),
                              widget.product.id.toString(),
                              widget.avatar_image,
                              widget.displayName,
                              context);
                    });
                  },
                  child: Ink(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColor.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/icons/i_lien_he.png",
                            width: 32,
                            height: 32,
                            // Optional: cache the image
                            cacheWidth: 32,
                            cacheHeight: 32,
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
