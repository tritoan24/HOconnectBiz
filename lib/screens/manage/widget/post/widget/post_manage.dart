import 'package:flutter/material.dart';

import '../../../../details_image/details_image_screen.dart';

class PostManage extends StatefulWidget {
  final bool isProfile;
  const PostManage({super.key, required this.isProfile});

  @override
  State<PostManage> createState() => _PostManageState();
}

class _PostManageState extends State<PostManage> {
  void _navigateToDetailScreen(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChiTietBaiDang(
          imageList: imageList,
          initialIndex: index,
          companyName: "Công ty TNHH Fujiwa Việt Nam",
          like: 110,
          comment: 32,
          dateTime: "16:18, 04/01/2025",
          description:
              "✨✨✨ Bộ Bàn Ghế Gỗ Gõ Đỏ K3 - Đẳng Cấp và Sang Trọng Cho Không Gian Nhà Bạn\nChống mối mọt tự nhiên\nĐộ bền cao theo thời gian\nMàu sắc vân gỗ đẹp mắt...",
        ),
      ),
    );
  }

  final List<String> imageList = [
    "assets/images/mausanpham3.png",
    "assets/images/mausanpham.png",
    "assets/images/mausanpham4.png",
    "assets/images/mausanpham4.png",
    "assets/images/mausanpham3.png",
    "assets/images/mausanpham3.png",
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15), // Độ bo góc
                    child: Image.asset(
                      "assets/images/logocty.png",
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "Công ty TNHH Fujiwa Việt Nam",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "16:18, 04/01/2025",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Text(
              "✨✨✨ Bộ Bàn Ghế Gỗ Gõ Đỏ K3 - Đẳng Cấp và Sang Trọng Cho Không Gian Nhà Bạn\nChống mối mọt tự nhiên\nĐộ bền cao theo thời gian\nMàu sắc vân gỗ đẹp mắt, nổi bật phong cách hiện đại.\n📞 Liên hệ để biết thêm chi tiết và nhận ưu đãi đặc biệt!\n📲 Hotline/Zalo: 0972008105; 0355590766\n📍 Địa chỉ: 996 Phạm Văn Đồng, Hiệp Bình Chánh, Thủ Đức, Thành phố Hồ Chí Minh",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Ảnh lớn
                  GestureDetector(
                    onTap: () => _navigateToDetailScreen(0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          imageList[0],
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Dãy ảnh nhỏ
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(3, (index) {
                        if (index == 2) {
                          return GestureDetector(
                            onTap: () => _navigateToDetailScreen(index + 1),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    imageList[index + 1],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "+${imageList.length - 3}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () => _navigateToDetailScreen(index + 1),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                imageList[index + 1],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xffD6E9FF),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/mausanpham4.png",
                      width: 88,
                      height: 88,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Nước Uống I-ON Kiềm Cao Cấp Fujiwa - Thùng 24 Chai - Loại 450ml",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Chiết khấu 5% hội viên CLB",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "168.000đ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Image.asset(
                              "assets/icons/icon_hear.png",
                              width: 24,
                              height: 24,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text("123"),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            //
                          },
                          child: Image.asset(
                            "assets/icons/ichat.png",
                            width: 24,
                            height: 24,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text("123"),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: 36,
                    child: GestureDetector(
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            "Đăng ký tham gia",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
