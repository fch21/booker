import 'dart:developer';

import 'package:booker/helper/strings.dart';
import 'package:booker/helper/user_firebase.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppointmentDetailsDataSource extends CalendarDataSource {
  AppointmentDetailsDataSource(List<AppointmentDetails> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return (appointments![index] as AppointmentDetails).from;
  }

  @override
  DateTime getEndTime(int index) {
    return (appointments![index] as AppointmentDetails).to;
  }

  @override
  String getSubject(int index) {
    AppointmentDetails appointmentDetails = appointments![index] as AppointmentDetails;

    if(appointmentDetails.serviceName.isEmpty && appointmentDetails.userName.isEmpty) return "";

    return "${appointmentDetails.serviceName} - ${appointmentDetails.userName}";
  }

  @override
  Color getColor(int index) {
    return (appointments![index] as AppointmentDetails).serviceProvided.color;
  }

  @override
  bool isAllDay(int index) {
    return (appointments![index] as AppointmentDetails).isAllDay;
  }
}

class AppointmentDetails {

  static DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  String id = "";
  String userName = "";
  String serviceProviderName = "";
  String serviceName = "";
  String userId = "";
  String serviceId = "";
  String serviceProviderUserId = "";
  String status = Strings.APPOINTMENT_STATUS_CONFIRMED;
  String canceledBy = "";
  String cancelMessage = "";
  DateTime day =  DateTime.fromMillisecondsSinceEpoch(0);
  DateTime from =  DateTime.fromMillisecondsSinceEpoch(0);
  DateTime to =  DateTime.fromMillisecondsSinceEpoch(0);
  bool isAllDay = false;

  ServiceProvided serviceProvided = ServiceProvided();

  AppointmentDetails();

  bool get isCanceled {
    return status == Strings.APPOINTMENT_STATUS_CANCELED;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      Strings.APPOINTMENT_ID: id,
      Strings.APPOINTMENT_USER_NAME: userName,
      Strings.APPOINTMENT_SERVICE_PROVIDER_NAME: serviceProviderName,
      Strings.APPOINTMENT_SERVICE_NAME: serviceName,
      Strings.APPOINTMENT_USER_ID: userId,
      Strings.APPOINTMENT_SERVICE_ID: serviceId,
      Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID: serviceProviderUserId,
      Strings.APPOINTMENT_STATUS: status,
      Strings.APPOINTMENT_CANCELED_BY: canceledBy,
      Strings.APPOINTMENT_CANCEL_MESSAGE: cancelMessage,
      Strings.APPOINTMENT_DAY: dateFormat.format(day),
      Strings.APPOINTMENT_FROM: dateFormat.format(from),
      Strings.APPOINTMENT_TO: dateFormat.format(to),
      Strings.APPOINTMENT_IS_ALL_DAY: isAllDay,
    };

