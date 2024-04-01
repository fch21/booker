import 'dart:async';

import 'package:booker/main.dart';
import 'package:flutter/material.dart';

class FeatureItem extends StatefulWidget {

  final IconData icon;
  final String title;
  final String description;
  final String longDescription;
  final VoidCallback? onTap;
  final VoidCallback? onDismissedDialog;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.longDescription,
    this.onTap,
    this.onDismissedDialog,
  });

  @override
  State<FeatureItem> createState() => _FeatureItemState();
}

class _FeatureItemState extends State<FeatureItem> {

  GlobalKey heroKey = GlobalKey();

  StreamController<bool> shadowStreamController = StreamController.broadcast();
  double animationPercentage = 0.0;

  Widget getBackgroundWidget({required GlobalKey heroKey, required double endValue}){
    return Positioned.fill(
        child: Hero(
          tag: "background$heroKey",
          child: StreamBuilder<bool>(
              stream: shadowStreamController.stream,
              builder: (context, snapshot) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10 * animationPercentage),
                    boxShadow: [
                      if(animationPercentage > 0.0)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5 * animationPercentage,
                          blurRadius: 7 * animationPercentage,
                          offset: Offset(0, 3 * animationPercentage),
                        ),
                    ],
                  ),
                );
              }
          ),
        )
    );
  }

  Future<void> _showDetailsDialog({required BuildContext context, required GlobalKey heroKey}) async {

    bool listenerAdded = false;

    await Navigator.push(context, PageRouteBuilder(
        barrierColor: Colors.black.withOpacity(0.2),
        opaque: false,
        barrierDismissible: true,
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if(!listenerAdded){
            listenerAdded = true;
            animation.addListener(() {
              shadowStreamController.add(true);
              animationPercentage = animation.value;
            });
          }
          return FadeTransition(opacity: animation, child: child);
        },
        pageBuilder: (context, animation1, animation2){

          double screenWidth = MediaQuery.of(context).size.width;
          double screenHeight = MediaQuery.of(context).size.height;

          bool greaterWidthLayout = screenWidth > screenHeight;

          return Column(
            children: [
              const Spacer(),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: greaterWidthLayout ? screenWidth/4 : 32, vertical: 16),
                  child: Stack(
                    children: [
                      getBackgroundWidget(heroKey: heroKey, endValue: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Hero(
                                tag: "icon$heroKey",
                                child: Icon(widget.icon, size: 42, color: standartTheme.primaryColor)
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: Hero(
                                tag: "title$heroKey",
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(widget.title, style: textStyleMediumBold, textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                            Hero(
                              tag: "description$heroKey",
                              child: Material(
                                  color: Colors.transparent,
                                  child: Text(widget.longDescription, textAlign: TextAlign.center)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              ),
              const Spacer(),
            ],
          );
        }));
    return;
  }

  @override
  void dispose() {
    shadowStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if(widget.onTap != null) widget.onTap!();
        await _showDetailsDialog(context: context, heroKey: heroKey);
        if(widget.onDismissedDialog != null) widget.onDismissedDialog!();
      },
      child: Stack(
        children: [
          getBackgroundWidget(heroKey: heroKey, endValue: 0.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: <Widget>[
                Hero(
                    tag: "icon$heroKey",
                    child: Icon(widget.icon, size: 42, color: standartTheme.primaryColor)
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Hero(
                    tag: "title$heroKey",
                    child: Material(
                      color: Colors.transparent,
                      child: Text(widget.title, style: textStyleMediumBold, textAlign: TextAlign.center),
                    ),
                  ),
                ),
                Hero(
                  tag: "description$heroKey",
                  child: Material(
                      color: Colors.transparent,
                      child: Text(widget.description, textAlign: TextAlign.center)
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}