import 'package:booker/main.dart';
import 'package:flutter/material.dart';

class LongText extends StatelessWidget {

  String appBarTitle;
  String title;
  String content;

  LongText({
    Key? key,
    required this.appBarTitle,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: Text(title, style: textStyleMediumBold),
            ),
            Text(content, textAlign: TextAlign.start)
          ],
        ),
      ),
    );
  }
}
