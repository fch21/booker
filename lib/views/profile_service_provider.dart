import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/available_schedule.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/models/time_interval.dart';
import 'package:booker/views/configurations_profile_service_provider.dart';
import 'package:booker/widgets/available_time_card.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/custom_divider.dart';
import 'package:booker/widgets/day_availability.dart';
import 'package:booker/widgets/profile_header.dart';
import 'package:booker/widgets/service_provided_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../widgets/clickable_item.dart';

class ProfileServiceProvider extends StatefulWidget {

  ProfileServiceProvider({Key? key,}) : super(key: key);

  @override
  State<ProfileServiceProvider> createState() => _ProfileServiceProviderState();
}

class _ProfileServiceProviderState extends State<ProfileServiceProvider> with SingleTickerProviderStateMixin {

  //late List<DayAvailability> _days;
  List<ServiceProvided> _servicesProvided = [];
  List<AvailableSchedule> _availableSchedules = [];
  late AppUser _appUser;
  late TabController _tabController;

  _getServicesProvided() async {
    _servicesProvided.clear();
    _servicesProvided = await ServiceProvided.getServicesProvidedByUser(currentAppUser!);
    setState(() {});
  }

  _getAvailableSchedules(){

    /*
    for(int i =0; i < 4; i++){
      _availableSchedules.add(AvailableSchedule(
          timeInterval: TimeInterval(
            startTime: TimeOfDay.fromDateTime(DateTime.now()),
            endTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))),
          ),
          selectedDays: [true, false, false, true, true, false, false],
          isSelected: true
        )
      );
    }
     */

    List<AvailableSchedule> availableSchedulesList = AvailableSchedule.convertMapToSchedules(_appUser.availabilityMap);

    setState(() {
      _availableSchedules = availableSchedulesList;
    });
  }

  _updateAvailabilityMap() async {
    print(">>>>> _updateAvailabilityMap");
    setState(() {
      _appUser.availabilityMap = AvailableSchedule.convertSchedulesToMap(_availableSchedules);
    });
    await _appUser.updateAppUserInFirestore(context);
    print("_appUser.availabilityMap) = ${_appUser.availabilityMap}");
  }

  /*
  _getWeekDaysAvailability(){
    print("getAllDayAvailability >>>>>>>");
    for (var day in Strings.WEEK_DAYS)
    print("_appUser.availabilityMap[day]?['times'] = ${_appUser.availabilityMap[day]?['times']}");

    setState(() {
      _days = [
        for (var day in  Strings.WEEK_DAYS)
          DayAvailability(
            dayName: day,
            activeColor: appUserColor,
            onDayChanged: _updateAvailabilityMap,
            initialIsSelected: _appUser.availabilityMap[day]?["isSelected"] ?? false,
            initialIntervals: _appUser.availabilityMap[day]?['intervals'] ?? [],
          )
      ];
    });
  }

   */

  /*
  Future <void> _updateAvailabilityMap(String dayName, bool isSelected, List<TimeInterval?> times) async {
    print("_updateAvailabilityMap >>>>>>>>>>>");
    print("times = $times");
    _appUser.availabilityMap[dayName] = {
      'isSelected': isSelected,
      'intervals': times,
    };
    _getWeekDaysAvailability();
    print(" _appUser..availabilityMap = ${ _appUser.availabilityMap}");
    await _appUser.updateAppUserInFirestore(context);
    print(_appUser.availabilityMap);
    return;
  }
   */

  late Color appUserColor;

