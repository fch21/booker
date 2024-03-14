import 'package:booker/helper/necessary_subscription_levels.dart';
import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:booker/widgets/appointment_details_card.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClientPage extends StatefulWidget {
  final AppUser client;

  ClientPage({Key? key, required this.client,}) : super(key: key);

  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {

  List<AppointmentDetails> clientAppointments = [];
  bool clientAppointmentsAreLoaded = false;

  Future<void> _getClientAppointments() async {
    List<AppointmentDetails> appointments = await currentAppUser!.getOrderedAppointmentDetailsOfClient(client: widget.client);
    setState(() {
      clientAppointments = appointments;
      clientAppointmentsAreLoaded = true;
    });
    return;
  }

  _changeClientBlockedStatus(bool isBlocked) async {
    if(isBlocked){
      currentAppUser!.blockedClientsIds.remove(widget.client.id);
      currentAppUser!.updateAppUserInFirestore(context);
      setState(() {});
    }
    else{
      bool canAccess = await Utils.showSubscriptionNeededDialogIfNecessary(context: context, subscriptionNeeded: NecessarySubscriptionLevels.BLOCK_CLIENT);
      if(canAccess){
        currentAppUser!.blockedClientsIds.add(widget.client.id);
        currentAppUser!.updateAppUserInFirestore(context);
        setState(() {});
      }
    }

  }

  _changeClientBlockedStatusDialog(bool isBlocked){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text(isBlocked ? "Desbloquear cliente" : "Bloquear cliente"),
          content: Text(isBlocked 
              ? "Ele poderá agendar serviços e ver seus horários de disponibilidade."
              : "Ele não poderá agendar serviços nem ver seus horários de disponibilidade."
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(isBlocked ? "Desbloquear" : "Bloquear"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _changeClientBlockedStatus(isBlocked);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _getClientAppointments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    DateTime currentDateTime = DateTime.now();
    bool clientIsBlocked = currentAppUser!.blockedClientsIds.contains(widget.client.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações do cliente'),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              Opacity(
                opacity: clientIsBlocked ? 0.5 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text("Dados para contato", style: textStyleMediumBold,),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Text("Nome: ${widget.client.name}", style: textStyleSmallNormal,),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child:GestureDetector(
                        onTap: (){
                          Utils.sendEmailTo(context, email: widget.client.email);
                        },
                        child: Text("email: ${widget.client.email}", style: textStyleSmallNormal,),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: GestureDetector(
                        onTap: (){
                          if(widget.client.phone.isNotEmpty) Utils.sendMessageToWhatsApp(context, phoneNumber: widget.client.phone);
                        },
                        child: Text("Telefone: ${widget.client.phone.isEmpty ? "Não informado" : widget.client.phone}", style: textStyleSmallNormal,),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(top: 32.0, bottom: 16),
                      child: Text("Histórico de agendamentos", style: textStyleMediumBold,),
                    ),
                    const Divider(
                      thickness: 1,
                      height: 1,
                    ),
                    if(!clientAppointmentsAreLoaded)
                      Padding(
                        padding: const EdgeInsets.only(top: 64.0),
                        child: LoadingData(),
                      ),
                    if(clientAppointmentsAreLoaded)
                      Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 300), // Define o tamanho máximo para 300
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: clientAppointments.length,
                              itemBuilder: (BuildContext context, int index) {
                                AppointmentDetails appointmentDetails = clientAppointments[index];
                                //print("appointmentDetails.from = ${appointmentDetails.from}");
                                return Opacity(
                                  opacity: (appointmentDetails.isCanceled || appointmentDetails.to.isBefore(currentDateTime)) ? 0.6 : 1.0,
                                  child: AppointmentDetailsCard(
                                    appointmentDetails: appointmentDetails,
                                    isClient: !currentAppUser!.isServiceProvider,
                                    onTap: (){
                                      Navigator.pushNamed(context, RouteGenerator.APPOINTMENT_DETAILS_PAGE, arguments: appointmentDetails).then((value){
                                        _getClientAppointments();
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          )

                      ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Divider(
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Center(
                  child: TextButton(
                    onPressed: () async {
                      _changeClientBlockedStatusDialog(clientIsBlocked);
                    },
                    child: Text(clientIsBlocked ? 'Desbloquear cliente' : 'Bloquear cliente', style: TextStyle(color: Colors.red, fontSize: fontSizeVerySmall),),
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }
}
