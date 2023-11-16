import 'dart:async';
import 'package:booker/views/choice_of_service.dart';
import 'package:booker/views/explore.dart';
import 'package:booker/views/make_an_appointment.dart';
import 'package:booker/views/service_form.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/Strings.dart';
import 'package:booker/views/profile.dart';
import 'package:booker/widgets/menu_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Home extends StatefulWidget {
  AppUser currentUser = AppUser();
  int? index;

  Home({super.key, required this.currentUser, this.index});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _menuItems = [];
  int _index = 0;

  List<BottomNavigationBarItem> _bottomNavBarItens = [];

  final StreamController<bool> _hasNewDrinksStreamController = StreamController<bool>.broadcast();

  void getHasNewDrinks(){
    print("getHasNewDrinks");
    //bool hasNewDrinks = appGlobalKey.currentState?.hasNewDrinksMap.values.any((value) => value > 0) ?? false;
    //_hasNewDrinksStreamController.add(hasNewDrinks);

    return;
  }

  BottomNavigationBarItem customBottomNavigationBarItem({
    required IconData icon,
    required String label,
    required bool active,
    required Color activeColor,
    required Color unActiveColor,
    //required int badgeCount,
    StreamController<bool>? hasNewStreamController
  }) {
    return BottomNavigationBarItem(
      label: label,
      icon: Stack(
        children: [
          Icon(icon, color: active ? activeColor : unActiveColor,),
          //if (badgeCount > 0)
          StreamBuilder<bool>(
            stream: hasNewStreamController?.stream,
            builder: (context, snapshot) {

              bool hasNew = snapshot.data ?? false;

              return Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: hasNew ? 12 : 0,
                    minHeight: hasNew ? 12 : 0,
                  ),
                  /*
                    child: Text(
                      '$badgeCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),

                     */
                ),
              );

            }
          ),
        ],
      ),
    );
  }

  _selectMenuItem(String itemSelecionado) {
    if(itemSelecionado == AppLocalizations.of(context)!.menu_config){
      Navigator.pushNamed(context, RouteGenerator.CONFIGURATIONS, arguments: widget.currentUser).then((value) => print("out CONFIGURATIONS => ${widget.currentUser}"));
    }
  }

  Widget _setMenuItemsWidgets(String item) {
    if (item == AppLocalizations.of(context)!.menu_config) {
      return MenuItem(
        iconData: Icons.settings,
        text: item,
      );
    }

    return Text(AppLocalizations.of(context)!.error);
  }

  // melhorar implementação !!!!!!!!!!!!!
  Widget _setAppBarTitle(int index) {
    TextStyle textStyle = const TextStyle(color: Colors.white);

    switch (index) {
      case 0:
        return Text(Strings.BOOKER, style: textStyle);
      case 1:
        //return Text(widget.currentUser.userName, style: textStyle);
        return Text(AppLocalizations.of(context)!.my_drinks, style: textStyle);
      // case 2:
      //   return Text("Conversas", style: textStyle);
      //   break;
      default:
        return Text(AppLocalizations.of(context)!.error, style: textStyle);
    }
  }

  _onItemTapped(int index) {
    _tabController.animateTo(index);
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: _index,
      length: 1,
      vsync: this,
    );
    print(widget.currentUser);
    //_tabController.addListener(() {setState(() {});    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _menuItems = [
      //AppLocalizations.of(context)!.menu_my_events,
      AppLocalizations.of(context)!.menu_config,
    ];
    _bottomNavBarItens = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.search),
        label: AppLocalizations.of(context)!.explore,
      ),
      /*BottomNavigationBarItem(
      icon: Icon(Icons.add),
      title: Text('Novo Evento'),
    ),*/
      customBottomNavigationBarItem(
        icon: Icons.shopping_cart,
        label: AppLocalizations.of(context)!.profile,
        active: _tabController.index == 1,
        activeColor: standartTheme.primaryColor,
        unActiveColor: Colors.grey,
        hasNewStreamController: _hasNewDrinksStreamController
      ),
      // BottomNavigationBarItem(
      //   icon: Icon(Icons.chat_bubble),
      //   title: Text('Mensagens'),
      // ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        //iconTheme: IconThemeData(color: standartTheme.primaryColor),
        //backgroundColor: Colors.white,
        title: _setAppBarTitle(_tabController.index),
        elevation: 0,
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
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: <Widget>[
          //Profile(user: widget.currentUser), /*Chats(widget.currentUser)*/
          //MakeAnAppointment(user: widget.currentUser)
          //ChoiceOfService(user: widget.currentUser,)
          //ServiceForm()
          Explore()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 28,
        type: BottomNavigationBarType.fixed,
        items: _bottomNavBarItens,
        currentIndex: _tabController.index,
        selectedItemColor: standartTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
