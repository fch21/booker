import 'package:booker/helper/strings.dart';
import 'package:booker/models/time_interval.dart';

class AvailableSchedule {
  TimeInterval timeInterval;
  List<bool> selectedDays;
  bool isSelected;

  AvailableSchedule({
    required this.timeInterval,
    required this.selectedDays,
    this.isSelected = false,
  }) : assert(selectedDays.length == 7, 'Deve haver exatamente 7 elementos para os dias da semana.');

  AvailableSchedule copy(){
    return AvailableSchedule(timeInterval: timeInterval.copy(), selectedDays: List.from(selectedDays), isSelected: isSelected);
  }

  static List<bool> getWeekDaysBoolList(){
    List<bool> weekDaysBoolList = [false, true, true, true, true, true, false];
    return weekDaysBoolList;
  }

  static Map<String, dynamic> convertSchedulesToMap(List<AvailableSchedule> schedules) {
    Map<String, dynamic> availabilityMap = {};

    for (var schedule in schedules) {
      for (int i = 0; i < schedule.selectedDays.length; i++) {
        if (schedule.selectedDays[i]) {
          if (!availabilityMap.containsKey(Strings.WEEK_DAYS[i])) {
            availabilityMap[Strings.WEEK_DAYS[i]] = {
              'isSelected': true,
              'intervals': [],
            };
          }
          availabilityMap[Strings.WEEK_DAYS[i]]['intervals'].add({
            'timeInterval': schedule.timeInterval,
            'isSelected': schedule.isSelected
          });
        }
      }
    }

    return availabilityMap;
  }


  static List<AvailableSchedule> convertMapToSchedules(Map<String, dynamic> availabilityMap) {
    List<AvailableSchedule> schedules = [];

    for (var day in Strings.WEEK_DAYS) {
      if (!availabilityMap.containsKey(day)) continue;

      var intervalsInfo = availabilityMap[day]['intervals'];
      for (var intervalInfo in intervalsInfo) {
        TimeInterval interval = intervalInfo['timeInterval'];
        bool isSelected = intervalInfo['isSelected'];

        // Verifica se um intervalo idêntico com mesmo estado de seleção já existe
        int existingScheduleIndex = schedules.indexWhere((s) =>
        s.timeInterval.startTime == interval.startTime &&
            s.timeInterval.endTime == interval.endTime &&
            s.isSelected == isSelected);

        if (existingScheduleIndex != -1) {
          // Atualiza os dias selecionados para um intervalo existente
          schedules[existingScheduleIndex].selectedDays[Strings.WEEK_DAYS.indexOf(day)] = true;
        } else {
          // Cria um novo AvailableSchedule
          List<bool> selectedDays = List.generate(7, (index) => false);
          selectedDays[Strings.WEEK_DAYS.indexOf(day)] = true;

          schedules.add(AvailableSchedule(
            timeInterval: interval,
            selectedDays: selectedDays,
            isSelected: isSelected,
          ));
        }
      }
    }

    return schedules;
  }


}