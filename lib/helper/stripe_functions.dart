import 'dart:async';

import 'package:booker/helper/http_functions.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/user_firebase.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/coupon.dart';
import 'package:booker/models/subscription.dart';
//import 'package:js/js_util.dart';
//import 'package:pay/pay.dart' as pay;
//import 'package:drinqr/main.dart';
//import 'package:js/js.dart';

//@JS('createPaymentMethod')
//external dynamic _createPaymentMethod(dynamic cardDetails, String customerId);


class StripeFunctions {
/*
  static Future<void> makeStripePaymentAutomatic({
    required BuildContext context,
    required int amount,
    required String currency,
    required String userId,
    required String userEmail,
    required String eventId,
    required Function(String) ifPaymentIsSucceeded,
  }) async {

    Map<String, dynamic>? paymentIntentData;

    final requestMap = {
      Strings.STRIPE_MAP_AMOUNT: amount.toString(),
      Strings.STRIPE_MAP_CURRENCY: currency,
      Strings.STRIPE_MAP_EVENT_ID : eventId,
      Strings.STRIPE_MAP_BUYER_USER_ID : userId,
      Strings.STRIPE_MAP_USER_EMAIL : userEmail
    };

    Map<String, dynamic>? responseBody = await HttpFunctions.getResponseMap(url: Strings.HTTPS_LINK_STRIPE_PAYMENT_AUTOMATIC, requestMap: requestMap);

    if(responseBody != null){
      if(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS].toString().contains(Strings.STRIPE_HTTP_RESPONSE_ERROR)){
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_buying_drinks)));
        return;
      }
      else{

        paymentIntentData = responseBody;
        print("paymentIntentData");
        print(paymentIntentData);

        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              customerId: userId,
              paymentIntentClientSecret: paymentIntentData[Strings.STRIPE_MAP_PAYMENT_INTENT_CLIENT_SECRET] ?? "",
              testEnv: true,
              applePay: true,
              googlePay: true,
              style: ThemeMode.dark,
              merchantCountryCode: Strings.STRIPE_MAP_PAYMENT_INTENT_MERCHANT_COUNTRY_CODE,
              merchantDisplayName: Strings.STRIPE_MAP_PAYMENT_INTENT_MERCHANT_DISPLAY_NAME,
            ));

        //setState(() {});

        await _displayPaymentSheet(context).then((value) {

          //Stripe.instance.confirmPaymentSheetPayment();
          print("paymentIntentData : ");
          print(paymentIntentData);
          //Stripe.instance.retrievePaymentIntent(paymentIntentData['client_secret']).then((paymentIntent) {});

          String paymentIntentId = paymentIntentData![Strings.STRIPE_MAP_PAYMENT_INTENT_ID];

          ifPaymentIsSucceeded(paymentIntentId);

          Navigator.pop(context);
          print("test2");

        });
        return;
      }
    }
  }

 */

/*
  static Future<void> _displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.payment_successful)));
    } catch (e) {
      print(e);
    }
  }

  static Future<void> makeStripePaymentManual({
    required BuildContext context,
    required int amount,
    required String currency,
    required String userId,
    required String userEmail,
    required String eventId,
    required Function(String) ifPaymentIsSucceeded,
  }) async {
    Map<String, dynamic>? paymentIntentData;

    final requestMap = {
      Strings.STRIPE_MAP_AMOUNT: amount.toString(),
      Strings.STRIPE_MAP_CURRENCY: currency,
      Strings.STRIPE_MAP_USER_EMAIL: userEmail,
    };

    Map<String, dynamic>? responseBody = await HttpFunctions.getResponseMap(url: Strings.HTTPS_LINK_STRIPE_PAYMENT_MANUAL, requestMap: requestMap);

    if(responseBody != null){
      if(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS].toString().contains(Strings.STRIPE_HTTP_RESPONSE_ERROR)){
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return;
        //setState(() {
        //_isDoingOperation = false;
        //});
      }
      else{

        paymentIntentData = responseBody;
        print("paymentIntentData");
        print(paymentIntentData);


        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                customerId: userId,
                paymentIntentClientSecret: paymentIntentData[Strings.STRIPE_MAP_PAYMENT_INTENT_CLIENT_SECRET] ?? "",
                //testEnv: true,
                //applePay: true,
                //googlePay: true,
                style: ThemeMode.dark,
                //merchantCountryCode: Strings.STRIPE_MAP_PAYMENT_INTENT_MERCHANT_COUNTRY_CODE,
                merchantDisplayName: Strings.STRIPE_MAP_PAYMENT_INTENT_MERCHANT_DISPLAY_NAME));

        //setState(() {});

        await _displayPaymentSheet(context).then((value) {

          //Stripe.instance.confirmPaymentSheetPayment();
          //Stripe.instance.retrievePaymentIntent(paymentIntentData['client_secret']).then((paymentIntent) {});

          String paymentIntentId = paymentIntentData![Strings.STRIPE_MAP_PAYMENT_INTENT_ID];

          //_setBuyOrderFirebase(paymentIntentId, order);
          ifPaymentIsSucceeded(paymentIntentId);

          //Navigator.pop(context);

        });
        return;
      }
    }
  }


 */


