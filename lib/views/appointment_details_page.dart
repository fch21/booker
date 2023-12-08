import 'package:booker/helper/strings.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final AppointmentDetails appointmentDetails;

  AppointmentDetailsPage({Key? key, required this.appointmentDetails,}) : super(key: key);

  @override
  _AppointmentDetailsPageState createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {

  AppUser? _appUser;
  bool isServiceProvider = currentAppUser!.isServiceProvider;

  Future<void> getClientInfo() async {

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(Strings.COLLECTION_USERS)
        .doc(isServiceProvider ? widget.appointmentDetails.userId : widget.appointmentDetails.serviceProviderUserId)
        .get();

    AppUser appUser = AppUser.fromDocumentSnapshot(documentSnapshot);

    setState(() {
      _appUser = appUser;
    });

    return;
  }

  @override
  void initState() {
    getClientInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Agendamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _appUser != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(widget.appointmentDetails.serviceName, style: textStyleMediumBold,),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: RichText(
                      text: TextSpan(
                        // Default style for text
                        style: textStyleSmallNormal,
                        children: <TextSpan>[
                          const TextSpan(text: 'Status: '),
                          // Applying a different color to a part of the text
                          TextSpan(
                            text: widget.appointmentDetails.isCanceled ? 'Cancelado' : 'Confirmado',
                            style: TextStyle(color: widget.appointmentDetails.isCanceled ? Colors.red : Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Data: ${DateFormat('dd/MM/yyyy').format(widget.appointmentDetails.from)}', style: textStyleSmallNormal),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Horário de início: ${DateFormat('HH:mm').format(widget.appointmentDetails.from)}', style: textStyleSmallNormal),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 32),
                    child: Text('Horário de término: ${DateFormat('HH:mm').format(widget.appointmentDetails.to)}', style: textStyleSmallNormal),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(isServiceProvider ? "Informações do cliente" : "Informações do prestador de serviço", style: textStyleMediumBold,),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text("Nome: ${_appUser!.name}", style: textStyleSmallNormal,),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SelectableText("email: ${_appUser!.email}", style: textStyleSmallNormal,),
                  ),
                  if(!widget.appointmentDetails.isCanceled)
                    Padding(
                      padding: const EdgeInsets.only(top: 64.0),
                      child: Center(
                        child: TextButton(
                          onPressed: () async {
                            bool confirmed = await AppointmentDetails.cancelAppointmentConfirmation(context, appointmentsList: [widget.appointmentDetails], isServiceProvider: isServiceProvider);
                            if(mounted && confirmed) Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar Agendamento', style: TextStyle(color: Colors.red, fontSize: fontSizeVerySmall),),
                        ),
                      ),
                    ),
                ],
              )
            : Center(
                child: LoadingData(),
              )
      ),
    );
  }
}
