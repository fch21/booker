import 'package:booker/helper/route_generator.dart';
import 'package:booker/main.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:booker/widgets/appointment_details_card.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:flutter/material.dart';

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

  List<AppointmentDetails> futureAppointments = [];
  List<AppointmentDetails> pastAppointments = [];
  //List<AppointmentDetails> futurePeriodicAppointments = [];
  //List<AppointmentDetails> pastPeriodicAppointments = [];
  bool appointmentsAreLoaded = false;
  DateTime currentDateTime = DateTime.now();

  _getAppointmentsList() async {
    pastAppointments.clear();
    futureAppointments.clear();
    //futurePeriodicAppointments.clear();
    //pastPeriodicAppointments.clear();
    List<AppointmentDetails> appointments = [];
    if(currentAppUser!.isServiceProvider){
      appointments = await AppointmentDetails.getServiceProviderAppointmentDetails(appUser: currentAppUser!);
    }
    else{
      appointments = await AppointmentDetails.getClientAppointmentDetails(appUser: currentAppUser!);
    }
    //appointments.sort((a, b) => a.from.compareTo(b.from));


    for(var appointment in appointments){

      /*
      if(appointment.periodicalWeekDay != null){
        //to only show the periodicAppointments that are canceled if we are looking the past appointments
        if(appointment.isCanceled) {
          pastPeriodicAppointments.add(appointment);
        }
        else {
          futurePeriodicAppointments.add(appointment);
        }

      }
      else{
        if(appointment.from.isBefore(currentDateTime)){
          pastAppointments.add(appointment);
        }
        else{
          futureAppointments.add(appointment);
        }
      }

       */
      if(appointment.from.isBefore(currentDateTime)){
        pastAppointments.add(appointment);
      }
      else{
        futureAppointments.add(appointment);
      }
    }

    pastAppointments.sort((a, b) => b.from.compareTo(a.from));
    futureAppointments.sort((a, b) => a.from.compareTo(b.from));
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

    bool greaterWidthLayout = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    List<AppointmentDetails> appointments = widget.showOnlyPastAppointments ? pastAppointments : futureAppointments;
    //List<AppointmentDetails> periodicAppointments = widget.showOnlyPastAppointments ? pastPeriodicAppointments : futurePeriodicAppointments;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.showOnlyPastAppointments ? "Histórico de agendamentos" : "Agendamentos Futuros"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: greaterWidthLayout ? MediaQuery.of(context).size.width/4 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if(!appointmentsAreLoaded)
              Padding(
                padding: const EdgeInsets.only(top: 64.0),
                child: LoadingData(),
              ),
            if(appointmentsAreLoaded)
              appointments.isEmpty //&& periodicAppointments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 64, bottom: 16),
                    child: Center(
                        child: Text(widget.showOnlyPastAppointments ? "Nenhum agendamento no histórico" : "Nenhum agendamento futuro", style: textStyleSmallNormal,)
                    ),
                  )
                : Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0), // Adicionado o padding lateral
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appointments.length, //+ periodicAppointments.length,
                      itemBuilder: (BuildContext context, int index) {

                        //AppointmentDetails appointmentDetails = index < periodicAppointments.length ? periodicAppointments[index] : appointments[index - periodicAppointments.length];
                        AppointmentDetails appointmentDetails = appointments[index];

                        return Opacity(
                          opacity: widget.showOnlyPastAppointments || appointmentDetails.isCanceled ? 0.5 : 1.0,
                          child: AppointmentDetailsCard(
                            appointmentDetails: appointmentDetails,
                            isClient: !currentAppUser!.isServiceProvider,
                            onTap: (){
                              Navigator.pushNamed(context, RouteGenerator.APPOINTMENT_DETAILS_PAGE, arguments: appointmentDetails).then((value){
                                _getAppointmentsList();
                              });
                            },
                          ),
                        );

                        /*
                        return Column(
                          children: [

                            if(index == 0 && periodicAppointments.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 12, bottom: 12),
                                child: Text("Agendamentos Periódicos", style: textStyleSmallBold,),
                              ),
                            Opacity(
                              opacity: widget.showOnlyPastAppointments || appointmentDetails.isCanceled ? 0.5 : 1.0,
                              child: AppointmentDetailsCard(
                                appointmentDetails: appointmentDetails,
                                isClient: !currentAppUser!.isServiceProvider,
                                onTap: (){
                                  Navigator.pushNamed(context, RouteGenerator.APPOINTMENT_DETAILS_PAGE, arguments: appointmentDetails).then((value){
                                    _getAppointmentsList();
                                  });
                                },
                              ),
                            ),
                            if(index == periodicAppointments.length - 1)
                              const Padding(
                                padding: EdgeInsets.only(top: 8, bottom: 16),
                                child: Divider(),
                              ),
                          ],
                        );

                         */
                      },
                    ),
                ),
            if(appointmentsAreLoaded && !widget.showOnlyPastAppointments)
              Padding(
                padding: const EdgeInsets.only(top: 48, bottom: 32),
                child: Center(
                  child: TextButton(
                    onPressed: (){
                      Navigator.pushNamed(context, RouteGenerator.MY_APPOINTMENTS, arguments: true);
                    },
                    child: const Text("Histórico de agendamentos"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}