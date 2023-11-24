import 'package:booker/helper/text_input_formatters.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/color_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfileServiceProvided extends StatefulWidget {

  EditProfileServiceProvided();

  @override
  _EditProfileServiceProvidedState createState() => _EditProfileServiceProvidedState();
}

class _EditProfileServiceProvidedState extends State<EditProfileServiceProvided> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  Color _selectedColor = Colors.blue;

  bool _isLoading = false;
  bool _userNameIsAvailable = false;

  final _formKey = GlobalKey<FormState>();

  final _decimalInputFormatter = DecimalTextInputFormatter();
  final _integerInputFormatter = IntegerTextInputFormatter();

  _validateFields() async {
    bool userNameChanged = _userNameController.text != currentAppUser!.userName;
    if(userNameChanged){
      setState(() {
        _isLoading = true;
      });
      bool userNameIsAvailable = await AppUser.checkIfUserNameIsAvailable(_userNameController.text);
      print("userNameIsAvailable = $userNameIsAvailable");

      _userNameIsAvailable = userNameIsAvailable;

    }
    else{
      _userNameIsAvailable = true;
    }

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      currentAppUser!.updateAppUserInFirestore(context);
      if(mounted) Navigator.of(context).pop();
    }

    if(userNameChanged){
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }

  }

  @override
  void initState() {
    super.initState();
    _nameController.text = currentAppUser!.name;
    _userNameController.text = currentAppUser!.userName;
    _descriptionController.text = currentAppUser!.description;
    _selectedColor = currentAppUser!.color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.edit),
        //backgroundColor: currentAppUser!.getUserColorResolved(),
        //foregroundColor: Utils.getContrastingColor(currentAppUser!.getUserColorResolved()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputCustom(
                label: 'Nome',
                controller: _nameController,
                onSaved: (name){
                  currentAppUser!.name = name ?? "";
                },
                validator: (value) {
                  if(value == "" || value == null ){
                    return AppLocalizations.of(context)!.required_field;
                  }
                  else{
                    return null;
                  }
                },
              ),
              SizedBox(height: 12),
              InputCustom(
                label: 'Nome de usuário',
                controller: _userNameController,
                onSaved: (name){
                  currentAppUser!.userName = name ?? "";
                },
                validator: (value) {
                  if(value == "" || value == null ){
                    return AppLocalizations.of(context)!.required_field;
                  }
                  else{
                    if(!_userNameIsAvailable) return AppLocalizations.of(context)!.register_unavailable_user_name_message;
                    return null;
                  }
                },
              ),
              SizedBox(height: 12),
              InputCustom(
                label: 'Descrição',
                controller: _descriptionController,
                onSaved: (description){
                  currentAppUser!.description = description ?? "";
                },
                validator: (value) {
                  return null;
                },
              ),
              SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  Color? color = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ColorPickerDialog(initialColor: _selectedColor);
                    },
                  );
                  print("cor = $color");
                  if (color != null) {
                    setState(() {
                      _selectedColor = color;
                      currentAppUser!.color = _selectedColor;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Escolher Cor', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.65)),),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            borderRadius: BorderRadius.circular(4.0),  // Bordas arredondadas
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: ButtonCustom(
                  //color: currentAppUser!.getUserColorResolved(),
                  onPressed: _validateFields,
                  text: 'Salvar',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
