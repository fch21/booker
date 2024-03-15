import 'package:booker/home.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:booker/models/available_schedule.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/splash_screen.dart';
import 'package:booker/views/about.dart';
import 'package:booker/views/add_payment_method_with_stripe_elements.dart';
import 'package:booker/views/appointment_details_page.dart';
import 'package:booker/views/available_schedule_form.dart';
import 'package:booker/views/calendar.dart';
import 'package:booker/views/calendar_blocked_periods.dart';
import 'package:booker/views/choice_of_service.dart';
import 'package:booker/views/client_page.dart';
import 'package:booker/views/configurations_home.dart';
import 'package:booker/views/edit_profile_client.dart';
import 'package:booker/views/edit_profile_service_provided.dart';
import 'package:booker/views/login.dart';
import 'package:booker/views/long_text.dart';
import 'package:booker/views/make_an_appointment.dart';
import 'package:booker/views/my_appointments.dart';
import 'package:booker/views/my_clients.dart';
import 'package:booker/views/presentation.dart';
import 'package:booker/views/profile_service_provider.dart';
import 'package:booker/views/register.dart';
import 'package:booker/views/reset_password.dart';
import 'package:booker/views/service_provided_form.dart';
import 'package:booker/views/subscriptions_management.dart';
import 'package:booker/views/waiting_email_verification.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static const String MAIN = "/";
  static const String HOME = "/home";
  static const String SPLASH_SCREEN = "/splash";
  //static const String HOME_WITH_INDEX = "/home_with_index";
  static const String LOGIN = "/login";
  static const String REGISTER = "/register";
  static const String RESET_PASSWORD = "/reset_password";
  static const String PRESENTATION = "/presentation";
  static const String WAITING_EMAIL_VERIFICATION = "/waiting_email_verification";
  static const String CONFIGURATIONS_HOME = "/configurations";
  static const String EDIT_PROFILE_CLIENT = "/edit_profile_client";
  static const String PROFILE_SERVICE_PROVIDER = "/profile_service_provider";
  static const String EDIT_PROFILE_SERVICE_PROVIDER = "/edit_profile_service_provideR";
  static const String CALENDAR = "/calendar";
  static const String PROFILE_CONFIGURATIONS = "/profile_configurations";
  static const String LANGUAGE_CONFIGURATIONS = "/language_configurations";
  //static const String PAYMENT_CONFIGURATIONS = "/payment_configurations";
  static const String SUBSCRIPTION_MANAGEMENT = "/subscription_management";
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
  static const String AVAILABLE_SCHEDULE_FORM = "/available_schedule_form";
  static const String APPOINTMENT_DETAILS_PAGE = "/appointment_details_page";
  //static const String EDIT_APPOINTMENT_DETAILS_PAGE = "/edit_appointment_details_page";
  static const String CLIENT_PAGE = "/client_page";
  static const String MY_APPOINTMENTS = "/my_appointments";
  static const String MY_CLIENTS = "/my_clients";
  static const String CALENDAR_BLOCKED_PERIOD = "/calendar_blocked_period";



  static Route<dynamic> generateRoute(RouteSettings settings) {
    Object? args = settings.arguments;

    print("Navigating to route => ${settings.name}");
    switch (settings.name) {
      //case MAIN:
       // return MaterialPageRoute(builder: (_) => App());
      case HOME:
        return MaterialPageRoute(builder: (_) => Home());
      case SPLASH_SCREEN:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      //case HOME_WITH_INDEX:
      //  return PageRouteBuilder(
      //    pageBuilder: (_, __, ___) => Home(index: args as int),
      //    transitionDuration: const Duration(seconds: 0),
      //  );
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
      case PRESENTATION:
        return MaterialPageRoute(builder: (_) => Presentation());
      case WAITING_EMAIL_VERIFICATION:
        return MaterialPageRoute(builder: (_) => WaitingEmailVerification(args as AppUser));
      case CONFIGURATIONS_HOME:
        return MaterialPageRoute(builder: (_) => ConfigurationsHome());
      case SUBSCRIPTION_MANAGEMENT:
        return MaterialPageRoute(builder: (_) => SubscriptionManagementPage());
      case PROFILE_SERVICE_PROVIDER:
        return MaterialPageRoute(builder: (_) => ProfileServiceProvider());
      case EDIT_PROFILE_CLIENT:
        return MaterialPageRoute(builder: (_) => EditProfileClient());
      case EDIT_PROFILE_SERVICE_PROVIDER:
        return MaterialPageRoute(builder: (_) => EditProfileServiceProvider());
      case CALENDAR:
        return MaterialPageRoute(builder: (_) => Calendar());
      case APPOINTMENT_DETAILS_PAGE:
        return MaterialPageRoute(builder: (_) => AppointmentDetailsPage(appointmentDetails: args as AppointmentDetails,));
      case CLIENT_PAGE:
        return MaterialPageRoute(builder: (_) => ClientPage(client: args as AppUser,));
      case ABOUT:
        return MaterialPageRoute(builder: (_) => const About());
      case MY_APPOINTMENTS:
        return MaterialPageRoute(builder: (_) => MyAppointments(showOnlyPastAppointments: (args ?? false) as bool,));
      case MY_CLIENTS:
        return MaterialPageRoute(builder: (_) => MyClients());
      case ADD_PAYMENT_METHOD_WITH_STRIPE_ELEMENTS:
        return MaterialPageRoute(builder: (_) => const AddPaymentMethodWithStripeElements());
        /*
      case PROFILE_CONFIGURATIONS:
        return MaterialPageRoute(builder: (_) => ProfileConfigurations(args as AppUser));
      case LANGUAGE_CONFIGURATIONS:
        return MaterialPageRoute(builder: (_) => LanguageConfigurations(args as AppUser));
      case PAYMENT_CONFIGURATIONS:
        return MaterialPageRoute(builder: (_) => PaymentConfigurations(args as AppUser));
      case USER_PAYMENT_METHODS:
        return MaterialPageRoute(builder: (_) => UserPaymentMethods(currentUser: args as AppUser));
      case CREDIT_CARDS:
        return MaterialPageRoute(builder: (_) => CreditCards(args as AppUser));
      case ADD_CREDIT_CARD:
        return MaterialPageRoute(builder: (_) => AddCreditCard(args as AppUser));
         */
      case LONG_TEXT:
        return MaterialPageRoute(builder: (_) => LongText(appBarTitle: (args as Map)["appBarTitle"] as String, title: args["title"] as String, content: args["content"] as String,));
      case CHOICE_OF_SERVICE:
        return MaterialPageRoute(builder: (_) => ChoiceOfService(
            appUser: (args as Map)["user"] as AppUser,
            manuallyAddAppointment: (args["manually_add_appointment"] ?? false) as bool,
            //showMenu: (args["show_menu"] ?? false) as bool
        ));
      case MAKE_AN_APPOINTMENT:
        return MaterialPageRoute(builder: (_) => MakeAnAppointment(
            appUser: (args as Map)["user"] as AppUser,
            serviceProvided: args["serviceProvided"] as ServiceProvided,
            manuallyAddAppointment: (args["manually_add_appointment"] ?? false) as bool,
            appointmentToChange: args["appointmentToChange"] as AppointmentDetails?,
          ),
        );
      case SERVICE_FORM:
        return MaterialPageRoute(builder: (_) => ServiceProvidedForm(serviceProvided: args as ServiceProvided?,));
      case AVAILABLE_SCHEDULE_FORM:
        return MaterialPageRoute(builder: (_) => AvailableScheduleForm(availableSchedule: (args as Map)["availableSchedule"] as AvailableSchedule?, onDelete: args["onDelete"] as VoidCallback,  onSave: args["onSave"] as VoidCallback));
      case CALENDAR_BLOCKED_PERIOD:
        //return MaterialPageRoute(builder: (_) => CalendarBlockedPeriods(showOnlyPastBlockedPeriods: (args ?? false) as bool,));
        return MaterialPageRoute(builder: (_) => CalendarBlockedPeriods());
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
