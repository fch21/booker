import 'package:booker/main.dart';
import 'package:flutter/material.dart';

class ImageWithDescriptionItem extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  bool invert;
  Color? bgColor;
  void Function(String)? onTapImage;

  ImageWithDescriptionItem({
    required this.title,
    required this.description,
    required this.imagePath,
    this.invert = false,
    this.bgColor = Colors.white,
    this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool greaterWidthLayout = screenWidth > screenHeight;
    bool muchGreaterWidthLayout = screenWidth > screenHeight * 1.5;

    TextAlign textAlign = invert ? TextAlign.start : TextAlign.end;
    CrossAxisAlignment textCrossAxisAlignment = invert ? CrossAxisAlignment.start : CrossAxisAlignment.end;

    Widget imageWidget = Expanded(
        flex: 3,
        child: GestureDetector(
          onTap: (){
            if(onTapImage != null) onTapImage!(imagePath);
          },
          child: Hero(
            tag: imagePath,
            child: Image.asset(imagePath, fit: BoxFit.fitWidth,)
          )
        )
    );

    Widget descriptionWidget = Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.only(right: invert ? 0 : 16, left: invert ? 16 : 0),
        child: Column(
          crossAxisAlignment: textCrossAxisAlignment,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Text(title, style: textStyleMediumBold, textAlign: textAlign,),
            ),
            Text(description, style: textStyleVerySmallNormal, textAlign: textAlign),
          ],
        ),
      ),
    );

    return Container(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 48),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: greaterWidthLayout ? muchGreaterWidthLayout? screenWidth * 0.3 : screenWidth * 0.2 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(invert)
                imageWidget,
              descriptionWidget,
              if(!invert)
                imageWidget,
            ],
          ),
        ),
      ),
    );
  }
}