  @override
  void initState() {
    _appUser = currentAppUser!;
    appUserColor = _appUser.getUserColorResolved();
    _tabController = TabController(length: 2, vsync: this);
    //_getWeekDaysAvailability();
    _getServicesProvided();
    _getAvailableSchedules();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SliderDrawer(
        appBar: SliderAppBar(
          appBarColor: appUserColor,
          appBarPadding: EdgeInsets.zero,
          appBarHeight: kToolbarHeight,
          drawerIconColor: Utils.getContrastingColor(appUserColor) ?? Colors.white,
          title: Text(AppLocalizations.of(context)!.profile, style: TextStyle(color: Utils.getContrastingColor(appUserColor), fontSize: fontSizeLarge))
        ),
        slideDirection: SlideDirection.RIGHT_TO_LEFT,
        slider: ConfigurationsProfileServiceProvider(),
        child: Container(
          color: Colors.white,
          child: DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                      child: Column(
                        children: [
                          ProfileHeader(
                            appUser: _appUser,
                            allowEdit: true,
                            useHero: false,
                            onReload: (){
                              setState(() {
                                appUserColor = _appUser.getUserColorResolved();
                                //_getWeekDaysAvailability();
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ListTile(
                              leading: Icon(Icons.calendar_month , color: Colors.black54,),
                              title: Text("Calendário", style: textStyleSmallNormal,),
                              onTap: () {
                                Navigator.pushNamed(context, RouteGenerator.CALENDAR,);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: Icon(Icons.list , color: Colors.black54,),
                              title: Text("Agendamentos", style: textStyleSmallNormal,),
                              onTap: () {
                                Navigator.pushNamed(context, RouteGenerator.MY_APPOINTMENTS,);
                              },
                            ),
                          ),
                          const Divider(),
                        ],
                      )
                  ), // Seu cabeçalho como um sliver
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    snap: false,
                    titleSpacing: 2,
                    automaticallyImplyLeading: false,
                    title: TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      indicatorColor: _appUser.getUserColorResolved(),
                      tabs: [
                        Tab(text: AppLocalizations.of(context)!.profile_time_availability),
                        Tab(text: AppLocalizations.of(context)!.profile_services_provided),
                      ],
                    ),
                    backgroundColor: Colors.white,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _availableSchedules.length + 1,
                    itemBuilder: (context, index){

                      if(index == _availableSchedules.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                          child: ButtonCustom(
                            color: appUserColor,
                            text: AppLocalizations.of(context)!.profile_add_available_schedule,
                            onPressed: (){

                              AvailableSchedule availableSchedule = AvailableSchedule(
                                  timeInterval: TimeInterval(
                                    startTime: TimeOfDay.fromDateTime(DateTime.now()),
                                    endTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))),
                                  ),
                                  selectedDays: [false, true, true, true, true, true, false],
                                  isSelected: true
                              );

                              _availableSchedules.add(availableSchedule);

                              //we use the scheduleWasSaved to not add a new schedule if the user did not saved it after the creation
                              bool scheduleWasSaved = false;

                              Map args = {
                                "availableSchedule" : availableSchedule,
                                "onDelete" : (){
                                  _availableSchedules.remove(availableSchedule);
                                },
                                "onSave" : (){
                                  scheduleWasSaved = true;
                                }
                              };

                              Navigator.pushNamed(context, RouteGenerator.AVAILABLE_SCHEDULE_FORM, arguments: args).then((value){
                                if(scheduleWasSaved){
                                  _updateAvailabilityMap();
                                }
                                else{
                                  _availableSchedules.remove(availableSchedule);
                                }
                              });
                            },
                          ),
                        );
                      }

                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          //child: _days[index],
                          child: GestureDetector(
                            onTap: (){
                              Map args = {
                                "availableSchedule" : _availableSchedules[index],
                                "onDelete" : (){
                                  _availableSchedules.remove(_availableSchedules[index]);
                                },
                                "onSave" : (){} //not necessary in this case because is the same reference
                              };

                              Navigator.pushNamed(context, RouteGenerator.AVAILABLE_SCHEDULE_FORM, arguments: args).then((value){
                                _updateAvailabilityMap();
                              });
                            },
                            child: AvailableScheduleCard(
                              schedule: _availableSchedules[index],
                              accentColor: appUserColor,
                              onChanged: () {
                                _updateAvailabilityMap();
                              },
                            ),
                          )
                      );
                    },
                  ), // Primeira Tab: A lista existente
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _servicesProvided.length + 1,
                    itemBuilder: (context, index){

                      if(index == _servicesProvided.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                          child: ButtonCustom(
                            color: appUserColor,
                            text: AppLocalizations.of(context)!.profile_add_service,
                            onPressed: (){
                              Navigator.pushNamed(context, RouteGenerator.SERVICE_FORM,);
                            },
                          ),
                        );
                      }

                      ServiceProvided serviceProvided = _servicesProvided[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ServiceProvidedCard(
                          serviceProvided: serviceProvided,
                          onTap: (){
                            //Map args = {"user" : widget.user, "serviceProvided" : _servicesProvided[index]};
                            //Navigator.pushNamed(context, RouteGenerator.MAKE_AN_APPOINTMENT, arguments: args);
                            Navigator.pushNamed(context, RouteGenerator.SERVICE_FORM, arguments: serviceProvided)
                                .then((value){
                              setState(() {});
                              //_getServicesProvided();
                            });
                          },
                        ),
                      );
                    },
                  ), // Segunda Tab: Placeholder para nova lista
                ],
              ),
            ),
          ),
        ),
      )




    );
  }
}
