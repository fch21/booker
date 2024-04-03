import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

class CustomSliderDrawer extends StatefulWidget {

  final Widget slider;
  final Widget child;
  final Widget? appBar;
  final GlobalKey<SliderDrawerState>? sliderDrawerKey;

  const CustomSliderDrawer({
    Key? key,
    required this.slider,
    required this.child,
    this.sliderDrawerKey,
    this.appBar = const SliderAppBar(),

  }) : super(key: key);

  @override
  State<CustomSliderDrawer> createState() => _CustomSliderDrawerState();
}

class _CustomSliderDrawerState extends State<CustomSliderDrawer> {

  late GlobalKey<SliderDrawerState> sliderDrawerKey;
  bool isDrawerOpen = false;

  void _keepTrackOfSliderAnimation(){
    sliderDrawerKey.currentState?.animationController.addListener(() {
      bool currentIsDrawerOpen = (sliderDrawerKey.currentState?.isDrawerOpen ?? false);
      if(isDrawerOpen != currentIsDrawerOpen) {
        setState(() {
          isDrawerOpen = currentIsDrawerOpen;
        });
      }
    });
    return;
  }

  @override
  void initState() {
    sliderDrawerKey = widget.sliderDrawerKey ?? GlobalKey<SliderDrawerState>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _keepTrackOfSliderAnimation();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliderDrawer(
      key: sliderDrawerKey,
      appBar: widget.appBar,
      slider: widget.slider,
      slideDirection: SlideDirection.RIGHT_TO_LEFT,
      child: Stack(
        children: [
          widget.child,
          if(isDrawerOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: (){
                  sliderDrawerKey.currentState?.closeSlider();
                },
                child: Container(color: Colors.transparent),
              ),
            )
        ],
      ),
    );
  }
}
