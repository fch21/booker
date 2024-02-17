import 'dart:async';

import 'package:booker/widgets/loading_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/user_firebase.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
//import 'dart:js' as js;

class UserSign {

  static Future<bool> addUserInFirestore(BuildContext context, UserCredential firebaseUser, {AppUser? user}) async {

    AppUser appUser = user ?? AppUser();

    FirebaseFirestore db = FirebaseFirestore.instance;

    bool result = false;

    print("firebaseUser.user?.uid = ${firebaseUser.user?.uid}");
    print("firebaseUser.user?.email = ${firebaseUser.user?.email}");
    String? userId = firebaseUser.user?.uid;
    String? email = firebaseUser.user?.email;
    if(userId != null && email != null){
      appUser.id = userId;
      appUser.email = email;
      //appUser.userName = nameFromEmail;
      //print("appUser.toMap() = ${appUser.toMap()}");
      if(appUser.name.isEmpty){
        String nameFromEmail = firebaseUser.user?.email?.split("@").first ?? "";
        appUser.name = nameFromEmail;
      }

      try{
        await db.collection(Strings.COLLECTION_USERS).doc(firebaseUser.user?.uid).set(appUser.toMap());
        result = true;
      }
      catch(e){
        Utils.showSnackBar(context, "${AppLocalizations.of(context)!.email_sign_error_message} $e");
        firebaseUser.user!.delete();
        result = false;
      }

    }
    else{
      firebaseUser.user?.delete();
      result = false;
    }

    return result;
  }

  static Future<bool> createUserWithEmailAndPassword(BuildContext context, AppUser user) async {

    bool result = false;

    FirebaseAuth auth = FirebaseAuth.instance;

    try{
      UserCredential firebaseUser = await auth.createUserWithEmailAndPassword(email: user.email, password: user.password);

      bool resultFirestore = await addUserInFirestore(context, firebaseUser, user: user);
      if(resultFirestore) {
        result = true;
      } else {
        result = false;
      }
    }
    catch(e){
      Utils.showSnackBar(context, "${AppLocalizations.of(context)!.email_sign_error_message} $e");
      result = false;
    }

    return result;
  }


