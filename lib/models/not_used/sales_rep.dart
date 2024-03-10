import 'package:booker/helper/strings.dart';
import 'package:booker/helper/user_firebase.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class DiscountCode {
  String id = "";
  String name = "";
  int numberOfClients = 0;


  DiscountCode();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      Strings.SALES_REP_ID: id,
      Strings.SALES_REP_NAME: name,
      Strings.SALES_REP_NUMBER_OF_CLIENTS: numberOfClients,
    };

    return map;
  }

  DiscountCode.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    if(documentSnapshot.data() != null){
      id = documentSnapshot.id;
      name = (documentSnapshot.data() as Map<String, dynamic>)[Strings.SALES_REP_NAME] ?? "";
      numberOfClients = (documentSnapshot.data() as Map<String, dynamic>)[Strings.SALES_REP_NUMBER_OF_CLIENTS] ?? 0;
    }
  }

  Future<bool> updateSalesRepInFirestore(BuildContext context) async {
    print("updateSalesRepInFirestore>>>");

    FirebaseFirestore db = FirebaseFirestore.instance;

    bool result = false;

    try{
      if(id.isEmpty){
        CollectionReference servicesProvided = db.collection(Strings.COLLECTION_SALES_REPS);
        id = servicesProvided.doc().id;
      }
      await db.collection(Strings.COLLECTION_SALES_REPS).doc(id).set(toMap());
      result = true;
    }
    catch(e){
      Utils.showSnackBar(context, "Erro ao atualizar assinatura: $e");
      result = false;
    }

    return result;
  }
}
