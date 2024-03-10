import 'dart:async';

import 'package:booker/helper/route_generator.dart';
import 'package:booker/widgets/app_user_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/widgets/loading_data.dart';


class Explore extends StatefulWidget {
  VoidCallback? onEventClick;

  Explore({super.key, this.onEventClick});

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  //String _selectedItemState;
  //String _selectedItemCategory;
  //List<DropdownMenuItem<String>> _listItemsDropState = [];
  //List<DropdownMenuItem<String>> _listItemsDropCategories = [];
  final TextEditingController _controllerSearch = TextEditingController();
  //final _controller = StreamController<QuerySnapshot>.broadcast();

/*
  _addListenerEvents() async {
    Stream<QuerySnapshot> stream = db
        .collection(Strings.COLLECTION_EVENTS)
        .where(AppLocalizations.of(context)!.event_visible, isEqualTo: true)
        .orderBy(AppLocalizations.of(context)!.event_sold_drinks, descending: true)
        .snapshots();

    stream.listen((data) {
      _controller.add(data);
    });
  }
*/
  /*_filterEvents() {
    /*Query query = db.collection(Strings.COLLECTION_EVENTS).orderBy(AppLocalizations.of(context)!.event_sold_drinks, descending: true);

    if (_selectedItemState != null) {
      query = query.where(AppLocalizations.of(context)!.event_state, isEqualTo: _selectedItemState);
    }
    if (_selectedItemCategory != null) {
      query = query.where(AppLocalizations.of(context)!.event_category, isEqualTo: _selectedItemCategory);
    }
    */
    //print("test0");
    Query query = db
        .collection(Strings.COLLECTION_EVENTS)
        .where(AppLocalizations.of(context)!.event_visible, isEqualTo: true)
        .orderBy(AppLocalizations.of(context)!.event_sold_drinks, descending: true);

    print(_controllerSearch.text);
    if (_controllerSearch.text != null && _controllerSearch.text != "") {
      print("test1");

      query = query.where(AppLocalizations.of(context)!.event_name, isEqualTo: _controllerSearch.text);
    }

    print(_controllerSearch.text);
    Stream stream = query.snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
    setState(() {});
  }
  */
  /*_loadDropLists() {
    _listItemsDropState = FiltersConfig.getStates();
    _listItemsDropCategories = FiltersConfig.getCategories();
  }
  */

  @override
  void initState() {
    super.initState();
    //_loadDropLists();
    //_addListenerEvents();
    checkIfHasUserLinkAndLaunch();
  }

  Future<bool> checkIfHasUserLinkAndLaunch() async {
    print("checkIfHasEventLinkAndLaunch");

    if(initialServiceProviderId != null){
      String id = initialServiceProviderId!;
      resetInitialServiceProviderId();
      AppUser? user = await AppUser.getUserFromId(id);
      if(user != null && context.mounted){
        //Map args = {"user" : user, "show_menu" : true};
        Map args = {"user" : user};
        await Navigator.pushNamed(context, RouteGenerator.CHOICE_OF_SERVICE, arguments: args);
        // do not offer the possibility to go back to the explore screen
        //await Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.CHOICE_OF_SERVICE,(route) => false , arguments: args);
      }
    }
    //String? eventId = appGlobalKey.currentState?.linkEventId;
    /*
    String? eventId = appGlobalKey.currentState?.eventIdUrlParameter;

    print("eventId = $eventId");
    if(eventId != null){
      appGlobalKey.currentState?.resetLinkEventId();

      AppUser? event = await getUserFromId(eventId);

      if(event != null){
        Map args = {"event" : event, "currentUser" : widget.currentUser, "heroTag" : event.id.toString()};
        if(mounted) Navigator.pushNamed(context, RouteGenerator.CHOICE_OF_SERVICE, arguments: args);
      }

      return true;
    }

     */
    return false;
  }


  @override
  Widget build(BuildContext context) {

    bool greaterWidthLayout = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    checkIfHasUserLinkAndLaunch();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: greaterWidthLayout ? MediaQuery.of(context).size.width/4 : 0),
      child: Column(
        children: <Widget>[
          /*Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: Center(
                    child: DropdownButton(
                      iconEnabledColor: standartTheme.primaryColor,
                      value: _selectedItemState,
                      items: _listItemsDropState,
                      onChanged: (state) {
                        setState(() {
                          _selectedItemState = state;
                          _filterEvents();
                        });
                      },
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.grey[200],
                height: 30,
                width: 2,
              ),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: Center(
                    child: DropdownButton(
                      iconEnabledColor: standartTheme.primaryColor,
                      value: _selectedItemCategory,
                      items: _listItemsDropCategories,
                      onChanged: (category) {
                        setState(() {
                          _selectedItemCategory = category;
                          _filterEvents();
                        });
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
          */
          /*Container(
            child: Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4),
                itemCount: 10,
                itemBuilder: (_,index){
                  Event event = Event();
                  event.name = "Calourada";
                  event.dateStart = "21/08/20" + index.toString();

                  return EventItem(event: event, onTapItem: (){},);
                },
              ),
            )
          ),*/
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: TextField(
              controller: _controllerSearch,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: AppLocalizations.of(context)!.search,
                hintStyle: textStyleSmallNormal
              ),
              onSubmitted: (text) {
                //_filterEvents();
                //set state is used to reload widget with the search text
                setState(() {});
              },
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                ///.collection(Strings.COLLECTION_USERS_PUBLIC)
                .collection(Strings.COLLECTION_USERS)
                .where(Strings.USER_IS_SERVICE_PROVIDER, isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return LoadingData();
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasError) return Text(AppLocalizations.of(context)!.loading_error);

                  QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;

                  if (querySnapshot.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 64),
                      child: Text("Sem resultados"),
                    );
                  }

                  List<DocumentSnapshot> users = querySnapshot.docs.toList();

                  List<DocumentSnapshot> filterList = [];

                  for (var element in users) {
                    if (_controllerSearch.text != ""){
                      String stringToSearch = (element[Strings.USER_USERNAME] ?? "").toString()
                          + (element[Strings.USER_NAME]  ?? "").toString()
                          + (element[Strings.USER_DESCRIPTION]  ?? "").toString();

                      stringToSearch.toLowerCase();

                      if (stringToSearch.contains(_controllerSearch.text.toLowerCase())){
                        filterList.add(element);
                      }
                    }
                    //else{ // will show all users if the _controllerSearch is empty
                    //  filterList.add(element);
                    // }
                  }
                  users = filterList;

                  if (users.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: 64),
                      child: Text(_controllerSearch.text != "" ? "Sem resultados para essa pesquisa" : "Digite sua busca no campo de pesquisa"),
                    );
                  }
                  return Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (_, index) {
                          DocumentSnapshot documentSnapshot = users[index];
                          AppUser user = AppUser.fromDocumentSnapshotPublic(documentSnapshot);

                          //return EventItemLoading();

                          return AppUserItem(
                              appUser: user,
                              onTapItem: () async {
                                Map args = {"user" : user};
                                await Navigator.pushNamed(context, RouteGenerator.CHOICE_OF_SERVICE, arguments: args);
                                if(widget.onEventClick != null) widget.onEventClick!();
                              },
                            );
                        },
                      ),
                  );
              }
            },
          )
        ],
      ),
    );
  }
}
