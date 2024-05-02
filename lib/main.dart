import 'dart:async';

import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/helper/web_utils/web_utils.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/splash_screen.dart';
import 'package:booker/views/presentation_web_page.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'helper/route_generator.dart';

GlobalKey<AppState> appGlobalKey = GlobalKey();
AppUser? currentAppUser;
//String? initialServiceProviderId = "IZDVVkzDFTZBjdOxRJOQbuaJHxP2";

Map<String, String> initialUrlParameters = {};

String? get initialServiceProviderId {
  return initialUrlParameters["id"];
}

void resetInitialServiceProviderId(){
  initialUrlParameters.remove("id");
}



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  initialUrlParameters = WebUtils.getUrlParameters();

  WebUtils.removeUrlParameters();

  runApp(App(key: appGlobalKey,));
}

const Color primaryColor = Color(0xff003399);
const Color secondaryColor = Color(0xfffaac05);

final ThemeData standardTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
    background: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    centerTitle: true
  ),
  dialogTheme: DialogTheme(
    surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states){
      if (states.contains(MaterialState.selected)) {
        return primaryColor;
      }
      return Colors.white;
    }),
    trackColor: MaterialStateProperty.resolveWith((states){
      if (states.contains(MaterialState.selected)) {
        return primaryColor.withOpacity(0.4);
      }
      return Colors.grey;
    }),
  ),
  dividerTheme: const DividerThemeData(color: Colors.black38),
  cardTheme: const CardTheme(surfaceTintColor: Colors.white),
  checkboxTheme: const CheckboxThemeData(side: BorderSide(color: Colors.black54)),
  listTileTheme: const ListTileThemeData(iconColor: Colors.black54),
  //chipTheme: ChipThemeData(backgroundColor: Colors.black26)
);

const fontSizeLarge = 24.0;
const fontSizeMedium = 18.0;
const fontSizeSmall = 16.0;
const fontSizeVerySmall = 14.0;

const textStyleLargeBold = TextStyle(
  color: Colors.black87,
  fontSize: fontSizeLarge,
  fontWeight: FontWeight.bold,
);

const textStyleMediumBold = TextStyle(
  color: Colors.black87,
  fontSize: fontSizeMedium,
  fontWeight: FontWeight.bold,
);

const textStyleMediumNormal = TextStyle(
  color: Colors.black87,
  fontSize: fontSizeMedium,
);

const textStyleSmallBold = TextStyle(
  color: Colors.black87,
  fontSize: fontSizeSmall,
  fontWeight: FontWeight.bold,
);

const textStyleSmallNormal = TextStyle(
  color: Colors.black87,
  fontSize: fontSizeSmall,
);

const textStyleVerySmallNormal = TextStyle(
  color: Colors.black87,
  fontSize: fontSizeVerySmall,
);

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {

  Future<void> redrawApp() async {
    Completer<void> completer = Completer();

    // Chama setState para marcar o widget para reconstrução.
    setState(() {});

    // Aguarda o fim do ciclo de pintura atual.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Completa a operação assíncrona após a reconstrução do widget.
      completer.complete();
    });

    // Espera a conclusão do Completer.
    return completer.future;
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
          //Locale('en', 'US'), // Inglês
          Locale('pt', 'BR'), // Português Brasil
        ],
        title: Strings.BOOKER,
        theme: standardTheme,
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
