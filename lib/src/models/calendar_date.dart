import 'package:nepali_utils/nepali_utils.dart';

/// The active representation mode of the calendar (Gregorian AD or Bikram Sambat BS).
enum CalendarMode { ad, bs }

/// The layout format of the calendar widget.
enum CalendarFormat { monthGrid, horizontalStrip }

/// A unified date abstraction wrapping both [DateTime] and [NepaliDateTime]
/// to provide seamless AD/BS synchronization and conversion.
class CalendarDate {
  /// The Gregorian date representation.
  final DateTime ad;

  /// The Bikram Sambat date representation.
  final NepaliDateTime bs;

  /// The active display mode for this date instance.
  final CalendarMode mode;

  /// Directly constructs a [CalendarDate] instance with pre-calculated representations.
  CalendarDate(this.ad, this.bs, this.mode);

  static final bool _hasLibraryShift = DateTime(2026, 7, 15).toNepaliDateTime().day == 32;

  /// Factory constructor to create a [CalendarDate] from a Gregorian [DateTime].
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

  /// Factory constructor to create a [CalendarDate] from a Bikram Sambat [NepaliDateTime].
  factory CalendarDate.fromBS(NepaliDateTime bs, {CalendarMode mode = CalendarMode.bs}) {
    return CalendarDate(
      bs.toDateTime(),
      bs,
      mode,
    );
  }

  /// Factory constructor to create a [CalendarDate] representing the current system date.
  factory CalendarDate.now({CalendarMode mode = CalendarMode.ad}) {
    final now = DateTime.now();
    return CalendarDate.fromAD(now, mode: mode);
  }

  /// The year value based on the current active mode.
  int get year => mode == CalendarMode.ad ? ad.year : bs.year;

  /// The month value based on the current active mode.
  int get month => mode == CalendarMode.ad ? ad.month : bs.month;

  /// The day value based on the current active mode.
  int get day => mode == CalendarMode.ad ? ad.day : bs.day;

  /// The weekday value based on the current active mode.
  int get weekday => mode == CalendarMode.ad ? ad.weekday : bs.weekday;

  /// The standardized weekday index starting from 0 (Sunday) to 6 (Saturday).
  int get weekdayIndex {
    if (mode == CalendarMode.ad) {
      return ad.weekday % 7;
    } else {
      return bs.weekday - 1;
    }
  }

  /// The weekday index for Bikram Sambat starting from 0 (Sunday) to 6 (Saturday).
  int get bsSundayFirstIndex {
    return bs.weekday - 1;
  }

  /// Returns a new copy of this date with a modified calendar display mode.
  CalendarDate copyWithMode(CalendarMode newMode) {
    return CalendarDate(ad, bs, newMode);
  }

  /// Adds a [Duration] to this date and returns the resulting date.
  CalendarDate add(Duration duration) {
    return addDays(duration.inDays);
  }

  /// Subtracts a [Duration] from this date and returns the resulting date.
  CalendarDate subtract(Duration duration) {
    return addDays(-duration.inDays);
  }

  /// Adds a number of days to this date and returns the resulting date.
  CalendarDate addDays(int days) {
    final newAd = DateTime(ad.year, ad.month, ad.day + days);
    return CalendarDate.fromAD(newAd, mode: mode);
  }

  /// Subtracts a number of days from this date and returns the resulting date.
  CalendarDate subtractDays(int days) {
    return addDays(-days);
  }

  /// Checks if two dates refer to the same day in the active mode.
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

  /// Checks if two dates refer to the same month in the active mode.
  bool isSameMonth(CalendarDate other) {
    if (mode == CalendarMode.ad) {
      return ad.year == other.ad.year && ad.month == other.ad.month;
    } else {
      return bs.year == other.bs.year && bs.month == other.bs.month;
    }
  }

  /// Checks if this date falls before another date.
  bool isBefore(CalendarDate other) {
    return ad.isBefore(other.ad);
  }

  /// Checks if this date falls after another date.
  bool isAfter(CalendarDate other) {
    return ad.isAfter(other.ad);
  }

  /// Checks if this date matches the current system date.
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

/// Holds the visual state of a day cell in the calendar widget.
class CalendarDayState {
  /// True if the date represents today.
  final bool isToday;

  /// True if the date is currently selected.
  final bool isSelected;

  /// True if the date is outside selectable ranges or boundaries.
  final bool isDisabled;

  /// True if the date is outside the active focused month.
  final bool isOutsideMonth;

  /// True if the date is currently focused.
  final bool isFocused;

  /// Creates a [CalendarDayState] to configure a day cell representation.
  const CalendarDayState({
    required this.isToday,
    required this.isSelected,
    required this.isDisabled,
    required this.isOutsideMonth,
    required this.isFocused,
  });

  /// Helper method to create a copy of this state with modified values.
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
