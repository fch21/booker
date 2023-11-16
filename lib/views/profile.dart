import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/models/time_interval.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/day_availability.dart';
import 'package:booker/widgets/profile_header.dart';
import 'package:booker/widgets/service_provided_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/clickable_item.dart';

class Profile extends StatefulWidget {

  AppUser user;

  Profile({Key? key, required this.user}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {

  late List<DayAvailability> _days;
  List<ServiceProvided> _servicesProvided = [];
  late AppUser _appUser;
  late TabController _tabController;

  _getServicesProvided() async {
    _servicesProvided.clear();
    _servicesProvided = await ServiceProvided.getServicesProvidedByUser(widget.user);
    setState(() {});
  }

  _getWeekDaysAvailability(){
    print("getAllDayAvailability >>>>>>>");
    for (var day in Strings.WEEK_DAYS)
    print("_appUser.availabilityMap[day]?['times'] = ${_appUser.availabilityMap[day]?['times']}");

    setState(() {
      _days = [
        for (var day in  Strings.WEEK_DAYS)
          DayAvailability(
            dayName: day,
            onDayChanged: _updateAvailabilityMap,
            initialIsSelected: _appUser.availabilityMap[day]?["isSelected"] ?? false,
            initialIntervals: _appUser.availabilityMap[day]?['intervals'] ?? [],
          )
      ];
    });
  }

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

  @override
  void initState() {
    _appUser = widget.user;
    _tabController = TabController(length: 2, vsync: this);
    _getWeekDaysAvailability();
    _getServicesProvided();
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    ProfileHeader(appUser: widget.user, allowEdit: true,),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ListTile(
                        leading: Icon(Icons.calendar_month , color: Colors.black54,),
                        title: Text("Meu calendário", style: textStyleSmallNormal,),
                        onTap: () {
                          Navigator.pushNamed(context, RouteGenerator.CALENDAR,);
                        },
                      ),
                    ),
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
                itemCount: _days.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _days[index],
                ),
              ), // Primeira Tab: A lista existente
              ListView.builder(
                shrinkWrap: true,
                itemCount: _servicesProvided.length + 1,
                itemBuilder: (context, index){

                  if(index == _servicesProvided.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                      child: ButtonCustom(
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
                            _getServicesProvided();
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
    );
  }
}
