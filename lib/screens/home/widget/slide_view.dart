import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/router/router.name.dart';
import '../../../models/product_model.dart';

class SlideView extends StatelessWidget {
  final String postId;
  final String displayName;
  final String avatarImage;
  final String title;
  final String content;
  final List<String> images;
  final List<ProductModel> product;

  const SlideView({
    Key? key,
    required this.postId,
    required this.displayName,
    required this.avatarImage,
    required this.title,
    required this.content,
    required this.images,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // VÙNG 1: HEADER - Chiều cao cố định
            _buildHeader(context),

            const SizedBox(height: 8),

            // VÙNG 2: CONTENT - Chiều cao linh hoạt với giới hạn dòng
            _buildContent(),

            const SizedBox(height: 10),

            // VÙNG 3: IMAGE LIST - Chiều cao cố định
            _buildImageList(),

            const SizedBox(height: 5),

            // VÙNG 4: PRODUCT - Chiều cao cố định
            _buildProductSection(context),
          ],
        ),
      ),
    );
  }

  // VÙNG 1: HEADER
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 50, // Chiều cao cố định cho header
      child: GestureDetector(
        onTap: () {
          context.push(
              AppRoutes.thongTinDoanhNghiep.replaceFirst(":isLeading", "true"));
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                avatarImage.isNotEmpty
                    ? avatarImage
                    : "assets/images/logocty.png",
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayName,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // VÙNG 2: CONTENT
  Widget _buildContent() {
    return Container(
      constraints: const BoxConstraints(minHeight: 20, maxHeight: 65),
      width: double.infinity,
      alignment: Alignment.topLeft,
      child: Text(
        content,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // VÙNG 3: IMAGE LIST
  Widget _buildImageList() {
    if (images.isEmpty) {
      return const SizedBox(height: 0);
    }

    return Container(
      height: 80, // Chiều cao cố định cho danh sách ảnh
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length > 4 ? 4 : images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                images[index],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              ),
            ),
          );
        },
      ),
    );
  }

  // VÙNG 4: PRODUCT
  Widget _buildProductSection(BuildContext context) {
    if (product.isEmpty) {
      return const SizedBox(height: 0);
    }

    return Container(
      height: 104, // Chiều cao cố định cho phần sản phẩm
      child: GestureDetector(
        onTap: () {
          context.push(AppRoutes.muaSanPham);
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xffD6E9FF),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.first.album.isNotEmpty
                      // || product.first.album.first.isN
                      ? product.first.album.first
                      : "https://img.freepik.com/free-vector/oops-404-error-with-broken-robot-concept-illustration_114360-1932.jpg?t=st=1741793632~exp=1741797232~hmac=997f6ba517b1e839d784a86db6612d63e453d5d9af66caa49f429763a5ebdc66&w=740",
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      product.first.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w400),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${product.first.price}đ",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                        Container(
                          width: 82,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "Mua ngay",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
