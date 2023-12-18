import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booker/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:booker/helper/route_generator.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/widgets/clickable_item.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfigurationsProfileServiceProvider extends StatefulWidget {

  ConfigurationsProfileServiceProvider();

  @override
  _ConfigurationsProfileServiceProviderState createState() => _ConfigurationsProfileServiceProviderState();
}

class _ConfigurationsProfileServiceProviderState extends State<ConfigurationsProfileServiceProvider> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  _logoutUser() async {
    await auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.LOGIN, (_) => false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          title: Text(AppLocalizations.of(context)!.configurations_appbar),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 16),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            children: <Widget>[
              ClickableItem(
                text: AppLocalizations.of(context)!.explore,
                iconData: Icons.search,
                onTap: () {
                  Navigator.pushNamed(context, RouteGenerator.HOME, arguments: currentAppUser);
                },
              ),
              ClickableItem(
                text: AppLocalizations.of(context)!.configurations_payments,
                iconData: Icons.payments_rounded,
                onTap: () {
                  Navigator.pushNamed(context, RouteGenerator.PAYMENT_CONFIGURATIONS, arguments: currentAppUser!);
                },
              ),
              ClickableItem(
                text: AppLocalizations.of(context)!.configurations_about,
                iconData: Icons.info,
                onTap: () {
                  Navigator.pushNamed(context, RouteGenerator.ABOUT);
                },
              ),

              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton(
                    style: ButtonStyle(
                      alignment: Alignment.center,
                      padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(vertical: 16)),
                    ),
                    onPressed: () {
                      _logoutUser();
                    },
                    child: Text(AppLocalizations.of(context)!.logout, style: TextStyle(color: Colors.red[600], fontSize: fontSizeVerySmall),)),
              )
            ],
          ),
        ));
  }
}
