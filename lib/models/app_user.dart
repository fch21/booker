import 'package:booker/helper/strings.dart';
import 'package:booker/helper/text_input_formatters.dart';
import 'package:booker/helper/user_sign.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/time_interval.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'appointment_details.dart';

class AppUser {
  String id = "";
  String name = "";
  String userName = "";
  String description = "";
  String email = "";
  String phone = "";
  String password = "";
  bool tutorialDone = false;
  bool wantNotifications = true;
  String language = "";
  String defaultPaymentMethodId = "";
  String urlProfileUserImage = "";
  String urlProfileBgImage = "";
  Color color = Colors.white;
  //String subscriptionId = "";

  bool isServiceProvider = false;
  bool hasActiveSubscription = false;
  Map<String, dynamic> availabilityMap = {};
  List blockedClientsIds = [];

  AppUser();

  AppUser copy(){
    AppUser copy = AppUser();
    copy.id = id;
    copy.name = name;
    copy.userName = userName;
    copy.description = description;
    copy.email = email;
    copy.phone = phone;
    copy.password = password;
    copy.tutorialDone = tutorialDone;
    copy.wantNotifications = wantNotifications;
    copy.language = language;
    copy.defaultPaymentMethodId = defaultPaymentMethodId;
    copy.urlProfileUserImage = urlProfileUserImage;
    copy.urlProfileBgImage = urlProfileBgImage;
    copy.color = color;
    //copy.subscriptionId = subscriptionId;

    return copy;
  }

  Color getUserColorResolved(){
    Color colorResolved;

    if(color != Colors.white) {
      colorResolved = color;
    }
    else {
      colorResolved = standartTheme.primaryColor;
    }

    return colorResolved;
  }

  Map<String, dynamic> convertAvailabilityMapToMap() {
    print("convertAvailabilityMapToMap >>>>>>>>");
    Map<String, dynamic> map = {};
    for (var entry in availabilityMap.entries) {
      List<Map<String, dynamic>> intervalsMap = [];
      //var intervals = entry.value['intervals'] as List<TimeInterval>;
      var schedules = entry.value['intervals'] as List;
      //for (var interval in intervals) {
      for (var schedule in schedules) {
        //intervalsMap.add(interval.toMap());
        intervalsMap.add({
          'timeInterval': (schedule['timeInterval'] as TimeInterval).toMap(),
          'isSelected': schedule['isSelected']
        });
      }
      print("intervalsMap = $intervalsMap");
      map[entry.key] = {
        'isSelected': entry.value['isSelected'],
        'intervals': intervalsMap,
      };
    }
    return map;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      Strings.USER_ID: id,
      Strings.USER_NAME: name,
      Strings.USER_USERNAME: userName,
      Strings.USER_DESCRIPTION: description,
      Strings.USER_EMAIL: email,
      Strings.USER_PHONE: phone,
      Strings.USER_TUTORIAL_DONE: tutorialDone,
      Strings.USER_WANT_NOTIFICATIONS: wantNotifications,
      Strings.USER_LANGUAGE: language,
      Strings.USER_URL_PROFILE_USER_IMAGE: urlProfileUserImage,
      Strings.USER_URL_PROFILE_BG_IMAGE: urlProfileBgImage,
      Strings.USER_COLOR: color.value,
      //Strings.USER_SUBSCRIPTION_ID: subscriptionId,

      Strings.USER_IS_SERVICE_PROVIDER: isServiceProvider,
      Strings.USER_HAS_ACTIVE_SUBSCRIPTION: hasActiveSubscription,
      Strings.USER_BLOCKED_CLIENTS_IDS: blockedClientsIds,
      Strings.USER_AVAILABILITY_MAP: convertAvailabilityMapToMap(),
    };

