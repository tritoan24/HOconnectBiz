import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';

class InputText extends StatefulWidget {
  final String? title;
  final String? hintText;
  final TextEditingController? controller;
  final String? errorText;

  final String name;
  const InputText({
    super.key,
    this.title,
    this.hintText,
    required this.name,
    this.errorText,
    this.controller,
  });


  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
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
          maxLines: 1, // Không cho phép xuống dòng
          autovalidateMode: AutovalidateMode.always,
          name: widget.name,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
        ),
        widget.errorText == null
            ? Container()
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 5),
                child: Wrap(
                  // Dùng Wrap để cho phép xuống dòng
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/ierror.svg",
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.errorText ?? "", // Tránh lỗi nếu errorText là null
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                      softWrap: true, // Cho phép xuống dòng khi quá dài
                      overflow: TextOverflow
                          .visible, // Đảm bảo toàn bộ nội dung được hiển thị
                    ),
                  ],
                ),
              )
      ],
    );
  }
}
