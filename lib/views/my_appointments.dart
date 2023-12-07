import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/widgets/appointment_details_card.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:booker/widgets/profile_header.dart';
import 'package:booker/widgets/service_provided_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyAppointments extends StatefulWidget {

  bool showOnlyPastAppointments;

  MyAppointments({
    Key? key,
    this.showOnlyPastAppointments = false,
  }) : super(key: key);

  @override
  State<MyAppointments> createState() => _MyAppointmentsState();
}

class _MyAppointmentsState extends State<MyAppointments> {

  List<AppointmentDetails> appointments = [];
  bool appointmentsAreLoaded = false;
  DateTime currentDateTime = DateTime.now();


  _getAppointmentsList() async {
    appointments = await AppointmentDetails.getClientAppointmentDetails(appUser: currentAppUser!);
    appointments.sort((a, b) => a.from.compareTo(b.from));

    setState(() {
      appointmentsAreLoaded = true;
    });
  }

  @override
  void initState() {
    _getAppointmentsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.showOnlyPastAppointments ? "Histórico de agendamentos" : "Agendamentos Futuros"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if(!appointmentsAreLoaded)
              Padding(
                padding: const EdgeInsets.only(top: 64.0),
                child: LoadingData(),
              ),
            if(appointmentsAreLoaded)
              appointments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 16),
                    child: Center(
                        child: Text(AppLocalizations.of(context)!.no_services_provided_message, style: textStyleSmallNormal,)
                    ),
                  )
                : Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0), // Adicionado o padding lateral
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.showOnlyPastAppointments ? appointments.length : appointments.length + 1,
                      itemBuilder: (BuildContext context, int index) {

                        if(!widget.showOnlyPastAppointments && index == appointments.length){
                          return Padding(
                            padding: const EdgeInsets.only(top: 32.0),
                            child: ButtonCustom(
                              text: "Histórico de agendamentos",
                              onPressed: (){
                                Navigator.pushNamed(context, RouteGenerator.MY_APPOINTMENTS, arguments: true);
                              },
                            ),
                          );
                        }

                        AppointmentDetails appointmentDetails = appointments[index];

                        //print("appointmentDetails.from = ${appointmentDetails.from}");
                        //print("appointmentDetails.from.isBefore(currentDateTime) = ${appointmentDetails.from.isBefore(currentDateTime)}");
                        if(widget.showOnlyPastAppointments ? appointmentDetails.from.isBefore(currentDateTime) : appointmentDetails.from.isAfter(currentDateTime)) {
                          return Opacity(
                            opacity: widget.showOnlyPastAppointments ? 0.5 : 1.0,
                            child: AppointmentDetailsCard(
                              appointmentDetails: appointmentDetails,
                              isClient: !currentAppUser!.isServiceProvider,
                              onTap: (){
                                Navigator.pushNamed(context, RouteGenerator.APPOINTMENT_DETAILS_PAGE, arguments: appointmentDetails);
                              },
                            ),
                          );
                        }
                        else{
                          return Container();
                        }
                      },
                    ),
                ),
          ],
        ),
      ),
    );
  }
}