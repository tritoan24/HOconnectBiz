import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

// Custom TextInputFormatter for currency formatting
import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _numberFormat;

  CurrencyInputFormatter({String locale = 'vi_VN', String symbol = ''})
      : _numberFormat = NumberFormat.currency(
            locale: locale, symbol: symbol, decimalDigits: 0);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Only keep digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Parse to number
    int value = int.parse(digitsOnly);

    // Format with thousand separators but without currency symbol
    String newText = _numberFormat.format(value).replaceAll('₫', '').trim();

    // Keep cursor at the right position
    int cursorPosition = newText.length;
    if (newValue.selection.start > 0) {
      // Try to keep cursor relative position when possible
      cursorPosition =
          newValue.selection.start + (newText.length - newValue.text.length);
      if (cursorPosition < 0) cursorPosition = 0;
      if (cursorPosition > newText.length) cursorPosition = newText.length;
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
