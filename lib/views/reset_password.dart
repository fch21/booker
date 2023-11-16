import 'package:booker/helper/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/input_custom.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  //TextEditingController _controllerEmail = TextEditingController(text: "fccmansur@gmail.com");
  final TextEditingController _controllerEmail = TextEditingController(text: "");
  //String _errorMessage = "";

  _validateFields() {
    String email = _controllerEmail.text;

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      _sendResetEmail(email);

    }
  }

  _sendResetEmail(String email) async {
    print("_sendResetEmail");
    print(email);
    FirebaseAuth auth = FirebaseAuth.instance;

    var methods = [];
    try{
      methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    }
    catch(e){
      print(e);
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email inválido")));
    }
    print(methods);
    if (methods.contains('password')) {
      auth.sendPasswordResetEmail(email: email);

      //setState(() {
      //  _errorMessage = "";
      //});

      if(mounted) Navigator.pop(context);
    }
    else {
      if(mounted) Utils.showSnackBar(context, AppLocalizations.of(context)!.reset_password_email_not_registered);
      //setState(() {
      //  _errorMessage = AppLocalizations.of(context)!.reset_password_email_not_registered;
      //});
    }
  }

  @override
  Widget build(BuildContext context) {

    bool greaterWidthLayout = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.reset_password_appbar),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(

            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 96),
                child: Center(
                  child: SizedBox(
                    width: greaterWidthLayout ? MediaQuery.of(context).size.width * 0.4 : null,
                    child: Image.asset("assets/drinqr_logo_name_transparent.png", fit: BoxFit.fitWidth,),
                  ),
                )
              ),
              Center(
                child: SizedBox(
                  width: greaterWidthLayout ? MediaQuery.of(context).size.width * 0.5 : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InputCustom(
                                  controller: _controllerEmail,
                                  label: AppLocalizations.of(context)!.login_email,
                                  textInputType: TextInputType.emailAddress,
                                  onSaved: (email) {
                                    //_anuncio.titulo = titulo;
                                  },
                                  validator: (value) {
                                    if(value == "" || value == null ){
                                      return AppLocalizations.of(context)!.required_field;
                                    }
                                    else{
                                      return null;
                                    }
                                  },
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 20),
                        child: ButtonCustom(
                          text: AppLocalizations.of(context)!.reset_password_send_email,
                          onPressed: _validateFields,
                        )
                      ),
                      /*
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: fontSizeSmall,
                  ),
                ),
              )

               */
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
