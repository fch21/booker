import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  ColorPickerDialog({required this.initialColor});

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escolha uma cor'),
      content: SingleChildScrollView(
        child: ColorPicker(
          enableAlpha: false,
          pickerColor: _currentColor,
          onColorChanged: (Color color) {
            setState(() {
              _currentColor = color;
            });
          },
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Voltar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_currentColor);
          },
          child: const Text('Selecionar'),
        ),
      ],
    );
  }
}