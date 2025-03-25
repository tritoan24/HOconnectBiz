// models/opportunity_rating.dart
import 'package:clbdoanhnhansg/models/auth_model.dart';
import 'package:clbdoanhnhansg/models/is_join_model.dart';
import 'package:clbdoanhnhansg/screens/business_opportunity_management/widget/rating.dart';
import 'package:clbdoanhnhansg/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../providers/bo_provider.dart';
import '../../../widgets/button_widget16.dart';
import '../../manage/widget/shop/widget/checkbox.dart';
import '../../manage/widget/shop/widget/un_checkbox.dart';

// Star rating widget (unchanged)
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final double spacing;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 24,
    this.color = Colors.amber,
    this.spacing = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
          child: SvgPicture.asset(
            index < rating
                ? 'assets/icons/staron.svg'
                : 'assets/icons/startoff.svg',
            width: size,
            height: size,
          ),
        );
      }),
    );
  }
}

class OpportunityRating2 extends StatefulWidget {
  final String idPost;
  final List<IsJoin> ratings;

  const OpportunityRating2({
    Key? key,
    required this.idPost,
    required this.ratings,
  }) : super(key: key);

  @override
  State<OpportunityRating2> createState() => _OpportunityRating2State();
}

class _OpportunityRating2State extends State<OpportunityRating2> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoProvider>(context);
    //in ra tiêu chí đánh giá

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Chi tiết đánh giá cơ hội'),
        ),
        body: provider.isLoadingRating
            ? const Center(child: CircularProgressIndicator())
            : Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: widget.ratings.isEmpty
                          ? const Center(
                              child: Text('Chưa có đánh giá nào'),
                            )
                          : ListView.builder(
                              itemCount: widget.ratings.length,
                              itemBuilder: (context, index) {
                                // Only build cards for entries that have reviews
                                if (widget.ratings[index].review == null) {
                                  return const SizedBox.shrink();
                                }
                                return _buildRatingCard(
                                  widget.ratings[index],
                                  // criteria,
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ButtonWidget16(
                        label: 'Đánh giá cơ hội kinh doanh',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RatingScreen(
                                businessOpportunityId: widget.idPost,
                              ),
                            ),
                          ).then((_) {});
                        },
                      ),
                    )
                  ],
                )));
  }

  Widget _buildRatingCard(
    IsJoin isJoin,
    // List<Rating> criteria
  ) {
    // Guard clause already in the ListView.builder
    final review = isJoin.review!;

    // Handle case where user might be null
    final user = isJoin.user;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompanyInfo(user!),
            const SizedBox(height: 16),
            _buildCriteria(review
                // criteria
                ),
            const SizedBox(height: 16),
            _buildRatingSection(review.star.toInt()),
            if (review.content != null && review.content!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.content!, style: TextStyles.textStyleNormal14W400),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfo(Author user) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: user.avatarImage.isNotEmpty
              ? NetworkImage(user.avatarImage)
              : null,
          backgroundColor: user.avatarImage.isEmpty
              ? Colors.grey.shade300
              : Colors.transparent,
          child: user.avatarImage.isEmpty
              ? Text(user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : '?')
              : null,
          radius: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (user.companyName != null && user.companyName!.isNotEmpty)
                Text(
                  user.companyName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCriteria(
    Review review,
    // List<Rating> criteria
  ) {
    // if (criteria.isEmpty) {
    //   return const Padding(
    //     padding: EdgeInsets.symmetric(vertical: 8.0),
    //     child: Text('Không có tiêu chí nào được hiển thị'),
    //   );
    // }
    final provider = Provider.of<BoProvider>(context);
    final criteria = provider.listCriteriaRating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiêu chí',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...criteria.map((criteriaItem) {
          // Check if this criteria was picked in the review
          final isPicked = review.picked.contains(criteriaItem.id);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                isPicked ? const Check() : const UnCheck(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    criteriaItem.title,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRatingSection(int rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mức độ hài lòng',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StarRating(rating: rating.toDouble()),
              const SizedBox(width: 30),
              Text('$rating/5',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }
}
