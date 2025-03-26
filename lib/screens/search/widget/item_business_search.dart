import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:flutter/material.dart';
import 'package:clbdoanhnhansg/models/bo_model.dart';

import '../../business_information/business_information.dart';

class BusinessSearchItem extends StatelessWidget {
  final Bo business;

  const BusinessSearchItem({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusinessInformation(
                idUser: business.id,
              ),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
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
                // Logo doanh nghiệp - sửa lại việc hiển thị ảnh
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: business.thumbnail.isNotEmpty
                      ? Image.network(
                          business.thumbnail,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              UrlImage.imageUserDefault,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          UrlImage.imageUserDefault,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
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
                        business.companyName.isNotEmpty
                            ? business.companyName
                            : "Chưa cập nhật",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        business.content.isNotEmpty
                            ? business.content
                            : "Chưa cập nhật",
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
      ),
    );
  }
}
