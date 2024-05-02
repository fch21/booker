import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
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
    //print("_sendResetEmail");
    print(email);
    FirebaseAuth auth = FirebaseAuth.instance;

    try{
      await auth.sendPasswordResetEmail(email: email);
      if(mounted) Navigator.pop(context);
    }
    catch(e){
      if(mounted) Utils.showSnackBar(context, "Email inváido");
    }
    //not used to email enumeration protection
    /*
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
      if(mounted) Navigator.pop(context);
    }
    else {
      if(mounted) Utils.showSnackBar(context, AppLocalizations.of(context)!.reset_password_email_not_registered);
    }

     */
  }

  @override
  Widget build(BuildContext context) {

    bool greaterWidthLayout = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
                child: Center(
                  child: SizedBox(
                      width: greaterWidthLayout ? MediaQuery.of(context).size.width * 0.4 : null,
                      child: Image.asset("assets/booker_logo.png", fit: BoxFit.fitWidth,)
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
                                  //onSaved: (email) {//_anuncio.titulo = titulo;},
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
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(
                          child: Text(
                            "Se este email estiver registrado, enviaremos um link para redefinir sua senha.",
                            style: textStyleVerySmallNormal,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32, bottom: 20),
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
