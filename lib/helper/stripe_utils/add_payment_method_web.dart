import 'package:booker/helper/stripe_utils/add_payment_method_Interface.dart';
import 'package:booker/helper/stripe_utils/add_payment_method_with_stripe_elements.dart';
import 'package:flutter/material.dart';



class AddPaymentMethodImpl extends AddPaymentMethodInterface{
  @override
  Future<void> launch(BuildContext context) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AddPaymentMethodWithStripeElements())
    );
    return;
  }

}