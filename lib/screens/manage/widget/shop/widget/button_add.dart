import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clbdoanhnhansg/utils/Color/app_color.dart';

class ButtonAdd extends StatefulWidget {
  final String? label;
  final void Function()? onPressed;
  const ButtonAdd({super.key, this.label, this.onPressed});

  @override
  State<ButtonAdd> createState() => _ButtonAddState();
}

class _ButtonAddState extends State<ButtonAdd> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.secondaryBlue,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: widget.onPressed,
          child: Text(
            "${widget.label}",
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
}
