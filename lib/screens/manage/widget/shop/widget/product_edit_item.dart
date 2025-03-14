import 'package:clbdoanhnhansg/screens/manage/widget/shop/widget/un_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../models/product_model.dart';
import '../../../../tin_mua_hang/chi_tiet_don_hang.dart';
import '../shoptab.dart';
import 'checkbox.dart';

class ProductEditItem extends StatefulWidget {
  final ProductModel sanPham;
  final Function(bool)? onPinToggle;

  const ProductEditItem({
    super.key,
    required this.sanPham,
    this.onPinToggle,
  });

  @override
  State<ProductEditItem> createState() => _ProductEditItemState();
}

class _ProductEditItemState extends State<ProductEditItem> {
  late bool isPinned;

  @override
  void initState() {
    super.initState();
    isPinned = widget.sanPham.isPin ?? false;
  }

  void _togglePin() {
    setState(() {
      isPinned = !isPinned;
    });
    widget.onPinToggle?.call(isPinned);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              widget.sanPham.album[0],
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image_not_supported,
                size: 80,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sanPham.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Chiết khấu ${widget.sanPham.discount}% cho hội viên CLB",
                    style: const TextStyle(
                      color: Color(0xFFF1645F),
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatCurrency.format(widget.sanPham.price),
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: _togglePin,
                        child: Container(
                          child: isPinned ? const Check() : const UnCheck(),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

