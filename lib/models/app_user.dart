import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/models/time_interval.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppUser {
  String id = "";
  String name = "";
  String userName = "";
  String description = "";
  String email = "";
  String password = "";
  bool tutorialDone = false;
  bool wantNotifications = true;
  String language = "";
  String defaultPaymentMethodId = "";
  String urlProfileUserImage = "";
  String urlProfileBgImage = "";

  bool isServiceProvider = false;
  Map<String, dynamic> availabilityMap = {};

  AppUser();

  Map<String, dynamic> convertAvailabilityMapToMap() {
    print("convertAvailabilityMapToMap >>>>>>>>");
    Map<String, dynamic> map = {};
    for (var entry in availabilityMap.entries) {
      List<Map<String, dynamic>> intervalsMap = [];
      var intervals = entry.value['intervals'] as List<TimeInterval>;
      for (var interval in intervals) {
        intervalsMap.add(interval.toMap());
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
      Strings.USER_TUTORIAL_DONE: tutorialDone,
      Strings.USER_WANT_NOTIFICATIONS: wantNotifications,
      Strings.USER_LANGUAGE: language,
      Strings.USER_URL_PROFILE_USER_IMAGE: urlProfileUserImage,
      Strings.USER_URL_PROFILE_BG_IMAGE: urlProfileBgImage,

      Strings.USER_IS_SERVICE_PROVIDER: isServiceProvider,
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

      Strings.USER_IS_SERVICE_PROVIDER: isServiceProvider,
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
      List<TimeInterval> intervals = intervalsList.map((intervalMap) {
        return TimeInterval.fromMap(intervalMap as Map<String, dynamic>);
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
      email = data.containsKey(Strings.USER_EMAIL) ? documentSnapshot[Strings.USER_EMAIL] ?? "" :  "";
      tutorialDone = data.containsKey(Strings.USER_TUTORIAL_DONE) ? documentSnapshot[Strings.USER_TUTORIAL_DONE] ?? false : false;
      wantNotifications = data.containsKey(Strings.USER_WANT_NOTIFICATIONS) ? documentSnapshot[Strings.USER_WANT_NOTIFICATIONS] ?? true : true;
      language = data.containsKey(Strings.USER_LANGUAGE) ? documentSnapshot[Strings.USER_LANGUAGE] ?? "" :  "";
      urlProfileUserImage = data[Strings.USER_URL_PROFILE_USER_IMAGE] ?? "";
      urlProfileBgImage = data[Strings.USER_URL_PROFILE_BG_IMAGE] ?? "";

      isServiceProvider = data[Strings.USER_IS_SERVICE_PROVIDER] ?? false;
      //availabilityMap = (documentSnapshot.data() as Map<String, dynamic>)[Strings.USER_AVAILABILITY_MAP] ?? {};
      convertMapToAvailabilityMap(data[Strings.USER_AVAILABILITY_MAP] as Map<String, dynamic>?);


    }
  }

  AppUser.fromDocumentSnapshotPublic(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    id = documentSnapshot.id;
    name = data[Strings.USER_NAME] ?? "";
    userName = data.containsKey(Strings.USER_USERNAME) ? documentSnapshot[Strings.USER_USERNAME] ?? "" :  "";
    urlProfileUserImage = data[Strings.USER_URL_PROFILE_USER_IMAGE] ?? "";
    urlProfileBgImage = data[Strings.USER_URL_PROFILE_BG_IMAGE] ?? "";

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

  static List<AppUser> getAppUsersFromDocumentSnapshots(List<DocumentSnapshot> documentSnapshots){

    List<AppUser> appUsersList = [];

    for(var documentSnapshot in documentSnapshots){
      appUsersList.add(AppUser.fromDocumentSnapshot(documentSnapshot));
    }

    return appUsersList;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "AppUser: ${toMap()}";
  }
}
