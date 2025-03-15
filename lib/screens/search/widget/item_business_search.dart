import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:clbdoanhnhansg/models/bo_model.dart';

class BusinessSearchItem extends StatelessWidget {
  final Bo business;

  const BusinessSearchItem({
    super.key,
    required this.business,
  });

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
              // Logo doanh nghiệp
              business.thumbnail.isNotEmpty
                  ? Image.network(
                      business.thumbnail,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          UrlImage.imageUserDefault,
                          width: 40,
                          height: 40,
                        );
                      },
                    )
                  : Image.asset(
                      UrlImage.imageUserDefault,
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
                    Text(
                      business.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      business.content,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          business.avgStar.toStringAsFixed(1),
                          style: const TextStyle(
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
                          width: 10,
                        ),
                        Text(
                          "(${business.totalCompany} cơ hội kinh doanh)",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        )
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
