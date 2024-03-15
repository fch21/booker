import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/color_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfileServiceProvider extends StatefulWidget {

  EditProfileServiceProvider({super.key});

  @override
  _EditProfileServiceProviderState createState() => _EditProfileServiceProviderState();
}

class _EditProfileServiceProviderState extends State<EditProfileServiceProvider> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(text: currentAppUser!.phone);
  Color _selectedColor = Colors.blue;

  //bool _isLoading = false;
  bool _userNameIsAvailable = false;

  final _formKey = GlobalKey<FormState>();

  _validateFields() async {
    bool userNameChanged = _userNameController.text != currentAppUser!.userName;
    if(userNameChanged){
      //setState(() {
      //  _isLoading = true;
      //});
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
        //setState(() {
        //  _isLoading = false;
        //});
      }
    }

  }

  @override
  void initState() {
    super.initState();
    _nameController.text = currentAppUser!.name;
    _userNameController.text = currentAppUser!.userName;
    _descriptionController.text = currentAppUser!.description;
    _phoneController.text = currentAppUser!.phone;
    _selectedColor = currentAppUser!.color;
  }

  @override
  Widget build(BuildContext context) {

    bool greaterWidthLayout = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.edit),
        //backgroundColor: currentAppUser!.getUserColorResolved(),
        //foregroundColor: Utils.getContrastingColor(currentAppUser!.getUserColorResolved()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: greaterWidthLayout ? MediaQuery.of(context).size.width/4 : 16 , vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputCustom(
                label: 'Nome',
                controller: _nameController,
                onSaved: (name){
                  currentAppUser!.name = name?.trim() ?? "";
                  return;
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
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: InputCustom(
                  label: 'Nome de usuário',
                  controller: _userNameController,
                  onSaved: (name){
                    currentAppUser!.userName = name?.trim() ?? "";
                    return;
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
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: InputCustom(
                  label: 'Descrição',
                  controller: _descriptionController,
                  maxLength: 120,
                  maxLines: 2,
                  onSaved: (description){
                    currentAppUser!.description = description?.trim() ?? "";
                    return;
                  },
                  validator: (value) {
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: InputCustom(
                  label: 'Telefone',
                  controller: _phoneController,
                  readOnly: true,
                  onTap: () async {
                    await currentAppUser!.addPhoneNumberToUser(context);
                    setState(() {
                      _phoneController.text = currentAppUser!.phone;
                    });
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text('Cor tema do seu perfil vista pelos clientes:', style: textStyleVerySmallNormal,),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: InkWell(
                  onTap: () async {
                    Color? color = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ColorPickerDialog(initialColor: _selectedColor);
                      },
                    );
                    //print("cor = $color");
                    if (color != null) {
                      Color resolvedColor = Utils.getNotTooLightColor(color);
                      if(resolvedColor != color && mounted) Utils.showSnackBar(context, "A cor escolhida era muito clara. Ela foi ajustada para uma melhor visualização.");
                      setState(() {
                        _selectedColor = resolvedColor;
                        currentAppUser!.color = _selectedColor;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('Escolher Cor', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.65)),),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              borderRadius: BorderRadius.circular(6),  // Bordas arredondadas
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
