import 'package:booker/helper/strings.dart';
import 'package:booker/helper/user_firebase.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/subscription.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class Coupon {
  String id = '';
  int percentOff = 0; // Percentual de desconto
  int amountOff = 0; // Valor de desconto em centavos
  String duration = ''; // Pode ser 'forever', 'once', ou 'repeating'
  int durationInMonths = 0;
  //DateTime? expiresAt; // Data de expiração do cupom

  String getDurationString(){
    String durationString = '';
    switch(duration){
      case 'forever':
        durationString = 'Vitalício';
        break;
      case 'once':
        durationString = '1 mês';
        break;
      case 'repeating':
        durationString = '$durationInMonths ${durationInMonths > 1 ? 'meses': 'mês'}';
        break;
    }
    return durationString;
  }

  Coupon.fromStripeJson(Map<String, dynamic> map) {
    id = map['id'] ?? '';
    percentOff = map['percent_off'] ?? 0;
    amountOff = map['amount_off'] ?? 0;
    duration = map['duration'] ?? '';
    durationInMonths = map['duration_in_months'] ?? 0;
    //expiresAt = map['redeem_by'] != null ? DateTime.fromMillisecondsSinceEpoch(map['redeem_by'] * 1000) : null;
  }
}
