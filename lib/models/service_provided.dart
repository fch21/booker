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
  Color color = Colors.white;
  bool hasPeriodicAppointments = false;

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
    copy.hasPeriodicAppointments = hasPeriodicAppointments;

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
      Strings.SERVICE_HAS_PERIODIC_APPOINTMENTS: hasPeriodicAppointments,
    };

    return map;
  }

  ServiceProvided.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    if(documentSnapshot.data() != null){
      id = documentSnapshot.id;
      name = (documentSnapshot.data() as Map<String, dynamic>)[Strings.SERVICE_NAME] ?? "";
      userId = (documentSnapshot.data() as Map<String, dynamic>)[Strings.SERVICE_USER_ID] ?? "";
      description = (documentSnapshot.data() as Map<String, dynamic>)[Strings.SERVICE_DESCRIPTION] ?? "";
      price = ((documentSnapshot.data() as Map<String, dynamic>)[Strings.SERVICE_PRICE] ?? 0.0) + .0;
      duration = Duration(minutes: (documentSnapshot.data() as Map<String, dynamic>)[Strings.SERVICE_DURATION] ?? 0);
      color = Color((documentSnapshot.data() as Map<String, dynamic>)[Strings.SERVICE_COLOR] ?? Colors.white.value);
      hasPeriodicAppointments = (documentSnapshot.data() as Map<String, dynamic>)[Strings.SERVICE_HAS_PERIODIC_APPOINTMENTS] ?? false;
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
}
