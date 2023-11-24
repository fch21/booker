import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/models/time_interval.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:booker/widgets/profile_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MakeAnAppointment extends StatefulWidget {

  AppUser appUser;
  ServiceProvided serviceProvided;

  MakeAnAppointment({
    Key? key,
    required this.appUser,
    required this.serviceProvided,
  }) : super(key: key);

  @override
  State<MakeAnAppointment> createState() => _MakeAnAppointmentState();
}

class _MakeAnAppointmentState extends State<MakeAnAppointment> {

  late int serviceDurationInMinutes;

  DateTime currentDateTime = DateTime.now();
  DateTime? selectedDateTime;
  TimeOfDay? selectedTimeOfDay;

  List<TimeOfDay> currentAvailableTimes = [];
  bool isLoadingCurrentAvailableTimes = false;
  
  String getDateTimeFormatted(DateTime dateTime){
    String dateTimeFormatted = DateFormat('dd/MM').format(dateTime);
    return dateTimeFormatted;
  }

  DateTime getDateTimeSimplified(DateTime dateTime){
    DateTime dateTimeSimplified = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return dateTimeSimplified;
  }

  String _getWeekDay(DateTime date) {
    // Dart 'weekday' dá 1 para Segunda-feira, 2 para Terça-feira e assim por diante
    return  Strings.WEEK_DAYS[date.weekday - 1];
  }
  
  // Function to get made appointments for a specific day
  Future<List<AppointmentDetails>> _getAppointmentsMade(DateTime dateTime) async {
    //print("_getAppointmentsMade >>>>>>");
    DateTime simplifiedDateTime = getDateTimeSimplified(dateTime);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Strings.COLLECTION_APPOINTMENTS_DETAILS_PUBLIC)
        .where(Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID, isEqualTo: widget.appUser.id)
        .where(Strings.APPOINTMENT_DAY, isEqualTo: simplifiedDateTime)
        .get();

    List<AppointmentDetails> appointments = [];
    for (var doc in querySnapshot.docs) {
      AppointmentDetails appointmentDetails = AppointmentDetails.fromDocumentSnapshotPublic(doc);
      appointments.add(appointmentDetails);
    }

