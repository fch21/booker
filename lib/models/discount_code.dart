import 'package:booker/helper/strings.dart';
import 'package:booker/helper/user_firebase.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class DiscountCode {
  String id = "";
  String salesRepId = "";
  String code = "";
  int discountPercentage = 0;
  String status = "";


  DiscountCode();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      Strings.DISCOUNT_CODE_ID: id,
      Strings.DISCOUNT_CODE_SALES_REP_ID: salesRepId,
      Strings.DISCOUNT_CODE_CODE: code,
      Strings.DISCOUNT_CODE_DISCOUNT_PERCENTAGE: discountPercentage,
      Strings.DISCOUNT_CODE_STATUS: status,
    };

    return map;
  }

  DiscountCode.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    if(documentSnapshot.data() != null){
      id = documentSnapshot.id;
      salesRepId = (documentSnapshot.data() as Map<String, dynamic>)[Strings.DISCOUNT_CODE_SALES_REP_ID] ?? "";
      code = (documentSnapshot.data() as Map<String, dynamic>)[Strings.DISCOUNT_CODE_CODE] ?? "";
      discountPercentage = (documentSnapshot.data() as Map<String, dynamic>)[Strings.DISCOUNT_CODE_DISCOUNT_PERCENTAGE] ?? 0;
      status = (documentSnapshot.data() as Map<String, dynamic>)[Strings.DISCOUNT_CODE_STATUS] ?? "";
    }
  }

  Future<bool> updateDiscountCodeInFirestore(BuildContext context) async {
    print("updateDiscountCodeInFirestore>>>");

    FirebaseFirestore db = FirebaseFirestore.instance;

    bool result = false;

    try{
      if(id.isEmpty){
        CollectionReference servicesProvided = db.collection(Strings.COLLECTION_DISCOUNT_CODES);
        id = servicesProvided.doc().id;
      }
      await db.collection(Strings.COLLECTION_DISCOUNT_CODES).doc(id).set(toMap());
      result = true;
    }
    catch(e){
      Utils.showSnackBar(context, "Erro ao atualizar assinatura: $e");
      result = false;
    }

    return result;
  }
}
