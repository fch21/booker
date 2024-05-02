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
  final Function()? onTap;
  final bool readOnly;

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
    this.onTap,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<InputCustom> createState() => _InputCustomState();
}

class _InputCustomState extends State<InputCustom> {

  late bool _passwordObscure;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasError = false;

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void initState() {
    _passwordObscure = widget.password;
    _focusNode.addListener(_handleFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _passwordObscure,
      keyboardType: widget.textInputType,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      validator: (value){
        if(widget.validator != null){
          String? result = widget.validator!(value);
          if(result != null && !_hasError){
            setState(() {
              _hasError = true;
            });
          }
          else if(result == null && _hasError){
            setState(() {
              _hasError = false;
            });
          }
          return result;
        }
        return null;
      },
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      style: textStyleSmallNormal,
      readOnly: widget.readOnly,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 10, 20),
          labelText: widget.label,
          hintText: widget.hint,
          labelStyle: const TextStyle(color: Colors.black54),
          floatingLabelStyle: TextStyle(color: _hasError ? Colors.red[700] : _isFocused ? standardTheme.primaryColor : Colors.black54),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
          suffixIcon: widget.password
              ? IconButton(
                  icon: Icon(
                    _passwordObscure ? Icons.visibility_off : Icons.visibility,
                    color: _isFocused ? standardTheme.primaryColor : Colors.black54,
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