  static Future<Map<String, dynamic>?> fetchSetupIntent() async {
    print("fetchSetupIntent>>>>> ");
    Map<String, dynamic>? responseBody = await HttpFunctions.getResponseMap(url: Strings.HTTPS_LINK_CREATE_SETUP_INTENT, requestMap: {});
    print("responseBody = $responseBody ");
    return responseBody;
  }

  /*
  static Future<void> attachCardToCustomer({
    required AppUser user,
  }) async {
    //print("attachCardToCustomer = $cardDetails");

    // 1. create some billing details
    final billingDetails = BillingDetails(
      name: user.name,
      email: user.email,
    );

    //String? paymentMethodId = await createPaymentMethod(cardDetails: cardDetails, billingDetails: billingDetails,customerId: user.id);

/*
    await Stripe.instance.dangerouslyUpdateCardDetails(cardDetails);

    final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
        options: const PaymentMethodOptions(
            setupFutureUsage: PaymentIntentsFutureUsage.OffSession
        )
    );

 */

/*
    CardTokenParams cardTokenParams = CardTokenParams(type: TokenType.Card, );
    CreateTokenParams createTokenParams = CreateTokenParams.card(params: cardTokenParams);


    await Stripe.instance.createToken(createTokenParams);

    final paymentMethod2 = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.cardFromToken(
          paymentMethodData: PaymentMethodDataCardFromToken(
            token: '',
            billingDetails: billingDetails,
          ),
        ),
        options: const PaymentMethodOptions(
            setupFutureUsage: PaymentIntentsFutureUsage.OffSession
        )
    );


 */

    /*
    if (paymentMethodId != null) {
      final requestMap = {
        //Strings.STRIPE_MAP_CUSTOMER_ID: user.id.toString(),
        Strings.STRIPE_MAP_PAYMENT_METHOD_ID: paymentMethodId,
      };
      
      Map<String, dynamic>? responseBody = await HttpFunctions.getResponseMap(url: Strings.HTTPS_LINK_ATTACH_PAYMENT_METHOD_TO_CUSTOMER, requestMap: requestMap);
      
      if(responseBody != null){
        if(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS].toString().contains(Strings.STRIPE_HTTP_RESPONSE_ERROR)){
          print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
          return;
          //setState(() {
          //_isDoingOperation = false;
          //});
        }
        else{
          print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
      
          return;
        }
      }
    }

     */
  }

   */

