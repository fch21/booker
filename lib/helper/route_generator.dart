import 'package:booker/views/initial_explore_page.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:booker/models/available_schedule.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/splash_screen.dart';
import 'package:booker/views/about.dart';
import 'package:booker/views/appointment_details_page.dart';
import 'package:booker/views/available_schedule_form.dart';
import 'package:booker/views/calendar.dart';
import 'package:booker/views/calendar_blocked_periods.dart';
import 'package:booker/views/choice_of_service.dart';
import 'package:booker/views/client_page.dart';
import 'package:booker/views/configurations_home.dart';
import 'package:booker/views/edit_profile_client.dart';
import 'package:booker/views/edit_profile_service_provider.dart';
import 'package:booker/views/login.dart';
import 'package:booker/views/long_text.dart';
import 'package:booker/views/make_an_appointment.dart';
import 'package:booker/views/my_appointments.dart';
import 'package:booker/views/my_clients.dart';
import 'package:booker/views/presentation.dart';
import 'package:booker/views/presentation_web_page.dart';
import 'package:booker/views/profile_service_provider.dart';
import 'package:booker/views/register.dart';
import 'package:booker/views/reset_password.dart';
import 'package:booker/views/service_provided_form.dart';
import 'package:booker/views/subscriptions_management.dart';
import 'package:booker/views/waiting_email_verification.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static const String MAIN = "/";
  static const String INITIAL_EXPLORE_PAGE = "/initial_explore_page";
  static const String PRESENTATION_WEB_PAGE = "/presentation_web_page";
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
  //static const String ADD_PAYMENT_METHOD_WITH_STRIPE_ELEMENTS = "/add_payment_method_with_stripe_elements";
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
      case INITIAL_EXPLORE_PAGE:
        return MaterialPageRoute(settings: settings, builder: (_) => InitialExplorePage());
      case PRESENTATION_WEB_PAGE:
        return MaterialPageRoute(settings: settings, builder: (_) => const PresentationWebPage());
      case SPLASH_SCREEN:
        return MaterialPageRoute(settings: settings, builder: (_) => const SplashScreen());
      case LOGIN:
        //return MaterialPageRoute(settings: settings, builder: (_) => Login());
        return PageRouteBuilder(
          settings: settings,
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
        return MaterialPageRoute(settings: settings, builder: (_) => const Register());
      case RESET_PASSWORD:
        return MaterialPageRoute(settings: settings, builder: (_) => const ResetPassword());
      case PRESENTATION:
        return MaterialPageRoute(settings: settings, builder: (_) => Presentation());
      case WAITING_EMAIL_VERIFICATION:
        return MaterialPageRoute(settings: settings, builder: (_) => WaitingEmailVerification(args as AppUser));
      case CONFIGURATIONS_HOME:
        return MaterialPageRoute(settings: settings, builder: (_) => ConfigurationsHome());
      case SUBSCRIPTION_MANAGEMENT:
        return MaterialPageRoute(settings: settings, builder: (_) => SubscriptionManagementPage());
      case PROFILE_SERVICE_PROVIDER:
        return MaterialPageRoute(settings: settings, builder: (_) => ProfileServiceProvider());
      case EDIT_PROFILE_CLIENT:
        return MaterialPageRoute(settings: settings, builder: (_) => EditProfileClient());
      case EDIT_PROFILE_SERVICE_PROVIDER:
        return MaterialPageRoute(settings: settings, builder: (_) => EditProfileServiceProvider());
      case CALENDAR:
        return MaterialPageRoute(settings: settings, builder: (_) => const Calendar());
      case APPOINTMENT_DETAILS_PAGE:
        return MaterialPageRoute(settings: settings, builder: (_) => AppointmentDetailsPage(appointmentDetails: args as AppointmentDetails,));
      case CLIENT_PAGE:
        return MaterialPageRoute(settings: settings, builder: (_) => ClientPage(client: args as AppUser,));
      case ABOUT:
        return MaterialPageRoute(settings: settings, builder: (_) => const About());
      case MY_APPOINTMENTS:
        return MaterialPageRoute(settings: settings, builder: (_) => MyAppointments(showOnlyPastAppointments: (args ?? false) as bool,));
      case MY_CLIENTS:
        return MaterialPageRoute(settings: settings, builder: (_) => MyClients());
      case LONG_TEXT:
        return MaterialPageRoute(settings: settings, builder: (_) => LongText(appBarTitle: (args as Map)["appBarTitle"] as String, title: args["title"] as String, content: args["content"] as String,));
      case CHOICE_OF_SERVICE:
        return MaterialPageRoute(settings: settings, builder: (_) => ChoiceOfService(
            appUser: (args as Map)["user"] as AppUser,
            manuallyAddAppointment: (args["manually_add_appointment"] ?? false) as bool,
            //showMenu: (args["show_menu"] ?? false) as bool
        ));
      case MAKE_AN_APPOINTMENT:
        return MaterialPageRoute(settings: settings, builder: (_) => MakeAnAppointment(
            appUser: (args as Map)["user"] as AppUser,
            serviceProvided: args["serviceProvided"] as ServiceProvided,
            manuallyAddAppointment: (args["manually_add_appointment"] ?? false) as bool,
            appointmentToChange: args["appointmentToChange"] as AppointmentDetails?,
          ),
        );
      case SERVICE_FORM:
        return MaterialPageRoute(settings: settings, builder: (_) => ServiceProvidedForm(serviceProvided: args as ServiceProvided?,));
      case AVAILABLE_SCHEDULE_FORM:
        return MaterialPageRoute(settings: settings, builder: (_) => AvailableScheduleForm(availableSchedule: (args as Map)["availableSchedule"] as AvailableSchedule?, onDelete: args["onDelete"] as VoidCallback,  onSave: args["onSave"] as VoidCallback));
      case CALENDAR_BLOCKED_PERIOD:
        //return MaterialPageRoute(settings: settings, builder: (_) => CalendarBlockedPeriods(showOnlyPastBlockedPeriods: (args ?? false) as bool,));
        return MaterialPageRoute(settings: settings, builder: (_) => CalendarBlockedPeriods());
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
