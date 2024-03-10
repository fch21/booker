import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/available_schedule.dart';
import 'package:booker/models/time_interval.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/custom_divider.dart';
import 'package:booker/widgets/time_picker_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class AvailableScheduleForm extends StatefulWidget {

  AvailableSchedule? availableSchedule;
  VoidCallback onDelete;
  VoidCallback onSave;

  AvailableScheduleForm({
    this.availableSchedule,
    required this.onDelete,
    required this.onSave,
  });

  @override
  _AvailableScheduleFormState createState() => _AvailableScheduleFormState();
}

class _AvailableScheduleFormState extends State<AvailableScheduleForm> {

  late AvailableSchedule _availableSchedule;

  Widget dayButton(int index, String day) {
    return InkWell(
      onTap: () {
        setState(() {
          _availableSchedule.selectedDays[index] = !_availableSchedule.selectedDays[index];
        });
      },
      child: CircleAvatar(
        backgroundColor: _availableSchedule.selectedDays[index] ? standartTheme.primaryColor : Colors.transparent,
        child: Text(
          day,
          style: TextStyle(
            color: _availableSchedule.selectedDays[index] ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<void> _deleteConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja excluir esse horário de disponibilidade? Os agendamentos já realizados não serão cancelados, mas os clientes não poderão mais agendar nesse horário.'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: Text('Voltar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () {
                widget.onDelete();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _savedConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Horário salvo com sucesso!'),
          actionsAlignment: MainAxisAlignment.end,
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _availableSchedule = widget.availableSchedule?.copy() ?? AvailableSchedule(
      timeInterval: TimeInterval(
        startTime: TimeOfDay.fromDateTime(DateTime.now()),
        endTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))),
      ),
      selectedDays: AvailableSchedule.getWeekDaysBoolList(),
    );
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    bool greaterWidthLayout = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile_add_available_schedule),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: greaterWidthLayout ? MediaQuery.of(context).size.width/4 : 16 , vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 32),
                          child: Text("Horário de inicio", style: textStyleSmallNormal),
                        ),
                        TimePickerScroll(
                          time: _availableSchedule.timeInterval.startTime,
                          fontSize: fontSizeLarge,
                          onTimeChanged: (timeOfDay){
                            print("onTimeChanged = $timeOfDay");
                            _availableSchedule.timeInterval.startTime = timeOfDay;
                          }
                        ),
                      ],
                    )
                  ),
                  Container(
                    height: fontSizeLarge * 6,
                    width: 1,
                    color: Colors.grey,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 32),
                          child: Text("Horário de término", style: textStyleSmallNormal),
                        ),
                        TimePickerScroll(
                            time: _availableSchedule.timeInterval.endTime,
                            fontSize: fontSizeLarge,
                            onTimeChanged: (timeOfDay){
                              _availableSchedule.timeInterval.endTime = timeOfDay;
                            }
                        ),
                      ],
                    )
                  ),
                ],
              ),
            ),
            const CustomDivider(),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                    .asMap()
                    .entries
                    .map((entry) => dayButton(entry.key, entry.value))
                    .toList(),
              ),
            ),
            const CustomDivider(),
            ListTile(
              title: const Text('Ativo', style: textStyleMediumNormal,),
              trailing: Switch(
                value: _availableSchedule.isSelected,
                activeColor: standartTheme.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _availableSchedule.isSelected = value;
                  });
                },
              ),
            ),
            const CustomDivider(),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: ButtonCustom(
                onPressed: () async {
                  if(_availableSchedule.timeInterval.isValid()){

                    widget.availableSchedule?.timeInterval.startTime = _availableSchedule.timeInterval.startTime;
                    widget.availableSchedule?.timeInterval.endTime = _availableSchedule.timeInterval.endTime;
                    widget.availableSchedule?.selectedDays = _availableSchedule.selectedDays;
                    widget.availableSchedule?.isSelected = _availableSchedule.isSelected;

                    widget.onSave();
                    await _savedConfirmationDialog();
                    Navigator.of(context).pop();
                  }
                  else{
                    Utils.showSnackBar(context, 'O horário de início precisa ser antes do horário de término');
                  }
                },
                text: 'Salvar',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: Center(
                child: TextButton(
                  onPressed: _deleteConfirmationDialog,
                  child: const Text('Excluir horário', style: TextStyle(color: Colors.red, fontSize: fontSizeVerySmall),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