    return map;
  }

  Map<String, dynamic> toMapPublic() {
    Map<String, dynamic> map = {
      Strings.USER_ID: id,
      Strings.USER_NAME: name,
      Strings.USER_USERNAME: userName,
      Strings.USER_URL_PROFILE_USER_IMAGE: urlProfileUserImage,
      Strings.USER_URL_PROFILE_BG_IMAGE: urlProfileBgImage,
      Strings.USER_COLOR: color.value,

      Strings.USER_IS_SERVICE_PROVIDER: isServiceProvider,
      Strings.USER_BLOCKED_CLIENTS_IDS: blockedClientsIds,
      //Strings.USER_AVAILABILITY_MAP: availabilityMap,
      Strings.USER_AVAILABILITY_MAP: convertAvailabilityMapToMap(),
    };

    return map;
  }

  void convertMapToAvailabilityMap(Map<String, dynamic>? map) {
    print("convertMapToAvailabilityMap");
    availabilityMap.clear();
    map?.forEach((key, value) {
      var intervalsList = value['intervals'] as List;
      List<Map<String, dynamic>> intervals = intervalsList.map((intervalMap) {
        return {
          'isSelected': intervalMap['isSelected'] as bool,
          'timeInterval': TimeInterval.fromMap(intervalMap['timeInterval'] as Map<String, dynamic>),
        };
        //return TimeInterval.fromMap(intervalMap as Map<String, dynamic>);
      }).toList();
      availabilityMap[key] = {
        'isSelected': value['isSelected'],
        'intervals': intervals,
      };
    });
  }

  AppUser.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    if(documentSnapshot.data() != null){
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      id = documentSnapshot.id;
      name = data.containsKey(Strings.USER_NAME) ? documentSnapshot[Strings.USER_NAME] ?? "" :  "";
      userName = data.containsKey(Strings.USER_USERNAME) ? documentSnapshot[Strings.USER_USERNAME] ?? "" :  "";
      description = data.containsKey(Strings.USER_DESCRIPTION) ? documentSnapshot[Strings.USER_DESCRIPTION] ?? "" :  "";
      email = data.containsKey(Strings.USER_EMAIL) ? documentSnapshot[Strings.USER_EMAIL] ?? "" :  "";
      phone = data.containsKey(Strings.USER_PHONE) ? documentSnapshot[Strings.USER_PHONE] ?? "" :  "";
      tutorialDone = data.containsKey(Strings.USER_TUTORIAL_DONE) ? documentSnapshot[Strings.USER_TUTORIAL_DONE] ?? false : false;
      wantNotifications = data.containsKey(Strings.USER_WANT_NOTIFICATIONS) ? documentSnapshot[Strings.USER_WANT_NOTIFICATIONS] ?? true : true;
      language = data.containsKey(Strings.USER_LANGUAGE) ? documentSnapshot[Strings.USER_LANGUAGE] ?? "" :  "";
      urlProfileUserImage = data[Strings.USER_URL_PROFILE_USER_IMAGE] ?? "";
      urlProfileBgImage = data[Strings.USER_URL_PROFILE_BG_IMAGE] ?? "";
      color = Color((documentSnapshot.data() as Map<String, dynamic>)[Strings.SERVICE_COLOR] ?? Colors.white.value);
      //subscriptionId = data[Strings.USER_SUBSCRIPTION_ID] ?? "";

      isServiceProvider = data[Strings.USER_IS_SERVICE_PROVIDER] ?? false;
      hasActiveSubscription = data[Strings.USER_HAS_ACTIVE_SUBSCRIPTION] ?? false;
      blockedClientsIds = data[Strings.USER_BLOCKED_CLIENTS_IDS] ?? [];
      //availabilityMap = (documentSnapshot.data() as Map<String, dynamic>)[Strings.USER_AVAILABILITY_MAP] ?? {};
      convertMapToAvailabilityMap(data[Strings.USER_AVAILABILITY_MAP] as Map<String, dynamic>?);


    }
  }

  AppUser.fromDocumentSnapshotPublic(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    id = documentSnapshot.id;
    name = data[Strings.USER_NAME] ?? "";
    userName = data.containsKey(Strings.USER_USERNAME) ? documentSnapshot[Strings.USER_USERNAME] ?? "" :  "";
    description = data.containsKey(Strings.USER_DESCRIPTION) ? documentSnapshot[Strings.USER_DESCRIPTION] ?? "" :  "";
    urlProfileUserImage = data[Strings.USER_URL_PROFILE_USER_IMAGE] ?? "";
    urlProfileBgImage = data[Strings.USER_URL_PROFILE_BG_IMAGE] ?? "";
    color = Color((documentSnapshot.data() as Map<String, dynamic>)[Strings.SERVICE_COLOR] ?? Colors.white.value);

    isServiceProvider = data[Strings.USER_IS_SERVICE_PROVIDER] ?? false;
    //availabilityMap = data[Strings.USER_AVAILABILITY_MAP] ?? {};
    convertMapToAvailabilityMap(data[Strings.USER_AVAILABILITY_MAP] as Map<String, dynamic>?);
  }

  Future<bool> updateAppUserInFirestore(BuildContext context) async {
    print("updateAppUserInFirestore>>>");

    FirebaseFirestore db = FirebaseFirestore.instance;

    bool result = false;

    if(id.isNotEmpty){
      try{
        await db.collection(Strings.COLLECTION_USERS).doc(id).set(toMap());
        result = true;
      }
      catch(e){
        Utils.showSnackBar(context, "${AppLocalizations.of(context)!.error_updating_user_message} $e");
        result = false;
      }
    }

    return result;
  }

  Future<void> addPhoneNumberToUser(BuildContext buildContext) async {

    String? phoneNumber;
    bool shouldVerifyPhone = false;

    await showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: const Text("Adicionar número de telefone"),
          content:IntlPhoneField(
            inputFormatters: [IntegerTextInputFormatter()],
            decoration: const InputDecoration(
              labelText: 'Número com DDD',
              border: OutlineInputBorder(
                borderSide: BorderSide(),
              ),
            ),
            initialCountryCode: 'BR',
            onChanged: (phone) {
              print(phone.completeNumber);
              bool isValidNumber = false;
              try{
                isValidNumber = phone.isValidNumber();
              }
              catch(e){print(e);}
              print(isValidNumber);
              if(isValidNumber){
                phoneNumber = phone.completeNumber;
              }
              else{
                phoneNumber = null;
              }
            },
            initialValue: "",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Confirmar"),
              onPressed: () async {
                if(phoneNumber != null){
                  shouldVerifyPhone = true;
                  Navigator.of(context).pop();
                }
                else{
                  Utils.showSnackBar(context, "Adicione um número válido");
                }
              },
            ),
          ],
        );
      },
    );
    if(shouldVerifyPhone && buildContext.mounted){
      await UserSign.verifyPhoneNumber(buildContext: buildContext, phoneNumber: phoneNumber!, onConfirmed: (){
        phone = phoneNumber!;
        updateAppUserInFirestore(buildContext);
      });
    }
    return;
  }

  String getLinkToTheUserProfile(){
    return "${Strings.BOOKER_DOMAIN}?id=$id";
  }

  Future<List<AppUser>> getClients() async {

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Strings.COLLECTION_USERS)
        .doc(id)
        .collection(Strings.COLLECTION_CLIENTS)
        .get();

    List<AppUser> clients = AppUser.getAppUsersFromDocumentSnapshots(querySnapshot.docs);

    return clients;
  }

  //only works if the user is a service provider
  Future<List<AppointmentDetails>> getAppointmentDetailsOfClient({required AppUser client}) async {
    List<AppointmentDetails> appointmentDetailsOfClientList = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Strings.COLLECTION_APPOINTMENTS_DETAILS)
        .where(Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID, isEqualTo: id)
        .where(Strings.APPOINTMENT_USER_ID, isEqualTo: client.id)
        .get().catchError((error) {
      print("Error getting services provided by user: $error");
    });

    for(var doc in querySnapshot.docs){
      appointmentDetailsOfClientList.add(AppointmentDetails.fromDocumentSnapshot(doc));
    }

    return appointmentDetailsOfClientList;
  }

  Future<List<AppointmentDetails>> getOrderedAppointmentDetailsOfClient({required AppUser client}) async {
    List<AppointmentDetails> orderedAppointmentDetailsOfClientList = await getAppointmentDetailsOfClient(client: client);

    orderedAppointmentDetailsOfClientList.sort((a, b) => b.from.compareTo(a.from));

    return orderedAppointmentDetailsOfClientList;
  }

  static Future<AppUser?> getUserFromId(String userId) async {
    //print("getUserFromId>>>>>>>>>");
    //print("userId = ${userId}");
    AppUser? user;
    try{
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(Strings.COLLECTION_USERS)
          //.collection(Strings.COLLECTION_USERS_PUBLIC)
          .doc(userId)
          .get();
      if(userDoc.data() != null) {
        user = AppUser.fromDocumentSnapshotPublic(userDoc);
      }
    }
    catch(e){
      print(e);
    }
    return user;
  }

  static Future<AppUser?> getUserFromUserName(String userName) async {
    //print("getUserFromUserName>>>>>>>>>");
    //print("userName = ${userName}");
    AppUser? user;
    try{
      QuerySnapshot querySnapshot =  await FirebaseFirestore.instance
          .collection(Strings.COLLECTION_USERS_PUBLIC)
          .where(Strings.USER_USERNAME, isEqualTo: userName)
          .get();

      if(querySnapshot.docs.length == 1){
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        if(userDoc.data()!= null) {
          user = AppUser.fromDocumentSnapshotPublic(userDoc);
        }
      }
    }
    catch(e){
      print(e);
    }
    return user;
  }

  static List<AppUser> getAppUsersFromDocumentSnapshots(List<DocumentSnapshot> documentSnapshots){

    List<AppUser> appUsersList = [];

    for(var documentSnapshot in documentSnapshots){
      appUsersList.add(AppUser.fromDocumentSnapshot(documentSnapshot));
    }

    return appUsersList;
  }

  static Future<bool> checkIfUserNameIsAvailable(String userName) async {

    bool userNameIsAvailable = false;

    print("checkIfUserNameIsAvailable");
    print("userName = $userName");
    QuerySnapshot querySnapshot =  await FirebaseFirestore.instance
        .collection(Strings.COLLECTION_USERS)
        ///change to COLLECTION_USERS_PUBLIC after setting cloud functions
        //.collection(Strings.COLLECTION_USERS_PUBLIC)
        .where(Strings.USER_USERNAME, isEqualTo: userName)
        .get();

    if(querySnapshot.docs.isEmpty) userNameIsAvailable = true;

    return userNameIsAvailable;

  }

  @override
  String toString() {
    // TODO: implement toString
    return "AppUser: ${toMap()}";
  }
}
