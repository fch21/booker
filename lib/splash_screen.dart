
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
              if(context.mounted) Navigator.pushReplacementNamed(context, RouteGenerator.PROFILE_SERVICE_PROVIDED);
            }
            else{
              Navigator.pushReplacementNamed(context, RouteGenerator.HOME);
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
      _showSplash();
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage("assets/booker_icon.png"), context);
    });

  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.white,
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