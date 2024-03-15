import 'package:booker/main.dart';
import 'package:booker/models/service_provided.dart';
import 'package:flutter/material.dart';

class ServiceProvidedCard extends StatelessWidget {

  ServiceProvided serviceProvided;
  VoidCallback onTap;

  ServiceProvidedCard({
    Key? key,
    required this.serviceProvided,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(serviceProvided.name, style: textStyleSmallNormal,),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(serviceProvided.description, style: textStyleSmallNormal,),
              const SizedBox(height: 4),
              Text('Duração: ${serviceProvided.duration.inMinutes} minutos', style: textStyleSmallNormal,),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
