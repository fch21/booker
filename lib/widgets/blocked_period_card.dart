import 'package:booker/main.dart';
import 'package:booker/models/period.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlockedPeriodCard extends StatelessWidget {
  final Period blockedPeriod;
  final VoidCallback onTap;
  final VoidCallback onTapTrailing;

  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  BlockedPeriodCard({
    Key? key,
    required this.blockedPeriod,
    required this.onTap,
    required this.onTapTrailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    bool multipleDates = blockedPeriod.startDate.year != blockedPeriod.endDate.year
        || blockedPeriod.startDate.month != blockedPeriod.endDate.month
        || blockedPeriod.startDate.day != blockedPeriod.endDate.day;

    String startDateFormatted = formatter.format(blockedPeriod.startDate);
    String endDateFormatted = formatter.format(blockedPeriod.endDate);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: const Icon(Icons.block, color: Colors.grey), // Ícone indicativo de bloqueio
        title: multipleDates
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Início: $startDateFormatted    Fim: $endDateFormatted', style: textStyleSmallNormal, overflow: TextOverflow.ellipsis,),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Data: $startDateFormatted', style: textStyleSmallNormal),
            ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onTapTrailing,
        ),
        onTap: onTap,
      ),
    );
  }
}