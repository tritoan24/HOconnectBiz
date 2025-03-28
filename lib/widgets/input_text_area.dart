import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class InputTextArea extends StatefulWidget {
  const InputTextArea({
    super.key,
    this.title,
    this.hintText,
    required this.name,
    this.controller,
  });

  final String? title;
  final String? hintText;
  final TextEditingController? controller;
  final String name;

  @override
  State<InputTextArea> createState() => _InputTextAreaState();
}

class _InputTextAreaState extends State<InputTextArea> {
  final FocusNode _focusNode = FocusNode(); // Thêm FocusNode

  @override
  void dispose() {
    _focusNode.dispose(); // Giải phóng FocusNode khi widget bị hủy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus(); // Tắt bàn phím khi người dùng nhấn ra ngoài
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 8),
          FormBuilderTextField(
            controller: widget.controller,
            focusNode: _focusNode, // Gán focusNode vào text field
            maxLines: 7,
            autovalidateMode: AutovalidateMode.always,
            name: widget.name,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              hintText: widget.hintText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xffB9BDC1),
                  width: 1.0,
                ),
              ),
              hintStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xffB9BDC1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xffB9BDC1),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
