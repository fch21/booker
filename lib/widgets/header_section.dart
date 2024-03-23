import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool greaterWidthLayout = screenWidth > screenHeight;

    double logoHeight = greaterWidthLayout
        ? screenWidth * 0.4
        : screenWidth * 0.9;

    double rightCornerImageHeight = greaterWidthLayout
        ? screenWidth * 0.25
        : screenWidth * 0.3;
    double rightCornerImageWidth = greaterWidthLayout
        ? screenWidth * 0.5
        : screenWidth * 0.5;

    double leftCornerImageHeight = greaterWidthLayout
        ? screenWidth * 0.15
        : screenWidth * 0.3;
    double leftCornerImageWidth = greaterWidthLayout
        ? screenWidth * 0.4
        : screenWidth * 0.5;

    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: leftCornerImageHeight,
              width: leftCornerImageWidth,
              child: Image.asset("assets/presentation_page_left_corner.png", fit: BoxFit.fill,),
            ),
            SizedBox(
              height: rightCornerImageHeight,
              width: rightCornerImageWidth,
              child: Image.asset("assets/presentation_page_right_corner.png", fit: BoxFit.fitWidth,),
            ),
          ],
        ),
        Padding(
            padding: EdgeInsets.only(top: leftCornerImageHeight * 0.6),
            child: Center(
              child: SizedBox(
                  width: logoHeight,
                  child: Image.asset("assets/booker_logo.png", fit: BoxFit.fitWidth,)
              ),
            )
        ),
      ],
    );
  }
}