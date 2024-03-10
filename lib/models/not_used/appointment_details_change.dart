import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';

class AppointmentDetailsChange {
  int index;
  DateTime newFrom;
  DateTime newTo;
  bool canceled = false;
  bool changeFollowing = false;

  AppointmentDetailsChange({
    this.index = 0,
    required this.newFrom,
    required this.newTo,
    this.canceled = false,
    this.changeFollowing = false,
  });

  Map<String, dynamic> toMap() {
    return {
      Strings.APPOINTMENT_CHANGE_INDEX: index,
      Strings.APPOINTMENT_CHANGE_NEW_FROM: Utils.dateFormatForOrdering.format(newFrom),
      Strings.APPOINTMENT_CHANGE_NEW_TO: Utils.dateFormatForOrdering.format(newTo),
      Strings.APPOINTMENT_CHANGE_CANCELED: canceled,
      Strings.APPOINTMENT_CHANGE_CHANGE_FOLLOWING: changeFollowing,
    };
  }

  factory AppointmentDetailsChange.fromMap(Map<String, dynamic> map) {
    return AppointmentDetailsChange(
      index: map[Strings.APPOINTMENT_CHANGE_INDEX],
      newFrom: Utils.dateFormatForOrdering.parse(map[Strings.APPOINTMENT_CHANGE_NEW_FROM] ?? ""),
      newTo: Utils.dateFormatForOrdering.parse(map[Strings.APPOINTMENT_CHANGE_NEW_TO] ?? ""),
      canceled: map[Strings.APPOINTMENT_CHANGE_CANCELED],
      changeFollowing: map[Strings.APPOINTMENT_CHANGE_CHANGE_FOLLOWING]
    );
  }

  @override
  String toString() {
    return 'AppointmentDetailsChange(index:$index newFrom: $newFrom, newTo: $newTo)';
  }
}
