import 'package:flutter/foundation.dart';
import 'package:nepali_utils/nepali_utils.dart';
import '../models/calendar_date.dart';

/// A controller that manages selected date, focused month, calendar formats,
/// and calendar display modes (Gregorian AD and Bikram Sambat BS).
class CalendarController extends ChangeNotifier {
  CalendarDate _selectedDate;
  CalendarDate _focusedDate;
  CalendarMode _calendarMode;
  CalendarFormat _calendarFormat;
  
  /// The earliest selectable date in the calendar.
  final CalendarDate firstDate;

  /// The latest selectable date in the calendar.
  final CalendarDate lastDate;

  /// Creates a [CalendarController] to manage the state of the calendar.
  CalendarController({
    CalendarDate? selectedDate,
    CalendarDate? focusedDate,
    CalendarMode calendarMode = CalendarMode.ad,
    CalendarFormat calendarFormat = CalendarFormat.monthGrid,
    CalendarDate? firstDate,
    CalendarDate? lastDate,
  })  : _calendarMode = calendarMode,
        _calendarFormat = calendarFormat,
        _selectedDate = (selectedDate ?? CalendarDate.now(mode: calendarMode)).copyWithMode(calendarMode),
        _focusedDate = (focusedDate ?? selectedDate ?? CalendarDate.now(mode: calendarMode)).copyWithMode(calendarMode),
        firstDate = (firstDate ?? CalendarDate.fromBS(NepaliDateTime(1970, 1, 1), mode: calendarMode)).copyWithMode(calendarMode),
        lastDate = (lastDate ?? CalendarDate.fromBS(NepaliDateTime(2099, 12, 30), mode: calendarMode)).copyWithMode(calendarMode) {
    // Clean up dates to start of day
    _selectedDate = _clampDate(_normalize(_selectedDate).copyWithMode(_calendarMode));
    _focusedDate = _normalize(_focusedDate).copyWithMode(_calendarMode);
  }

  /// The currently selected date.
  CalendarDate get selectedDate => _selectedDate;

  /// The date representing the currently focused month.
  CalendarDate get focusedDate => _focusedDate;

  /// The current active calendar mode (AD or BS).
  CalendarMode get calendarMode => _calendarMode;

  /// The current format of the calendar (standard grid or horizontal strip).
  CalendarFormat get calendarFormat => _calendarFormat;

  CalendarDate _normalize(CalendarDate date) {
    return CalendarDate(
      date.ad.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0),
      NepaliDateTime(date.bs.year, date.bs.month, date.bs.day),
      date.mode,
    );
  }

  CalendarDate _clampDate(CalendarDate date) {
    if (date.isBefore(firstDate)) return firstDate.copyWithMode(date.mode);
    if (date.isAfter(lastDate)) return lastDate.copyWithMode(date.mode);
    return date;
  }

  /// Selects the given [date], normalized to the active calendar mode and start of day.
  void selectDate(CalendarDate date) {
    final normalized = _normalize(date).copyWithMode(_calendarMode);
    if (_selectedDate == normalized) return;
    _selectedDate = _clampDate(normalized);
    _focusedDate = _selectedDate.copyWithMode(_calendarMode);
    notifyListeners();
  }

  /// Sets the currently focused [date] (used to change the active month/view).
  void setFocusedDate(CalendarDate date) {
    final normalized = _normalize(date).copyWithMode(_calendarMode);
    if (_focusedDate == normalized) return;
    _focusedDate = normalized;
    notifyListeners();
  }

  /// Toggles between Bikram Sambat (BS) and Gregorian (AD) calendar modes.
  void toggleCalendarMode() {
    setCalendarMode(_calendarMode == CalendarMode.ad ? CalendarMode.bs : CalendarMode.ad);
  }

  /// Programmatically sets the calendar mode to [mode] (AD or BS).
  void setCalendarMode(CalendarMode mode) {
    if (_calendarMode == mode) return;
    _calendarMode = mode;
    _selectedDate = _selectedDate.copyWithMode(mode);
    _focusedDate = _focusedDate.copyWithMode(mode);
    notifyListeners();
  }

  /// Programmatically sets the calendar format to [format] (month grid or horizontal strip).
  void setCalendarFormat(CalendarFormat format) {
    if (_calendarFormat == format) return;
    _calendarFormat = format;
    notifyListeners();
  }

  /// Jumps the calendar view focus to the next month, respecting bounds.
  void nextMonth() {
    if (_calendarMode == CalendarMode.ad) {
      final nextAd = DateTime(_focusedDate.ad.year, _focusedDate.ad.month + 1, 1);
      final nextDate = CalendarDate.fromAD(nextAd, mode: _calendarMode);
      if (!nextDate.isAfter(lastDate)) {
        setFocusedDate(nextDate);
      }
    } else {
      var year = _focusedDate.bs.year;
      var month = _focusedDate.bs.month + 1;
      if (month > 12) {
        year++;
        month = 1;
      }
      final nextDate = CalendarDate.fromBS(NepaliDateTime(year, month, 1), mode: _calendarMode);
      if (!nextDate.isAfter(lastDate)) {
        setFocusedDate(nextDate);
      }
    }
  }

  /// Jumps the calendar view focus to the previous month, respecting bounds.
  void previousMonth() {
    if (_calendarMode == CalendarMode.ad) {
      final prevAd = DateTime(_focusedDate.ad.year, _focusedDate.ad.month - 1, 1);
      final prevDate = CalendarDate.fromAD(prevAd, mode: _calendarMode);
      if (!prevDate.isBefore(firstDate)) {
        setFocusedDate(prevDate);
      }
    } else {
      var year = _focusedDate.bs.year;
      var month = _focusedDate.bs.month - 1;
      if (month < 1) {
        year--;
        month = 12;
      }
      final prevDate = CalendarDate.fromBS(NepaliDateTime(year, month, 1), mode: _calendarMode);
      if (!prevDate.isBefore(firstDate)) {
        setFocusedDate(prevDate);
      }
    }
  }
}
