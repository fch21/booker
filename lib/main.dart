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
import 'dart:html' as html;
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

void getUrlParameters() {
  final search = html.window.location.search;
  print("html.window.location.search = ${html.window.location.search}");
  if (search?.isEmpty ?? true) return;

  final searchParameters = search!.substring(1).split('&');
  final parameterMap = <String, String>{};

  for (final parameter in searchParameters) {
    final keyValue = parameter.split('=');
    if (keyValue.length != 2) continue;
    final key = Uri.decodeComponent(keyValue[0]);
    final value = Uri.decodeComponent(keyValue[1]);
    parameterMap[key] = value;
  }

  initialUrlParameters = parameterMap;
  print("initialUrlParameters = $initialUrlParameters");
  return;
}

void removeUrlParameters() {
  Uri? uri = Uri.tryParse(html.window.location.href);
  print("uri.origin = ${uri?.origin}");
  print("uri.path = ${uri?.path}");
  if(uri != null){
    Uri? newUri = Uri.tryParse(uri.origin);

    // Atualize a URL sem parâmetros e sem adicionar uma entrada no histórico do navegador
    if(newUri != null) html.window.history.replaceState(null, '', newUri.toString());
  }
}

Future<void> main() async {

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  getUrlParameters();

  removeUrlParameters();

  runApp(App(key: appGlobalKey,));
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

  redrawApp(){
    setState(() {});
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
