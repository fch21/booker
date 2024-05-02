import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/widgets/custom_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage("assets/booker_logo.png"), context);
      precacheImage(const AssetImage("assets/instagram_logo.png"), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.configurations_about),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.125),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * (1/3),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: AssetImage("assets/booker_logo.png"),
                  )
                ),
              ),
            ),
            const CustomDivider(),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 32),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.configurations_about_social_network,
                  style: textStyleMediumBold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Center(
                child: GestureDetector(
                  onTap: (){
                    Uri? uri = Uri.tryParse(Strings.BOOKER_INSTAGRAM_LINK);
                    if(uri != null){
                      launchUrl(uri);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (4/9)),
                    child: Container(
                      width: MediaQuery.of(context).size.width/8,
                      height: MediaQuery.of(context).size.width/8,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: AssetImage("assets/instagram_logo.png"),
                          )
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const CustomDivider(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.configurations_about_contact_email,
                  style: textStyleMediumBold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 64.0, top: 16.0),
              child: Center(
                child: GestureDetector(
                  onTap: (){
                    Utils.sendEmailTo(context, email: Strings.BOOKER_EMAIL);
                  },
                  child: const Text(
                    Strings.BOOKER_EMAIL,
                    style: textStyleMediumNormal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
