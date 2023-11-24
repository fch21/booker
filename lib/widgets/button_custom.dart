import 'package:booker/main.dart';
import 'package:flutter/material.dart';

class ButtonCustom extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;

  const ButtonCustom({super.key, required this.text, this.onPressed, this.color, this.textColor,});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        backgroundColor: color ?? standartTheme.primaryColor,
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Text(
          text,
          style: TextStyle(color: textColor ?? Colors.white, fontSize: fontSizeMedium,),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
