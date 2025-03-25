// text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  static TextStyle textStyleNormal14W400 = GoogleFonts.roboto(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w400,
  );
  static TextStyle textStyleNormal14W500 = GoogleFonts.roboto(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );
  static TextStyle textStyleNormal14W700 = GoogleFonts.roboto(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
  static TextStyle textStyleNormal12W400 = GoogleFonts.roboto(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w400,
  );

  static TextStyle textStyleNormal12W400Grey = GoogleFonts.roboto(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );
  static TextStyle textStyleNormal12W400Grey15 = GoogleFonts.roboto(
    fontSize: 12,
    height: 1.6,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );
  static TextStyle textStyleNormal12W500 = GoogleFonts.roboto(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );
  static TextStyle textStyleNormal12W400White = GoogleFonts.roboto(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static TextStyle textStyleNormal14W500White = GoogleFonts.roboto(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static TextStyle titleStyleColumnW600 = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.55, // 155% line height
    color: Colors.black,
  );

  static TextStyle bodyStyle = GoogleFonts.roboto(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static TextStyle textStyleNormal30W700 = GoogleFonts.roboto(
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
}
