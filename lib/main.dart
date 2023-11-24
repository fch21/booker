import 'package:booker/helper/strings.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/splash_screen.dart';
import 'package:booker/views/calendar.dart';
import 'package:booker/views/choice_of_service.dart';
import 'package:booker/views/make_an_appointment.dart';
import 'package:booker/views/profile_service_provider.dart';
import 'package:booker/views/service_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'helper/route_generator.dart';

GlobalKey<AppState> appGlobalKey = GlobalKey();
AppUser? currentAppUser;

Future<void> main() async {

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  runApp(const App());
}

final ThemeData standartTheme = ThemeData(
  primaryColor: const Color(0xff003399),
  backgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xff003399),
    //onPrimary: Color(0xfffaac05),
    secondary: const Color(0xfffaac05),
    background: Colors.white,
  ), //Color(0xffC21200)),
);

const fontSizeLarge = 24.0;
const fontSizeMedium = 18.0;
const fontSizeSmall = 16.0;
const fontSizeVerySmall = 14.0;

const textStyleLargeBold = TextStyle(
  fontSize: fontSizeLarge,
  fontWeight: FontWeight.bold,
);

const textStyleMediumBold = TextStyle(
  fontSize: fontSizeMedium,
  fontWeight: FontWeight.bold,
);

const textStyleMediumNormal = TextStyle(
  fontSize: fontSizeMedium,
);

const textStyleSmallNormal = TextStyle(

  fontSize: fontSizeSmall,
);

const textStyleVerySmallNormal = TextStyle(
  fontSize: fontSizeVerySmall,
);

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {

  bool userLogged = false;
  User? currentUser = FirebaseAuth.instance.currentUser;

  updateAppForNewUser(){
    print("updateAppForNewUser");
    print("userLogged = $userLogged");
    if(!userLogged){
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // Inglês
          Locale('pt', 'BR'), // Português Brasil
        ],
        title: Strings.BOOKER,
        theme: standartTheme,
        home: const SplashScreen(),
        initialRoute: "/",
        onGenerateRoute: RouteGenerator.generateRoute,
        /*
        home: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(Strings.BOOKER),
          ),
          //body: Calendar(),
          //body: Profile(),
          //body: MakeAnAppointment(),
          //body: ChoiceOfService(),
          body: ServiceForm(),
        )

         */
    );
  }
}
