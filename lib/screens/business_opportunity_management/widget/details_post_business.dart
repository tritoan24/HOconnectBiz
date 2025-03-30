import 'package:clbdoanhnhansg/models/auth_model.dart';
import 'package:clbdoanhnhansg/models/is_join_model.dart';
import 'package:clbdoanhnhansg/providers/auth_provider.dart';
import 'package:clbdoanhnhansg/screens/business_opportunity_management/widget/edit_member.dart';
import 'package:clbdoanhnhansg/screens/business_opportunity_management/widget/rating.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:clbdoanhnhansg/widgets/horizontal_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../providers/bo_provider.dart';
import '../../../widgets/button_widget16.dart';
import '../../../widgets/confirmdialog.dart';
import '../../../widgets/text_styles.dart';
import 'member_update_revenue_item.dart';
import 'opportunityrating.dart';
import 'item_post_business.dart';
import 'package:lottie/lottie.dart';
import 'member_item.dart';

class DetailsPostBusiness extends StatefulWidget {
  final String idPost;

  const DetailsPostBusiness({
    super.key,
    required this.idPost,
  });

  @override
  State<DetailsPostBusiness> createState() => _DetailsPostBusinessState();
}

class _DetailsPostBusinessState extends State<DetailsPostBusiness> {
  late String currentUserId = "";
  late bool isInBusiness;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final boProvider = Provider.of<BoProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      boProvider.fetchBoDataById(context, widget.idPost);
      boProvider.fetchListCriteria(context);
      currentUserId = (await authProvider.getuserID())!;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final boProvider = Provider.of<BoProvider>(context);

    final bo = boProvider.selectedBo;
    final members = boProvider.members;
    final lists = boProvider.lists;
    final author = boProvider.author;

    IsJoin? getCurrentUserMember(List<IsJoin> list, String currentUserId) {
      if (list.isEmpty) {
        return null;
      }

      for (var item in list) {
        if (item.user?.id == currentUserId) {
          return item; // Return the entire member object for the current user
        }
      }

      return null;
    }

    List<IsJoin> otherMembers = [];
    IsJoin? currentUserMember;
// Separate current user from others
    for (var member in members) {
      if (member.user?.id == currentUserId) {
        currentUserMember = member;
      } else {
        otherMembers.add(member);
      }
    }
    //nếu
    author.id == currentUserId ? isInBusiness = true : isInBusiness = false;

    print('trạng thái is business: ${isInBusiness}');

