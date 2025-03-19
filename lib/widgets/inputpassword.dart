import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class Inputpassword extends StatefulWidget {
  final String name;
  final String? title;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;

  const Inputpassword({
    super.key,
    required this.name,
    required this.title,
    this.hintText,
    this.errorText,
    this.controller,
  });

  @override
  State<Inputpassword> createState() => _InputpasswordState();
}

class _InputpasswordState extends State<Inputpassword> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${widget.title}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        FormBuilderTextField(
          controller: widget.controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          name: widget.name,
          maxLines: 1,
          obscureText: _isObscured,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            hintText: "${widget.hintText}",
            suffixIcon: IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xffB9BDC1),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12), // Đồng bộ với enabledBorder
              borderSide: const BorderSide(
                color: Color(0xffB9BDC1),
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.0,
              ),
            ),
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xffB9BDC1),
            ),
            errorStyle: const TextStyle(height: 0), // Ẩn lỗi mặc định
          ),
        ),
        if (widget.errorText != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 5),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/ierror.svg",
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 5),
                Text(
                  widget.errorText ?? "",
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
