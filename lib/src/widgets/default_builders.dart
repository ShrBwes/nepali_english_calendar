import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';
import '../controller/calendar_controller.dart';
import '../models/calendar_date.dart';

/// A helper class containing localization utility lookup arrays and formatting methods
/// for Gregorian (AD) and Bikram Sambat (BS) calendar rendering.
class CalendarHelper {
  static const List<String> adMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  static const List<String> bsMonthsNepali = [
    'वैशाख',
    'जेठ',
    'असार',
    'साउन',
    'भदौ',
    'असोज',
    'कात्तिक',
    'मंसिर',
    'पुस',
    'माघ',
    'फागुन',
    'चैत'
  ];

  static const List<String> bsMonthsEnglish = [
    'Baishakh',
    'Jestha',
    'Asar',
    'Shrawan',
    'Bhadra',
    'Ashwin',
    'Kartik',
    'Mangsir',
    'Poush',
    'Magh',
    'Falgun',
    'Chaitra'
  ];

  static const List<String> adWeekdaysShort = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  static const List<String> adMonthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  static const List<String> bsWeekdaysShortNepali = [
    'आइत',
    'सोम',
    'मङ्गल',
    'बुध',
    'बिही',
    'शुक्र',
    'शनि'
  ];

  static const List<String> bsWeekdaysShortEnglish = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  /// Converts an English digit string to Devanagari/Nepali digit characters.
  static String toNepaliDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const nepali = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
    var result = input;
    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], nepali[i]);
    }
    return result;
  }

  /// Returns the localized month name based on the calendar mode and script preferences.
  static String getMonthName(CalendarDate date,
      {bool useNepaliScript = false}) {
    if (date.mode == CalendarMode.ad) {
      return adMonths[date.ad.month - 1];
    } else {
      return useNepaliScript
          ? bsMonthsNepali[date.bs.month - 1]
          : bsMonthsEnglish[date.bs.month - 1];
    }
  }

  /// Returns the formatted year string based on the calendar mode and script preferences.
  static String getYearString(CalendarDate date,
      {bool useNepaliScript = false}) {
    final yearStr = date.year.toString();
    if (date.mode == CalendarMode.bs && useNepaliScript) {
      return toNepaliDigits(yearStr);
    }
    return yearStr;
  }
}

/// The default header widget containing navigation arrows and the calendar mode switcher.
class DefaultCalendarHeader extends StatelessWidget {
  /// The currently focused month reference date.
  final CalendarDate focusedDate;

  /// The active controller governing calendar state.
  final CalendarController controller;

  /// Flag showing or hiding the AD/BS calendar mode toggle widget.
  final bool enableModeToggle;

  /// Option enabling Devanagari digits/Nepali script formatting.
  final bool useNepaliScript;

  /// Optional font family config to apply to Devanagari rendering.
  final String? nepaliFontFamily;

  /// Option to show the alternate date in each day cell.
  final bool showAlternativeDate;

  /// Creates a [DefaultCalendarHeader] instance.
  const DefaultCalendarHeader({
    super.key,
    required this.focusedDate,
    required this.controller,
    required this.enableModeToggle,
    this.useNepaliScript = false,
    this.nepaliFontFamily,
    this.showAlternativeDate = false,
  });

  String _getAlternativeHeaderLabel() {
    if (focusedDate.mode == CalendarMode.bs) {
      final startBs =
          NepaliDateTime(focusedDate.bs.year, focusedDate.bs.month, 1);
      final endBs = NepaliDateTime(
          focusedDate.bs.year, focusedDate.bs.month, focusedDate.bs.totalDays);
      final startAd = startBs.toDateTime();
      final endAd = endBs.toDateTime();
      final startMonth = CalendarHelper.adMonthsShort[startAd.month - 1];
      final endMonth = CalendarHelper.adMonthsShort[endAd.month - 1];
      if (startMonth == endMonth) {
        return '$startMonth ${startAd.year}';
      } else if (startAd.year == endAd.year) {
        return '$startMonth/$endMonth ${startAd.year}';
      } else {
        return '$startMonth ${startAd.year}/$endMonth ${endAd.year}';
      }
    } else {
      final startAd = DateTime(focusedDate.ad.year, focusedDate.ad.month, 1);
      final nextMonth =
          DateTime(focusedDate.ad.year, focusedDate.ad.month + 1, 1);
      final endAd = nextMonth.subtract(const Duration(days: 1));

      final startBs = CalendarDate.fromAD(startAd).bs;
      final endBs = CalendarDate.fromAD(endAd).bs;

      final startMonth = useNepaliScript
          ? CalendarHelper.bsMonthsNepali[startBs.month - 1]
          : CalendarHelper.bsMonthsEnglish[startBs.month - 1];
      final endMonth = useNepaliScript
          ? CalendarHelper.bsMonthsNepali[endBs.month - 1]
          : CalendarHelper.bsMonthsEnglish[endBs.month - 1];
      final startYearStr = useNepaliScript
          ? CalendarHelper.toNepaliDigits(startBs.year.toString())
          : startBs.year.toString();
      final endYearStr = useNepaliScript
          ? CalendarHelper.toNepaliDigits(endBs.year.toString())
          : endBs.year.toString();

      if (startBs.month == endBs.month) {
        return '$startMonth $startYearStr';
      } else if (startBs.year == endBs.year) {
        return '$startMonth/$endMonth $startYearStr';
      } else {
        return '$startMonth $startYearStr/$endMonth $endYearStr';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = CalendarHelper.getMonthName(focusedDate,
        useNepaliScript: useNepaliScript);
    final yearName = CalendarHelper.getYearString(focusedDate,
        useNepaliScript: useNepaliScript);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month and Year label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$monthName $yearName',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.onSurface,
                  fontFamily:
                      (focusedDate.mode == CalendarMode.bs && useNepaliScript)
                          ? nepaliFontFamily
                          : null,
                ),
              ),
              if (showAlternativeDate) ...[
                const SizedBox(height: 2),
                Text(
                  _getAlternativeHeaderLabel(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withAlpha(140),
                    fontFamily:
                        (focusedDate.mode == CalendarMode.ad && useNepaliScript)
                            ? nepaliFontFamily
                            : null,
                  ),
                ),
              ],
            ],
          ),

          // Action controls: Prev, Mode toggle, Next
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 28),
                onPressed: controller.previousMonth,
              ),
              if (enableModeToggle) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: controller.toggleCalendarMode,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withAlpha(50),
                      ),
                    ),
                    child: Text(
                      controller.calendarMode == CalendarMode.ad ? 'AD' : 'BS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 28),
                onPressed: controller.nextMonth,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The default weekday header label cell widget (e.g., Sun, Mon, etc.).
class DefaultWeekdayHeader extends StatelessWidget {
  /// The weekday text label.
  final String weekdayName;

  /// Optional font family to apply for Nepali script representation.
  final String? nepaliFontFamily;

  /// Option to translate the labels to Nepali script.
  final bool useNepaliScript;

  /// Creates a [DefaultWeekdayHeader] instance.
  const DefaultWeekdayHeader({
    super.key,
    required this.weekdayName,
    this.nepaliFontFamily,
    this.useNepaliScript = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          weekdayName,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withAlpha(140),
            fontFamily: useNepaliScript ? nepaliFontFamily : null,
          ),
        ),
      ),
    );
  }
}

