import 'package:booker/helper/user_sign.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:flutter/material.dart';
import 'package:booker/helper/route_generator.dart';
import 'package:booker/widgets/clickable_item.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfigurationsProfileServiceProvider extends StatefulWidget {

  VoidCallback? onReload;

  ConfigurationsProfileServiceProvider({
    this.onReload
  });

  @override
  _ConfigurationsProfileServiceProviderState createState() => _ConfigurationsProfileServiceProviderState();
}

class _ConfigurationsProfileServiceProviderState extends State<ConfigurationsProfileServiceProvider> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: currentAppUser!.getUserColorResolved(),
          title: Text(AppLocalizations.of(context)!.configurations_appbar),
        ),
        body: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.grey
              )
            )
          ),
          padding: const EdgeInsets.only(top: 16),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            children: <Widget>[
              ClickableItem(
                text: 'Editar Perfil',
                iconData: Icons.edit,
                onTap: () async {
                  await Navigator.pushNamed(context, RouteGenerator.EDIT_PROFILE_SERVICE_PROVIDER, arguments: currentAppUser!).then((value){
                    if(widget.onReload != null) widget.onReload!();
                  });
                },
              ),
              ClickableItem(
                //text: AppLocalizations.of(context)!.configurations_payments,
                text: 'Assinatura',
                //iconData: Icons.payments_rounded,
                iconData: Icons.diamond_outlined,
                onTap: () {
                  Navigator.pushNamed(context, RouteGenerator.SUBSCRIPTION_MANAGEMENT, arguments: currentAppUser!);
                },
              ),
              ClickableItem(
                text: "Copiar link do Perfil",
                iconData: Icons.link,
                onTap: () {
                  String linkToTheUserProfile = currentAppUser!.getLinkToTheUserProfile();
                  Clipboard.setData(ClipboardData(text: linkToTheUserProfile));
                  Utils.showSnackBar(context, 'Texto copiado para a área de transferência!');
                },
              ),
              ClickableItem(
                text: AppLocalizations.of(context)!.explore,
                iconData: Icons.search,
                onTap: () {
                  Navigator.pushNamed(context, RouteGenerator.INITIAL_EXPLORE_PAGE);
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
                padding: const EdgeInsets.only(top: 32.0),
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
            ],
          ),
        ));
  }
}
