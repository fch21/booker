import 'dart:async';

import 'package:booker/helper/user_firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:booker/helper/route_generator.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/widgets/button_custom.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class WaitingEmailVerification extends StatefulWidget {

  AppUser currentUser;

  WaitingEmailVerification(this.currentUser, {super.key});

  @override
  _WaitingEmailVerificationState createState() => _WaitingEmailVerificationState();
}

class _WaitingEmailVerificationState extends State<WaitingEmailVerification> {

  //String _errorMessage = "";
  late Timer _timerCheck;
  late Timer _timerSendEmailAgain;

  final int _timeToResendEmail = 60;

  bool _canResendEmail =  false;
  int _secondsSinceLastEmail = 0;

  FirebaseAuth auth = FirebaseAuth.instance;
  User? _userFirebase;

  _resendVerificationEmail(){
    print("email sent");
    _userFirebase = auth.currentUser;
    _userFirebase?.sendEmailVerification();

    setState(() {
      _canResendEmail = false;
      _secondsSinceLastEmail = 0;
    });
  }

  _sendVerificationAndCheck(){
    _userFirebase = auth.currentUser;
    _userFirebase?.sendEmailVerification();

    _timerCheck = Timer.periodic(const Duration(seconds: 1), (timer) async {
      //print("test");
      _userFirebase = auth.currentUser;
      await _userFirebase?.reload();
      print("_userFirebase?.emailVerified = ${_userFirebase?.emailVerified}");
      if(_userFirebase?.emailVerified ?? false){
        _timerCheck.cancel();
        _timerSendEmailAgain.cancel();

        appGlobalKey.currentState?.updateAppForNewUser();
        AppUser user = await UserFirebase.getCurrentUserData();
        currentAppUser = user;
        //if(mounted) Navigator.pushReplacementNamed(context, RouteGenerator.PRESENTATION, arguments: widget.currentUser);
        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(RouteGenerator.HOME, (Route<dynamic> route) => false, arguments: widget.currentUser,);
      }
    });
  }

  _checkIfCanResendEmail(){
    _timerSendEmailAgain = Timer.periodic(const Duration(seconds: 1), (timer){
      int seconds = _secondsSinceLastEmail;
      setState(() {
        _secondsSinceLastEmail += 1;
      });
      if(seconds >= _timeToResendEmail){
        setState(() {
          _canResendEmail = true;
        });
      }
    });
  }

  @override
  void initState() {
    _sendVerificationAndCheck();
    _checkIfCanResendEmail();
    super.initState();
  }

  @override
  void dispose() {
    _timerCheck.cancel();
    _timerSendEmailAgain.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Center(
                      child: Center(
                        child: Image.asset("assets/booker_logo.png", fit: BoxFit.fitWidth,),
                      ),
                    )),

                Center(
                  child: Text(
                    AppLocalizations.of(context)!.waiting_email_verification,
                    style: textStyleSmallNormal,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Center(
                      child: Text(
                        _userFirebase?.email ?? "" ,
                        style: textStyleSmallNormal,
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 20),
                    child: ButtonCustom(
                      text: _canResendEmail
                          ? AppLocalizations.of(context)!.resend_verification_email
                          : AppLocalizations.of(context)!.resend_verification_email_in + (_timeToResendEmail - _secondsSinceLastEmail).toString(),
                      onPressed: _canResendEmail
                        ? _resendVerificationEmail
                        : null,
                    )),
                /*
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
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
      ),
    );
  }
}
