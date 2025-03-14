import 'package:flutter/material.dart';

class ButtonWidget16 extends StatefulWidget {
  final String? label;
  final void Function()? onPressed;
  const ButtonWidget16({super.key, this.label, this.onPressed});

  @override
  State<ButtonWidget16> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget16> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff006AF5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: widget.onPressed,
          child: Text(
            "${widget.label}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
