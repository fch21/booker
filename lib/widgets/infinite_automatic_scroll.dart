import 'dart:async';

import 'package:flutter/material.dart';

class InfiniteAutomaticScroll extends StatefulWidget {

  List<Widget> items ;

  InfiniteAutomaticScroll({
    required this.items,
    super.key
  });

  @override
  _FeatureSectionState createState() => _FeatureSectionState();
}

class _FeatureSectionState extends State<InfiniteAutomaticScroll> {
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;

  int itemsRepeatTimes = 3;

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
    const scrollIncrement = 0.5;

    _timer = Timer.periodic(scrollDuration, (timer) {

      double maxScrollExtent = _scrollController.position.maxScrollExtent + MediaQuery.of(context).size.width;
      double itemsListScrollExtent = maxScrollExtent /itemsRepeatTimes;

      if(_scrollController.offset < _scrollController.position.maxScrollExtent && _scrollController.offset != 0) {
        _scrollController.jumpTo(_scrollController.offset + scrollIncrement);
      }
      else if(_scrollController.offset == 0){
        _scrollController.jumpTo(itemsListScrollExtent);
      }
      else {
        _scrollController.jumpTo(_scrollController.offset - itemsListScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          for(int i = 0; i < itemsRepeatTimes; i++)...widget.items,
        ],
      ),
    );
  }
}