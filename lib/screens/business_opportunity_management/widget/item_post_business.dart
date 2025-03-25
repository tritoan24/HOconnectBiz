import 'package:clbdoanhnhansg/models/bo_model.dart';
import 'package:clbdoanhnhansg/screens/business_opportunity_management/widget/details_post_business.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../utils/router/router.name.dart';

class ItemPostBussiness extends StatelessWidget {
  final Bo bo;
  final bool isInBusiness;

  const ItemPostBussiness(
      {super.key, required this.bo, this.isInBusiness = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Widget targetScreen;
        targetScreen = DetailsPostBusiness(
          idPost: bo.id,
          isInBusiness: isInBusiness,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(bo.authorAvatar),
                    onBackgroundImageError: (_, __) {},
                    child: ClipOval(
                      child: Image.network(
                        bo.authorAvatar,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            UrlImage.errorImage,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bo.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateTimeUtils.formatDateTime(
                    DateTimeUtils.toLocalTime(bo.createdAt!),
                    format: 'dd/MM/yyyy HH:mm'),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                bo.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    bo.avgStar.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${bo.totalCompany} doanh nghiệp)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (bo.album.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    bo.album[0], // Dùng ảnh đầu tiên trong album
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