/// The default widget rendering an individual day cell in the monthly grid.
class DefaultDayCell extends StatelessWidget {
  /// The specific calendar date associated with this cell.
  final CalendarDate date;

  /// The visual highlight/disabled state of the day cell.
  final CalendarDayState state;

  /// Option enabling Nepali Devanagari digit rendering.
  final bool useNepaliScript;

  /// Optional custom font family for Devanagari digits.
  final String? nepaliFontFamily;

  /// Callback callback when a user taps this day cell.
  final ValueChanged<CalendarDate>? onTap;

  /// Option to display alternative calendar day index inside this day cell.
  final bool showAlternativeDate;

  /// Creates a [DefaultDayCell] instance.
  const DefaultDayCell({
    super.key,
    required this.date,
    required this.state,
    required this.useNepaliScript,
    this.nepaliFontFamily,
    this.onTap,
    this.showAlternativeDate = false,
  });

  String _getAlternativeText() {
    if (date.mode == CalendarMode.bs) {
      return date.ad.day.toString();
    } else {
      return useNepaliScript
          ? CalendarHelper.toNepaliDigits(date.bs.day.toString())
          : date.bs.day.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayStr = date.day.toString();
    final displayText = (date.mode == CalendarMode.bs && useNepaliScript)
        ? CalendarHelper.toNepaliDigits(dayStr)
        : dayStr;

    // Determine colors based on state
    Color? textColor;
    BoxDecoration? decoration;

    if (state.isSelected) {
      textColor = theme.colorScheme.onPrimary;
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(80),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      );
    } else if (state.isToday) {
      textColor = theme.colorScheme.primary;
      decoration = BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(12),
      );
    } else if (state.isDisabled) {
      textColor = theme.colorScheme.onSurface.withAlpha(80);
    } else if (state.isOutsideMonth) {
      textColor = theme.colorScheme.onSurface.withAlpha(100);
    } else {
      textColor = theme.colorScheme.onSurface;
    }

    final subText = _getAlternativeText();

    return Container(
      margin: const EdgeInsets.all(3.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: state.isDisabled ? null : () => onTap?.call(date),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: decoration,
            child: Stack(
              children: [
                // Main date
                Align(
                  alignment: (showAlternativeDate && !state.isOutsideMonth)
                      ? Alignment.centerLeft
                      : Alignment.center,
                  child: Padding(
                    padding: (showAlternativeDate && !state.isOutsideMonth)
                        ? const EdgeInsets.only(left: 8.0, bottom: 6.0)
                        : EdgeInsets.zero,
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: (showAlternativeDate && !state.isOutsideMonth) ? 14 : 15,
                        fontWeight: state.isSelected || state.isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: textColor,
                        fontFamily:
                            (date.mode == CalendarMode.bs && useNepaliScript)
                                ? nepaliFontFamily
                                : null,
                      ),
                    ),
                  ),
                ),

                // Alternative date (bottom-right corner)
                if (showAlternativeDate && !state.isOutsideMonth)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 4, top: 2, right: 3, bottom: 2),
                      child: Text(
                        subText,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: state.isSelected
                              ? theme.colorScheme.onPrimary.withAlpha(200)
                              : theme.colorScheme.onSurface.withAlpha(160),
                          fontFamily: (date.mode == CalendarMode.ad &&
                                  useNepaliScript)
                              ? nepaliFontFamily
                              : null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
