import 'package:booker/main.dart';
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
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: RichText(
                  text: TextSpan(
                    // Default style for text
                    style: textStyleSmallNormal,
                    children: <TextSpan>[
                      const TextSpan(text: 'Status: '),
                      // Applying a different color to a part of the text
                      TextSpan(
                        text: appointmentDetails.isCanceled ? 'Cancelado' : 'Confirmado',
                        style: TextStyle(color: appointmentDetails.isCanceled ? Colors.red : Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              //if(appointmentDetails.periodicalWeekDay == null)
                Text('Data: ${DateFormat('dd/MM/yyyy').format(appointmentDetails.from)}      Hora: ${DateFormat('HH:mm').format(appointmentDetails.from)}', style: const TextStyle(color: Colors.black54, fontSize: fontSizeSmall),),
              //if(appointmentDetails.periodicalWeekDay != null)
              //  Text('Dia: ${Utils.getFullWeekDayUpperCaseString(appointmentDetails.from)}s  Hora: ${DateFormat('HH:mm').format(appointmentDetails.from)}', style: TextStyle(color: Colors.black54, fontSize: fontSizeSmall),),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