    return Scaffold(
      backgroundColor: const Color(0xffF4F5F6),
      appBar: AppBar(
        title: Text(bo?.title ?? "Chi tiết bài viết"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            icon: SvgPicture.asset("assets/icons/more.svg", fit: BoxFit.cover),
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            itemBuilder: (BuildContext context) {
              if (isInBusiness) {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'end_strategy',
                    child: Text(
                      'Kết thúc chiến lược',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  )
                ];
              } else {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'leave_club',
                    child: Text(
                      'Rời khỏi nhóm',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  )
                ];
              }
            },
            onSelected: (String value) {
              if (value == 'end_strategy') {
                // Kết thúc chiến lược
                showDialog(
                  context: context,
                  builder: (context) => CustomConfirmDialog(
                    titleButtonLeft: "Hủy",
                    titleButtonRight: "Xác nhận",
                    content:
                        "Xác nhận kết thúc chiến lược này? Bạn sẽ không thể thay đổi sau khi kết thúc.",
                    onConfirm: () {
                      Navigator.pop(context);
                      boProvider.endBoData(context, widget.idPost);
                    },
                  ),
                );
              } else if (value == 'leave_club') {
                // Rời khỏi CLB
                showDialog(
                  context: context,
                  builder: (context) => CustomConfirmDialog(
                    titleButtonLeft: "Hủy",
                    titleButtonRight: "Xác nhận",
                    content:
                        "Bạn có chắc chắn muốn rời khỏi nhóm không? Hành động này không thể hoàn tác.",
                    onConfirm: () {
                      Navigator.pop(context);
                      boProvider.leaveBo(context, widget.idPost);
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: boProvider.isLoadingBoDetail
          ? Center(
              child: Lottie.asset(
                'assets/lottie/loading.json',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            )
          : bo == null
              ? Center(child: Text(boProvider.errorMessageBoDetail))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderSection(
                          owner: bo.authorName,
                          ownerAvatar: bo.authorAvatar,
                          totalRevenue: bo.revenue,
                          rating: bo.avgStar,
                          ratedBy: bo.totalReview,
                          memberCount: bo.totalBo,
                          data: lists,
                          member: members,
                          author: author ?? AuthorBusiness.defaultAuthor(),
                          idPost: widget.idPost,
                          isBusiness: isInBusiness,
                          currentUserId: currentUserId,
                        ),
                        const SizedBox(height: 8),
                        MemberListSection(
                          idPost: widget.idPost,
                          members: lists,
                          currentUserId: currentUserId,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final String owner;
  final String ownerAvatar;
  final double totalRevenue;
  final double rating;
  final int ratedBy;
  final int memberCount;
  final List<IsJoin> data;
  final List<IsJoin> member;
  final AuthorBusiness author;
  final String idPost;
  final bool isBusiness;
  final String currentUserId;

  const _HeaderSection({
    required this.owner,
    required this.ownerAvatar,
    required this.totalRevenue,
    required this.rating,
    required this.ratedBy,
    required this.memberCount,
    required this.data,
    required this.member,
    required this.author,
    required this.idPost,
    required this.isBusiness,
    required this.currentUserId,
  });

  double? getUserStar(List<IsJoin> list, String userId) {
    if (list.isEmpty) {
      print("Danh sách trống, không thể tìm user.");
      return null;
    }
    for (var item in list) {
      if (item.user?.id == userId && item.review != null) {
        print('Tìm thấy user: ${item.user?.id}, star: ${item.review?.star}');
        return item.review?.star; // Trả về số sao nếu có review
      }
    }
    print("Không tìm thấy user trong danh sách.");
    return null; // Không tìm thấy user hoặc không có review
  }

  @override
  Widget build(BuildContext context) {
    double? userStar = getUserStar(data, currentUserId.toString());
    print("userStar: $currentUserId");
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                "assets/icons/user_profile.svg",
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              Text("Chủ sở hữu", style: TextStyles.textStyleNormal14W500),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    ClipOval(
                      child: Image.network(
                        ownerAvatar,
                        fit: BoxFit.cover,
                        width: 35,
                        height: 35,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            UrlImage.errorImage,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        owner,
                        style: TextStyles.textStyleNormal14W400,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const HorizontalDivider(),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.monetization_on,
            label: "Tổng doanh thu",
            isIcon: true,
            value: totalRevenue,
          ),
          const SizedBox(height: 12),
          const HorizontalDivider(),
          _buildRatingRow(context, idPost),
          !isBusiness
              ? (userStar != null
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Đã đánh giá '),
                            StarRating(rating: userStar),
                          ]),
                    )
                  : Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ButtonWidget16(
                        label: 'Đánh giá cơ hội kinh doanh',
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RatingScreen(
                                      businessOpportunityId: idPost,
                                    )),
                          );

                          if (result == true) {
                            final provider =
                                Provider.of<BoProvider>(context, listen: false);
                            await provider.fetchBoDataById(context, idPost);
                          }
                        },
                      ),
                    ))
              : const SizedBox.shrink(),
          const HorizontalDivider(),
          const SizedBox(height: 8),
          _buildMemberCountRow(context, data, member, author, isBusiness),
        ],
      ),
    );
  }

  Widget _buildRatingRow(BuildContext context, String idPost) {
    double? userStar = getUserStar(data, currentUserId.toString());
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons/idanhgia.svg",
          width: 24,
          height: 24,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "Đánh giá cơ hội",
            style: TextStyles.textStyleNormal14W500,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyles.textStyleNormal14W500,
        ),
        const Icon(Icons.star, color: Colors.yellow),
        Text(
          "($ratedBy doanh nghiệp)",
          style: TextStyles.textStyleNormal12W400,
        ),
        Container(
          height: 24,
          width: 24,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x0dee2e6f), width: 1.0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OpportunityRating2(
                            ratings: data,
                            idPost: idPost,
                            userStar: userStar,
                            isInBusiness: isBusiness,
                          )));
            },
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 17,
              color: Colors.black,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCountRow(BuildContext context, List<IsJoin> data,
      List<IsJoin> member, AuthorBusiness author, bool isBusiness) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons/documenttext.svg",
          width: 24,
          height: 24,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 8),
        Text(
          "Thành viên tham gia",
          style: TextStyles.textStyleNormal14W500,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 8),
        if (isBusiness)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              data.length.toString(),
              style: TextStyles.textStyleNormal12W400White,
            ),
          ),
        const Spacer(),
        if (isBusiness)
          IconButton(
            onPressed: () async {
              // Chuyển đến màn chỉnh sửa thành viên
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditMember(data: data, member: member, author: author),
                ),
              );
            },
            icon: SvgPicture.asset(
              "assets/icons/iconedit.svg",
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}

