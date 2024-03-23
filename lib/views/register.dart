import 'package:booker/helper/user_sign.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:booker/helper/route_generator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/input_custom.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  //TextEditingController _controllerName = TextEditingController(text: "User 1");
  final TextEditingController _controllerName = TextEditingController(text: "");
  //final TextEditingController _controllerUserName = TextEditingController(text: "user_1");
  //TextEditingController _controllerEmail = TextEditingController(text: "user1@gmail.com");
  final TextEditingController _controllerEmail = TextEditingController(text: "");
  //TextEditingController _controllerPassword = TextEditingController(text: "123456");
  final TextEditingController _controllerPassword = TextEditingController(text: "");
  //TextEditingController _controllerConfirmPassword = TextEditingController(text: "123456");
  final TextEditingController _controllerConfirmPassword = TextEditingController(text: "");
  //String _errorMessage = "";

  bool _checked = false;
  bool _isLoading = false;
  //bool _userNameIsAvailable = false;

  final AppUser _user = AppUser();

  Future<void>_validateFields() async {
    setState(() {
      _isLoading = true;
    });

    //bool userNameIsAvailable = await AppUser.checkIfUserNameIsAvailable(_controllerUserName.text);
    //print("userNameIsAvailable = $userNameIsAvailable");

    //_userNameIsAvailable = userNameIsAvailable;

    if (_formKey.currentState?.validate() ?? false) {
      if(_checked){
        _formKey.currentState?.save();
        await _registerUser(_user);
      }
      else{
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.register_must_accept_terms_message)));
      }
    }

    setState(() {
      _isLoading = false;
    });

  }

  Future<void> _registerUser(AppUser user) async {
    bool result = await UserSign.createUserWithEmailAndPassword(context, user);
    if(result) await UserSign.checkCurrentUser(context);

    return;
  }

  bool _imageLoaded = false;
  @override
  void initState() {
    // TODO: implement initState
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.register_appbar),
        centerTitle: true
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
                  child: Center(
                    child: SizedBox(
                        width: greaterWidthLayout ? MediaQuery.of(context).size.width * 0.4 : null,
                        child: Image.asset("assets/booker_logo.png", fit: BoxFit.fitWidth,)
                    ),
                  )
              ),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Container(
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
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: InputCustom(
                                        controller: _controllerName,
                                        label: AppLocalizations.of(context)!.register_name,
                                        textInputType: TextInputType.text,
                                        onSaved: (name) {
                                          _user.name = name!;
                                          return null;
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
                                    ),
                                    /*
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: InputCustom(
                                        controller: _controllerUserName,
                                        label: AppLocalizations.of(context)!.register_user_name,
                                        textInputType: TextInputType.text,
                                        onSaved: (userName) {
                                          _user.userName = userName!;
                                          return null;
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

                                     */
                                    Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: InputCustom(
                                          controller: _controllerEmail,
                                          label: AppLocalizations.of(context)!.register_email,
                                          textInputType: TextInputType.emailAddress,
                                          onSaved: (email) {
                                            _user.email = email!;
                                            return null;
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
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: InputCustom(
                                        controller: _controllerPassword,
                                        label: AppLocalizations.of(context)!.register_password,
                                        password: true,
                                        textInputType: TextInputType.text,
                                        onSaved: (password) {
                                          _user.password = password!;
                                          return null;
                                        },
                                        validator: (value) {
                                          if(value == "" || value == null ){
                                            return AppLocalizations.of(context)!.required_field;
                                          }
                                          // Expressão regular para validar a senha.
                                          // Esta expressão verifica a presença de letras maiúsculas, minúsculas, números e caracteres especiais.
                                          var regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

                                          // Verifica se a senha atende aos critérios da expressão regular.
                                          if (!regex.hasMatch(value)) {
                                            // Retorna uma mensagem de erro se a senha não atender aos critérios.
                                            return 'Deve ter pelo menos:\n-8 caracteres\n-Letras maiúsculas\n-Letras minúsculas\n-Números\n-Caracteres especiais';
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: InputCustom(
                                        controller: _controllerConfirmPassword,
                                        label: AppLocalizations.of(context)!.register_confirm_password,
                                        password: true,
                                        textInputType: TextInputType.text,
                                        validator: (value) {
                                          if (_controllerPassword.text != _controllerConfirmPassword.text) {
                                            return AppLocalizations.of(context)!.register_different_passwords;
                                          }

                                          if(value == "" || value == null ){
                                            return AppLocalizations.of(context)!.required_field;
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _checked,
                                          onChanged: (value) {
                                            if(value != null){
                                              setState(() {
                                                _checked = value;
                                              });
                                            }
                                          },
                                        ),
                                        Expanded(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    style: const TextStyle(color: Colors.black),
                                                    text: AppLocalizations.of(context)!.register_terms_part_1,
                                                  ),
                                                  TextSpan(
                                                    text: AppLocalizations.of(context)!.register_terms_of_use,
                                                    style: const TextStyle(color: Colors.blue),
                                                    recognizer: TapGestureRecognizer()
                                                      ..onTap = () {
                                                        String title = AppLocalizations.of(context)!.register_terms_of_use;
                                                        Map args = {"appBarTitle" : "", "title" : title, "content" : Strings.TERMS_OF_USE};
                                                        Navigator.pushNamed(context, RouteGenerator.LONG_TEXT, arguments: args);
                                                      },
                                                  ),
                                                  TextSpan(
                                                    style: const TextStyle(color: Colors.black),
                                                    text: AppLocalizations.of(context)!.register_terms_part_2,
                                                  ),
                                                  TextSpan(
                                                    text: AppLocalizations.of(context)!.register_privacy_policy,
                                                    style: const TextStyle(color: Colors.blue),
                                                    recognizer: TapGestureRecognizer()
                                                      ..onTap = () {
                                                        String title = AppLocalizations.of(context)!.register_privacy_policy;
                                                        Map args = {"appBarTitle" : "", "title" : title, "content" : Strings.PRIVACY_POLICY};
                                                        Navigator.pushNamed(context, RouteGenerator.LONG_TEXT, arguments: args);
                                                      },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: ButtonCustom(
                                    text: AppLocalizations.of(context)!.register_button_text,
                                    onPressed: _validateFields,
                                  )
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 32),
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
                                    }),
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
                                    }),
                              ),

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
                  ),
                  if(_isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white,
                        child: LoadingData(),
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
