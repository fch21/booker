import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {

  IconData iconData;
  Color iconColor;
  String text;


  MenuItem({super.key, required this.iconData, required this.text ,this.iconColor = Colors.black38});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(iconData, color: iconColor,),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(text),
        )
      ],
    );
  }
}
