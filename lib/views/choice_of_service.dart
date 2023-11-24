import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:booker/widgets/profile_header.dart';
import 'package:booker/widgets/service_provided_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChoiceOfService extends StatefulWidget {

  AppUser appUser;

  ChoiceOfService({
    Key? key,
    required this.appUser
  }) : super(key: key);

  @override
  State<ChoiceOfService> createState() => _ChoiceOfServiceState();
}

class _ChoiceOfServiceState extends State<ChoiceOfService> {

  // Exemplo de uma lista de serviços

  List<ServiceProvided> services = [];
  bool servicesAreLoaded = false;

  _getServiceList() async {
    services = await ServiceProvided.getServicesProvidedByUser(widget.appUser);
    setState(() {
      servicesAreLoaded = true;
    });
  }

  @override
  void initState() {
    _getServiceList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("widget.appUser = ${widget.appUser.getUserColorResolved()}");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Serviços disponíveis"),
        elevation: 0,
        backgroundColor: widget.appUser.getUserColorResolved(),
        foregroundColor: Utils.getContrastingColor(widget.appUser.getUserColorResolved()),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeader(appUser: widget.appUser,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
              child: Text(
                'Escolha seu serviço',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 18,
              endIndent: 18,
            ),
            if(!servicesAreLoaded)
              Padding(
                padding: const EdgeInsets.only(top: 64.0),
                child: LoadingData(),
              ),
            if(servicesAreLoaded)
              services.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 16),
                    child: Center(
                        child: Text(AppLocalizations.of(context)!.no_services_provided_message, style: textStyleSmallNormal,)
                    ),
                  )
                : ListView.builder(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0), // Adicionado o padding lateral
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (BuildContext context, int index) {
                    ServiceProvided serviceProvided = services[index];
                    return ServiceProvidedCard(
                      serviceProvided: serviceProvided,
                      onTap: (){
                        Map args = {"user" : widget.appUser, "serviceProvided" : serviceProvided};
                        Navigator.pushNamed(context, RouteGenerator.MAKE_AN_APPOINTMENT, arguments: args);
                      },
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}