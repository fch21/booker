import 'package:flutter/material.dart';

class SubscriptionDetailCard extends StatelessWidget {
  final Widget title;
  final Widget content;

  const SubscriptionDetailCard({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: title,
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: content,
        ),
      ),
    );
  }
}