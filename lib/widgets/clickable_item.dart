import 'package:flutter/material.dart';

class ClickableItem extends StatelessWidget {

  final String text;
  final IconData iconData;
  final Color iconColor;
  final VoidCallback onTap;
  final double textSize;

  const ClickableItem({super.key, required this.text, required this.iconData, required this.onTap, this.iconColor = Colors.black54, this.textSize = 18});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconData , color: iconColor,),
      title: Text(text, style: TextStyle(fontSize: textSize),),
      onTap: onTap,
    );
  }
}
