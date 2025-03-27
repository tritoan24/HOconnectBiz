import 'package:clbdoanhnhansg/models/is_join_model.dart';
import 'package:clbdoanhnhansg/utils/router/router.name.dart';
import 'package:clbdoanhnhansg/widgets/horizontal_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../../widgets/text_styles.dart';

// Shared Widgets
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final bool isIcon;

  const InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.isIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String displayValue =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(value);

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              isIcon
                  ? SvgPicture.asset(
                      "assets/icons/coin.svg",
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    )
                  : Container(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyles.textStyleNormal14W500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                displayValue,
                style: TextStyles.textStyleNormal14W400,
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatusTag extends StatelessWidget {
  final String status;

  const StatusTag({
    Key? key,
    required this.status,
  }) : super(key: key);

  Color getColor() {
    switch (status) {
      case "Đã thanh toán":
        return Colors.green;
      case "Đã ký hợp đồng":
        return Colors.red;
      case "Đã gặp gỡ":
        return Colors.orange;
      case "Chưa cập nhật":
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: getColor(),
          fontSize: 14,
        ),
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  final IsJoin member;
  final bool isLast; // Thêm biến kiểm tra thành viên cuối cùng

  const MemberCard({
    super.key,
    required this.member,
    required this.isLast, // Nhận giá trị từ danh sách
  });

  @override
  Widget build(BuildContext context) {
    print("trạng thái: " + '${member.statusMessage}');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(member.user!.avatarImage),
                  onBackgroundImageError: (_, __) {},
                  child: ClipOval(
                    child: Image.network(
                      member.user!.avatarImage,
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
                    member.user!.displayName.isEmpty
                        ? 'Chưa cập nhật'
                        : member.user!.displayName,
                    style: TextStyles.textStyleNormal14W400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Text(
                    "Trạng thái: ",
                    style: TextStyles.textStyleNormal14W500,
                  ),
                  StatusTag(status: member.statusMessage.toString()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.monetization_on,
              label: "Doanh thu",
              value: member.revenue!.toDouble(),
            ),
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.account_balance_wallet,
              label: "Trích quỹ",
              value: member.deduction!.toDouble(),
            ),
            if (!isLast) ...[
              // Chỉ hiển thị nếu không phải là thành viên cuối cùng
              const SizedBox(height: 13),
              const HorizontalDivider(),
              const SizedBox(height: 13),
            ],
            const SizedBox(height: 13),
          ],
        ),
      ),
    );
  }
}
