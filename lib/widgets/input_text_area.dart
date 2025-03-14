import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class InputTextArea extends StatefulWidget {
  const InputTextArea(
      {super.key,
      this.title,
      this.hintText,
      required this.name,
      this.controller});
  final String? title;
  final String? hintText;
  final TextEditingController? controller;
  final String name;

  @override
  State<InputTextArea> createState() => _InputTextAreaState();
}

class _InputTextAreaState extends State<InputTextArea> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.title == null
            ? Container()
            : Text(
                "${widget.title}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
        const SizedBox(height: 8),
        FormBuilderTextField(
          controller: widget.controller,
          maxLines: 7,
          autovalidateMode: AutovalidateMode.always,
          name: widget.name,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            hintText: widget.hintText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Bo góc viền
              borderSide: const BorderSide(
                color: Color(0xffB9BDC1), // Màu của viền
                width: 1.0, // Độ dày của viền
              ),
            ),
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xffB9BDC1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xffB9BDC1), // Màu của viền
                width: 1.0, // Độ dày của viền
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        )
      ],
    );
  }
}
