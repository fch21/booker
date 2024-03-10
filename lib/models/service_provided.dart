import 'package:booker/helper/strings.dart';
import 'package:booker/helper/user_firebase.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServiceProvided {
  String id = "";
  String name = "";
  String userId = "";
  String description = "";
  double price = 0.0;
  Duration duration = Duration.zero;
  Color color = Colors.blue;
  //bool hasPeriodicAppointments = false;
  //int? numberOfPeriodicAppointments;
  int minSchedulingDelayInMinutes = 30;
  int schedulingIntervalInMinutes = 10;
  int maxSchedulingDelayInDays = 30;

  ServiceProvided();

  ServiceProvided copy(){
    ServiceProvided copy = ServiceProvided();
    copy.id = id;
    copy.name = name;
    copy.userId = userId;
    copy.description = description;
    copy.price = price;
    copy.duration = duration;
    copy.color = color;
    //copy.hasPeriodicAppointments = hasPeriodicAppointments;
    //copy.numberOfPeriodicAppointments = numberOfPeriodicAppointments;
    copy.minSchedulingDelayInMinutes = minSchedulingDelayInMinutes;
    copy.schedulingIntervalInMinutes = schedulingIntervalInMinutes;
    copy.maxSchedulingDelayInDays = maxSchedulingDelayInDays;

    return copy;
  }

  Map<String, dynamic> toMap() {
    print("color = $color");
    Map<String, dynamic> map = {
      Strings.SERVICE_ID: id,
      Strings.SERVICE_NAME: name,
      Strings.SERVICE_USER_ID: userId,
      Strings.SERVICE_DESCRIPTION: description,
      Strings.SERVICE_PRICE: price,
      Strings.SERVICE_DURATION: duration.inMinutes,
      Strings.SERVICE_COLOR: color.value,
      //Strings.SERVICE_HAS_PERIODIC_APPOINTMENTS: hasPeriodicAppointments,
      //Strings.SERVICE_NUMBER_OF_PERIODIC_APPOINTMENTS: numberOfPeriodicAppointments,
      Strings.SERVICE_MINIMUM_SCHEDULING_DELAY_IN_MINUTES: minSchedulingDelayInMinutes,
      Strings.SERVICE_SCHEDULING_INTERVAL_IN_MINUTES: schedulingIntervalInMinutes,
      Strings.SERVICE_FURTHEST_APPOINTMENT_ALLOWED_IN_DAYS: maxSchedulingDelayInDays,
    };

    return map;
  }

  ServiceProvided.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    if(documentSnapshot.data() != null){
      Map<String, dynamic> documentMap = documentSnapshot.data() as Map<String, dynamic>;
      id = documentSnapshot.id;
      name = documentMap[Strings.SERVICE_NAME] ?? "";
      userId = documentMap[Strings.SERVICE_USER_ID] ?? "";
      description = documentMap[Strings.SERVICE_DESCRIPTION] ?? "";
      price = (documentMap[Strings.SERVICE_PRICE] ?? 0.0) + .0;
      duration = Duration(minutes: documentMap[Strings.SERVICE_DURATION] ?? 0);
      color = Color(documentMap[Strings.SERVICE_COLOR] ?? Colors.blue.value);
      //hasPeriodicAppointments = documentMap[Strings.SERVICE_HAS_PERIODIC_APPOINTMENTS] ?? false;
      //numberOfPeriodicAppointments = documentMap[Strings.SERVICE_NUMBER_OF_PERIODIC_APPOINTMENTS];
      minSchedulingDelayInMinutes = documentMap[Strings.SERVICE_MINIMUM_SCHEDULING_DELAY_IN_MINUTES] ?? 30;
      schedulingIntervalInMinutes = documentMap[Strings.SERVICE_SCHEDULING_INTERVAL_IN_MINUTES] ?? 10;
      maxSchedulingDelayInDays = documentMap[Strings.SERVICE_FURTHEST_APPOINTMENT_ALLOWED_IN_DAYS] ?? 30;
    }
  }

  Future<bool> updateServiceProvidedInFirestore(BuildContext context) async {
    print("updateServiceProvidedInFirestore>>>");

    FirebaseFirestore db = FirebaseFirestore.instance;

    bool result = false;

    try{
      if(id.isEmpty){
        CollectionReference servicesProvided = db.collection(Strings.COLLECTION_SERVICES_PROVIDED);
        id = servicesProvided.doc().id;
      }
      if(userId.isEmpty) userId = UserFirebase.getCurrentUser()?.uid ?? "";
      if(userId.isNotEmpty){
        await db.collection(Strings.COLLECTION_SERVICES_PROVIDED).doc(id).set(toMap());
        result = true;
      }
    }
    catch(e){
      Utils.showSnackBar(context, "${AppLocalizations.of(context)!.error_updating_service_provided_message} $e");
      result = false;
    }

    return result;
  }

  Future<bool> deleteServiceProvidedInFirestore(BuildContext context) async {
    print("deleteServiceProvidedInFirestore>>>");

    FirebaseFirestore db = FirebaseFirestore.instance;

    bool result = false;

    try{
      await db.collection(Strings.COLLECTION_SERVICES_PROVIDED).doc(id).delete();
      result = true;
    }
    catch(e){
      Utils.showSnackBar(context, "${AppLocalizations.of(context)!.error_updating_service_provided_message} $e");
      result = false;
    }

    return result;
  }

  static Future<List<ServiceProvided>> getServicesProvidedByUser(AppUser appUser) async {
    List<ServiceProvided> servicesProvidedList = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Strings.COLLECTION_SERVICES_PROVIDED)
        .where(Strings.SERVICE_USER_ID, isEqualTo: appUser.id)
        .get().catchError((error) {
          print("Error getting services provided by user: $error");
        });

    for(var doc in querySnapshot.docs){
      servicesProvidedList.add(ServiceProvided.fromDocumentSnapshot(doc));
    }

    return servicesProvidedList;
  }

  bool isWithinValidSchedulingInterval(DateTime dateTimeToCheck) {
    //print("isWithinBlockedPeriod>>>>>>>>>");
    //print("this = $this");
    DateTime dateTimeToCheckSimplified = Utils.getDateTimeSimplified(dateTimeToCheck);
    DateTime dateTimeNowSimplified = Utils.getDateTimeSimplified(DateTime.now());
    return !dateTimeToCheck.isBefore(DateTime.now().add(Duration(minutes: minSchedulingDelayInMinutes)))
        && !dateTimeToCheckSimplified.isAfter(dateTimeNowSimplified.add(Duration(days: maxSchedulingDelayInDays)));
  }
}
