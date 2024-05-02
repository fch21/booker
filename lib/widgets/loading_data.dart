import 'package:booker/main.dart';
import 'package:flutter/material.dart';

class LoadingData extends StatelessWidget {

  Color? color;

  LoadingData({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CircularProgressIndicator(
            color: color ?? standardTheme.primaryColor,
      ),
    ));
  }
}
