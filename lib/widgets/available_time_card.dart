import 'package:booker/main.dart';
import 'package:booker/models/available_schedule.dart';
import 'package:flutter/material.dart';


class AvailableScheduleCard extends StatefulWidget {
  AvailableSchedule schedule;
  Color backgroundColor;
  Color textColor;
  Color weekDaysColor;
  Color accentColor;
  Function() onChanged; // Callback para mudanças no switch

  AvailableScheduleCard({
    Key? key,
    required this.schedule,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.weekDaysColor = Colors.black54,
    required this.accentColor,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<AvailableScheduleCard> createState() => _AvailableScheduleCardState();
}

class _AvailableScheduleCardState extends State<AvailableScheduleCard> {

  Future<bool> changeActiveConfirmation(bool currentValue) async {

    bool confirmed = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: Text(currentValue
            ?'Tem certeza que deseja desativar esse horário de disponibilidade? Os agendamentos já realizados não serão cancelados, mas os clientes não poderão mais agendar nesse horário.'
            :'Tem certeza que deseja ativar esse horário de disponibilidade? Os clientes agora poderão agendar nesse horário.'
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Voltar'),
              onPressed: () {
                confirmed = false;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                confirmed = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.schedule.isSelected ? 1.0 : 0.4,
      child: Card(
        elevation: 5,
        color: widget.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  widget.schedule.timeInterval.toString(),
                  style: textStyleMediumNormal.copyWith(color: widget.textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 0, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int index = 0; index < 7; index++)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.schedule.selectedDays[index])
                            Container(
                              height: 5,
                              width: 5,
                              margin: const EdgeInsets.only(bottom: 2), // Espaço entre o ponto e o texto
                              decoration: BoxDecoration(
                                color: widget.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'][index],
                            style: TextStyle(color: widget.weekDaysColor, fontSize: fontSizeSmall),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Switch(
                value: widget.schedule.isSelected,
                onChanged: (value) async {

                  bool confirmed = await changeActiveConfirmation(widget.schedule.isSelected);
                  if(confirmed){
                    setState(() {
                      widget.schedule.isSelected = value;
                    });
                    widget.onChanged();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

