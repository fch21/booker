import 'package:booker/helper/necessary_subscription_levels.dart';
import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/appointment_details.dart';
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
  bool isPastAppointment = false;

  bool appointmentWasEdited = false;

  Future<void> getClientInfo() async {

    AppUser appUser;

    String id = isServiceProvider ? widget.appointmentDetails.userId : widget.appointmentDetails.serviceProviderUserId;

    if(id.isNotEmpty){

      DocumentSnapshot documentSnapshot;

      if(isServiceProvider){
        documentSnapshot = await FirebaseFirestore.instance
            .collection(Strings.COLLECTION_USERS)
            .doc(currentAppUser!.id)
            .collection(Strings.COLLECTION_CLIENTS)
            .doc(id)
            .get();
      }
      else{
        documentSnapshot = await FirebaseFirestore.instance
          .collection(Strings.COLLECTION_USERS)
          .doc(id)
          .get();
      }

      appUser = AppUser.fromDocumentSnapshot(documentSnapshot);
    }
    else{ // only in the case that the userId is empty in the manually added appointments
      appUser = AppUser()..name = widget.appointmentDetails.userName;
    }

    setState(() {
      _appUser = appUser;
    });


    return;
  }

  @override
  void initState() {
    widget.appointmentDetails.initServiceProvided(context);
    //if(widget.appointmentDetails.periodicalWeekDay == null){
    //  isPastAppointment = widget.appointmentDetails.from.isBefore(DateTime.now());
    //}
    //else{
    //  isPastAppointment = widget.appointmentDetails.isCanceled;
    //}
    isPastAppointment = widget.appointmentDetails.from.isBefore(DateTime.now());
    getClientInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(appointmentWasEdited);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Agendamento'),
        ),
        body: Opacity(
          opacity: isPastAppointment ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _appUser != null
                ? SingleChildScrollView(
                    child: Column(
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
                          child: //widget.appointmentDetails.periodicalWeekDay == null ?
                              Text('Data: ${DateFormat('dd/MM/yyyy').format(widget.appointmentDetails.from)}', style: textStyleSmallNormal)
                              //: Text('Data: ${DateFormat('dd/MM/yyyy').format(widget.appointmentDetails.from)} (${Utils.getFullWeekDayUpperCaseString(widget.appointmentDetails.from)}s)', style: textStyleSmallNormal,),

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
                        if(_appUser!.email.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: GestureDetector(
                              onTap: ()=> Utils.sendEmailTo(context, email: _appUser!.email),
                              child: Text("Email: ${_appUser!.email}", style: textStyleSmallNormal,),
                            )
                          ),
                        if(_appUser!.phone.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: GestureDetector(
                              onTap: ()=> Utils.sendMessageToWhatsApp(context, phoneNumber: _appUser!.phone),
                              child: Text("Telefone: ${_appUser!.phone}", style: textStyleSmallNormal,),
                            ),
                          ),
                        if(isServiceProvider && !widget.appointmentDetails.isCanceled && !isPastAppointment)
                          Padding(
                            padding: const EdgeInsets.only(top: 48.0),
                            child: Center(
                              child: TextButton(
                                onPressed: () async {
                                  bool canAccess = await Utils.showSubscriptionNeededDialogIfNecessary(context: context, subscriptionNeeded: NecessarySubscriptionLevels.EDIT_APPOINTMENT);
                                  if(canAccess){
                                    await widget.appointmentDetails.initServiceProvided(context);
                                    if(mounted) {
                                      Map args = {"user" : currentAppUser!, "serviceProvided" : widget.appointmentDetails.serviceProvided, "appointmentToChange" : widget.appointmentDetails};
                                      Navigator.pushNamed(context, RouteGenerator.MAKE_AN_APPOINTMENT, arguments: args).then((value){
                                        if(value is bool && value){
                                          appointmentWasEdited = true;
                                          setState(() {});
                                        }
                                      });
                                    }
                                  }
                                },
                                child: Text('Editar Agendamento', style: TextStyle(color: standartTheme.primaryColor, fontSize: fontSizeVerySmall),),
                              ),
                            ),
                          ),
                        if(!widget.appointmentDetails.isCanceled && !isPastAppointment)
                          Padding(
                            padding: const EdgeInsets.only(top: 64.0, bottom: 32),
                            child: Center(
                              child: TextButton(
                                onPressed: () async {
                                  bool confirmed = await AppointmentDetails.cancelAppointmentConfirmation(context, appointmentsList: [widget.appointmentDetails], isServiceProvider: isServiceProvider);
                                  if(confirmed && mounted) Navigator.of(context).pop(true);
                                },
                                child: const Text('Cancelar Agendamento', style: TextStyle(color: Colors.red, fontSize: fontSizeVerySmall),),
                              ),
                            ),
                          ),
                      ],
                    ),
                )
                : Center(
                    child: LoadingData(),
                  )
          ),
        ),
      ),
    );
  }
}
