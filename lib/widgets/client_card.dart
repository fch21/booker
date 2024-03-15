import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/models/appointment_details.dart';
import 'package:flutter/material.dart';

class ClientCard extends StatefulWidget {

  AppUser client;
  VoidCallback onTap;
  bool compact;

  ClientCard({
    Key? key,
    required this.client,
    required this.onTap,
    this.compact = false
  }) : super(key: key);

  @override
  State<ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<ClientCard> {

  AppointmentDetails? lastAppointmentDetails;

  _getLastAppointmentDetails() async {
    AppointmentDetails appointmentDetails = await AppointmentDetails.getClientLastAppointmentDetailsWithCurrentServiceProvider(appUser: widget.client);
    setState(() {
      lastAppointmentDetails = appointmentDetails;
    });
  }

  @override
  void initState() {
    _getLastAppointmentDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool clientIsBlocked = currentAppUser!.blockedClientsIds.contains(widget.client.id);

    return GestureDetector(
      onTap: widget.onTap,
      child: Opacity(
        opacity: clientIsBlocked ? 0.6 : 1.0,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8,8,8,8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Nome: ${widget.client.name}",
                          style: textStyleSmallBold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if(clientIsBlocked) const Padding(
                        padding: EdgeInsets.only( left: 8.0),
                        child: Text('Bloqueado', style: TextStyle(color: Colors.red, fontSize: fontSizeSmall),),
                      ),
                    ],
                  ),
                ),
                Text('Email: ${widget.client.email}', style: const TextStyle(fontSize: fontSizeSmall),),
                if(!widget.compact)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Último agendamento: ${lastAppointmentDetails == null
                        ? "Carregando..."
                        : Utils.formatDateTimeToVisualize(lastAppointmentDetails!.from)}',
                      style: const TextStyle(fontSize: fontSizeSmall),),
                  ),
              ],
            ),
          )
        ),
      ),
    );
  }
}