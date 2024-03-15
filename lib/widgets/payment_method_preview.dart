import 'package:booker/models/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PaymentMethodPreview extends StatelessWidget {

  PaymentMethod paymentMethod;
  void Function(String?)? onSelected;
  void Function(String?)? onLongPressed;
  void Function(String?)? onTrailingPressed;
  Widget? trailing;

  PaymentMethodPreview({
    required this.paymentMethod,
    this.onSelected,
    this.onLongPressed,
    this.onTrailingPressed,
    this.trailing,
    Key? key
  }) : super(key: key);

  String? _getCardBrandIconPath(String brandName) {

    switch (brandName) {
      case 'visa':
        return "assets/visa_logo.png";
      case 'mastercard':
        return "assets/mastercard_logo.png";
      case 'amex':
        return "assets/amex_logo.png";
      default:
        return null;
    }
  }

  IconData? _getCardBrandIconData(String brandName) {

    switch (brandName) {
      case 'visa':
        return FontAwesomeIcons.ccVisa;
      case 'mastercard':
        return FontAwesomeIcons.ccMastercard;
      case 'amex':
        return FontAwesomeIcons.ccAmex;
      case 'diners':
        return FontAwesomeIcons.ccDinersClub;
      case 'discover':
        return FontAwesomeIcons.ccDiscover;
      case 'jcb':
        return FontAwesomeIcons.ccJcb;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    dynamic brandName = paymentMethod.cardBrand;
    String? brandIconPath;
    IconData? brandIconData;

    if(brandName is String){
      brandIconPath = _getCardBrandIconPath(brandName);
      brandIconData = _getCardBrandIconData(brandName);
    }


    return GestureDetector(
      onTap: (){
        if(onSelected != null) onSelected!(paymentMethod.id);
      },
      onLongPress: (){
        if(onLongPressed != null) onLongPressed!(paymentMethod.id);
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: ListTile(
          leading: brandIconPath != null
              ? Image.asset(brandIconPath, height: 48, width: 48,)
              : Icon(brandIconData ?? Icons.credit_card,size: 40, ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(brandName[0].toUpperCase() + brandName.substring(1), maxLines: 1, overflow: TextOverflow.ellipsis,)),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(paymentMethod.getCardNumberString(), maxLines: 1, overflow: TextOverflow.ellipsis,),
                    if(trailing != null) Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: GestureDetector(
                        onTap: (){
                          if(onTrailingPressed != null) onTrailingPressed!(paymentMethod.id);
                        },
                        child: trailing!
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}