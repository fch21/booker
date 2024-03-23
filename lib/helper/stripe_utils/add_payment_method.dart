
import 'package:booker/helper/stripe_utils/add_payment_method_non_web.dart'
if (dart.library.html)'package:booker/helper/stripe_utils/add_payment_method_web.dart';
import 'package:flutter/material.dart';



class AddPaymentMethod {

  static Future<void> launch(BuildContext context) {
    AddPaymentMethodImpl addPaymentMethodImpl = AddPaymentMethodImpl();
    return addPaymentMethodImpl.launch(context);
  }

}