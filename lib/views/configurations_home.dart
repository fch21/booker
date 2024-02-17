import 'package:booker/helper/user_sign.dart';
import 'package:booker/main.dart';
import 'package:flutter/material.dart';
import 'package:booker/helper/route_generator.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/widgets/clickable_item.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfigurationsHome extends StatefulWidget {

  ConfigurationsHome();

  @override
  _ConfigurationsHomeState createState() => _ConfigurationsHomeState();
}

class _ConfigurationsHomeState extends State<ConfigurationsHome> {

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
            children: currentAppUser == null
                ? <Widget>[
                    ClickableItem(
                      text: "Login",
                      iconData: Icons.login,
                      onTap: () {
                        Navigator.pushNamed(context, RouteGenerator.LOGIN);
                      },
                    ),
                  ]
                : <Widget>[
                    // Padding(
                    //   padding: EdgeInsets.only(bottom: 16),
                    //   child: TextField(
                    //     decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: AppLocalizations.of(context)!.search),
                    //   ),
                    // ),
                    ClickableItem(
                      text: AppLocalizations.of(context)!.configurations_my_profile,
                      iconData: Icons.person,
                      onTap: () {
                        if(currentAppUser!.isServiceProvider){
                          Navigator.pushNamed(context, RouteGenerator.PROFILE_SERVICE_PROVIDED);
                        }
                        else{
                          Navigator.pushNamed(context, RouteGenerator.EDIT_PROFILE_CLIENT);
                        }
                      },
                    ),
                    ClickableItem(
                      text: AppLocalizations.of(context)!.configurations_my_appointments,
                      iconData: Icons.calendar_month,
                      onTap: () {
                        Navigator.pushNamed(context, RouteGenerator.MY_APPOINTMENTS);
                      },
                    ),
                    /*
                    ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: Colors.black54,
                      ),
                      title: SwitchListTile(
                        contentPadding: EdgeInsets.all(0),
                        value: widget.currentUser.wantNotifications != null ? widget.currentUser.wantNotifications : true,
                        title: Text(
                          AppLocalizations.of(context)!.configurations_notifications,
                          style: TextStyle(fontSize: 18),
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            widget.currentUser.wantNotifications = newValue;
                          });
                        },
                      ),
                    ),

                    */
                    // ClickableItem(
                    //   text: AppLocalizations.of(context)!.configurations_privacy,
                    //   iconData: Icons.lock,
                    //   onTap: () {},
                    // ),
                    // ClickableItem(
                    //   text: AppLocalizations.of(context)!.configurations_security,
                    //   iconData: Icons.security,
                    //   onTap: () {},
                    // ),
                    // ClickableItem(
                    //   text: AppLocalizations.of(context)!.configurations_friends,
                    //   iconData: Icons.people,
                    //   onTap: () {},
                    // ),
                    /*
                    ClickableItem(
                      text: AppLocalizations.of(context)!.configurations_language,
                      iconData: Icons.language,
                      onTap: () {
                        Navigator.pushNamed(context, RouteGenerator.LANGUAGE_CONFIGURATIONS, arguments: widget.currentUser);
                      },
                    ),

                     */
                    ClickableItem(
                      text: AppLocalizations.of(context)!.configurations_about,
                      iconData: Icons.info,
                      onTap: () {
                        Navigator.pushNamed(context, RouteGenerator.ABOUT);
                      },
                    ),
                    /*
                    ClickableItem(
                      text: AppLocalizations.of(context)!.configurations_help,
                      iconData: Icons.help,
                      onTap: () {
                        Navigator.pushNamed(context, RouteGenerator.PRESENTATION, arguments: currentAppUser!);
                      },
                    ),

                     */
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextButton(
                          style: ButtonStyle(
                            alignment: Alignment.center,
                            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(vertical: 16)),
                          ),
                          onPressed: () {
                            UserSign.logoutUser(context);
                          },
                          child: Text(AppLocalizations.of(context)!.logout, style: TextStyle(color: Colors.red[600], fontSize: fontSizeVerySmall),)),
                    )
                  ]
          ),
        ));
  }
}