  static void sendVerificationCode({
    required BuildContext context,
    required String phoneNumber,
    int? initialResendToken,
    required void Function(String verificationId, int? resendToken) onCodeSent
  }) async {

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Este callback é opcional em seu caso
        // Aqui, em vez de fazer login, você associa o número ao usuário existente
        try {
          await FirebaseAuth.instance.currentUser!.updatePhoneNumber(credential);
          // Número de telefone adicionado com sucesso ao usuário
        } catch (e) {
          Utils.showSnackBar(context, "verificationCompleted: Erro ao atualizar número de telefone. $e");
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        Navigator.of(context).pop();
        Utils.showSnackBar(context, "verificationFailed: Erro ao atualizar número de telefone. $e");
        // Trate os erros de verificação aqui
      },
      codeSent: (String verificationId, int? resendToken) {
        // Salve o verificationId para uso posterior
        // Atualize a interface do usuário para permitir que o usuário insira o código de SMS
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Este callback é opcional em seu caso
      },
      forceResendingToken: initialResendToken
    );

  }

  static Future<void> verifyPhoneNumber({required BuildContext buildContext, required String phoneNumber, VoidCallback? onConfirmed}) async {

    String? phoneNumberVerificationId;
    int? phoneNumberResendToken;
    int resendWaitSeconds = 60;
    StreamController<bool> canResendStreamController = StreamController.broadcast();
    StreamController<bool> dialogStreamController = StreamController.broadcast();
    Timer? resendTimer;
    bool isVerifyingCode = false;

    void startTimer(){
      resendWaitSeconds = 60;
      resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (resendWaitSeconds == 0) {
          resendTimer?.cancel();
          canResendStreamController.add(true);
        } else {
          resendWaitSeconds--;
          canResendStreamController.add(false);
        }
      });
    }

    startTimer();

    sendVerificationCode(context: buildContext, phoneNumber: phoneNumber, initialResendToken: phoneNumberResendToken, onCodeSent:(String verificationId, int? resendToken){
      phoneNumberVerificationId = verificationId;
      phoneNumberResendToken = resendToken;
      dialogStreamController.add(true);
    });

    TextEditingController pinCodeController = TextEditingController();

    await showDialog(
      context: buildContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: const Center(child: Text("Código de verificação")),
          content: StreamBuilder<bool>(
            stream: dialogStreamController.stream,
            builder: (context, snapshot) {

              /*
              if(phoneNumberVerificationId == null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text("Enviando código..."),
                    ),
                    LoadingData(),
                  ],
                );
              }
               */

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PinCodeTextField(
                    appContext: context,
                    length: 6, // o número de caracteres do código
                    controller: pinCodeController,
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 35,
                      activeColor: standartTheme.primaryColor,
                      selectedColor: Colors.grey,
                      inactiveColor: Colors.grey,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      //selectedFillColor: Colors.lightGreen[50],
                    ),
                    onCompleted: (String value) {
                      // Você pode optar por confirmar o código automaticamente após o preenchimento
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: StreamBuilder<bool>(
                      stream: canResendStreamController.stream,
                      builder: (context, snapshot) {

                        bool canResendCode = snapshot.data ?? false;

                        return TextButton(
                          onPressed: canResendCode ? () {
                            sendVerificationCode(context: context, phoneNumber: phoneNumber, initialResendToken: phoneNumberResendToken, onCodeSent:(String verificationId, int? resendToken){
                              phoneNumberVerificationId = verificationId;
                              phoneNumberResendToken = resendToken;
                              canResendStreamController.add(false);
                            });
                            startTimer();
                          } : null,
                          child: Text(canResendCode ? 'Reenviar código' : 'Reenviar em $resendWaitSeconds segundos'),
                        );
                      }
                    ),
                  )
                ],
              );
            }
          ),

          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Confirmar"),
              onPressed: () async {
                if(phoneNumberVerificationId != null && !isVerifyingCode){
                  isVerifyingCode = true;
                  dialogStreamController.add(true);
                  String smsCode = pinCodeController.text;
                  print("phoneNumberVerificationId = $phoneNumberVerificationId");
                  print("smsCode = $smsCode");
                  if(smsCode.length == 6) {
                    bool? confirmed = await _confirmVerificationCode(smsCode: smsCode, verificationId: phoneNumberVerificationId!);
                    if(confirmed ?? false) {
                      if(onConfirmed != null) onConfirmed();
                      Navigator.of(context).pop();
                      Utils.showSnackBar(buildContext, "Número de telefone salvo com sucesso!");
                    }
                    else{
                      if(confirmed != null){
                        Utils.showSnackBar(buildContext, "Código incorreto ou expirado");
                      }
                      else{
                        Utils.showSnackBar(buildContext, "Erro ao cadastrar o número. Por favor entre em contato com a assistência para mais informações.");
                      }

                    }
                  }
                  else{
                    print("SMS code is empty");
                    Utils.showSnackBar(buildContext, "Digite o código recebido por SMS");
                  }

                  isVerifyingCode = false;
                  dialogStreamController.add(true);
                }
              },
            ),
          ],
        );
      },
    );

    resendTimer?.cancel();
    return;
  }

  static Future<bool?> _confirmVerificationCode({required String smsCode, required String verificationId}) async {

    bool? codeConfirmed;

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode,);
      // Aqui, você poderia autenticar o usuário, mas como você só quer verificar o número,
      // você pode simplesmente verificar se o código é correto sem fazer login
      //await FirebaseAuth.instance.signInWithCredential(credential);
      await FirebaseAuth.instance.currentUser!.updatePhoneNumber(credential);
      // Se a linha acima não lançar um erro, o código é válido
      codeConfirmed = true;
      // Salve o número de telefone verificado no banco de dados ou preferência do usuário
    } catch (e) {
    // Trate os erros aqui (por exemplo, código inválido)
      codeConfirmed = false;
      print("error = $e");
      if(e.toString().contains("firebase_auth/account-exists-with-different-credential")){
        codeConfirmed = null; //para sinalizar um erro diferente
      }
    }

    return codeConfirmed;
  }

  static bool? checkIfIsNewUser(UserCredential userCredential){
    return userCredential.additionalUserInfo?.isNewUser;
  }

  static Future<void> onSignedUser(BuildContext context, UserCredential firebaseUser) async {
    bool? isNewUser = checkIfIsNewUser(firebaseUser);

    bool resultFirebase = true;
    if (isNewUser ?? false) {
      resultFirebase = await addUserInFirestore(context, firebaseUser);
    }

    if (resultFirebase) await checkCurrentUser(context, isNewUser: isNewUser);

    return;
  }

  static Future<void> getCurrentAppUser() async {
    User? firebaseUser = UserFirebase.getCurrentUser();
    if (firebaseUser != null){
      AppUser user = await UserFirebase.getCurrentUserData();
      currentAppUser = user;
    }
    else{
      currentAppUser = null;
    }
    appGlobalKey.currentState?.redrawApp();
  }

  static Future<void> logoutUser(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: const Text("Logout"),
          content: const Text("Tem certeza que você quer sair da sua conta?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Confirmar"),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.SPLASH_SCREEN, (_) => false);
              },
            ),
          ],
        );
      },
    );
    return;
  }

  static Future<void> _firstUserAddPhoneNumberDialog(BuildContext context) async {
    bool addPhoneNumberToUser = false;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Melhore sua experiência!'),
          content: const Text('Cadastre seu número para notificações de agendamentos via WhatsApp.'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Talvez mais tarde'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Cadastrar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                addPhoneNumberToUser = true;
              },
            ),
          ],
        );
      },
    );

    if(addPhoneNumberToUser){
      await currentAppUser!.addPhoneNumberToUser(context);
    }
    return;
  }

  static Future<void> checkCurrentUser(BuildContext context, {bool? isNewUser}) async {
    print("_checkCurrentUser");

    User? firebaseUser = UserFirebase.getCurrentUser();

    if (firebaseUser != null) {

      AppUser user = await UserFirebase.getCurrentUserData();
      print("user = $user");
      print("firebaseUser.emailVerified = ${firebaseUser.emailVerified}");
      bool loggedWithFacebook = UserSign.isLoggedWithFacebook(firebaseUser);

      print("loggedWithFacebook = $loggedWithFacebook");
      print("isNewUser = $isNewUser");

      if(firebaseUser.emailVerified || loggedWithFacebook){
      //if(true){
        currentAppUser = user;
        appGlobalKey.currentState?.redrawApp();
        if(isNewUser ?? false){
          await _firstUserAddPhoneNumberDialog(context);
        }
        //if(isNewUser ?? false){
        if(false){
          if(context.mounted) Navigator.pushReplacementNamed(context, RouteGenerator.PRESENTATION, arguments: user);
        }
        else{
          if(user.isServiceProvider){
            if(context.mounted) Navigator.pushReplacementNamed(context, RouteGenerator.PROFILE_SERVICE_PROVIDED);
          }
          else{
            //if(context.mounted) Navigator.pushReplacementNamed(context, RouteGenerator.HOME, arguments: user);
            // the login now is note made on the first screen, so we should just close the login screen to go back to the previous screen
            if(context.mounted) Navigator.pop(context); }
        }
      }
      else{
        if(context.mounted) Navigator.pushNamed(context, RouteGenerator.WAITING_EMAIL_VERIFICATION, arguments: user);
      }

    }
  }

  static Future<UserCredential> signInWithGoogle() async {

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: "1060470892593-46d486l7p1knpkeglnu2ccqqvl9igjbi.apps.googleusercontent.com"
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    return userCredential;
  }

  static bool isLoggedWithFacebook(User firebaseUser){
    bool loggedWithFacebook = false;

    for (UserInfo userInfo in firebaseUser.providerData) {
      if (userInfo.providerId == 'facebook.com') {
        loggedWithFacebook = true;
      }
    }

    return loggedWithFacebook;
  }

  static Future<UserCredential?> signInWithFacebook() async {
    // Inicie o fluxo de login do Facebook
    // Verifique se o SDK do Facebook está pronto

    print("signInWithFacebook");
    final LoginResult result = await FacebookAuth.instance.login();
    print("result = $result");
    print("result.accessToken?.token = ${result.accessToken?.token}");

    if(result.accessToken?.token != null){
      // Crie uma credencial para passar para o FirebaseAuth
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken!.token);

      // Faça login (ou registre-se) no FirebaseAuth com a credencial do Facebook
      return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    }

    return null;
  }

  static Widget googleSignInButton(BuildContext context, {required VoidCallback onStartProcessing, required VoidCallback onEndProcessing,}) {
    return ElevatedButton.icon(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Image.asset('assets/google_logo.png', height: 24.0,),
      ),
      label: Text(AppLocalizations.of(context)!.google_sign_button_text, style: textStyleSmallNormal,),
      onPressed: () async {
        onStartProcessing();
        try {
          UserCredential firebaseUser = await signInWithGoogle();

          await onSignedUser(context, firebaseUser);

        } catch (error) {
          // Trate erros de autenticação aqui
          Utils.showSnackBar(context, '${AppLocalizations.of(context)!.google_sign_error_message} $error');
        }
        onEndProcessing();
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        onPrimary: Colors.black,
        elevation: 8.0,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))
      ),
    );
  }

  static Widget facebookSignInButton(BuildContext context, {required VoidCallback onStartProcessing, required VoidCallback onEndProcessing}) {
    return ElevatedButton.icon(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Image.asset('assets/facebook_logo.png', height: 24.0,),
      ),
      label: Text(AppLocalizations.of(context)!.facebook_sign_button_text, style: const TextStyle(color: Colors.white, fontSize: fontSizeSmall ),),
      onPressed: () async {
        onStartProcessing();
        try {
          UserCredential? firebaseUser = await signInWithFacebook();

          print("firebaseUser = $firebaseUser");
          if(firebaseUser != null){
            await onSignedUser(context, firebaseUser);
          }
        } catch (error) {
          // Trate erros de autenticação aqui
          print(error);
          Utils.showSnackBar(context, '${AppLocalizations.of(context)!.facebook_sign_error_message} $error');
        }
        onEndProcessing();
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff1877f2),
          elevation: 8.0,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))
      ),
    );
  }

}