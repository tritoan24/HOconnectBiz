import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
import '../../cart/cart_tab.dart';

class Button extends StatefulWidget {
  final String id;
  const Button({super.key, required this.id});

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    if (isConfirmed) {
      return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const Cart(initialTab: CartTab.PurchaseOrder),
              ),
            );
          },
          child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.blue,
                      ),
                      Text(
                        'Đã Xác nhận mua hàng',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios_rounded),
                ],
              )));
    }

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    final cartProvider =
                        Provider.of<CartProvider>(context, listen: false);

                    cartProvider.updateStatusOrder(widget.id, 1, context);
                    isConfirmed = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF006AF5), // Màu nút "Xác nhận"

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Xác nhận mua hàng',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context), // Hành động khi đóng
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6E9FF), // Màu nút "Đóng"

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Hủy',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF006AF5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
