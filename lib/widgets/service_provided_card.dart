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
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(serviceProvided.name, style: textStyleSmallBold,),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(serviceProvided.description, style: textStyleSmallNormal,),
              const SizedBox(height: 4),
              Text(
                'Duração: ${serviceProvided.duration.inMinutes} min      ${serviceProvided.price != 0.0 ? 'Preço: R\$${serviceProvided.price.toStringAsFixed(2).replaceAll('.', ',')}' : ''}',
                style: textStyleSmallNormal,
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
