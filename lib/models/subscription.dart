import 'package:booker/helper/strings.dart';
import 'package:booker/helper/user_firebase.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/coupon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Subscription {
  String id = "";
  DateTime creationDate = DateTime.now();
  List<String> planIds = [];
  String status = "";
  DateTime currentPeriodStart = DateTime.now();
  DateTime currentPeriodEnd = DateTime.now();
  Coupon? coupon;

  Subscription();

  bool checkStatus(String statusName) {
    return status == statusName;
  }

  bool get isValid => status == "active";
  bool get isCanceled => status ==  "canceled";

  Subscription.fromStripeJson(Map<String, dynamic> map) {
    id = map['id'];
    status = map['status'];
    creationDate = DateTime.fromMillisecondsSinceEpoch(map['created'] * 1000);
    currentPeriodStart = DateTime.fromMillisecondsSinceEpoch(map['current_period_start'] * 1000);
    currentPeriodEnd = DateTime.fromMillisecondsSinceEpoch(map['current_period_end'] * 1000);

    if (map.containsKey('discount') && map['discount'] != null) {
      coupon = Coupon.fromStripeJson(map['discount']['coupon']);
    }

    if (map.containsKey('items') && map['items']['data'] is List) {
      //planIds = map['items']['data'].map<String>((item) => item['plan']['id']).toList();
    }
  }

  static String getSubscriptionPriceString(Coupon? coupon){
    double amount = Consts.SUBSCRIPTION_PRICE;
    if(coupon != null){
      amount = amount * (1 - (coupon.percentOff/100));
    }
    return "R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}";
  }
}
