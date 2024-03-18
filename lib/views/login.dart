import 'dart:html' as html;

import 'package:booker/helper/user_sign.dart';
import 'package:flutter/material.dart';
import 'package:booker/helper/route_generator.dart';
import 'package:booker/main.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:booker/widgets/loading_data.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  //TextEditingController _controllerEmail = TextEditingController(text: "fccmansur@gmail.com");
  //TextEditingController _controllerEmail = TextEditingController(text: "contact.context.development@gmail.com");
  final TextEditingController _controllerEmail = TextEditingController(text: "");
  //TextEditingController _controllerPassword = TextEditingController(text: "123456");
  //TextEditingController _controllerPassword = TextEditingController(text: "Ff123456");
  final TextEditingController _controllerPassword = TextEditingController(text: "");
  //String _errorMessage = "";
  //bool _isLoading = true;
  bool _isLoading = false;

  Future<void> _validateFields() async {
    setState(() {
      _isLoading = true;
    });
    String email = _controllerEmail.text;
    String password = _controllerPassword.text;

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      await UserSign.logUserWithEmailAndPassword(context: context, email: email, password: password);
    }
    setState(() {
      _isLoading = false;
    });
    return;
  }

  Future<void> _openDialogInstagramBrowserMessage() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(AppLocalizations.of(context)!.login_instagram_browser_message_title, style: textStyleMediumBold,),
              content: Text(AppLocalizations.of(context)!.login_instagram_browser_message, style: textStyleMediumNormal,),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    "Entendi",
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ]);
        });
    return;
  }

  Future<void> _checkIfIsInstagramBrowser() async {
    bool showDialog = false;

    if (html.window.navigator.userAgent.contains('Instagram')) {
      showDialog = true;
    }

    if(showDialog){
      await _openDialogInstagramBrowserMessage();
    }
    return;
  }

  bool _imageLoaded = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _checkIfIsInstagramBrowser();
    });
    /*
    UserSign.checkCurrentUser(context).then((value){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _isLoading = false;
        });
      });
    });

     */
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage("assets/booker_logo.png"), context).then((_){
        setState(() {
          _imageLoaded = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    bool greaterWidthLayout = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    if(!_imageLoaded) return LoadingData();

    return Scaffold(
      appBar: Navigator.canPop(context) ? AppBar(title: const Text("Login"),) : null,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(

          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
                child: Center(
                  child: SizedBox(
                      width: greaterWidthLayout ? MediaQuery.of(context).size.width * 0.4 : null,
                      child: Image.asset("assets/booker_logo.png", fit: BoxFit.fitWidth,)
                  ),
                )
            ),
            _isLoading
                ? LoadingData()
                : Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Center(
                      child: SizedBox(
                        width: greaterWidthLayout ? MediaQuery.of(context).size.width * 0.5 : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
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
                                        //onSaved: (email) {},
                                        validator: (value) {
                                          if(value == "" || value == null ){
                                            return AppLocalizations.of(context)!.required_field;
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                      )),
                                  InputCustom(
                                    controller: _controllerPassword,
                                    label: AppLocalizations.of(context)!.login_password,
                                    password: true,
                                    textInputType: TextInputType.text,
                                    //onSaved: (password) {},
                                    validator: (value) {
                                      if(value == "" || value == null ){
                                        return AppLocalizations.of(context)!.required_field;
                                      }
                                      else{
                                        return null;
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Center(
                                child: GestureDetector(
                                  child: Text(
                                    AppLocalizations.of(context)!.login_forgot_password,
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(context, RouteGenerator.RESET_PASSWORD).then((value){
                                      if(value is bool && value){
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.login_forgot_password_go_to_email)));
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 20),
                                child: ButtonCustom(
                                  text: AppLocalizations.of(context)!.login_button_text,
                                  onPressed: _validateFields,
                                )
                            ),
                            Center(
                              child: GestureDetector(
                                child: Text(
                                  AppLocalizations.of(context)!.login_subscribe,
                                  style: const TextStyle(color: Colors.blue),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, RouteGenerator.REGISTER);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: UserSign.googleSignInButton(
                                context,
                                onStartProcessing: (){
                                  setState(() {
                                    _isLoading = true;
                                  });
                                },
                                onEndProcessing: (){
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              ),
                            ),
                            /*
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 64),
                              child: UserSign.facebookSignInButton(
                                context,
                                onStartProcessing: (){
                                  setState(() {
                                    _isLoading = true;
                                  });
                                },
                                onEndProcessing: (){
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              ),
                            )

                             */

                            /*
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            )

                             */
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      )
    );
  }
}
