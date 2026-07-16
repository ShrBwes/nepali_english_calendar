import 'package:nepali_utils/nepali_utils.dart';

enum CalendarMode { ad, bs }

enum CalendarFormat { monthGrid, horizontalStrip }

class CalendarDate {
  final DateTime ad;
  final NepaliDateTime bs;
  final CalendarMode mode;

  CalendarDate(this.ad, this.bs, this.mode);

  static final bool _hasLibraryShift = DateTime(2026, 7, 15).toNepaliDateTime().day == 32;

  factory CalendarDate.fromAD(DateTime ad, {CalendarMode mode = CalendarMode.ad}) {
    final correctedAd = DateTime(ad.year, ad.month, ad.day);
    final bs = _hasLibraryShift
        ? correctedAd.subtract(const Duration(days: 1)).toNepaliDateTime()
        : correctedAd.toNepaliDateTime();

    return CalendarDate(
      correctedAd,
      NepaliDateTime(bs.year, bs.month, bs.day),
      mode,
    );
  }

  factory CalendarDate.fromBS(NepaliDateTime bs, {CalendarMode mode = CalendarMode.bs}) {
    return CalendarDate(
      bs.toDateTime(),
      bs,
      mode,
    );
  }

  factory CalendarDate.now({CalendarMode mode = CalendarMode.ad}) {
    final now = DateTime.now();
    return CalendarDate.fromAD(now, mode: mode);
  }

  int get year => mode == CalendarMode.ad ? ad.year : bs.year;
  int get month => mode == CalendarMode.ad ? ad.month : bs.month;
  int get day => mode == CalendarMode.ad ? ad.day : bs.day;
  int get weekday => mode == CalendarMode.ad ? ad.weekday : bs.weekday;

  int get weekdayIndex {
    if (mode == CalendarMode.ad) {
      return ad.weekday % 7;
    } else {
      return bs.weekday - 1;
    }
  }

  int get bsSundayFirstIndex {
    return bs.weekday - 1;
  }

  CalendarDate copyWithMode(CalendarMode newMode) {
    return CalendarDate(ad, bs, newMode);
  }

  CalendarDate add(Duration duration) {
    return addDays(duration.inDays);
  }

  CalendarDate subtract(Duration duration) {
    return addDays(-duration.inDays);
  }

  CalendarDate addDays(int days) {
    final newAd = DateTime(ad.year, ad.month, ad.day + days);
    return CalendarDate.fromAD(newAd, mode: mode);
  }

  CalendarDate subtractDays(int days) {
    return addDays(-days);
  }

  bool isSameDay(CalendarDate other) {
    if (mode == CalendarMode.ad) {
      return ad.year == other.ad.year &&
          ad.month == other.ad.month &&
          ad.day == other.ad.day;
    } else {
      return bs.year == other.bs.year &&
          bs.month == other.bs.month &&
          bs.day == other.bs.day;
    }
  }

  bool isSameMonth(CalendarDate other) {
    if (mode == CalendarMode.ad) {
      return ad.year == other.ad.year && ad.month == other.ad.month;
    } else {
      return bs.year == other.bs.year && bs.month == other.bs.month;
    }
  }

  bool isBefore(CalendarDate other) {
    return ad.isBefore(other.ad);
  }

  bool isAfter(CalendarDate other) {
    return ad.isAfter(other.ad);
  }

  bool get isToday {
    final today = CalendarDate.now(mode: mode);
    return isSameDay(today);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDate &&
          ad.year == other.ad.year &&
          ad.month == other.ad.month &&
          ad.day == other.ad.day &&
          mode == other.mode;

  @override
  int get hashCode => Object.hash(ad.year, ad.month, ad.day, mode);

  @override
  String toString() {
    return mode == CalendarMode.ad
        ? 'AD: ${ad.year}-${ad.month.toString().padLeft(2, '0')}-${ad.day.toString().padLeft(2, '0')}'
        : 'BS: ${bs.year}-${bs.month.toString().padLeft(2, '0')}-${bs.day.toString().padLeft(2, '0')}';
  }
}

class CalendarDayState {
  final bool isToday;
  final bool isSelected;
  final bool isDisabled;
  final bool isOutsideMonth;
  final bool isFocused;

  const CalendarDayState({
    required this.isToday,
    required this.isSelected,
    required this.isDisabled,
    required this.isOutsideMonth,
    required this.isFocused,
  });

  CalendarDayState copyWith({
    bool? isToday,
    bool? isSelected,
    bool? isDisabled,
    bool? isOutsideMonth,
    bool? isFocused,
  }) {
    return CalendarDayState(
      isToday: isToday ?? this.isToday,
      isSelected: isSelected ?? this.isSelected,
      isDisabled: isDisabled ?? this.isDisabled,
      isOutsideMonth: isOutsideMonth ?? this.isOutsideMonth,
      isFocused: isFocused ?? this.isFocused,
    );
  }
}
