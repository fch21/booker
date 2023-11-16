import 'package:booker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCustom extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final String label;
  final bool password;
  final TextInputType? textInputType;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final String? Function(String?)? onSaved;
  final Function(String)? onChanged;

  const InputCustom({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.password = false,
    this.textInputType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onSaved,
    this.onChanged,
  }) : super(key: key);

  @override
  State<InputCustom> createState() => _InputCustomState();
}

class _InputCustomState extends State<InputCustom> {

  late bool _passwordObscure;

  @override
  void initState() {
    _passwordObscure = widget.password;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _passwordObscure,
      keyboardType: widget.textInputType,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      style: textStyleSmallNormal,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 10, 20),
          labelText: widget.label,
          hintText: widget.hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          suffixIcon: widget.password
              ? IconButton(
            icon: Icon(
              _passwordObscure ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _passwordObscure = !_passwordObscure;
              });
            },
          )
              : null
      ),
    );
  }
}
