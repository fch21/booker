
import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/user_sign.dart';
import 'package:booker/main.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  static Duration splashAnimationDuration = const Duration(milliseconds: 700);
  static Duration splashDuration = const Duration(milliseconds: 300);

  _showSplash(){
    Navigator.pushReplacement(context, PageRouteBuilder(
        transitionDuration: splashAnimationDuration,
        transitionsBuilder: (context, animation1, animation2, child){

          final curveAnimation = CurvedAnimation(
            parent: animation1,
            curve: Curves.easeOutBack,
          );

          return ScaleTransition(
            scale: curveAnimation,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          Future.delayed(splashAnimationDuration + splashDuration, () async {
            await UserSign.getCurrentAppUser();
            if(currentAppUser?.isServiceProvider ?? false){
              if(context.mounted) Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.PROFILE_SERVICE_PROVIDER, (Route<dynamic> route) => false,);
            }
            else{
              //if(context.mounted) Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.INITIAL_EXPLORE_PAGE, (Route<dynamic> route) => false);
              if(context.mounted) Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.PRESENTATION_WEB_PAGE, (Route<dynamic> route) => false);
            }
          });

          bool greaterWidthLayout = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

          return Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: greaterWidthLayout ? MediaQuery.of(context).size.width/8 : 0),
              color: Colors.white,
              width: MediaQuery.of(context).size.width * 0.6,
              child: Image.asset("assets/booker_icon.png", fit: BoxFit.fitWidth,),
            ),
          );
        })
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      precacheImage(const AssetImage("assets/presentation_page_left_corner.png"), context);
      precacheImage(const AssetImage("assets/presentation_page_right_corner.png"), context);
      precacheImage(const AssetImage("assets/booker_icon.png"), context);
      _showSplash();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.white,
      child: const Center(child: CircularProgressIndicator()),
    );


    /*
    return AnimatedSplashScreen.withScreenRouteFunction(
      splash: Container(
        child: Hero(
          tag: "logo",
          child: Image.asset("assets/drinqr_logo_transparent.png", fit: BoxFit.fitWidth,),
        ),
      ),
      splashIconSize: double.infinity,
      //nextRoute: '/init',
      screenRouteFunction: () async {
        return RouteGenerator.LOGIN;
      },
      duration: 5000,
      disableNavigation: true,
      splashTransition: SplashTransition.scaleTransition,
      curve: Curves.easeOutBack,
      pageTransitionType: PageTransitionType.fade,
    );

     */
  }
}