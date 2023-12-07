import 'package:booker/helper/route_generator.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsCard extends StatelessWidget {

  AppointmentDetails appointmentDetails;
  bool isClient;
  VoidCallback onTap;

  AppointmentDetailsCard({
    Key? key,
    required this.appointmentDetails,
    required this.isClient,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text("${appointmentDetails.serviceName} - ${isClient ? appointmentDetails.serviceProviderName : appointmentDetails.userName}", style: textStyleSmallNormal,),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data: ${DateFormat('dd/MM/yyyy').format(appointmentDetails.from)}      Hora: ${DateFormat('HH:mm').format(appointmentDetails.from)}', style: textStyleSmallNormal,),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
