import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MoreButton extends StatelessWidget {
  final String postId;
  final Function onEdit;
  final Function onDelete;

  const MoreButton({
    Key? key,
    required this.postId,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(Offset.zero, ancestor: overlay),
            button.localToGlobal(button.size.bottomRight(Offset.zero),
                ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );

        showMenu<String>(
          context: context,
          position: position,
          color: Colors.white,
          items: [
            PopupMenuItem<String>(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              value: 'edit',
              child: Text('Sửa bài đăng'),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              value: 'delete',
              child: Text('Xóa bài đăng'),
            ),
          ],
        ).then((String? value) {
          if (value == 'edit') {
            onEdit();
          } else if (value == 'delete') {
            onDelete();
          }
        });
      },
      child: SvgPicture.asset(
        "assets/icons/more.svg",
        width: 29,
        fit: BoxFit.cover,
      ),
    );
  }
}
