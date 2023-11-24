import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/text_input_formatters.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/widgets/custom_divider.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/color_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileCustomer extends StatefulWidget {

  ProfileCustomer();

  @override
  _ProfileCustomerState createState() => _ProfileCustomerState();
}

class _ProfileCustomerState extends State<ProfileCustomer> {
  final TextEditingController _nameController = TextEditingController(text: currentAppUser!.name);

  final _formKey = GlobalKey<FormState>();

  void _createUserNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _userNameFormKey = GlobalKey<FormState>();
        TextEditingController userNameController = TextEditingController();
        bool userNameIsAvailable = false;

        return AlertDialog(
          title: Text('Criar nome de usuário:'),
          content: Form(
            key: _userNameFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('O nome de usuário é o nome uníco que será usado pelos clientes para encontrar você'),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: InputCustom(
                    label: "",
                    controller: userNameController,
                    onSaved: (userName){
                      currentAppUser!.userName = userName ?? "";
                    },
                    validator: (value) {
                      print("value = $value");
                      if(value == "" || value == null ){
                        return AppLocalizations.of(context)!.required_field;
                      }
                      else{
                        if(!userNameIsAvailable) return AppLocalizations.of(context)!.register_unavailable_user_name_message;
                        return null;
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.confirm),
              onPressed: () async {
                bool userNameIsAvailableResult = await AppUser.checkIfUserNameIsAvailable(userNameController.text);
                userNameIsAvailable = userNameIsAvailableResult;
                //print("userNameIsAvailableResult = $userNameIsAvailableResult");
                //print("userNameIsAvailable = $userNameIsAvailable");
                if (_userNameFormKey.currentState?.validate() ?? false) {
                  _userNameFormKey.currentState?.save(); //saves the userName
                  currentAppUser!.isServiceProvider = true;
                  currentAppUser!.updateAppUserInFirestore(context);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();// to pop the Profile Customer screen
                  Navigator.pushNamed(context, RouteGenerator.PROFILE_SERVICE_PROVIDED);
                }
              },
            ),
          ],
        );
      },
    );
  }

  _validateFields() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      currentAppUser!.updateAppUserInFirestore(context);
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.edit)),
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
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: ButtonCustom(
                  onPressed: _validateFields,
                  text: 'Salvar mudanças',
                ),
              ),
              CustomDivider(),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Center(child: Text("Quer se tornar um prestador de serviço?", style: textStyleMediumNormal,))
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: ButtonCustom(
                  onPressed: (){
                    _createUserNameDialog(context);
                  },
                  text: 'Quero ser prestador de serviço',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
