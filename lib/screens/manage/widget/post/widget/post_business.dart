import 'package:flutter/material.dart';

class PostBusinessManage extends StatefulWidget {
  const PostBusinessManage({super.key});

  @override
  State<PostBusinessManage> createState() => _PostBusinessManageState();
}

class _PostBusinessManageState extends State<PostBusinessManage> {
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
              "✨ Nước Uống I-ON Kiềm Cao Cấp Fujiwa - Thùng 24 Chai\n    ✅Giúp thanh lọc cơ thể\n    ✅ Loại bỏ gốc tự do và ngăn vừa lão hóa\n    ✅ Bổ sung vi khoáng chất thiết yếu cho cơ thể\n    ✅ Cải thiện bệnh đường ruột và dạ dày",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/img_1.png",
                  width: MediaQuery.of(context).size.width / 2 - (3 * 10),
                ),
                const SizedBox(
                  width: 10,
                ),
                Image.asset(
                  "assets/images/img_1.png",
                  width: MediaQuery.of(context).size.width / 2 - (3 * 10),
                ),
              ],
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
                      "assets/images/mausanpham.png",
                      width: 88,
                      height: 88,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Nước Uống I-ON Kiềm Cao Cấp Fujiwa - Thùng 24 Chai - Loại 450ml",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            "Chiết khấu 5% hội viên CLB",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "168.000đ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ],
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
                          SizedBox(
                            width: 10,
                          ),
                          const Text("123"),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Image.asset(
                            "assets/icons/ichat.png",
                            width: 24,
                            height: 24,
                          ),
                        ),
                        SizedBox(
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
