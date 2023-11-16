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
    //String nameFromEmail = firebaseUser.user?.email?.split("@").first ?? "";
    if(userId != null && email != null){
      appUser.id = userId;
      appUser.email = email;
      //appUser.userName = nameFromEmail;
      //print("appUser.toMap() = ${appUser.toMap()}");

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

  static Future<void> checkCurrentUser(BuildContext context, {bool? isNewUser}) async {
    print("_checkCurrentUser");

    User? firebaseUser = UserFirebase.getCurrentUser();

    if (firebaseUser != null) {

      AppUser user = await UserFirebase.getCurrentUserData();
      print("user = $user");
      print("firebaseUser.emailVerified = ${firebaseUser.emailVerified}");
      bool loggedWithFacebook = UserSign.isLoggedWithFacebook(firebaseUser);

      print("loggedWithFacebook = $loggedWithFacebook");

      //if(firebaseUser.emailVerified || loggedWithFacebook){
      if(true){
        appGlobalKey.currentState?.updateAppForNewUser();
        if(isNewUser ?? false){
          if(context.mounted) Navigator.pushReplacementNamed(context, RouteGenerator.PRESENTATION, arguments: user);
        }
        else{
          if(context.mounted) Navigator.pushReplacementNamed(context, RouteGenerator.HOME, arguments: user);
        }
      }
      else{
        if(context.mounted) Navigator.pushNamed(context, RouteGenerator.WAITING_EMAIL_VERIFICATION, arguments: user);
      }

    }
  }

  static Future<UserCredential> signInWithGoogle() async {

    final GoogleSignIn googleSignIn = GoogleSignIn();

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

    final LoginResult result = await FacebookAuth.instance.login();

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
      label: Text(AppLocalizations.of(context)!.facebook_sign_button_text, style: textStyleSmallNormal,),
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
          primary: const Color(0xff1877f2),
          onPrimary: Colors.white,
          elevation: 8.0,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))
      ),
    );
  }

}