import 'package:flutter/material.dart';
import 'package:booker/helper/route_generator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:booker/main.dart';
import 'package:introduction_screen/introduction_screen.dart';

class Presentation extends StatefulWidget {

  bool isServiceProviderPresentation;

  Presentation({super.key, this.isServiceProviderPresentation = false});

  @override
  _PresentationState createState() => _PresentationState();
}

class _PresentationState extends State<Presentation> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(widget.isServiceProviderPresentation){

      }
      else{
        precacheImage(const AssetImage("assets/slide_1.jpg"), context);
        precacheImage(const AssetImage("assets/slide_2.jpg"), context);
        precacheImage(const AssetImage("assets/slide_3.jpg"), context);
        precacheImage(const AssetImage("assets/slide_4.jpg"), context);
      }
    });
  }

  void onDonePress() {
    Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.INITIAL_EXPLORE_PAGE, (_) => false, arguments: currentAppUser!);
  }

  PageViewModel getPage({required String text, required String imagePath}){
    return PageViewModel(
      title: "",
      body: text,
      image: Padding(
        padding: const EdgeInsets.fromLTRB(32.0,48.0,32.0,0.0),
        child: Center(
          child: Image.asset(
            imagePath,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
      decoration: const PageDecoration(
        pageColor: Colors.white,
        imageFlex: 2,
        bodyFlex: 1,
        bodyPadding: EdgeInsets.symmetric(horizontal: 32.0),
      ),
    );
  }

  List<PageViewModel> getSlides(){
    List<PageViewModel> slides = [];

    if(widget.isServiceProviderPresentation){

    }
    else{
      slides.add(getPage(text: AppLocalizations.of(context)!.presentation_hi + currentAppUser!.name + AppLocalizations.of(context)!.presentation_slide_1, imagePath: "assets/slide_1.jpg"));
      slides.add(getPage(text: AppLocalizations.of(context)!.presentation_slide_2, imagePath: "assets/slide_2.jpg"));
      slides.add(getPage(text: AppLocalizations.of(context)!.presentation_slide_3, imagePath: "assets/slide_3.jpg"));
      slides.add(getPage(text: AppLocalizations.of(context)!.presentation_slide_4, imagePath: "assets/slide_4.jpg"));
    }

    return slides;
  }

  @override
  Widget build(BuildContext context) {

    return IntroductionScreen(
      pages: getSlides(),
      showSkipButton: false,
      showBackButton: true,
      showNextButton: true,
      back: const Icon(Icons.arrow_back),
      next: const Icon(Icons.arrow_forward),
      done: Text(AppLocalizations.of(context)!.start, style: const TextStyle(fontSize: 16, color: Colors.white)),
      doneStyle: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(standartTheme.primaryColor)),
      onDone: onDonePress,
      dotsDecorator: DotsDecorator(
        activeColor: Theme.of(context).primaryColor,
      ),
      dotsContainerDecorator: const BoxDecoration(color: Colors.white),
      dotsFlex: 2,
    );
  }
}