/*
  static Future<bool> chargeCardOffSession({
    required int amount,
    required String currency,
    required String userId,
    required String eventId,
    required String paymentMethodId,
  }) async {

    final requestMap = {
      Strings.STRIPE_MAP_AMOUNT: amount.toString(),
      Strings.STRIPE_MAP_CURRENCY: currency,
      Strings.STRIPE_MAP_CUSTOMER_ID: userId,
      Strings.STRIPE_MAP_EVENT_ID: eventId,
      Strings.STRIPE_MAP_PAYMENT_METHOD_ID: paymentMethodId,
    };

    Map<String, dynamic>? responseBody = await HttpFunctions.getResponseMap(url: Strings.HTTPS_LINK_CHARGE_CARD_OFF_SESSION, requestMap: requestMap);

    if(responseBody != null){
      if(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS].toString().contains(Strings.STRIPE_HTTP_RESPONSE_ERROR)){
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return false;
        //setState(() {
        //_isDoingOperation = false;
        //});
      }
      else{
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return true;
      }
    }
    print(Strings.STRIPE_HTTP_RESPONSE_UNKNOWN_ERROR);
    return false;
  }

 */

  /*
  static Future<void> detachCardFromCustomer({
    required AppUser user,
    required String paymentMethodId
  }) async {

    final requestMap = {
      Strings.STRIPE_MAP_PAYMENT_METHOD_ID: paymentMethodId,
    };

    Map<String, dynamic>? responseBody = await HttpFunctions.getResponseMap(url: Strings.HTTPS_LINK_DETACH_PAYMENT_METHOD_FROM_CUSTOMER, requestMap: requestMap);

    if(responseBody != null){
      if(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS].toString().contains(Strings.STRIPE_HTTP_RESPONSE_ERROR)){
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return;
      }
      else{
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);

        return;
      }
    }
    return;
  }
   */

  static Future<List> getCustomerPaymentMethods({
    required String userId,
  }) async {

    //final requestMap = {Strings.STRIPE_MAP_CUSTOMER_ID: userId,};
    final requestMap = {};

    Map<String, dynamic>? responseBody = await HttpFunctions.getResponseMap(url: Strings.HTTPS_LINK_GET_CUSTOMER_PAYMENT_METHODS, requestMap: requestMap);

    if(responseBody != null){
      if(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS].toString().contains(Strings.STRIPE_HTTP_RESPONSE_ERROR)){
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return [];
      }
      else{

        List paymentMethods = [];

        paymentMethods = responseBody[Strings.STRIPE_HTTP_RESPONSE_PAYMENT_METHODS] ?? [];

        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return paymentMethods;
      }
    }
    print(Strings.STRIPE_HTTP_RESPONSE_UNKNOWN_ERROR);
    return [];
  }

  static Future<List> getCustomerPaymentIntents() async {
    print("getCustomerPaymentIntents >>>>>>>>>>");

    final requestMap = {};

    Map<String, dynamic>? responseBody = await HttpFunctions.getResponseMap(url: Strings.HTTPS_LINK_GET_CUSTOMER_PAYMENT_INTENTS, requestMap: requestMap);

    if(responseBody != null){
      if(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS].toString().contains(Strings.STRIPE_HTTP_RESPONSE_ERROR)){
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return [];
      }
      else{

        List paymentIntents = [];

        paymentIntents = responseBody[Strings.STRIPE_HTTP_RESPONSE_PAYMENT_INTENTS] ?? [];

        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return paymentIntents;
      }
    }
    print(Strings.STRIPE_HTTP_RESPONSE_UNKNOWN_ERROR);
    return [];
  }

  static Future<Subscription?> getCustomerSubscription() async {

    final requestMap = {};

    Map<String, dynamic>? responseBody = await HttpFunctions.getResponseMap(url: Strings.HTTPS_LINK_GET_CUSTOMER_SUBSCRIPTION, requestMap: requestMap);

    if(responseBody != null){
      if(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS].toString().contains(Strings.STRIPE_HTTP_RESPONSE_ERROR)){
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return null;
      }
      else{
        print(responseBody);
        Subscription subscription = Subscription.fromStripeJson(responseBody);
        return subscription;
      }
    }

    return null;
  }

  static Future<bool> cancelCustomerSubscription() async {

    final requestMap = {};

    Map<String, dynamic>? responseBody = await HttpFunctions.getResponseMap(url: Strings.HTTPS_LINK_CANCEL_CUSTOMER_SUBSCRIPTION, requestMap: requestMap);

    if(responseBody != null){
      if(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS].toString().contains(Strings.STRIPE_HTTP_RESPONSE_ERROR)){
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return false;
      }
      else{
        print(responseBody);
        return true;
      }
    }

    return false;
  }

  static Future<Coupon?> getCouponFromPromotionCode({
    String? promotionCode,
  }) async {

    final requestMap = {
      Strings.STRIPE_MAP_PROMOTION_CODE: promotionCode,
    };

    Map<String, dynamic>? responseBody = await HttpFunctions.getResponseMap(url: Strings.HTTPS_LINK_GET_COUPON_FROM_PROMOTION_CODE, requestMap: requestMap);

    if(responseBody != null){
      if(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS].toString().contains(Strings.STRIPE_HTTP_RESPONSE_ERROR)){
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return null;
      }
      else{
        print(responseBody);
        Coupon promotionCode = Coupon.fromStripeJson(responseBody);
        return promotionCode;
      }
    }

    return null;
  }

  static Future<bool> createSubscriptionForCustomer({
    String? promotionCode,
  }) async {

    final requestMap = {
      Strings.STRIPE_MAP_PROMOTION_CODE: promotionCode,
    };

    Map<String, dynamic>? responseBody = await HttpFunctions.getResponseMap(url: Strings.HTTPS_LINK_CREATE_SUBSCRIPTION_FOR_CUSTOMER, requestMap: requestMap);

    if(responseBody != null){
      if(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS].toString().contains(Strings.STRIPE_HTTP_RESPONSE_ERROR)){
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return false;
      }
      else{
        print(responseBody[Strings.STRIPE_HTTP_RESPONSE_STATUS]);
        return true;
      }
    }

    return false;
  }

}