    return map;
  }

  Map<String, dynamic> toMapPublic() {
    Map<String, dynamic> map = {
      Strings.APPOINTMENT_ID: id,
      Strings.APPOINTMENT_SERVICE_ID: serviceId,
      Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID: serviceProviderUserId,
      Strings.APPOINTMENT_STATUS: status,
      Strings.APPOINTMENT_CANCELED_BY: canceledBy,
      Strings.APPOINTMENT_CANCEL_MESSAGE: cancelMessage,
      Strings.APPOINTMENT_DAY: dateFormat.format(day),
      Strings.APPOINTMENT_FROM: dateFormat.format(from),
      Strings.APPOINTMENT_TO: dateFormat.format(to),
      Strings.APPOINTMENT_IS_ALL_DAY: isAllDay,
    };

    return map;
  }

  AppointmentDetails.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    if(documentSnapshot.data() != null){
      id = documentSnapshot.id;
      userName = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_USER_NAME] ?? "";
      serviceProviderName = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_SERVICE_PROVIDER_NAME] ?? "";
      serviceName = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_SERVICE_NAME] ?? "";
      userId = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_USER_ID] ?? "";
      serviceId = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_SERVICE_ID] ?? "";
      serviceProviderUserId = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID] ?? "";
      status = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_STATUS] ?? "";
      canceledBy = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_CANCELED_BY] ?? "";
      cancelMessage = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_CANCEL_MESSAGE] ?? "";
      //day = (((documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_DAY] ?? Timestamp.fromMillisecondsSinceEpoch(0)) as Timestamp).toDate();
      //from = (((documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_FROM] ?? Timestamp.fromMillisecondsSinceEpoch(0)) as Timestamp).toDate();
      //to = (((documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_TO] ??  Timestamp.fromMillisecondsSinceEpoch(0)) as Timestamp).toDate();
      day = dateFormat.parse((documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_DAY] ?? "");
      from = dateFormat.parse((documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_FROM] ?? "");
      to = dateFormat.parse((documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_TO] ?? "");
      isAllDay = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_IS_ALL_DAY] ?? false;
    }
  }

  AppointmentDetails.fromDocumentSnapshotPublic(DocumentSnapshot documentSnapshot) {
    if(documentSnapshot.data() != null){
      id = documentSnapshot.id;
      serviceId = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_SERVICE_ID] ?? "";
      serviceProviderUserId = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID] ?? "";
      status = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_STATUS] ?? "";
      canceledBy = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_CANCELED_BY] ?? "";
      cancelMessage = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_CANCEL_MESSAGE] ?? "";
      //day = (((documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_DAY] ?? Timestamp.fromMillisecondsSinceEpoch(0)) as Timestamp).toDate();
      //from = (((documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_FROM] ?? Timestamp.fromMillisecondsSinceEpoch(0)) as Timestamp).toDate();
      //to = (((documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_TO] ??  Timestamp.fromMillisecondsSinceEpoch(0)) as Timestamp).toDate();
      day = dateFormat.parse((documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_DAY] ?? "");
      from = dateFormat.parse((documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_FROM] ?? "");
      to = dateFormat.parse((documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_TO] ?? "");
      isAllDay = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_IS_ALL_DAY] ?? false;
    }
  }

  Future<void> initServiceProvided(BuildContext context) async {
    //print("initServiceProvided>>>");
    FirebaseFirestore db = FirebaseFirestore.instance;
    try{
      if(serviceId.isNotEmpty){
        DocumentSnapshot documentSnapshot = await db.collection(Strings.COLLECTION_SERVICES_PROVIDED).doc(serviceId).get();
        serviceProvided = ServiceProvided.fromDocumentSnapshot(documentSnapshot);
      }
      else{
        Utils.showSnackBar(context, "${AppLocalizations.of(context)!.invalid_data}");
      }
    }
    catch(e){
      Utils.showSnackBar(context, "${AppLocalizations.of(context)!.error_updating_appointment_details_message} $e");
    }
    return;
  }

  Future<bool> updateAppointmentDetailsInFirestore(BuildContext context) async {
    print("updateServiceProvidedInFirestore>>>");

    FirebaseFirestore db = FirebaseFirestore.instance;

    bool result = false;

    try{
      if(id.isEmpty){
        CollectionReference servicesProvided = db.collection(Strings.COLLECTION_APPOINTMENTS_DETAILS);
        id = servicesProvided.doc().id;
      }
      if(userId.isEmpty) userId = UserFirebase.getCurrentUser()?.uid ?? "";
      if(userId.isNotEmpty && serviceId.isNotEmpty && serviceProviderUserId.isNotEmpty){
        await db.collection(Strings.COLLECTION_APPOINTMENTS_DETAILS).doc(id).set(toMap());
        await db.collection(Strings.COLLECTION_APPOINTMENTS_DETAILS_PUBLIC).doc(id).set(toMapPublic());
        result = true;
      }
      else{
        Utils.showSnackBar(context, "${AppLocalizations.of(context)!.invalid_data}");
      }
    }
    catch(e){
      Utils.showSnackBar(context, "${AppLocalizations.of(context)!.error_updating_appointment_details_message} $e");
      result = false;
    }

    return result;
  }

  static String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

  static Future<List<AppointmentDetails>> getClientAppointmentDetails({required AppUser appUser}) async {
    return getUserAppointmentDetails(appUser: appUser, client: true);
  }

  static Future<List<AppointmentDetails>> getServiceProviderAppointmentDetails({required AppUser appUser}) async {
    return getUserAppointmentDetails(appUser: appUser, client: false);
  }

  static Future<List<AppointmentDetails>> getUserAppointmentDetails({required AppUser appUser, required bool client}) async {
    List<AppointmentDetails> appointmentDetailsList = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Strings.COLLECTION_APPOINTMENTS_DETAILS)
        .where(client ? Strings.APPOINTMENT_USER_ID : Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID, isEqualTo: appUser.id)
        .get().catchError((error) {
      print("Error getting services provided by user: $error");
    });

    for(var doc in querySnapshot.docs){
      appointmentDetailsList.add(AppointmentDetails.fromDocumentSnapshot(doc));
    }

    return appointmentDetailsList;
  }

  static Future<bool> cancelAppointmentConfirmation(BuildContext context, {required List<AppointmentDetails> appointmentsList, required bool isServiceProvider, bool useCancelAllMessage = false, String extraTextForCancelAll = ""}) async {
    print("appointmentsList.length = ${appointmentsList.length}");
    bool confirmed = false;
    bool showCancelAppointmentAddMessageDialog = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Cancelamento'),
          content: Text(useCancelAllMessage ? 'Tem certeza que deseja cancelar todos os agendamentos marcados ${extraTextForCancelAll}?' : 'Tem certeza que deseja cancelar este agendamento?'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: Text('Voltar'),
              onPressed: () {
                confirmed = false;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirmar'),
              onPressed: () async {
                confirmed = true;
                showCancelAppointmentAddMessageDialog = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if(showCancelAppointmentAddMessageDialog && context.mounted){
      String cancelMessage = "";
      if(isServiceProvider) {
        cancelMessage = await _cancelAppointmentAddMessage(context, useCancelAllMessage: useCancelAllMessage);
      }
      for(var appointment in appointmentsList){
        appointment.status = Strings.APPOINTMENT_STATUS_CANCELED;
        appointment.canceledBy = isServiceProvider ? Strings.APPOINTMENT_CANCELED_BY_SERVICE_PROVIDER : Strings.APPOINTMENT_CANCELED_BY_CLIENT;
        appointment.cancelMessage = cancelMessage;
        await appointment.updateAppointmentDetailsInFirestore(context);
      }
    }

    return confirmed;
  }

  static Future<String> _cancelAppointmentAddMessage(BuildContext context, {bool useCancelAllMessage = false}) async {

    String cancelMessage = "";

    await showDialog(
      context: context,
      builder: (BuildContext context) {

        TextEditingController textEditingController = TextEditingController();

        return AlertDialog(
          title: Text('Mensagem de Cancelamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(useCancelAllMessage ? 'Adicione a mensagem que você deseja enviar para os clientes:' : 'Adicione a mensagem que você deseja enviar para o cliente:'),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: InputCustom(
                  label: "",
                  maxLines: 5,
                  maxLength: 500,
                  controller: textEditingController,
                ),
              )
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: Text('Deixar em branco'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enviar'),
              onPressed: () {
                // Adicione a lógica para cancelar o agendamento
                print("message = ${textEditingController.text}");
                cancelMessage = textEditingController.text;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return cancelMessage;
  }
}