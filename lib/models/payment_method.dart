class PaymentMethod {
  String id = '';
  String cardBrand = '';
  String cardLastFour = '';

  String getCardNumberString(){
    return "**** $cardLastFour";
  }

  PaymentMethod.fromStripeJson(Map<String, dynamic> map) {
    print("PaymentMethod.fromStripeJson = $map");
    id = map['id'] ?? '';
    cardBrand = map["card"]["brand"] ?? '';
    cardLastFour = map["card"]["last4"].toString() ?? '';
  }
}