import 'package:flutter/material.dart';

class Messenger extends StatefulWidget {
  const Messenger({super.key});

  @override
  State<Messenger> createState() => _MessengerState();
}

class _MessengerState extends State<Messenger> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tin nhắn',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 50, // Đảm bảo Stack không bị giới hạn
                height: 50,
                child: Stack(
                  clipBehavior:
                      Clip.none, // Cho phép phần tử con vượt ra ngoài Stack
                  children: [
                    Image.asset(
                      "assets/icons/img_3.png",
                      width: 40,
                      height: 40,
                    ),
                    Positioned(
                      top: -3, // Đưa số lên trên một chút
                      right: -3, // Đẩy số sang phải để không bị cắt
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "13",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14, // Tăng kích thước chữ
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(),
    );
  }
}