    return appointments;
  }

  DateTime getNextAvailableTime(DateTime startTime, List<AppointmentDetails> appointments, int serviceDurationInMinutes) {
    //print("getNextAvailableTime >>>>");
    DateTime endTime = startTime.add(Duration(minutes: serviceDurationInMinutes));
    //print("startTime = ${startTime}");
    //print("endTime = ${endTime}");

    DateTime nextAvailable = startTime;

    for (var appointment in appointments) {
      // Check for a conflict: the slot is unavailable if the start time is before the end of an existing appointment
      // or the end time is after the start of that appointment
      //print("appointment.from = ${appointment.from}");
      //print("appointment.to = ${appointment.to}");
      if (startTime.isBefore(appointment.to) && endTime.isAfter(appointment.from)) {
        //return false; // There is a conflict
        if (appointment.to.isAfter(nextAvailable)) {
          nextAvailable = appointment.to;
        }
      }
    }
    //return true; // No conflict, the slot is available
    return nextAvailable;
  }

  // Function to generate available times considering existing appointments
  Future<void> generateAvailableTimes(DateTime dateTime) async {

    setState(() {
      isLoadingCurrentAvailableTimes = true;
    });
    //print("generateAvailableTimes >>>>>>");
    // Find out the week day of the provided date
    String weekDay = _getWeekDay(dateTime);
    //print("weekDay = $weekDay");

    // Get intervals for the specific day
    var dayIntervals = widget.appUser.availabilityMap[weekDay];
    List<TimeOfDay> availableTimes = [];

    List<AppointmentDetails> appointments = await _getAppointmentsMade(currentDateTime);

    if (dayIntervals != null && dayIntervals['isSelected'] && dayIntervals['intervals'] is List) {
      for (var interval in (dayIntervals['intervals'] as List<TimeInterval>)) {
        TimeOfDay intervalStartTime = interval.startTime;
        TimeOfDay intervalEndTime = interval.endTime;
        DateTime intervalEndDateTime = dateTime.copyWith(hour: intervalEndTime.hour, minute: intervalEndTime.minute, second: 0, millisecond: 0, microsecond: 0);

        DateTime appointmentStartDateTime = dateTime.copyWith(hour: intervalStartTime.hour, minute: intervalStartTime.minute, second: 0, millisecond: 0, microsecond: 0);
        DateTime appointmentEndDateTime = appointmentStartDateTime.add(Duration(minutes: serviceDurationInMinutes));

        while (!appointmentEndDateTime.isAfter(intervalEndDateTime)) {

          //await Future.delayed(Duration(milliseconds: 200));
          // Check if the current time slot is available. If not, adjust the start time

          DateTime nextAvailableTime = getNextAvailableTime(appointmentStartDateTime, appointments, serviceDurationInMinutes);
          //print("appointmentStartDateTime = ${appointmentStartDateTime}");
          //print("nextAvailableTime = ${nextAvailableTime}");
          if (nextAvailableTime.isAfter(appointmentStartDateTime)) {
            appointmentStartDateTime = nextAvailableTime;
            continue;
          }

          if (appointmentStartDateTime.isAfter(DateTime.now())) {
            availableTimes.add(TimeOfDay(hour: appointmentStartDateTime.hour, minute: appointmentStartDateTime.minute));
          }

          // Calculate the next possible start time
          appointmentStartDateTime = appointmentStartDateTime.add(Duration(minutes: serviceDurationInMinutes));
          appointmentEndDateTime = appointmentStartDateTime.add(Duration(minutes: serviceDurationInMinutes));
        }
      }
    }

    print("availableTimes = $availableTimes");

    setState(() {
      currentAvailableTimes = availableTimes;
      isLoadingCurrentAvailableTimes = false;
    });

    return;
  }

  Future<bool> _makeAppointment() async {
    if(selectedTimeOfDay != null && selectedDateTime != null){

      DateTime startingDateTime = selectedDateTime!.copyWith(hour: selectedTimeOfDay!.hour, minute: selectedTimeOfDay!.minute, second: 0, millisecond: 0, microsecond: 0);

      AppointmentDetails appointmentDetails = AppointmentDetails();
      appointmentDetails.serviceId = widget.serviceProvided.id;
      appointmentDetails.serviceProviderUserId = widget.serviceProvided.userId;
      appointmentDetails.name = "${widget.serviceProvided.name} - ${widget.appUser.name}";
      appointmentDetails.day = getDateTimeSimplified(selectedDateTime!);
      appointmentDetails.from = startingDateTime;
      appointmentDetails.to = startingDateTime.add(widget.serviceProvided.duration);

      return await appointmentDetails.updateAppointmentDetailsInFirestore(context);
    }
    return false;
  }

  _showAppointmentMadeDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.end,
          title: Text("Confirmado"),
          content: Text("Agendamento marcado com sucesso!\nVocê receberá um email de confimação."),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok, style: TextStyle(color: widget.appUser.getUserColorResolved())),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showMakeAppointmentDialog(){
    if(selectedTimeOfDay != null && selectedDateTime != null){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceBetween,
            title: Text("Marcar Horário"),
            content: Text("Você deseja marcar o serviço ${widget.serviceProvided.name} para ${selectedTimeOfDay!.format(context)} do dia ${getDateTimeFormatted(selectedDateTime!)}?"),
            actions: <Widget>[
              TextButton(
                child: Text("Cancelar", style: TextStyle(color: widget.appUser.getUserColorResolved())),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Confirmar", style: TextStyle(color: widget.appUser.getUserColorResolved())),
                onPressed: () {
                  _makeAppointment();
                  Navigator.of(context).pop();
                  _showAppointmentMadeDialog();
                },
              ),
            ],
          );
        },
      );
    }
    else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.end,
            title: Text("Selecione um Horário"),
            content: Text("Você precisa selecionar um horário antes de marcar."),
            actions: <Widget>[
              TextButton(
                child: Text("Ok", style: TextStyle(color: widget.appUser.getUserColorResolved()),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    serviceDurationInMinutes = widget.serviceProvided.duration.inMinutes;
    generateAvailableTimes(currentDateTime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Marcar um horário"),
        elevation: 0,
        backgroundColor: widget.appUser.getUserColorResolved(),
        foregroundColor: Utils.getContrastingColor(widget.appUser.getUserColorResolved()),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeader(appUser: widget.appUser,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  splashRadius: 20,
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 18,
                  onPressed: () {
                    currentDateTime = currentDateTime.subtract(const Duration(days: 1));
                    generateAvailableTimes(currentDateTime);
                    setState(() {});
                  },
                ),
                InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );

                    if (pickedDate != null) {
                      currentDateTime = pickedDate;
                      generateAvailableTimes(currentDateTime);
                      setState(() {});
                    }
                  },
                  child: Text(
                    getDateTimeFormatted(currentDateTime),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  splashRadius: 20,
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 18,
                  onPressed: () {
                    currentDateTime = currentDateTime.add(const Duration(days: 1));
                    generateAvailableTimes(currentDateTime);
                    setState(() {});
                  },
                ),
              ],
            ),
            if(isLoadingCurrentAvailableTimes)
              Padding(
                padding: const EdgeInsets.all(64.0),
                child: LoadingData(color: widget.appUser.getUserColorResolved(),),
              ),
            if(!isLoadingCurrentAvailableTimes)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: currentAvailableTimes.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 16),
                    child: Center(
                      child: Text(AppLocalizations.of(context)!.no_available_times_message, style: textStyleSmallNormal,)
                    ),
                  )
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: currentAvailableTimes.map((timeOfDay) {
                        //int index = currentAvailableTimes.indexOf(timeOfDay);
                        bool isSelected = selectedDateTime == currentDateTime && selectedTimeOfDay == timeOfDay;
                        return ChoiceChip(
                          key: UniqueKey(),
                          disabledColor: Colors.black26,
                          selectedColor: Colors.white,
                          labelStyle: const TextStyle(color: Colors.black, fontSize: 16,),
                          label: Text(timeOfDay.format(context)),
                          //elevation: isSelected ? 3 : 1,
                          side: isSelected ? const BorderSide(width: 0, color: Colors.green) : null,
                          //selectedShadowColor: Colors.green,
                          selected: isSelected,
                          onSelected: (value){
                            if(!value){
                              setState(() {
                                selectedDateTime = null;
                                selectedTimeOfDay = null;
                              });
                            }
                            else{
                              setState(() {
                                selectedDateTime = currentDateTime;
                                selectedTimeOfDay = timeOfDay;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
              child: ButtonCustom(
                color: widget.appUser.getUserColorResolved(),
                text: "Marcar horário",
                textColor: Utils.getContrastingColor(widget.appUser.getUserColorResolved()),
                onPressed: _showMakeAppointmentDialog,
              ),
            )
          ],
        ),
      )
    );
  }
}

