import 'dart:async';

import 'package:flutter/material.dart';

class InfiniteAutomaticScroll extends StatefulWidget {

  List<Widget> items;

  InfiniteAutomaticScroll({
    required this.items,
    super.key
  });

  @override
  InfiniteAutomaticScrollState createState() => InfiniteAutomaticScrollState();
}

class InfiniteAutomaticScrollState extends State<InfiniteAutomaticScroll> {
  final ScrollController _scrollController = ScrollController(initialScrollOffset: baseScrollIncrement);
  late Timer _timer;

  int itemsRepeatTimes = 5;//if change, test automatic scroll until the end to assure that has no problem

  bool userIsTapping = false;
  bool userIsManuallyScrolling = false;

  static const double baseScrollIncrement = 0.5;

  bool pause = false;

  @override
  void initState() {
    super.initState();
    _startScrolling();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startScrolling() {
    const scrollDuration = Duration(milliseconds: 10);

    double scrollIncrement = baseScrollIncrement;

    _timer = Timer.periodic(scrollDuration, (timer) {

      double maxScrollExtent = _scrollController.position.maxScrollExtent + MediaQuery.of(context).size.width;
      double itemsListScrollExtent = maxScrollExtent /itemsRepeatTimes;

      //print("_scrollController.offset = ${_scrollController.offset}");
      //print("_scrollController.position.maxScrollExtent = ${_scrollController.position.maxScrollExtent}");
      //print("itemsListScrollExtent = ${itemsListScrollExtent}");
      //print("itemsRepeatTimes = ${itemsRepeatTimes}");

      int numberOfItemsScrollExtendInScroll = (_scrollController.position.maxScrollExtent/itemsListScrollExtent).floor();
      double resetStepScrollAmount = itemsListScrollExtent * (numberOfItemsScrollExtendInScroll - 1 );
      //print("numberOfItemsScrollExtendInScroll = ${numberOfItemsScrollExtendInScroll}");
      //print("resetStepScrollAmount = ${resetStepScrollAmount}");
      if(_scrollController.offset + scrollIncrement < _scrollController.position.maxScrollExtent && _scrollController.offset > 0) {
        //print("option 1 >>>>>");
        //condition to allow manual drag of the scroll by the user
        if(!userIsTapping && !userIsManuallyScrolling && !pause) _scrollController.jumpTo(_scrollController.offset + scrollIncrement);
      }
      else if(_scrollController.offset <= 0){
        //print("option 2 >>>>>");
        //print("resetStepScrollAmount = ${resetStepScrollAmount}");
        _scrollController.jumpTo(resetStepScrollAmount);
      }
      else {
        //print("option 3 >>>>>");
        //print("_scrollController.offset - resetStepScrollAmount = ${_scrollController.offset - resetStepScrollAmount}");
        _scrollController.jumpTo(_scrollController.offset - resetStepScrollAmount);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event){userIsTapping = true;},
      onPointerUp: (PointerUpEvent event){userIsTapping = false;},
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification) {
            if(userIsTapping) userIsManuallyScrolling = true;
          }
          if (notification is ScrollEndNotification) {
            if(userIsManuallyScrolling) userIsManuallyScrolling = false;
          }
          // Return true to indicate the notification was handled.
          return true;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              for(int i = 0; i < itemsRepeatTimes; i++)...widget.items,
            ],
          ),
        ),
      ),
    );
  }
}