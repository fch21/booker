import 'package:booker/models/payment_method.dart';
import 'package:booker/widgets/payment_method_preview.dart';
import 'package:flutter/material.dart';

class PaymentMethodPreviewList extends StatefulWidget {

  List<PaymentMethod> paymentMethods;
  void Function(String?)? onPaymentMethodSelected;
  void Function(String?)? onPaymentMethodLongPressed;
  void Function(String?)? onPaymentMethodTrailingPressed;
  Widget? trailing;

   PaymentMethodPreviewList({
    required this.paymentMethods,
    this.onPaymentMethodSelected,
    this.onPaymentMethodLongPressed,
    this.onPaymentMethodTrailingPressed,
    this.trailing,
    Key? key
  }) : super(key: key);

  @override
  State<PaymentMethodPreviewList> createState() => _PaymentMethodPreviewListState();
}

class _PaymentMethodPreviewListState extends State<PaymentMethodPreviewList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.paymentMethods.length,
      itemBuilder: (BuildContext context, int index) {
        return PaymentMethodPreview(
          paymentMethod: widget.paymentMethods[index],
          onSelected: widget.onPaymentMethodSelected,
          onLongPressed: widget.onPaymentMethodLongPressed,
          onTrailingPressed: widget.onPaymentMethodTrailingPressed,
          trailing: widget.trailing,
        );
      },

    );
  }
}
