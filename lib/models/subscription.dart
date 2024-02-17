import 'package:booker/helper/strings.dart';
import 'package:booker/helper/user_firebase.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Subscription {
  String id = "";
  String userId = "";
  String paymentMethodId = "";
  String discountCodeId = "";
  String status = "";

  Subscription();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      Strings.SUBSCRIPTION_ID: id,
      Strings.SUBSCRIPTION_USER_ID: userId,
      Strings.SUBSCRIPTION_PAYMENT_METHOD_ID: paymentMethodId,
      Strings.SUBSCRIPTION_DISCOUNT_CODE_ID: discountCodeId,
      Strings.SUBSCRIPTION_STATUS: status,
    };

    return map;
  }

  Subscription.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    if(documentSnapshot.data() != null){
      id = documentSnapshot.id;
      userId = (documentSnapshot.data() as Map<String, dynamic>)[Strings.SUBSCRIPTION_USER_ID] ?? "";
      paymentMethodId = (documentSnapshot.data() as Map<String, dynamic>)[Strings.SUBSCRIPTION_PAYMENT_METHOD_ID] ?? "";
      discountCodeId = (documentSnapshot.data() as Map<String, dynamic>)[Strings.SUBSCRIPTION_DISCOUNT_CODE_ID] ?? "";
      status = (documentSnapshot.data() as Map<String, dynamic>)[Strings.SUBSCRIPTION_STATUS] ?? "";
    }
  }

  Future<bool> updateSubscriptionInFirestore(BuildContext context) async {
    print("updateSubscriptionInFirestore>>>");

    FirebaseFirestore db = FirebaseFirestore.instance;

    bool result = false;

    try{
      if(id.isEmpty){
        CollectionReference servicesProvided = db.collection(Strings.COLLECTION_SUBSCRIPTIONS);
        id = servicesProvided.doc().id;
      }
      if(userId.isEmpty) userId = UserFirebase.getCurrentUser()?.uid ?? "";
      if(userId.isNotEmpty){
        await db.collection(Strings.COLLECTION_SUBSCRIPTIONS).doc(id).set(toMap());
        result = true;
      }
    }
    catch(e){
      Utils.showSnackBar(context, "Erro ao atualizar assinatura: $e");
      result = false;
    }

    return result;
  }
}
