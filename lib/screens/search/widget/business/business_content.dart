import 'package:flutter/material.dart';

class BusinessContent extends StatefulWidget {
  const BusinessContent({super.key});

  @override
  State<BusinessContent> createState() => _BusinessContentState();
}

class _BusinessContentState extends State<BusinessContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white70,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                "assets/images/Frame 1000007431.png",
                width: 40,
                height: 40,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Công ty TNHH Fujiwa Việt Nam",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Sản phẩm tốt nhất cho sức khỏe từ nước I-on kiềm cao cấp FUJIWA.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          "4.8",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Image.asset(
                          "assets/images/img.png",
                          width: 15,
                          height: 15,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("(12 cơ hội kinh doanh)",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ))
                      ],
                    )
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
