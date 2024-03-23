import 'package:booker/helper/route_generator.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/widgets/custom_divider.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfileClient extends StatefulWidget {

  EditProfileClient();

  @override
  _EditProfileClientState createState() => _EditProfileClientState();
}

class _EditProfileClientState extends State<EditProfileClient> {
  final TextEditingController _nameController = TextEditingController(text: currentAppUser!.name);
  //final TextEditingController _emailController = TextEditingController(text: currentAppUser!.email);
  final TextEditingController _phoneController = TextEditingController(text: currentAppUser!.phone);

  final _formKey = GlobalKey<FormState>();

  Future<void> _mustHavePhoneNumberDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: const Text('Para se tornar um prestador de serviço, é necessário configurar um número de telefone.'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await currentAppUser!.addPhoneNumberToUser(context);
                setState(() {});
              },
            ),
          ],
        );
      },
    );
    return;
  }

  void _createUserNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final userNameFormKey = GlobalKey<FormState>();
        TextEditingController userNameController = TextEditingController();
        bool userNameIsAvailable = false;

        return AlertDialog(
          title: const Text('Criar nome de usuário:'),
          content: Form(
            key: userNameFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('O nome de usuário é o nome uníco que será usado pelos clientes para encontrar você'),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: InputCustom(
                    label: "",
                    controller: userNameController,
                    onSaved: (userName){
                      currentAppUser!.userName = userName ?? "";
                      return;
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
                if (userNameFormKey.currentState?.validate() ?? false) {
                  userNameFormKey.currentState?.save(); //saves the userName
                  currentAppUser!.isServiceProvider = true;
                  currentAppUser!.updateAppUserInFirestore(context);
                  Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.PROFILE_SERVICE_PROVIDER, (Route<dynamic> route) => false,);
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

    bool greaterWidthLayout = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.edit)),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: greaterWidthLayout ? MediaQuery.of(context).size.width/4 : 16),
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
                padding: const EdgeInsets.only(top: 16.0),
                child: ButtonCustom(
                  onPressed: _validateFields,
                  text: 'Salvar nome',
                ),
              ),
              if(currentAppUser!.phone.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
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
              if(currentAppUser!.phone.isEmpty)
                const CustomDivider(),
              if(currentAppUser!.phone.isEmpty)
                const Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: Center(child: Text("Quer receber notificações por Whatsapp?", style: textStyleMediumNormal,))
                ),
              if(currentAppUser!.phone.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: ButtonCustom(
                    onPressed: () async {
                      await currentAppUser!.addPhoneNumberToUser(context);
                      //print("setting state after addPhoneNumberToUser>>>>>");
                      setState(() {
                        _phoneController.text = currentAppUser!.phone;
                      });
                    },
                    text: 'Adicionar número de telefone',
                  ),
                ),
              const CustomDivider(),
              const Padding(
                padding: EdgeInsets.only(top: 32.0),
                child: Center(child: Text("Quer se tornar um prestador de serviço?", style: textStyleMediumNormal,))
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: ButtonCustom(
                  onPressed: (){
                    if(currentAppUser!.phone.isNotEmpty){
                      _createUserNameDialog(context);
                    }
                    else{
                      _mustHavePhoneNumberDialog();
                    }
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
