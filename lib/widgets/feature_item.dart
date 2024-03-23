import 'package:booker/main.dart';
import 'package:flutter/material.dart';

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  FeatureItem({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 42, color: standartTheme.primaryColor),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(title, style: textStyleMediumBold),
          ),
          Text(description, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}