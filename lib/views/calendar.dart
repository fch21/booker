import 'dart:async';

import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/necessary_subscription_levels.dart';
import 'package:booker/helper/user_firebase.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:booker/models/available_schedule.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:booker/widgets/menu_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Calendar extends StatefulWidget {
  Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {

  List<AppointmentDetails> _appointmentsList = [];
  final CalendarController _controller = CalendarController();
  DateTime? _lastInitialDateTime;
  List<String> _menuItems = [];
  StreamController<bool> loadingStreamController = StreamController.broadcast();


  void _changeCalendarView(CalendarView newView) {
    //print("newView = $newView");
    _controller.view = newView;
    setState(() {});
  }

  DateTime getEndDate(DateTime startDate){
    DateTime endDate = startDate;
    switch (_controller.view) {
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

  //List<AppointmentDetails> getAvailableSchedules(){
    //currentAppUser!.availabilityMap;
  //}

  Future<void> _getAppointments(DateTime initialDateTime) async {
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
    bool isMonthView = _controller.view == CalendarView.month;

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
      AppointmentDetails appointmentDetails = AppointmentDetails.fromDocumentSnapshot(doc);
      if(mounted) await appointmentDetails.initServiceProvided(context);
      //if(appointmentDetails.status == Strings.APPOINTMENT_STATUS_CANCELED) appointmentDetails.serviceProvided.color = Colors.red.withOpacity(0.5);
      //appointments.add(appointmentDetails);
      if(getAllWeekDays && appointmentDetails.periodicalWeekDay != null){
        //to show the periodic appointment in all week days
        appointmentDetails.from = appointmentDetails.from.copyWith(year: startDate.year, month: startDate.month, day: startDate.day).add(Duration(days: appointmentDetails.periodicalWeekDay!));
        appointmentDetails.to = appointmentDetails.to.copyWith(year: startDate.year, month: startDate.month, day: startDate.day).add(Duration(days: appointmentDetails.periodicalWeekDay!));
      }
      if(!appointmentDetails.isCanceled){
        AppointmentDetails copy = appointmentDetails.copy();
        if(copy.to.isBefore(DateTime.now())) copy.serviceProvided.color = copy.serviceProvided.color.withOpacity(0.5);
        appointments.add(copy);
        //print("isMonthView = ${isMonthView}");
        if(appointmentDetails.periodicalWeekDay != null && isMonthView){
          for(int i = 0; i < 4; i++) {//the month view shows 6 weeks, so we should add 5 more periodic appointments
            AppointmentDetails copy = appointmentDetails.copy();
            copy.from = appointmentDetails.from.add(Duration(days: 7 * (i + 1)));
            copy.to = appointmentDetails.to.add(Duration(days: 7 * (i + 1)));
            if(copy.to.isBefore(DateTime.now())) copy.serviceProvided.color = copy.serviceProvided.color.withOpacity(0.5);
            appointments.add(copy);
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

  List<TimeRegion> _getAvailableSchedulesSpecialRegions(){
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

    print("availableSchedulesConverted = ${availableSchedulesConverted.length}");
    return availableSchedulesConverted;
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

  _selectMenuItem(String itemSelecionado) async {
    if(itemSelecionado == AppLocalizations.of(context)!.menu_calendar_cancel_all){
      if(_appointmentsList.isNotEmpty){
        bool canceled = await AppointmentDetails.cancelAppointmentConfirmation(context, appointmentsList: _appointmentsList, isServiceProvider: true, useCancelAllMessage: true, extraTextForCancelAll: getTimePeriodString());
        if(canceled && _lastInitialDateTime != null) await _getAppointments(_lastInitialDateTime!);
      }
      else{
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Nenhum agendamento'),
              content: Text('Não existem agendamentos para cancelar ${getTimePeriodString()}'),
              actionsAlignment: MainAxisAlignment.end,
              actions: <Widget>[
                TextButton(
                  child: Text('Ok'),
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
  }

  Widget _setMenuItemsWidgets(String item) {
    if (item == AppLocalizations.of(context)!.menu_calendar_cancel_all) {
      return MenuItem(
        iconData: Icons.cancel_rounded,
        iconColor: Colors.red,
        text: item,
      );
    }

    return Text(AppLocalizations.of(context)!.error);
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
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    _menuItems = [
      AppLocalizations.of(context)!.menu_calendar_cancel_all,
    ];

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.calendar),
          elevation: 0,
          //backgroundColor: currentAppUser?.getUserColorResolved(),
          //foregroundColor: Utils.getContrastingColor(currentAppUser!.getUserColorResolved()),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: _selectMenuItem,
              itemBuilder: (context) {
                return _menuItems.map((String item) {
                  return PopupMenuItem<String>(
                    value: item,
                    child: _setMenuItemsWidgets(item),
                  );
                }).toList();
              },
            )
          ],
        ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: standartTheme.primaryColor, // Bordas na cor azul
                      width: 2, // Espessura da borda
                    ),
                    color: Colors.white
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CalendarView>(
                      value: _controller.view,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down_circle),
                      iconSize: 24,
                      iconEnabledColor: standartTheme.primaryColor, // Cor do ícone
                      onChanged: (CalendarView? newValue) {
                        if (newValue != null) {
                          _changeCalendarView(newValue);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: CalendarView.day,
                          child: Text('Dia'),
                        ),
                        DropdownMenuItem(
                          value: CalendarView.week,
                          child: Text('Semana'),
                        ),
                        DropdownMenuItem(
                          value: CalendarView.month,
                          child: Text('Mês'),
                        ),
                      ],
                      style: textStyleSmallNormal,
                      dropdownColor: Colors.white, // Cor de fundo do menu suspenso
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SfCalendar(
                  controller: _controller,
                  dataSource: AppointmentDetailsDataSource(_appointmentsList),
                  specialRegions: _getAvailableSchedulesSpecialRegions(),
                  monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
                  onViewChanged: (ViewChangedDetails details){
                    //print("onViewChanged >>>>>>");
                    DateTime startDate = details.visibleDates.first;
                    if(startDate != _lastInitialDateTime) {
                      _getAppointments(startDate);
                    }
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
                  headerHeight: 30,
                  headerStyle: const CalendarHeaderStyle(
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  selectionDecoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: standartTheme.primaryColor, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
            ],
          ),
          StreamBuilder<bool>(
              stream: loadingStreamController.stream,
              builder: (context, snapshot) {
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
      )
    );
  }
}
