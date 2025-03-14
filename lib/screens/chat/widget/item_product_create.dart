import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemProductCreate extends StatefulWidget {
  final Map<String, dynamic> sanPham;
  final Function(int) onQuantityChanged;
  final int quantity;
  const ItemProductCreate(
      {super.key,
      required this.sanPham,
      required this.onQuantityChanged,
      required this.quantity});

  @override
  State<ItemProductCreate> createState() => _ItemProductCreateState();
}

class _ItemProductCreateState extends State<ItemProductCreate> {
  late int content = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEBF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.sanPham['anhSanPham'],
                width: 88,
                height: 88,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sanPham['tenSanPham'],
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    widget.sanPham['chietKhau'],
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.sanPham['gia'],
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              // Đặt IconButton vào giữa
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                iconSize: 16,
                                icon: Icon(Icons.remove, color: Colors.white),
                                onPressed: () {
                                  if (widget.quantity > 1) {
                                    widget
                                        .onQuantityChanged(widget.quantity - 1);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.quantity.toString(),
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              // Đặt IconButton vào giữa
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                iconSize: 16,
                                icon: Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  widget.onQuantityChanged(widget.quantity + 1);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
