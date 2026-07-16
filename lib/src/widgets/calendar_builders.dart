import 'package:flutter/widgets.dart';
import '../controller/calendar_controller.dart';
import '../models/calendar_date.dart';

/// Builder signature for the calendar header.
typedef CalendarHeaderBuilder = Widget Function(
  BuildContext context,
  CalendarDate focusedDate,
  CalendarController controller,
);

/// Builder signature for the weekday labels row (e.g. Sunday to Saturday).
typedef CalendarWeekdayBuilder = Widget Function(
  BuildContext context,
  String weekdayName,
);

/// Builder signature for individual day cells.
typedef CalendarDayBuilder = Widget? Function(
  BuildContext context,
  CalendarDate date,
  CalendarDayState state,
);
