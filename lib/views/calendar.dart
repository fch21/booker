import 'dart:async';

import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/necessary_subscription_levels.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:booker/models/available_schedule.dart';
import 'package:booker/models/period.dart';
import 'package:booker/widgets/clickable_item.dart';
import 'package:booker/widgets/custom_divider.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {

  final List<AppointmentDetails> _appointmentsList = [];
  final CalendarController _controller = CalendarController();
  DateTime? _lastInitialDateTime;
  StreamController<bool> loadingStreamController = StreamController.broadcast();
  StreamController<bool> calendarStreamController = StreamController.broadcast();

  final GlobalKey<SliderDrawerState> _sliderDrawerKey = GlobalKey<SliderDrawerState>();

  void _changeCalendarView(CalendarView newView) {
    //print("newView = $newView");
    setState(() {
      _controller.view = newView;
    });
  }

  DateTime getEndDate(DateTime startDate){
    DateTime endDate = startDate;
    switch (_controller.view) {
      case CalendarView.schedule:
      //startDate = DateTime(initialDateTime.year, initialDateTime.month, initialDateTime.day);
        endDate = startDate.add(const Duration(days: 60));
        break;
      case CalendarView.day:
      //startDate = DateTime(initialDateTime.year, initialDateTime.month, initialDateTime.day);
        endDate = startDate.add(const Duration(days: 1));
        break;
      case CalendarView.week:
      //int weekDay = initialDateTime.weekday;
      //print("weekDay = $weekDay");
      //startDate = initialDateTime.subtract(Duration(days: (weekDay % 7) - 1)); // adjusts to the beginning of the week (sunday)
        endDate = startDate.add(const Duration(days: 7)); // adjusts to the end of the week (saturday)
        break;
      case CalendarView.month:
      //startDate = DateTime(initialDateTime.year, initialDateTime.month, 1); // First day of the month
      //endDate = DateTime(dateTime.year, dateTime.month + 1, 1);// Last day of the month
        endDate = startDate.add(const Duration(days: 42));
        break;
      default:
        break;
    }

    return endDate;
  }

  List<Period> queryHistory = [];
  
  Future<void> _getAppointments(DateTime initialDateTime) async {
    if(_controller.view == CalendarView.schedule) initialDateTime = initialDateTime.subtract(const Duration(days: 30));
    print("_getAppointments >>>>>>");
    loadingStreamController.add(true);
    //DateTime simplifiedDateTime = getDateTimeSimplified(dateTime);
    _lastInitialDateTime = initialDateTime;
    DateTime startDate = initialDateTime;
    DateTime endDate = getEndDate(startDate);
    print("startDate = $startDate");
    print("endDate = $endDate");

    List<AppointmentDetails> appointments = [];
    List<Future> queryListToBeDone = [];

    //QuerySnapshot? querySnapshotForPeriodicalAppointments;

    /*
    if(queryHistory.isEmpty){
      queryListToBeDone.add(
          FirebaseFirestore.instance
          .collection(Strings.COLLECTION_APPOINTMENTS_DETAILS)
          .where(Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID, isEqualTo: currentAppUser!.id)
          .where(Strings.APPOINTMENT_PERIODICAL_WEEK_DAY, isNull: false)
          .get()
      );
    }

     */

    QuerySnapshot? querySnapshotForOneTimeAppointments;

    //print("queryHistory = $queryHistory");
    if(!queryHistory.any((element) => !element.startDate.isAfter(startDate) && !element.endDate.isBefore(endDate))){
      //only search if is not already done
      String formattedStartDate = Utils.formatDateTimeToOrder(startDate);
      String formattedEndDate = Utils.formatDateTimeToOrder(endDate);

      queryListToBeDone.add(
          FirebaseFirestore.instance
          .collection(Strings.COLLECTION_APPOINTMENTS_DETAILS)
          .where(Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID, isEqualTo: currentAppUser!.id)
          .where(Strings.APPOINTMENT_DAY, isGreaterThanOrEqualTo: formattedStartDate)
          .where(Strings.APPOINTMENT_DAY, isLessThanOrEqualTo: formattedEndDate)
          .get()
      );

      queryHistory.add(Period(startDate: startDate, endDate: endDate));
    }

    var queryResults = await Future.wait(queryListToBeDone);

    /*
    if(queryResults.length == 2){
      querySnapshotForPeriodicalAppointments = queryResults.first;
      querySnapshotForOneTimeAppointments = queryResults.last;
    }
    else if(queryResults.length == 1){
      querySnapshotForOneTimeAppointments = queryResults.first;
    }

     */

    if(queryResults.isNotEmpty) querySnapshotForOneTimeAppointments = queryResults.first;

    List<Future> initServiceProvidedTasks = [];
    List<AppointmentDetails> oneTimeAppointments = [];
    //List<AppointmentDetails> periodicAppointments = [];

    for(var doc in querySnapshotForOneTimeAppointments?.docs ?? []){
      AppointmentDetails appointmentDetails = AppointmentDetails.fromDocumentSnapshot(doc);
      oneTimeAppointments.add(appointmentDetails);
      initServiceProvidedTasks.add(appointmentDetails.initServiceProvided(context));
    }

    /*
    for(var doc in querySnapshotForPeriodicalAppointments?.docs ?? []){
      AppointmentDetails appointmentDetails = AppointmentDetails.fromDocumentSnapshot(doc);
      periodicAppointments.add(appointmentDetails);
      initServiceProvidedTasks.add(appointmentDetails.initServiceProvided(context));
    }

     */

    await Future.wait(initServiceProvidedTasks);

    for(var appointmentDetails in oneTimeAppointments){
      if(!appointmentDetails.isCanceled){
        if(appointmentDetails.to.isBefore(DateTime.now())) appointmentDetails.serviceProvided.color = appointmentDetails.serviceProvided.color.withOpacity(0.5);
        appointments.add(appointmentDetails);
      }
    }
    /*

    for(var appointmentDetails in periodicAppointments){
      if(!appointmentDetails.isCanceled){
        List<AppointmentDetails> periodicAppointments = await appointmentDetails.getListOfPeriodicAppointments(context);
        for(var appointment in periodicAppointments) {
          if(appointment.to.isBefore(DateTime.now())) appointment.serviceProvided.color = appointment.serviceProvided.color.withOpacity(0.5);
          //print("appointment.from = ${appointment.from}");
          //print("appointmentDetails.from = ${appointmentDetails.from}");
          appointments.add(appointment);
        }
      }
    }

     */

    //print("number of appointments = ${appointments.length}");

    for(var appointment in appointments){
      //if((!_appointmentsList.any((element) => element.id == appointment.id)) || appointment.periodicalWeekDay != null){
      if((!_appointmentsList.any((element) => element.id == appointment.id))){
        _appointmentsList.add(appointment);
      }
    }
    //print("_appointmentsList = ${_appointmentsList.length}");
    //for(var appointment in _appointmentsList){
    //  print("appointment = ${appointment.from}");
    //}
    calendarStreamController.add(true);
    loadingStreamController.add(false);
    return;
  }

  /*
  Future<void> _getAppointments(DateTime initialDateTime) async {
    if(_controller.view == CalendarView.schedule) initialDateTime = initialDateTime.subtract(const Duration(days: 30));

    print("_getAppointments >>>>>>");
    loadingStreamController.add(true);
    //DateTime simplifiedDateTime = getDateTimeSimplified(dateTime);
    _lastInitialDateTime = initialDateTime;
    DateTime startDate = initialDateTime;
    DateTime endDate = getEndDate(startDate);
    print("startDate = $startDate");
    print("endDate = $endDate");

    String formattedStartDate = Utils.formatDateTimeToOrder(startDate);
    String formattedEndDate = Utils.formatDateTimeToOrder(endDate);

    QuerySnapshot querySnapshotForOneTimeAppointments = await FirebaseFirestore.instance
        .collection(Strings.COLLECTION_APPOINTMENTS_DETAILS)
        .where(Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID, isEqualTo: currentAppUser!.id)
        .where(Strings.APPOINTMENT_DAY, isGreaterThanOrEqualTo: formattedStartDate)
        .where(Strings.APPOINTMENT_DAY, isLessThanOrEqualTo: formattedEndDate)
        .get();

    bool getAllWeekDays = _controller.view != CalendarView.day;
    bool isMonthView = _controller.view == CalendarView.month || _controller.view == CalendarView.schedule;

    QuerySnapshot querySnapshotForPeriodicalAppointments;
    Query queryForPeriodicalAppointments = FirebaseFirestore.instance
        .collection(Strings.COLLECTION_APPOINTMENTS_DETAILS)
        .where(Strings.APPOINTMENT_SERVICE_PROVIDER_USER_ID, isEqualTo: currentAppUser!.id);

    if(getAllWeekDays){
      querySnapshotForPeriodicalAppointments = await queryForPeriodicalAppointments
          .where(Strings.APPOINTMENT_PERIODICAL_WEEK_DAY, isNull: false)
          .get();

    }
    else{
      querySnapshotForPeriodicalAppointments = await queryForPeriodicalAppointments
          .where(Strings.APPOINTMENT_PERIODICAL_WEEK_DAY, isEqualTo: Utils.getWeekDay(startDate))
          .get();
    }

    List<DocumentSnapshot> allDocs = [...querySnapshotForPeriodicalAppointments.docs, ...querySnapshotForOneTimeAppointments.docs];
    //List<DocumentSnapshot> allDocs = [...querySnapshotForOneTimeAppointments.docs];

    List<AppointmentDetails> appointments = [];
    for (var doc in allDocs) {
      AppointmentDetails originalAppointmentDetails = AppointmentDetails.fromDocumentSnapshot(doc);
      if(mounted) await originalAppointmentDetails.initServiceProvided(context);
      //if(appointmentDetails.status == Strings.APPOINTMENT_STATUS_CANCELED) appointmentDetails.serviceProvided.color = Colors.red.withOpacity(0.5);
      //appointments.add(appointmentDetails);
      AppointmentDetails appointmentDetails = originalAppointmentDetails.copy();
      //if(getAllWeekDays && appointmentDetails.periodicalWeekDay != null){
      if(appointmentDetails.periodicalWeekDay != null){
        if(getAllWeekDays){
          //to show the periodic appointment in all week days
          appointmentDetails.from = appointmentDetails.from.copyWith(year: startDate.year, month: startDate.month, day: startDate.day).add(Duration(days: appointmentDetails.periodicalWeekDay!));
          appointmentDetails.to = appointmentDetails.to.copyWith(year: startDate.year, month: startDate.month, day: startDate.day).add(Duration(days: appointmentDetails.periodicalWeekDay!));
        }
        else{
          //_controller.view == CalendarView.day
          //to update de date in the appointment to the current day
          if(Utils.getWeekDay(startDate) == appointmentDetails.periodicalWeekDay){
            appointmentDetails.from = appointmentDetails.from.copyWith(year: startDate.year, month: startDate.month, day: startDate.day);
            appointmentDetails.to = appointmentDetails.to.copyWith(year: startDate.year, month: startDate.month, day: startDate.day);
          }
        }
      }
      if(!appointmentDetails.isCanceled){
        AppointmentDetails copy = appointmentDetails.copy();
        if(copy.to.isBefore(DateTime.now())) copy.serviceProvided.color = copy.serviceProvided.color.withOpacity(0.5);
        //condition to not add periodic appointments before the appointment creation date
        print("copy.from = ${copy.from}");
        print("appointmentDetails.from = ${originalAppointmentDetails.from}");
        if(copy.periodicalWeekDay == null || (copy.periodicalWeekDay != null && !copy.from.isBefore(originalAppointmentDetails.from))) {
          print("copy added");
          if(await originalAppointmentDetails.isBeforeTheLastPeriodicAppointment(context, copy)) {
            appointments.add(copy);
          }
        }

        //print("isMonthView = ${isMonthView}");
        if(appointmentDetails.periodicalWeekDay != null && isMonthView){
          for(int i = 0; i < 5; i++) {//the month view shows 6 weeks, so we should add 5 more periodic appointments
            AppointmentDetails copyForMonth = appointmentDetails.copy();
            copyForMonth.from = appointmentDetails.from.add(Duration(days: 7 * (i + 1)));
            copyForMonth.to = appointmentDetails.to.add(Duration(days: 7 * (i + 1)));
            if(copyForMonth.to.isBefore(DateTime.now())) copyForMonth.serviceProvided.color = copyForMonth.serviceProvided.color.withOpacity(0.5);
            //condition to not add periodic appointments before the appointment creation date
            print("copyForMonth.from = ${copyForMonth.from}");
            print("appointmentDetails.from = ${originalAppointmentDetails.from}");
            if(!copyForMonth.from.isBefore(originalAppointmentDetails.from)) {
              print("copyForMonth added");
              if(await originalAppointmentDetails.isBeforeTheLastPeriodicAppointment(context, copyForMonth)) {
                appointments.add(copyForMonth);
              }
            }
          }
        }
      }
    }

    print("number of appointments = ${appointments.length}");

    setState(() {
      _appointmentsList = appointments;
    });

    loadingStreamController.add(false);
    return;
  }
   */

  List<TimeRegion> _getAvailableSchedulesSpecialRegions(){

    List<TimeRegion> timeRegions = [];

    List<AvailableSchedule> availableSchedulesList = AvailableSchedule.convertMapToSchedules(currentAppUser!.availabilityMap);

    List<TimeRegion> availableSchedulesConverted = [];

    if(_lastInitialDateTime != null){
      for(var availableSchedule in availableSchedulesList){
        if(availableSchedule.isSelected){
          List<TimeRegion> timeRegionsList = availableSchedule.convertIntoTimeRegionsList(_lastInitialDateTime!, getEndDate(_lastInitialDateTime!));
          availableSchedulesConverted.addAll(timeRegionsList);
        }
      }
    }

    //print("availableSchedulesConverted = ${availableSchedulesConverted.length}");

    availableSchedulesConverted.removeWhere((element) => currentAppUser!.isWithinBlockedPeriods(element.startTime));

    List<TimeRegion> blockedPeriodsTimeRegions = currentAppUser!.getBlockedPeriodsTimeRegionsList();

    timeRegions = [...availableSchedulesConverted, ...blockedPeriodsTimeRegions];

    return timeRegions;
  }

  String getTimePeriodString(){
    if(_lastInitialDateTime != null){
      DateTime startDate = _lastInitialDateTime!;
      if(_controller.view == CalendarView.day){
        return "no dia ${DateFormat('dd/MM').format(startDate)}";
      }
      else if(_controller.view == CalendarView.month){
        if(_controller.displayDate?.month != null){
          return "no mês de ${DateFormat('MMMM', 'pt_BR').format(_controller.displayDate!)}";
        }
      }
      else{
        DateTime endDate = getEndDate(startDate);

        return "no período de ${DateFormat('dd/MM').format(startDate)} até ${DateFormat('dd/MM').format(endDate.subtract(const Duration(seconds: 1)))}";
      }
    }
    return "";
  }

  Widget getCalendarConfigurationWidget(){
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          children:<Widget>[
            const Center(child: Text("Visualização", style: textStyleSmallNormal,)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: CustomDivider()),
            ClickableItem(
              text: "Agenda",
              iconData: Icons.schedule,
              onTap: () {
                _changeCalendarView(CalendarView.schedule);
                _sliderDrawerKey.currentState?.closeSlider();
              },
            ),
            ClickableItem(
              text: "Dia",
              iconData: Icons.calendar_view_day_outlined,
              onTap: () {
                _changeCalendarView(CalendarView.day);
                _sliderDrawerKey.currentState?.closeSlider();
              },
            ),
            ClickableItem(
              text: "Semana",
              iconData: Icons.calendar_view_week,
              onTap: () {
                _changeCalendarView(CalendarView.week);
                _sliderDrawerKey.currentState?.closeSlider();
              },
            ),
            ClickableItem(
              text: "Mês",
              iconData: Icons.calendar_view_month,
              onTap: () {
                _changeCalendarView(CalendarView.month);
                _sliderDrawerKey.currentState?.closeSlider();
              },
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: CustomDivider()),
            const Center(child: Text("Agendamentos", style: textStyleSmallNormal,)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0), child: CustomDivider()),
            ClickableItem(
              text: AppLocalizations.of(context)!.menu_calendar_block_periods,
              iconData: Icons.block,
              onTap: () {
                if(mounted) Navigator.pushNamed(context, RouteGenerator.CALENDAR_BLOCKED_PERIOD);
              },
            ),
            ClickableItem(
              text: AppLocalizations.of(context)!.menu_calendar_cancel_all,
              iconData: Icons.cancel_rounded,
              iconColor: Colors.red,
              onTap: () async {
                if(_controller.view != CalendarView.schedule){
                  if(_appointmentsList.isNotEmpty){
                    bool canceled = await AppointmentDetails.cancelAppointmentConfirmation(context, appointmentsList: _appointmentsList, isServiceProvider: true, useCancelAllMessage: true, extraTextForCancelAll: getTimePeriodString());
                    if(canceled && _lastInitialDateTime != null) await _getAppointments(_lastInitialDateTime!);
                  }
                  else{
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Nenhum agendamento'),
                          content: Text('Não existem agendamentos para cancelar ${getTimePeriodString()}'),
                          actionsAlignment: MainAxisAlignment.end,
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
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
                else{
                  Utils.showSnackBar(context, "É preciso mudar o modo de visualização.");
                }
              },
            ),
          ]
      ),
    );
  }

  @override
  void initState() {
    Utils.quitScreenIfUserIsNotASubscriber(context: context, subscriptionNeeded: NecessarySubscriptionLevels.CALENDAR);
    //WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //  DateTime? initialDate = _controller.displayDate;
     // if(initialDate != null) {
        //await _getAppointments(initialDate);
      //}
    //});
    //_controller.addPropertyChangedListener((property) {
    //  print("property = ${property}");
    //  print("_controller.displayDate = ${_controller.displayDate}");
    //});
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    Widget body = SliderDrawer(
      key: _sliderDrawerKey,
      appBar: SliderAppBar(
          appBarColor: standartTheme.primaryColor,
          appBarPadding: EdgeInsets.zero,
          appBarHeight: kToolbarHeight,
          drawerIconColor: Colors.white,
          trailing: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: (){Navigator.pop(context);},
          ),
          title:  Text(AppLocalizations.of(context)!.calendar, style: const TextStyle(color: Colors.white, fontSize: fontSizeLarge))
      ),
      slideDirection: SlideDirection.RIGHT_TO_LEFT,
      slider: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Text(AppLocalizations.of(context)!.configurations_appbar),
          ),
          body: getCalendarConfigurationWidget()
      ),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            StreamBuilder<bool>(
              stream: calendarStreamController.stream,
              builder: (context, snapshot) {
                return SfCalendar(
                  controller: _controller,
                  view: CalendarView.schedule,
                  dataSource: AppointmentDetailsDataSource(_appointmentsList),
                  specialRegions: _getAvailableSchedulesSpecialRegions(),
                  monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
                  onViewChanged: (ViewChangedDetails details){
                    print("onViewChanged >>>>>>");
                    DateTime startDate = details.visibleDates.first;
                    if(startDate != _lastInitialDateTime) {
                      _getAppointments(startDate);
                    }
                  },
                  onSelectionChanged: (CalendarSelectionDetails details){
                    print("onSelectionChanged >>>>>>");
                    print("details.date = ${details.date}");
                    print("details.resource = ${details.resource}");
                  },
                  onTap: (CalendarTapDetails details) {
                    if (details.targetElement == CalendarElement.appointment) {
                      final AppointmentDetails appointmentDetails = details.appointments!.first;
                      //print("appointmentDetails.periodicalWeekDay = ${appointmentDetails.periodicalWeekDay}");
                      //print("appointmentDetails.serviceName = ${appointmentDetails.serviceName}");
                      //print("appointmentDetails.from = ${appointmentDetails.from}");
                      //print("appointmentDetails.to = ${appointmentDetails.to}");
                      Navigator.pushNamed(context, RouteGenerator.APPOINTMENT_DETAILS_PAGE, arguments: appointmentDetails);
                    }
                  },
                  headerHeight: 50,
                  headerStyle: const CalendarHeaderStyle(
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  scheduleViewSettings: ScheduleViewSettings(
                    monthHeaderSettings: MonthHeaderSettings(
                        height: 70,
                        backgroundColor: standartTheme.primaryColor,
                    )
                  ),
                  timeSlotViewSettings: const TimeSlotViewSettings(
                    timeIntervalHeight: 60,
                  ),
                  selectionDecoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: standartTheme.primaryColor, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    shape: BoxShape.rectangle,
                  ),
                  showNavigationArrow: true,
                  showDatePickerButton: true,
                  showTodayButton: true,
                  //showWeekNumber: true,
                );
              }
            ),
            StreamBuilder<bool>(
                stream: loadingStreamController.stream,
                initialData: true,
                builder: (context, snapshot) {
                  print("snapshot.hasData = ${snapshot.hasData}");
                  print("loadingStreamController = ${snapshot.data}");
                  if(snapshot.hasData) {
                    bool isLoading = snapshot.data!;
                    if(isLoading){
                      return Container(
                        color: Colors.white.withOpacity(0.5),
                        child: LoadingData(),
                      );
                    }
                  }
                  return Container();
                }
            )
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: null,
      body: body,
    );
  }
}