class MemberListSection extends StatefulWidget {
  final String idPost;
  final List<IsJoin> members;
  final String currentUserId;

  const MemberListSection({
    Key? key,
    required this.idPost,
    required this.members,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<MemberListSection> createState() => _MemberListSectionState();
}

class _MemberListSectionState extends State<MemberListSection> {
  late IsJoin? currentUserMember;
  late List<IsJoin> otherMembers;

  @override
  void initState() {
    super.initState();
    _separateMembers();
  }

  @override
  void didUpdateWidget(MemberListSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.members != widget.members ||
        oldWidget.currentUserId != widget.currentUserId) {
      _separateMembers();
    }
  }

  void _separateMembers() {
    currentUserMember = null;
    otherMembers = [];

    for (var member in widget.members) {
      if (member.user?.id == widget.currentUserId) {
        currentUserMember = member;
      } else {
        otherMembers.add(member);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current User Section
        if (currentUserMember != null) _buildCurrentUserSection(),

        // Other Members Section
        _buildOtherMembersSection(),
      ],
    );
  }

  Widget _buildCurrentUserSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: UpdateRevenueForm(
            initialRevenue: currentUserMember!.revenue?.toDouble() ?? 0.0,
            initialDeduction: currentUserMember!.deduction?.toDouble() ?? 0.0,
            member: currentUserMember!,
            onSave: (revenue, deduction, status) async {
              // Kiểm tra xem widget vẫn còn mounted hay không
              if (!mounted) {
                print("Widget đã bị hủy, bỏ qua cập nhật");
                return;
              }

              final boProvider =
                  Provider.of<BoProvider>(context, listen: false);

              // Check if values actually changed before making the API call
              double currentRevenue =
                  currentUserMember!.revenue?.toDouble() ?? 0.0;
              double currentDeduction =
                  currentUserMember!.deduction?.toDouble() ?? 0.0;
              int currentStatus = currentUserMember!.status ?? 0;

              bool hasChanges = revenue != currentRevenue ||
                  deduction != currentDeduction ||
                  status != currentStatus;

              if (!hasChanges) {
                print("✅ Không có thay đổi, bỏ qua cập nhật");
                return;
              }

              if (revenue < deduction) {
                if (mounted) {
                  // Kiểm tra lại trước khi hiển thị dialog
                  showDialog(
                    context: context,
                    builder: (context) => CustomConfirmDialog(
                      titleButtonLeft: "Hủy",
                      titleButtonRight: "Xác nhận",
                      content:
                          "Doanh thu không thể nhỏ hơn chi phí. Vui lòng kiểm tra lại.",
                      onConfirm: () {
                        Navigator.of(context).pop(); // Đóng dialog
                      },
                    ),
                  );
                }
              } else {
                showDialog(
                  context: context,
                  builder: (context) => CustomConfirmDialog(
                    titleButtonLeft: "Hủy",
                    titleButtonRight: "Xác nhận",
                    content:
                        "Bạn có chắc chắn muốn cập nhật doanh thu và trích quỹ không?",
                    onConfirm: () async {
                      try {
                        await boProvider.updateRevenue(
                          widget.idPost,
                          status,
                          revenue.toInt(),
                          deduction.toInt(),
                          context,
                        );

                        // Kiểm tra lại xem widget có còn mounted không
                        if (mounted) {
                          setState(() {}); // Refresh UI after update

                          //hiển thị thông báo thành công
                        }
                      } catch (e) {
                        print("❌ Error updating revenue: $e");
                        // Có thể hiển thị thông báo lỗi nếu widget vẫn mounted
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Lỗi khi cập nhật: $e")),
                          );
                        }
                      }
                    },
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOtherMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Duyệt danh sách và lấy cả index
        ...otherMembers.asMap().entries.map((entry) {
          int index = entry.key; // Lấy index của phần tử
          IsJoin member = entry.value; // Lấy giá trị của phần tử

          return MemberCard(
            member: member,
            isLast: index ==
                otherMembers.length - 1, // Kiểm tra nếu là thành viên cuối
          );
        }).toList(), // Chuyển đổi Iterable thành List
      ],
    );
  }
}
