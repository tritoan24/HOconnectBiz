import 'package:clbdoanhnhansg/models/is_join_model.dart';
import 'package:clbdoanhnhansg/providers/bo_provider.dart';
import 'package:clbdoanhnhansg/widgets/button_widget16.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../models/rating_model.dart';
import '../../manage/widget/shop/widget/checkbox.dart';
import '../../manage/widget/shop/widget/un_checkbox.dart';

class RatingScreen extends StatefulWidget {
  final String businessOpportunityId;
  final bool? isBusiness;

  const RatingScreen({
    super.key,
    required this.businessOpportunityId,
    this.isBusiness,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int? selectedRating = 0;
  List<bool> selectedCriteria =
      []; // Danh sách theo dõi trạng thái chọn/bỏ chọn
  List<String> pickedCriteriaIds = [];
  bool showRatingContainer = false;
  bool showInputComment = false;
  TextEditingController commentController = TextEditingController();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCriteria();
    });
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void _loadCriteria() async {
    final provider = Provider.of<BoProvider>(context, listen: false);
    setState(() {
      selectedCriteria =
          List.generate(provider.listCriteriaRating.length, (_) => false);
    });
  }

  Future<void> _submitRating() async {
    if (pickedCriteriaIds.isEmpty) {
      _showErrorSnackBar('Vui lòng chọn tiêu chí');
      return;
    }

    if (!mounted) return;

    setState(() {
      isSubmitting = true;
    });

    final provider = Provider.of<BoProvider>(context, listen: false);

    await provider.submitRating(
      widget.businessOpportunityId,
      pickedCriteriaIds,
      selectedRating!,
      commentController.text.isEmpty ? '' : commentController.text,
      context,
    );

    if (!mounted) return;

    // Bước này đã có trong mã của bạn, nhưng chúng ta đảm bảo
    // rằng nó luôn được gọi để cập nhật dữ liệu trước khi quay lại
    await provider.fetchBoDataById(context, widget.businessOpportunityId);

    if (mounted) {
      setState(() {
        isSubmitting = false;
      });

      _showSuccessSnackBar('Đánh giá đã được gửi thành công');

      // Trả về kết quả true và quay lại ngay lập tức
      Navigator.pop(context, true);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoProvider>(context);
    final criteria = provider.listCriteriaRating;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Đánh giá'),
      ),
      body: provider.isLoading && criteria.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                // Thêm SingleChildScrollView để nội dung có thể cuộn
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (criteria.isNotEmpty) ...[
                      const Text(
                        'Bạn hài lòng với tiêu chí nào sau đây?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(
                        criteria.length,
                        (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCriteria[index] =
                                  !selectedCriteria[index];

                              // ✅ Thêm hoặc xóa ID của tiêu chí khỏi danh sách đã chọn
                              if (selectedCriteria[index]) {
                                pickedCriteriaIds.add(criteria[index].id);
                              } else {
                                pickedCriteriaIds.remove(criteria[index].id);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                selectedCriteria[index]
                                    ? const Check()
                                    : const UnCheck(),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    criteria[index].title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Đánh giá mức độ hài lòng với cơ hội kinh doanh',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!showRatingContainer)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                5,
                                (index) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRating = index + 1;
                                      showRatingContainer = true;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: SvgPicture.asset(
                                      selectedRating != null &&
                                              index < selectedRating!
                                          ? 'assets/icons/staron.svg'
                                          : 'assets/icons/startoff.svg',
                                      width: 32,
                                      height: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            Text('$selectedRating/5',
                                style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                    if (showRatingContainer)
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Đánh giá mức độ hài lòng của bạn với cơ hội kinh doanh',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Rating stars display
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...List.generate(
                                  5,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedRating = index + 1;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: SvgPicture.asset(
                                        index < (selectedRating ?? 0)
                                            ? 'assets/icons/staron.svg'
                                            : 'assets/icons/startoff.svg',
                                        width: 32,
                                        height: 32,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('${selectedRating ?? 0}/5',
                                    style: const TextStyle(fontSize: 20)),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Action buttons
                            if (!showInputComment)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedRating = 0;
                                          showRatingContainer = false;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xffd6e9ff),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Đánh giá lại",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          showInputComment = true;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Viết nhận xét",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            if (showInputComment)
                              Column(
                                children: [
                                  TextField(
                                    controller: commentController,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      hintText: "Viết nhận xét...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    ButtonWidget16(
                      label: isSubmitting ? 'Đang gửi...' : 'Gửi đánh giá',
                      onPressed: (selectedRating != null &&
                              selectedRating! > 0 &&
                              !isSubmitting)
                          ? _submitRating
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Đệm dưới cùng để tránh bàn phím che nút
                  ],
                ),
              ),
            ),
    );
  }
}
