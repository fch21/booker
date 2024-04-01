import 'package:flutter/material.dart';

class ExampleImageToScroll extends StatelessWidget {

  String imagePath;
  final Function(String, Object)? onTap;
  final VoidCallback? afterOnTap;

  ExampleImageToScroll({
    required this.imagePath,
    this.onTap,
    this.afterOnTap,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool greaterWidthLayout = screenWidth > screenHeight;

    UniqueKey heroKey = UniqueKey();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: SizedBox(
        width: greaterWidthLayout ? screenWidth * 0.2 : screenWidth * 0.5,
        child: GestureDetector(
          onTap: (){
            if(onTap != null) onTap!(imagePath, heroKey);
          },
          child: Hero(
            tag: "$imagePath$heroKey",
            child: Image.asset(imagePath, fit: BoxFit.fitWidth,)
          )
        ),
      ),
    );
  }
}
