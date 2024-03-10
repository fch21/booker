import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';

class Period {
  DateTime startDate;
  DateTime endDate;

  Period({
    required this.startDate,
    required this.endDate,
  });

  bool isWithinBlockedPeriod(DateTime dateToCheck) {
    //print("isWithinBlockedPeriod>>>>>>>>>");
    //print("this = $this");
    return !dateToCheck.isBefore(startDate) && !dateToCheck.isAfter(endDate);
  }

  Map<String, dynamic> toMap() {
    return {
      Strings.BLOCKED_PERIOD_START_DATE: Utils.dateFormatForOrdering.format(startDate),
      Strings.BLOCKED_PERIOD_END_DATE: Utils.dateFormatForOrdering.format(endDate),
    };
  }

  factory Period.fromMap(Map<String, dynamic> map) {
    return Period(
      startDate: Utils.dateFormatForOrdering.parse(map[Strings.BLOCKED_PERIOD_START_DATE] ?? ""),
      endDate: Utils.dateFormatForOrdering.parse(map[Strings.BLOCKED_PERIOD_END_DATE] ?? ""),
    );
  }

  @override
  String toString() {
    return 'Period(start: $startDate, end: $endDate)';
  }
}
