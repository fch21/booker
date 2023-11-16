import 'package:flutter/services.dart';


class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAll('.', ',');
    final regExp = RegExp(r'^\d{0,6}(,)?\d{0,2}$');

    if (regExp.hasMatch(newText)) {
      return TextEditingValue(
        text: newText,
        selection: newValue.selection.copyWith(
          baseOffset: newText.length,
          extentOffset: newText.length,
        ),
      );
    }

    return oldValue;
  }
}

class IntegerTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    final regExp = RegExp(r'^\d+$'); // Esta expressão regular permite apenas dígitos

    if (regExp.hasMatch(newText) || newText.isEmpty) {
      return newValue;
    }

    return oldValue;
  }
}
