
import 'package:booker/home.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/views/appointment_details_page.dart';
import 'package:booker/views/calendar.dart';
import 'package:booker/views/choice_of_service.dart';
import 'package:booker/views/configurations.dart';
import 'package:booker/views/login.dart';
import 'package:booker/views/long_text.dart';
import 'package:booker/views/make_an_appointment.dart';
import 'package:booker/views/profile.dart';
import 'package:booker/views/register.dart';
import 'package:booker/views/reset_password.dart';
import 'package:booker/views/service_form.dart';
import 'package:booker/views/waiting_email_verification.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static const String MAIN = "/";
  static const String HOME = "/home";
  static const String HOME_WITH_INDEX = "/home_with_index";
  static const String LOGIN = "/login";
  static const String REGISTER = "/register";
  static const String RESET_PASSWORD = "/reset_password";
  static const String PRESENTATION = "/presentation";
  static const String WAITING_EMAIL_VERIFICATION = "/waiting_email_verification";
  static const String CONFIGURATIONS = "/configurations";
  static const String PROFILE = "/profile";
  static const String CALENDAR = "/calendar";
  static const String PROFILE_CONFIGURATIONS = "/profile_configurations";
  static const String LANGUAGE_CONFIGURATIONS = "/language_configurations";
  static const String PAYMENT_CONFIGURATIONS = "/payment_configurations";
  static const String USER_PAYMENT_METHODS = "/user_payment_methods";
  static const String PAYMENT_SCREEN = "/payment_screen";
  static const String CREDIT_CARDS = "/credit_cards";
  static const String ADD_CREDIT_CARD = "/add_credit_card";
  static const String ADD_PAYMENT_METHOD_WITH_STRIPE_ELEMENTS = "/add_payment_method_with_stripe_elements";
  static const String LONG_TEXT = "/long_text";
  static const String ABOUT = "/about";
  static const String CHOICE_OF_SERVICE = "/choice_of_service";
  static const String MAKE_AN_APPOINTMENT = "/make_an_appointment";
  static const String SERVICE_FORM = "/service_form";
  static const String APPOINTMENT_DETAILS_PAGE = "/appointment_details_page";



  static Route<dynamic> generateRoute(RouteSettings settings) {
    Object? args = settings.arguments;

    print("Navigating to route => ${settings.name}");
    switch (settings.name) {
      //case MAIN:
       // return MaterialPageRoute(builder: (_) => App());
      case HOME:
        return MaterialPageRoute(builder: (_) => Home(currentUser: args as AppUser));
      case HOME_WITH_INDEX:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => Home(currentUser: (args as Map)["currentUser"] as AppUser, index: args["index"] as int,),
          transitionDuration: const Duration(seconds: 0),
        );
      case LOGIN:
        //return MaterialPageRoute(builder: (_) => Login());
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation1, animation2, child){
            return FadeTransition(
              opacity: animation1,
              child: child,
            );
          },
          pageBuilder: (context, animation, secondaryAnimation) {
            return Login();
          });
      case REGISTER:
        return MaterialPageRoute(builder: (_) => const Register());
      case RESET_PASSWORD:
        return MaterialPageRoute(builder: (_) => const ResetPassword());
      //case PRESENTATION:
      //  return MaterialPageRoute(builder: (_) => Presentation(args as AppUser));
      case WAITING_EMAIL_VERIFICATION:
        return MaterialPageRoute(builder: (_) => WaitingEmailVerification(args as AppUser));
      case CONFIGURATIONS:
        return MaterialPageRoute(builder: (_) => Configurations(args as AppUser));
      case PROFILE:
        return MaterialPageRoute(builder: (_) => Profile(user: args as AppUser,));
      case CALENDAR:
        return MaterialPageRoute(builder: (_) => Calendar());
      case APPOINTMENT_DETAILS_PAGE:
        return MaterialPageRoute(builder: (_) => AppointmentDetailsPage(appointmentDetails: args as AppointmentDetails,));
        /*
      case PROFILE_CONFIGURATIONS:
        return MaterialPageRoute(builder: (_) => ProfileConfigurations(args as AppUser));
      case LANGUAGE_CONFIGURATIONS:
        return MaterialPageRoute(builder: (_) => LanguageConfigurations(args as AppUser));
      case ABOUT:
        return MaterialPageRoute(builder: (_) => const About());
      case PAYMENT_CONFIGURATIONS:
        return MaterialPageRoute(builder: (_) => PaymentConfigurations(args as AppUser));
      case USER_PAYMENT_METHODS:
        return MaterialPageRoute(builder: (_) => UserPaymentMethods(currentUser: args as AppUser));
      case CREDIT_CARDS:
        return MaterialPageRoute(builder: (_) => CreditCards(args as AppUser));
      case ADD_CREDIT_CARD:
        return MaterialPageRoute(builder: (_) => AddCreditCard(args as AppUser));
      case ADD_PAYMENT_METHOD_WITH_STRIPE_ELEMENTS:
        return MaterialPageRoute(builder: (_) => const AddPaymentMethodWithStripeElements());

         */
      case LONG_TEXT:
        return MaterialPageRoute(builder: (_) => LongText(appBarTitle: (args as Map)["appBarTitle"] as String, title: args["title"] as String, content: args["content"] as String,));
      case CHOICE_OF_SERVICE:
        return MaterialPageRoute(builder: (_) => ChoiceOfService(user: args as AppUser,));
      case MAKE_AN_APPOINTMENT:
        return MaterialPageRoute(builder: (_) => MakeAnAppointment(user: (args as Map)["user"] as AppUser, serviceProvided: args["serviceProvided"] as ServiceProvided,));
      case SERVICE_FORM:
        return MaterialPageRoute(builder: (_) => ServiceForm(serviceProvided: args as ServiceProvided?,));
      default:
        return _routeError();
    }
  }


  static Route<dynamic> _routeError() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text("Tela não encontrada")),
        body: const Center(
          child: Text("Tela não encontrada"),
        ),
      );
    });
  }
}
