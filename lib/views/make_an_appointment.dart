import 'dart:async';

import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/models/time_interval.dart';
import 'package:booker/views/my_clients.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/client_card.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:booker/widgets/profile_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MakeAnAppointment extends StatefulWidget {

  AppUser appUser;
  ServiceProvided serviceProvided;
  AppointmentDetails? appointmentToChange;
  bool manuallyAddAppointment;

  MakeAnAppointment({
    Key? key,
    required this.appUser,
    required this.serviceProvided,
    this.manuallyAddAppointment = false,
    this.appointmentToChange,
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
  
  // Function to get made appointments for a specific day
  Future<List<AppointmentDetails>> _getAppointmentsMade(DateTime dateTime) async {
    //print("_getAppointmentsMade >>>>>>");
    DateTime simplifiedDateTime = Utils.getDateTimeSimplified(dateTime);

    List<Future<QuerySnapshot>> queryListToBeDone = [];

    //querySnapshotForPeriodicalAppointments
    /*
    queryListToBeDone.add(FirebaseFirestore.instance
        .collection(Strings.COLLECTION_APPOINTMENTS_DETAILS_PUBLIC)
        .where(Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID, isEqualTo: widget.appUser.id)
        .where(Strings.APPOINTMENT_PERIODICAL_WEEK_DAY, isEqualTo: Utils.getWeekDay(dateTime))
        .get());

     */

    /*
    if(widget.serviceProvided.hasPeriodicAppointments){

      for(int i = 0; i < widget.serviceProvided.numberOfPeriodicAppointments!; i ++){

        String dayDateTimeString = Utils.dateFormatForOrdering.format(simplifiedDateTime.add(Duration(days: 7 * i)));
        //querySnapshotForOneTimeAppointments
        queryListToBeDone.add(FirebaseFirestore.instance
            .collection(Strings.COLLECTION_APPOINTMENTS_DETAILS_PUBLIC)
            .where(Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID, isEqualTo: widget.appUser.id)
            .where(Strings.APPOINTMENT_DAY, isEqualTo: dayDateTimeString)
            .get());
      }
    }

     */
    String dayDateTimeString = Utils.dateFormatForOrdering.format(simplifiedDateTime);
    //querySnapshotForOneTimeAppointments
    queryListToBeDone.add(FirebaseFirestore.instance
        .collection(Strings.COLLECTION_APPOINTMENTS_DETAILS_PUBLIC)
        .where(Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID, isEqualTo: widget.appUser.id)
        .where(Strings.APPOINTMENT_DAY, isEqualTo: dayDateTimeString)
        .get());

    List<QuerySnapshot> queryResults = await Future.wait(queryListToBeDone);

    //List<DocumentSnapshot> docsForPeriodicalAppointments = queryResults.first.docs;

    List<DocumentSnapshot> docsForOneTimeAppointments = [];

    for(var queryResult in queryResults){
      /*
      if(queryResult != queryResults.first){
        docsForOneTimeAppointments.addAll(queryResult.docs);
      }
       */
      docsForOneTimeAppointments.addAll(queryResult.docs);
    }

    //List<DocumentSnapshot> allDocs = [...docsForPeriodicalAppointments, ...docsForOneTimeAppointments];

    List<AppointmentDetails> appointments = [];
    //for (var doc in allDocs) {
    for (var doc in docsForOneTimeAppointments) {
      AppointmentDetails appointmentDetails = AppointmentDetails.fromDocumentSnapshotPublic(doc);
      //print("appointmentDetails.from = ${appointmentDetails.from}");
      //print("appointmentDetails.to = ${appointmentDetails.to}");
      if(!appointmentDetails.isCanceled){
        /*
        if(appointmentDetails.periodicalWeekDay != null){
          //to show the periodic appointment in the selected date
          AppointmentDetails copy = appointmentDetails.copy();
          copy.from = copy.from.copyWith(year: dateTime.year, month: dateTime.month, day: dateTime.day);
          copy.to = copy.to.copyWith(year: dateTime.year, month: dateTime.month, day: dateTime.day);
          if(await appointmentDetails.isBeforeTheLastPeriodicAppointment(context, copy)) appointments.add(copy);
        }
        else{
          appointments.add(appointmentDetails);
        }

         */
        /*
        if(appointmentDetails.periodicalWeekDay != null){
          List<AppointmentDetails> periodicAppointments = await appointmentDetails.getListOfPeriodicAppointments(context);
          for(var appointment in periodicAppointments) {
            appointments.add(appointment);
          }
        }
        else{
          //to show future, but conflicting one time appointment in the selected date
          if(appointmentDetails.periodicalWeekDay == null){
            AppointmentDetails copy = appointmentDetails.copy();
            copy.from = copy.from.copyWith(year: dateTime.year, month: dateTime.month, day: dateTime.day);
            copy.to = copy.to.copyWith(year: dateTime.year, month: dateTime.month, day: dateTime.day);
            appointments.add(copy);
          }
        }

         */
        AppointmentDetails copy = appointmentDetails.copy();
        copy.from = copy.from.copyWith(year: dateTime.year, month: dateTime.month, day: dateTime.day);
        copy.to = copy.to.copyWith(year: dateTime.year, month: dateTime.month, day: dateTime.day);
        appointments.add(copy);
      }
    }

    appointments.sort((a, b) => a.from.compareTo(b.from));
    return appointments;
  }

  DateTime getNextAvailableTime(DateTime startTime, List<AppointmentDetails> appointments, int serviceDurationInMinutes) {
    //print("getNextAvailableTime >>>>");
    DateTime endTime = startTime.add(Duration(minutes: serviceDurationInMinutes));
    //print("startTime = ${startTime}");
    //print("endTime = ${endTime}");
    //print("appointments.length = ${appointments.length}");

    DateTime nextAvailable = startTime;
    //for (var appointment in appointments)print("appointment: from = ${appointment.from}, to = ${appointment.to}");

    for (var appointment in appointments) {
      // Check for a conflict: the slot is unavailable if the start time is before the end of an existing appointment
      // or the end time is after the start of that appointment
      //print("appointment.from = ${appointment.from}");
      //print("appointment.to = ${appointment.to}");
      //print("nextAvailable.isBefore(appointment.to) && endTime.isAfter(appointment.from) = ${nextAvailable.isBefore(appointment.to) && endTime.isAfter(appointment.from)}");
      if (nextAvailable.isBefore(appointment.to) && endTime.isAfter(appointment.from)) {
        //return false; // There is a conflict
        //print("appointment.to.isAfter(nextAvailable) = ${appointment.to.isAfter(nextAvailable)}");
        if (appointment.to.isAfter(nextAvailable)) {
          nextAvailable = appointment.to;
          endTime = nextAvailable.add(Duration(minutes: serviceDurationInMinutes));
        }
      }
    }
    //return true; // No conflict, the slot is available
    //print("getNextAvailableTime nextAvailable = ${nextAvailable}");
    return nextAvailable;
  }

  Future<List<TimeOfDay>> getAvailableTimesList(DateTime dateTime) async {
    //print("getAvailableTimesList >>>>>>>");
    List<TimeOfDay> availableTimes = [];

    String weekDay = Utils.getWeekDayString(dateTime);
    //print("weekDay = $weekDay");

    // Get intervals for the specific day
    var dayIntervals = widget.appUser.availabilityMap[weekDay];
    //print("dayIntervals = $dayIntervals");

    List<AppointmentDetails> appointments = await _getAppointmentsMade(currentDateTime);
    if (dayIntervals != null && dayIntervals['isSelected'] && dayIntervals['intervals'] is List) {

      List<TimeInterval> activeTimeIntervals = [];

      for (var interval in (dayIntervals['intervals'] as List<dynamic>)){
        if(interval['isSelected'] as bool){
          activeTimeIntervals.add(interval['timeInterval'] as TimeInterval);
        }
      }
      for (var interval in activeTimeIntervals) {
        TimeOfDay intervalStartTime = interval.startTime;
        TimeOfDay intervalEndTime = interval.endTime;
        DateTime intervalEndDateTime = dateTime.copyWith(hour: intervalEndTime.hour, minute: intervalEndTime.minute, second: 0, millisecond: 0, microsecond: 0);

        DateTime appointmentStartDateTime = dateTime.copyWith(hour: intervalStartTime.hour, minute: intervalStartTime.minute, second: 0, millisecond: 0, microsecond: 0);
        DateTime appointmentEndDateTime = appointmentStartDateTime.add(Duration(minutes: serviceDurationInMinutes));

        while (!appointmentEndDateTime.isAfter(intervalEndDateTime)) {
          //print("appointmentEndDateTime = ${appointmentEndDateTime}");
          //print("!appointmentEndDateTime.isAfter(intervalEndDateTime) = ${!appointmentEndDateTime.isAfter(intervalEndDateTime)}");
          //await Future.delayed(Duration(milliseconds: 200));
          // Check if the current time slot is available. If not, adjust the start time
          DateTime nextAvailableTime = getNextAvailableTime(appointmentStartDateTime, appointments, serviceDurationInMinutes);
          //print("appointmentStartDateTime = ${appointmentStartDateTime}");
          //print("nextAvailableTime = ${nextAvailableTime}");
          //print("nextAvailableTime.isAfter(appointmentStartDateTime) = ${nextAvailableTime.isAfter(appointmentStartDateTime)}");
          if (nextAvailableTime.isAfter(appointmentStartDateTime)) {
            nextAvailableTime = Utils.roundDateTime(nextAvailableTime);
            appointmentStartDateTime = nextAvailableTime;
            appointmentEndDateTime = appointmentStartDateTime.add(Duration(minutes: serviceDurationInMinutes));
            continue;//restart the loop
          }

          if (appointmentStartDateTime.isAfter(DateTime.now()) && widget.serviceProvided.isWithinValidSchedulingInterval(appointmentStartDateTime)) {
            appointmentStartDateTime = Utils.roundDateTime(appointmentStartDateTime);
            availableTimes.add(TimeOfDay(hour: appointmentStartDateTime.hour, minute: appointmentStartDateTime.minute));
          }
          //print("loop availableTimes = $availableTimes");
          // Calculate the next possible start time
          //appointmentStartDateTime = appointmentStartDateTime.add(Duration(minutes: serviceDurationInMinutes)); //to show start options each serviceDurationInMinutes minutes
          //appointmentStartDateTime = appointmentStartDateTime.add(Duration(minutes: 10));//to show start options each 10 minutes
          appointmentStartDateTime = appointmentStartDateTime.add(Duration(minutes: widget.serviceProvided.schedulingIntervalInMinutes));//to show start options each schedulingIntervalInMinutes
          appointmentEndDateTime = appointmentStartDateTime.add(Duration(minutes: serviceDurationInMinutes));
        }
      }
    }

    return availableTimes;
  }

  // Function to generate available times considering existing appointments
  Future<void> generateCurrentAvailableTimes(DateTime dateTime) async {

    currentAvailableTimes.clear();
    //to prevent making appointment in BlockedPeriods
    //print("widget.appUser.name = ${widget.appUser.name}");
    if(widget.appUser.isWithinBlockedPeriods(dateTime)) return;

    setState(() {
      isLoadingCurrentAvailableTimes = true;
    });
    //print("generateAvailableTimes >>>>>>");
    // Find out the week day of the provided date

    List<TimeOfDay> availableTimes = await getAvailableTimesList(dateTime);

    //print("availableTimes = $availableTimes");

    setState(() {
      currentAvailableTimes = availableTimes;
      isLoadingCurrentAvailableTimes = false;
    });

    return;
  }

  /*
  Future<int?> _showChangeOptionsDialog() async {
    return await showDialog <int>(
      context: context,
      builder: (BuildContext context) {
        TextStyle optionsStyle = const TextStyle(fontSize: fontSizeSmall, color: Colors.blue);

        return SimpleDialog(
          alignment: Alignment.center,
          title: const Center(child: Text('Atualizar agendamento periódico')),
          contentPadding: const EdgeInsets.only(top: 32, bottom: 16),
          children:[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 0);
              },
              child: Center(child: Text('Somente este agendamento', style: optionsStyle,)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 1);
              },
              child: Center(child: Text('Este e todos os agendamentos seguintes', style: optionsStyle,)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 2);
              },
              child: Center(child: Text('Todos', style: optionsStyle,)),
            ),
          ],
        );
      },
    );
  }
   */

  Future<void> _showTimeNotAvailableDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.end,
          title: const Text("Horário indisponível"),
          content: const Text("Sentimos muito, esse horário não está mais disponível"),
          actions: <Widget>[
            TextButton(
              child: Text("Mudar horário", style: TextStyle(color: widget.appUser.getUserColorResolved())),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return;
  }

  //To avoid two clients simultaneously booking the same time
  Future<bool> verifyIfTimeIsStillAvailable() async {

    bool stillAvailable = false;

    if(selectedTimeOfDay != null && selectedDateTime != null){
      List<TimeOfDay> availableTimes = await getAvailableTimesList(selectedDateTime!);
      if(availableTimes.any((element) => element == selectedTimeOfDay)){
        stillAvailable = true;
      }
      else{
        await _showTimeNotAvailableDialog();
        generateCurrentAvailableTimes(selectedDateTime!);
      }
    }


    return stillAvailable;
  }


  Future<bool> _makeAppointment(AppUser client) async {
    //print("_makeAppointment >>>");
    if(selectedTimeOfDay != null && selectedDateTime != null){

      bool stillAvailable = await verifyIfTimeIsStillAvailable();

      if(stillAvailable){
        DateTime startingDateTime = selectedDateTime!.copyWith(hour: selectedTimeOfDay!.hour, minute: selectedTimeOfDay!.minute, second: 0, millisecond: 0, microsecond: 0);

        if(widget.appointmentToChange == null){
          AppointmentDetails appointmentDetails = AppointmentDetails();
          appointmentDetails.serviceId = widget.serviceProvided.id;
          appointmentDetails.serviceProviderUserId = widget.serviceProvided.userId;
          appointmentDetails.userName = client.name;
          appointmentDetails.serviceProviderName = widget.appUser.name;
          appointmentDetails.serviceName = widget.serviceProvided.name;
          //print("widget.serviceProvided.hasPeriodicAppointments = ${widget.serviceProvided.hasPeriodicAppointments}");
          //if(widget.serviceProvided.hasPeriodicAppointments){
          //  appointmentDetails.periodicalWeekDay = Utils.getWeekDay(selectedDateTime!);
          //}
          //else{
          // appointmentDetails.day = Utils.getDateTimeSimplified(selectedDateTime!);
          //}
          appointmentDetails.day = Utils.getDateTimeSimplified(selectedDateTime!);
          appointmentDetails.from = startingDateTime;
          appointmentDetails.to = startingDateTime.add(widget.serviceProvided.duration);
          appointmentDetails.address = lastEnteredAddress;

          return await appointmentDetails.updateAppointmentDetailsInFirestore(context, client: client);
        }
        else{
          AppointmentDetails appointmentDetails = widget.appointmentToChange!;

          /*
        print("widget.serviceProvided.hasPeriodicAppointments = ${widget.serviceProvided.hasPeriodicAppointments}");
        if(widget.serviceProvided.hasPeriodicAppointments){
          //ATTENTION: do not use the updateAppointmentDetailsInFirestore directly
          //because the appointmentDetails have the from and to modified by
          //the method getListOfPeriodicAppointments
          int? option = await _showChangeOptionsDialog();

          print("option = ${option}");

          if(option == 0){//only this appointment
            appointmentDetails.addAppointmentChange(context, newFrom: startingDateTime);
          }
          else if(option == 1){//this and all following appointments
            appointmentDetails.addAppointmentChange(context, newFrom: startingDateTime, changeFollowing: true);
          }
          else if(option == 2){//all appointments
            appointmentDetails.addAppointmentChange(context, newFrom: startingDateTime, changeAll: true);
          }


          if(option != null){
            appointmentDetails.updateAppointmentDetailsInFirestore(context, client: client);
            return true;
          }
        }
        else{
          appointmentDetails.day = Utils.getDateTimeSimplified(selectedDateTime!);
          appointmentDetails.from = startingDateTime;
          appointmentDetails.to = startingDateTime.add(widget.serviceProvided.duration);
          appointmentDetails.updateAppointmentDetailsInFirestore(context, client: client);
          return true;
        }

         */

          appointmentDetails.day = Utils.getDateTimeSimplified(selectedDateTime!);
          appointmentDetails.from = startingDateTime;
          appointmentDetails.to = startingDateTime.add(widget.serviceProvided.duration);
          appointmentDetails.address = lastEnteredAddress;
          appointmentDetails.updateAppointmentDetailsInFirestore(context, client: client);
          return true;
        }
      }

    }
    return false;
  }

  Future<void> _showAppointmentMadeDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.end,
          title: const Text("Confirmado"),
          content: Text(widget.manuallyAddAppointment ? "Agendamento manualmente marcado com sucesso!" : "Agendamento marcado com sucesso!"),
          actions: <Widget>[
            TextButton(
              child: Text("Continuar", style: TextStyle(color: widget.appUser.getUserColorResolved())),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    return;
  }

  Future<String?> _getAddressForHomeService() async {

    String? address;

    bool showErrorMessage = false;

    StreamController<bool> updateDialogStreamController = StreamController.broadcast();
    TextEditingController controllerAddress = TextEditingController(text: "");

    await showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: const Text("Informe seu endereço"),
          content: StreamBuilder<bool>(
              stream: updateDialogStreamController.stream,
              builder: (context, snapshot) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text("Pelo serviço ${widget.serviceProvided.name} ser a domicílio, é preciso informar o seu endereço.\n\nDigite o endereço completo:"),
                      ),
                      GooglePlaceAutoCompleteTextField(
                        textEditingController: controllerAddress,
                        debounceTime: 300,
                        googleAPIKey: Strings.GOOGLE_API_KEY,
                        isLatLngRequired: false,
                        inputDecoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Digite seu endereço",
                        ),
                        getPlaceDetailWithLatLng:(_){},
                        countries: ["br"],
                        itemClick: (Prediction prediction) {
                          //print("description = " + prediction.description.toString());
                          controllerAddress.text = prediction.description ?? "";
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controllerAddress.selection = TextSelection.fromPosition(
                              TextPosition(offset: controllerAddress.text.length),
                            );
                          });
                        },
                        itemBuilder: (context, index, Prediction prediction) {
                          if(showErrorMessage){
                            showErrorMessage = false;
                            updateDialogStreamController.add(true);
                          }
                          return ListTile(
                            leading: Icon(Icons.location_on, color: standartTheme.primaryColor,),
                            title: Text(prediction.description ?? ""),
                          );
                        },
                        seperatedBuilder: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(height: 1, thickness: 1),
                        ),
                        containerHorizontalPadding: 8,
                        boxDecoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: const BorderRadius.all(Radius.circular(6))
                        ),
                      ),
                      if(showErrorMessage)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text("Endereço inválido.", style: TextStyle(color: Colors.red),),
                        ),
                    ],
                  ),
                );
              }
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar", style: TextStyle(color: widget.appUser.getUserColorResolved())),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Confirmar", style: TextStyle(color: widget.appUser.getUserColorResolved())),
              onPressed: () async {
                if(controllerAddress.text.isNotEmpty){
                  address = controllerAddress.text;
                  Navigator.of(context).pop();
                }
                else{
                  showErrorMessage = true;
                  updateDialogStreamController.add(true);
                }
              },
            ),
          ],
        );
      }
    );



    return address;
  }

  String lastEnteredAddress = "";

  Future<void> _showMakeAppointmentDialog() async {
    if(selectedTimeOfDay != null && selectedDateTime != null){

      StreamController<bool> updateDialogStreamController = StreamController.broadcast();
      TextEditingController controllerClientName = TextEditingController(text: "");
      AppUser? selectedClient;

      bool userIsLogged = currentAppUser != null;
      Widget dialog;
      //int weekday = Utils.getWeekDay(selectedDateTime!);
      //print("widget.serviceProvided.hasPeriodicAppointments = ${widget.serviceProvided.hasPeriodicAppointments}");
      if(userIsLogged){

        if(widget.serviceProvided.isHomeService){
          if(widget.appointmentToChange == null){
            String? address = await _getAddressForHomeService();
            if(address == null) return;
            lastEnteredAddress = address;
          }
          else{
            lastEnteredAddress = widget.appointmentToChange!.address;
          }
        }

        dialog = AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: const Text("Marcar Horário"),
          content: widget.manuallyAddAppointment
              ? StreamBuilder<bool>(
              stream: updateDialogStreamController.stream,
              builder: (context, snapshot) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(//widget.serviceProvided.hasPeriodicAppointments
                        //? "Marcar manualmente o serviço ${widget.serviceProvided.name} para ${selectedTimeOfDay!.format(context)} ${(weekday == 0 || weekday == 6) ? "aos" : "às"} ${Utils.getFullWeekDayString(selectedDateTime!)}s?"
                          "Marcar manualmente o serviço ${widget.serviceProvided.name} para ${selectedTimeOfDay!.format(context)} do dia ${getDateTimeFormatted(selectedDateTime!)}?"
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                        child: Text(
                            selectedClient != null
                                ? "Cliente selecionado:"
                                : "Adicione o nome do cliente ou escolha um cliente já existente:"
                        ),
                      ),
                      if(selectedClient == null)
                        InputCustom(
                            controller: controllerClientName,
                            label: "Nome do cliente"
                        ),

                      if(selectedClient == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Center(
                            child: GestureDetector(
                              child: const Text(
                                "Escolher um cliente existente",
                                style: TextStyle(color: Colors.blue),
                              ),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => MyClients(
                                      onTapUser: (client){
                                        selectedClient = client;
                                        updateDialogStreamController.add(true);
                                        Navigator.of(context).pop();
                                      },
                                    )
                                )
                                );
                              },
                            ),
                          ),
                        ),

                      if(selectedClient != null)
                        ClientCard(
                          client: selectedClient!,
                          compact: true,
                          onTap: (){},
                        ),
                    ],
                  ),
                );
              }
          )
              : widget.appointmentToChange == null
              ? Text(//widget.serviceProvided.hasPeriodicAppointments
            //? "Marcar o serviço ${widget.serviceProvided.name} para ${selectedTimeOfDay!.format(context)} ${(weekday == 0 || weekday == 6) ? "aos" : "às"} ${Utils.getFullWeekDayString(selectedDateTime!)}s?"
              "Marcar o serviço ${widget.serviceProvided.name} para ${selectedTimeOfDay!.format(context)} do dia ${getDateTimeFormatted(selectedDateTime!)}?"
          )
              : Text("Alterar o agendamento selecionado para ${selectedTimeOfDay!.format(context)} do dia ${getDateTimeFormatted(selectedDateTime!)}?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar", style: TextStyle(color: widget.appUser.getUserColorResolved())),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Confirmar", style: TextStyle(color: widget.appUser.getUserColorResolved())),
              onPressed: () async {

                if(widget.manuallyAddAppointment){
                  if(controllerClientName.text != "" || selectedClient != null){

                    AppUser? client = selectedClient;
                    if(client == null){
                      client = AppUser();
                      client.name = controllerClientName.text;
                    }
                    bool made = await _makeAppointment(client);
                    if(mounted) Navigator.of(context).pop();
                    if(made) await _showAppointmentMadeDialog();
                  }
                  else{
                    Utils.showSnackBar(context, "Adicione o nome do cliente ou escolha um cliente existente");
                  }
                }
                else if(widget.appointmentToChange != null){
                  AppUser? client = selectedClient;
                  if(client == null){
                    client = AppUser();
                    client.name = widget.appointmentToChange!.userName;
                  }
                  bool made = await _makeAppointment(client);
                  if(mounted) Navigator.of(context).pop();
                  if(made) await _showAppointmentMadeDialog();
                }
                else{
                  bool made = await _makeAppointment(currentAppUser!);
                  if(mounted) Navigator.of(context).pop();
                  if(made) await _showAppointmentMadeDialog();
                }
              },
            ),
          ],
        );
      }
      else{
        dialog = AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: const Text("Faça o login"),
          content: const Text("Para marcar um horário você precisa fazer o login"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar", style: TextStyle(color: widget.appUser.getUserColorResolved())),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Login", style: TextStyle(color: widget.appUser.getUserColorResolved())),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, RouteGenerator.LOGIN);
              },
            ),
          ],
        );
      }

      await showDialog(context: context, builder: (BuildContext context) => dialog);
    }
    else{
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.end,
            title: const Text("Selecione um Horário"),
            content: const Text("É preciso selecionar um horário antes de marcar."),
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
    return;
  }

  @override
  void initState() {
    serviceDurationInMinutes = widget.serviceProvided.duration.inMinutes;
    generateCurrentAvailableTimes(currentDateTime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Marcar um horário"),
        elevation: 0,
        backgroundColor: widget.appUser.getUserColorResolved(),
        foregroundColor: Utils.getContrastingColor(widget.appUser.getUserColorResolved()),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(appUser: widget.appUser,),
          const Divider(),
          Center(child: Text(widget.serviceProvided.name, style: textStyleSmallNormal)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.arrow_back),
                iconSize: 18,
                onPressed: () {
                  currentDateTime = currentDateTime.subtract(const Duration(days: 1));
                  generateCurrentAvailableTimes(currentDateTime);
                  setState(() {});
                },
              ),
              InkWell(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: currentDateTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: widget.serviceProvided.maxSchedulingDelayInDays)),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: widget.appUser.getUserColorResolved(), // header background color
                            onPrimary: Utils.getContrastingColor(widget.appUser.getUserColorResolved()) ?? Colors.black, // header text color
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black87, // button text color
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    currentDateTime = pickedDate;
                    generateCurrentAvailableTimes(currentDateTime);
                    setState(() {});
                  }
                },
                child: Text(
                  "${getDateTimeFormatted(currentDateTime)} (${Utils.getFullWeekDayUpperCaseString(currentDateTime)})",
                  style: textStyleSmallNormal,
                ),
              ),
              IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.arrow_forward),
                iconSize: 18,
                onPressed: () {
                  currentDateTime = currentDateTime.add(const Duration(days: 1));
                  generateCurrentAvailableTimes(currentDateTime);
                  setState(() {});
                },
              ),
            ],
          ),
          const Divider(height: 1.5),
          if(isLoadingCurrentAvailableTimes)
            Expanded(
              child: Center(child: LoadingData(color: widget.appUser.getUserColorResolved(),)),
            ),
          if(!isLoadingCurrentAvailableTimes)
            Expanded(
              child: currentAvailableTimes.isEmpty
                ? Padding(
                  padding: const EdgeInsets.only(top: 32.0, bottom: 16),
                  child: Center(
                    child: Text(AppLocalizations.of(context)!.no_available_times_message, style: textStyleSmallNormal,)
                  ),
                )
                : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Center(
                    child: Wrap(
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
                            label: SizedBox(width: 50, child: Center(child: Text(timeOfDay.format(context)))),
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
                ),
            ),
          const Divider(height: 1.5),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: ButtonCustom(
              color: widget.appUser.getUserColorResolved(),
              text: "Marcar horário",
              textColor: Utils.getContrastingColor(widget.appUser.getUserColorResolved()),
              onPressed: _showMakeAppointmentDialog,
            ),
          )
        ],
      )
    );
  }
}

