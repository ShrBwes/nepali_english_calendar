import 'package:flutter/foundation.dart';
import 'package:nepali_utils/nepali_utils.dart';
import '../models/calendar_date.dart';

class CalendarController extends ChangeNotifier {
  CalendarDate _selectedDate;
  CalendarDate _focusedDate;
  CalendarMode _calendarMode;
  CalendarFormat _calendarFormat;
  
  final CalendarDate firstDate;
  final CalendarDate lastDate;

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

  CalendarDate get selectedDate => _selectedDate;
  CalendarDate get focusedDate => _focusedDate;
  CalendarMode get calendarMode => _calendarMode;
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

  void selectDate(CalendarDate date) {
    final normalized = _normalize(date).copyWithMode(_calendarMode);
    if (_selectedDate == normalized) return;
    _selectedDate = _clampDate(normalized);
    _focusedDate = _selectedDate.copyWithMode(_calendarMode);
    notifyListeners();
  }

  void setFocusedDate(CalendarDate date) {
    final normalized = _normalize(date).copyWithMode(_calendarMode);
    if (_focusedDate == normalized) return;
    _focusedDate = normalized;
    notifyListeners();
  }

  void toggleCalendarMode() {
    setCalendarMode(_calendarMode == CalendarMode.ad ? CalendarMode.bs : CalendarMode.ad);
  }

  void setCalendarMode(CalendarMode mode) {
    if (_calendarMode == mode) return;
    _calendarMode = mode;
    _selectedDate = _selectedDate.copyWithMode(mode);
    _focusedDate = _focusedDate.copyWithMode(mode);
    notifyListeners();
  }

  void setCalendarFormat(CalendarFormat format) {
    if (_calendarFormat == format) return;
    _calendarFormat = format;
    notifyListeners();
  }

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
