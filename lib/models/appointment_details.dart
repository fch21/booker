import 'package:booker/helper/necessary_subscription_levels.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/user_firebase.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  //int? periodicalWeekDay;//only for periodical services
  //DateTime? day; //only for one time services
  DateTime day = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime from =  DateTime.fromMillisecondsSinceEpoch(0);
  DateTime to =  DateTime.fromMillisecondsSinceEpoch(0);
  bool reminderSent = false;
  bool isAllDay = false;

  bool serviceProvidedInitialized = false;
  ServiceProvided serviceProvided = ServiceProvided();

  //List<AppointmentDetailsChange> changes = [];//only used for periodic appointments, to allow changing only one

  //int index = 0; //only local;

  AppointmentDetails();

  bool get isCanceled {
    return status == Strings.APPOINTMENT_STATUS_CANCELED;
  }

  AppointmentDetails copy(){
    AppointmentDetails copy = AppointmentDetails();
    copy.id = id;
    copy.userName = userName;
    copy.serviceProviderName = serviceProviderName;
    copy.serviceName = serviceName;
    copy.userId = userId;
    copy.serviceId = serviceId;
    copy.serviceProviderUserId = serviceProviderUserId;
    copy.status = status;
    copy.canceledBy = canceledBy;
    copy.cancelMessage = cancelMessage;
    //copy.periodicalWeekDay = periodicalWeekDay;
    copy.day = day;
    copy.from = from;
    copy.to = to;
    copy.reminderSent = reminderSent;
    copy.isAllDay = isAllDay;
    copy.serviceProvidedInitialized = serviceProvidedInitialized;
    copy.serviceProvided = serviceProvided.copy();
    //copy.changes = List.from(changes);

    return copy;
  }

  /*
  List<Map<String, dynamic>> changesToMapList() {
    return changes.map((change) => change.toMap()).toList();
  }
   */

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
      //if(periodicalWeekDay != null)
      //  Strings.APPOINTMENT_PERIODICAL_WEEK_DAY: periodicalWeekDay,
      //if(day != null)
      //  Strings.APPOINTMENT_DAY: Utils.dateFormatForOrdering.format(day!),
      Strings.APPOINTMENT_DAY: Utils.dateFormatForOrdering.format(day),
      Strings.APPOINTMENT_FROM: Utils.dateFormatForOrdering.format(from),
      Strings.APPOINTMENT_TO: Utils.dateFormatForOrdering.format(to),
      Strings.APPOINTMENT_REMINDER_SENT: reminderSent,
      //Strings.APPOINTMENT_CHANGES: changesToMapList(),
      //Strings.APPOINTMENT_IS_ALL_DAY: isAllDay,
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
      //if(periodicalWeekDay != null)
      //  Strings.APPOINTMENT_PERIODICAL_WEEK_DAY: periodicalWeekDay,
      //if(day != null)
      //  Strings.APPOINTMENT_DAY: Utils.dateFormatForOrdering.format(day!),
      Strings.APPOINTMENT_DAY: Utils.dateFormatForOrdering.format(day),
      Strings.APPOINTMENT_FROM: Utils.dateFormatForOrdering.format(from),
      Strings.APPOINTMENT_TO: Utils.dateFormatForOrdering.format(to),
      //Strings.APPOINTMENT_CHANGES: changesToMapList(),
      //Strings.APPOINTMENT_IS_ALL_DAY: isAllDay,
    };

    return map;
  }

  /*
  void convertMapListToChanges(List mapList) {
    changes = mapList.map((map) => AppointmentDetailsChange.fromMap(map)).toList();
  }

   */

  AppointmentDetails.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    print("documentSnapshot.id = ${documentSnapshot.id}");
    if(documentSnapshot.data() != null){
      Map<String, dynamic> documentMap = (documentSnapshot.data() as Map<String, dynamic>);
      id = documentSnapshot.id;
      userName = documentMap[Strings.APPOINTMENT_USER_NAME] ?? "";
      serviceProviderName = documentMap[Strings.APPOINTMENT_SERVICE_PROVIDER_NAME] ?? "";
      serviceName = documentMap[Strings.APPOINTMENT_SERVICE_NAME] ?? "";
      userId = documentMap[Strings.APPOINTMENT_USER_ID] ?? "";
      serviceId = documentMap[Strings.APPOINTMENT_SERVICE_ID] ?? "";
      serviceProviderUserId = documentMap[Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID] ?? "";
      status = documentMap[Strings.APPOINTMENT_STATUS] ?? "";
      canceledBy = documentMap[Strings.APPOINTMENT_CANCELED_BY] ?? "";
      cancelMessage = documentMap[Strings.APPOINTMENT_CANCEL_MESSAGE] ?? "";
      //periodicalWeekDay = documentMap[Strings.APPOINTMENT_PERIODICAL_WEEK_DAY];
      //if(documentMap[Strings.APPOINTMENT_DAY] != null) {
      //  day = Utils.dateFormatForOrdering.parse(documentMap[Strings.APPOINTMENT_DAY]);
      //}
      day = Utils.dateFormatForOrdering.parse(documentMap[Strings.APPOINTMENT_DAY] ?? "");
      from = Utils.dateFormatForOrdering.parse(documentMap[Strings.APPOINTMENT_FROM] ?? "");
      to = Utils.dateFormatForOrdering.parse(documentMap[Strings.APPOINTMENT_TO] ?? "");
      reminderSent = documentMap[Strings.APPOINTMENT_REMINDER_SENT] ?? false;
      //convertMapListToChanges((documentMap[Strings.APPOINTMENT_CHANGES] as List?) ?? []);
      //isAllDay = (documentSnapshot.data() as Map<String, dynamic>)[Strings.APPOINTMENT_IS_ALL_DAY] ?? false;
      //print("serviceName = $serviceName");
      //print("documentMap = $documentMap");
    }

  }

  AppointmentDetails.fromDocumentSnapshotPublic(DocumentSnapshot documentSnapshot) {
    if(documentSnapshot.data() != null){
      Map<String, dynamic> documentMap = (documentSnapshot.data() as Map<String, dynamic>);
      id = documentSnapshot.id;
      serviceId = documentMap[Strings.APPOINTMENT_SERVICE_ID] ?? "";
      serviceProviderUserId = documentMap[Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID] ?? "";
      status = documentMap[Strings.APPOINTMENT_STATUS] ?? "";
      canceledBy = documentMap[Strings.APPOINTMENT_CANCELED_BY] ?? "";
      cancelMessage = documentMap[Strings.APPOINTMENT_CANCEL_MESSAGE] ?? "";
      //periodicalWeekDay = documentMap[Strings.APPOINTMENT_PERIODICAL_WEEK_DAY];
      //if(documentMap[Strings.APPOINTMENT_DAY] != null) {
      //  day = Utils.dateFormatForOrdering.parse(documentMap[Strings.APPOINTMENT_DAY]);
      //}
      day = Utils.dateFormatForOrdering.parse(documentMap[Strings.APPOINTMENT_DAY] ?? "");
      from = Utils.dateFormatForOrdering.parse(documentMap[Strings.APPOINTMENT_FROM] ?? "");
      to = Utils.dateFormatForOrdering.parse(documentMap[Strings.APPOINTMENT_TO] ?? "");
      //convertMapListToChanges((documentMap[Strings.APPOINTMENT_CHANGES] as List?) ?? []);
      //isAllDay = documentMap[Strings.APPOINTMENT_IS_ALL_DAY] ?? false;
    }
  }

  Future<void> initServiceProvided(BuildContext context) async {
    if(!serviceProvidedInitialized){
      //print("initServiceProvided>>>");
      FirebaseFirestore db = FirebaseFirestore.instance;
      try{
        //print("serviceId = $serviceId");
        if(serviceId.isNotEmpty){
          DocumentSnapshot documentSnapshot = await db.collection(Strings.COLLECTION_SERVICES_PROVIDED).doc(serviceId).get();
          serviceProvided = ServiceProvided.fromDocumentSnapshot(documentSnapshot);
        }
        else{
          Utils.showSnackBar(context, AppLocalizations.of(context)!.invalid_data);
        }
      }
      catch(e){
        Utils.showSnackBar(context, "Error in initServiceProvided $e");
      }
      serviceProvidedInitialized = true;
      return;
    }
    return;
  }

  Future<bool> updateAppointmentDetailsInFirestore(BuildContext context, {AppUser? client}) async {
    print("updateServiceProvidedInFirestore>>>");

    //To not upload to firestore copies of appointments tha are not the index 0 appointment
    //AppointmentDetails originalAppointment = getOriginalPeriodicAppointment();

    FirebaseFirestore db = FirebaseFirestore.instance;

    bool result = false;

    try{
      if(id.isEmpty){
        CollectionReference appointmentsDetailsRef = db.collection(Strings.COLLECTION_APPOINTMENTS_DETAILS);
        id = appointmentsDetailsRef.doc().id;
      }
      if(userId.isEmpty) userId = client?.id ?? UserFirebase.getCurrentUser()?.uid ?? "";
      if((userId.isNotEmpty || (client?.id.isEmpty ?? false)) && serviceId.isNotEmpty && serviceProviderUserId.isNotEmpty){
        //print("toMap() = ${toMap()}");
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
      AppointmentDetails appointmentDetails = AppointmentDetails.fromDocumentSnapshot(doc);
      appointmentDetailsList.add(appointmentDetails);
    }


    return appointmentDetailsList;
  }

  static Future<AppointmentDetails> getClientLastAppointmentDetailsWithCurrentServiceProvider({required AppUser appUser}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Strings.COLLECTION_APPOINTMENTS_DETAILS)
        .where(Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID, isEqualTo: currentAppUser!.id)
        .where(Strings.APPOINTMENT_USER_ID, isEqualTo: appUser.id)
        .orderBy(Strings.APPOINTMENT_FROM, descending: true)
        .limit(1)
        .get().catchError((error) {
      print("Error getting services provided by user: $error");
    });

   return AppointmentDetails.fromDocumentSnapshot(querySnapshot.docs.first);
  }
  
  static Future<bool> cancelAppointmentConfirmation(BuildContext context, {required List<AppointmentDetails> appointmentsList, required bool isServiceProvider, bool useCancelAllMessage = false, String extraTextForCancelAll = ""}) async {
    print("appointmentsList.length = ${appointmentsList.length}");
    bool confirmed = false;
    bool showCancelAppointmentAddMessageDialog = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Cancelamento'),
          content: Text(useCancelAllMessage ? 'Tem certeza que deseja cancelar todos os agendamentos marcados $extraTextForCancelAll?' : 'Tem certeza que deseja cancelar este agendamento?'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Voltar'),
              onPressed: () {
                confirmed = false;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
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

    print("useCancelAllMessage && confirmed = ${useCancelAllMessage && confirmed}");
    if(useCancelAllMessage && confirmed){
      bool canAccess = await Utils.showSubscriptionNeededDialogIfNecessary(context: context, subscriptionNeeded: NecessarySubscriptionLevels.CANCEL_ALL_APPOINTMENTS);
      print("canAccess = $canAccess");
      if(!canAccess) return false;
    }


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
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {

        TextEditingController textEditingController = TextEditingController();

        return AlertDialog(
          title: const Text('Mensagem de Cancelamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(useCancelAllMessage ? 'Adicione a mensagem que você deseja enviar para os clientes:' : 'Adicione a mensagem que você deseja enviar para o cliente:'),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: InputCustom(
                  label: "",
                  maxLines: 4,
                  maxLength: 500,
                  controller: textEditingController,
                ),
              )
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Deixar em branco'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enviar'),
              onPressed: () async {
                bool canAccess = await Utils.showSubscriptionNeededDialogIfNecessary(context: context, subscriptionNeeded: NecessarySubscriptionLevels.SEND_CANCELATION_MESSAGE);
                if(canAccess){
                  print("message = ${textEditingController.text}");
                  cancelMessage = textEditingController.text;
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );

    return cancelMessage;
  }

  /*
  Future<bool> isBeforeTheLastPeriodicAppointment(BuildContext context, AppointmentDetails compareAppointmentDetails) async {
    print("isBeforeTheLastPeriodicAppointment");
    if(!serviceProvidedInitialized) await initServiceProvided(context);
    bool hasPeriodicAppointments = serviceProvided.hasPeriodicAppointments;
    if(hasPeriodicAppointments){
      int? numberOfAppointments = serviceProvided.numberOfPeriodicAppointments;
      print("numberOfAppointments = $numberOfAppointments");
      if(numberOfAppointments == null) return true;
      DateTime lastAppointmentFrom = from.add(Duration(days: 7 * (numberOfAppointments - 1)));
      print("lastAppointmentFrom = $lastAppointmentFrom");
      print("compareAppointmentDetails.from = ${compareAppointmentDetails.from}");
      if(!compareAppointmentDetails.from.isAfter(lastAppointmentFrom)){
        print("returning  true");
        return true;
      }
      return false;

    }
    else{
      return true;
    }


  }
  */

  void delayAppointment(Duration duration){
    from = from.add(duration);
    to = to.add(duration);
  }

  /*
  Future<List<AppointmentDetails>> getListOfPeriodicAppointments(BuildContext context) async {

    List<AppointmentDetails> appointmentsList = [];

    if(!serviceProvidedInitialized) await initServiceProvided(context);
    bool hasPeriodicAppointments = serviceProvided.hasPeriodicAppointments;

    if(hasPeriodicAppointments){
      int? numberOfAppointments = serviceProvided.numberOfPeriodicAppointments;
      print("numberOfAppointments = $numberOfAppointments");
      numberOfAppointments ??= 100; //adapt after for infinite periodic appointments
      for(int i = 0; i < numberOfAppointments; i++){
        int index = i;

        if(changes.any((element) => element.index == index)){

        }
        else{

        }

        AppointmentDetails copy = this.copy();
        copy.delayAppointment(Duration(days: 7 * i));
        copy.index = index;
        appointmentsList.add(copy);
      }
    }
    else{
      appointmentsList.add(copy());
    }

    return appointmentsList;
  }

   */

  /*
  AppointmentDetails getOriginalPeriodicAppointment() {
    AppointmentDetails copy = this.copy();
    copy.delayAppointment(Duration(days: 7 * (-index)));
    return copy;
  }

   */

  /*
  Future<void> addAppointmentChange(BuildContext context, {int? manualIndex, DateTime? newFrom, bool? canceled, bool? changeFollowing, bool changeAll = false}) async {
    if(changeAll){
      from = newFrom ?? from;
      to = newFrom?.add(serviceProvided.duration) ?? to;
    }
    else{
      AppointmentDetailsChange appointmentDetailsChange = AppointmentDetailsChange(
        index: manualIndex ?? index,
        newFrom: newFrom ?? from,
        newTo: newFrom?.add(serviceProvided.duration) ?? to,
        canceled: canceled ?? false,
        changeFollowing: changeFollowing ?? false,
      );
      changes.add(appointmentDetailsChange);
    }
  }

   */

}