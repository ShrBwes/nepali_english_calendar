import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';
import '../controller/calendar_controller.dart';
import '../models/calendar_date.dart';
import 'calendar_builders.dart';
import 'default_builders.dart';

class MonthGridView extends StatefulWidget {
  final CalendarController controller;
  final CalendarDayBuilder? dayBuilder;
  final CalendarWeekdayBuilder? weekdayBuilder;
  final bool useNepaliScript;
  final String? nepaliFontFamily;
  final bool showAlternativeDate;

  const MonthGridView({
    super.key,
    required this.controller,
    this.dayBuilder,
    this.weekdayBuilder,
    required this.useNepaliScript,
    this.nepaliFontFamily,
    this.showAlternativeDate = false,
  });

  @override
  State<MonthGridView> createState() => _MonthGridViewState();
}

class _MonthGridViewState extends State<MonthGridView> {
  late PageController _pageController;
  late CalendarMode _currentMode;
  bool _isAnimatingPage = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.controller.calendarMode;
    final initialPage = _getMonthIndex(widget.controller.focusedDate);
    _pageController = PageController(initialPage: initialPage);

    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_currentMode != widget.controller.calendarMode) {
      // Re-initialize page controller if mode changes
      _currentMode = widget.controller.calendarMode;
      final page = _getMonthIndex(widget.controller.focusedDate);
      _pageController.jumpToPage(page);
    } else {
      final targetPage = _getMonthIndex(widget.controller.focusedDate);
      if (_pageController.hasClients &&
          _pageController.page?.round() != targetPage &&
          !_isAnimatingPage) {
        _isAnimatingPage = true;
        _pageController
            .animateToPage(
              targetPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
            .then((_) {
          if (mounted) {
            setState(() {
              _isAnimatingPage = false;
            });
          }
        });
      }
    }
  }

  int _getMonthCount() {
    final start = widget.controller.firstDate;
    final end = widget.controller.lastDate;
    if (widget.controller.calendarMode == CalendarMode.ad) {
      return (end.ad.year - start.ad.year) * 12 + (end.ad.month - start.ad.month) + 1;
    } else {
      return (end.bs.year - start.bs.year) * 12 + (end.bs.month - start.bs.month) + 1;
    }
  }

  int _getMonthIndex(CalendarDate date) {
    final start = widget.controller.firstDate;
    if (widget.controller.calendarMode == CalendarMode.ad) {
      return (date.ad.year - start.ad.year) * 12 + (date.ad.month - start.ad.month);
    } else {
      return (date.bs.year - start.bs.year) * 12 + (date.bs.month - start.bs.month);
    }
  }

  CalendarDate _getDateForMonthIndex(int index) {
    final start = widget.controller.firstDate;
    if (widget.controller.calendarMode == CalendarMode.ad) {
      final year = start.ad.year + (start.ad.month - 1 + index) ~/ 12;
      final month = (start.ad.month - 1 + index) % 12 + 1;
      return CalendarDate.fromAD(DateTime(year, month, 1), mode: widget.controller.calendarMode);
    } else {
      final year = start.bs.year + (start.bs.month - 1 + index) ~/ 12;
      final month = (start.bs.month - 1 + index) % 12 + 1;
      return CalendarDate.fromBS(NepaliDateTime(year, month, 1), mode: widget.controller.calendarMode);
    }
  }

  List<CalendarDate> _generateMonthDays(CalendarDate monthDate) {
    CalendarDate firstOfMonth;
    if (monthDate.mode == CalendarMode.ad) {
      firstOfMonth = CalendarDate.fromAD(
        DateTime(monthDate.ad.year, monthDate.ad.month, 1),
        mode: widget.controller.calendarMode,
      );
    } else {
      firstOfMonth = CalendarDate.fromBS(
        NepaliDateTime(monthDate.bs.year, monthDate.bs.month, 1),
        mode: widget.controller.calendarMode,
      );
    }

    final weekdayIndex = firstOfMonth.weekdayIndex;

    // Current month days
    int daysInMonth;
    if (monthDate.mode == CalendarMode.ad) {
      final nextMonth = DateTime(monthDate.ad.year, monthDate.ad.month + 1, 1);
      daysInMonth = nextMonth.subtract(const Duration(days: 1)).day;
    } else {
      daysInMonth = monthDate.bs.totalDays;
    }

    final totalWeeks = ((weekdayIndex + daysInMonth) / 7.0).ceil();
    final totalCells = totalWeeks * 7;
    final days = <CalendarDate>[];

    // Backfill previous month days using subtractDays
    for (var i = weekdayIndex; i > 0; i--) {
      days.add(firstOfMonth.subtractDays(i));
    }

    for (var i = 0; i < daysInMonth; i++) {
      days.add(firstOfMonth.addDays(i));
    }

    // Forward fill next month days using addDays up to totalCells
    final remaining = totalCells - days.length;
    for (var i = 1; i <= remaining; i++) {
      days.add(firstOfMonth.addDays(daysInMonth + i - 1));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final weekdayLabels = widget.controller.calendarMode == CalendarMode.ad
        ? CalendarHelper.adWeekdaysShort
        : (widget.useNepaliScript
            ? CalendarHelper.bsWeekdaysShortNepali
            : CalendarHelper.bsWeekdaysShortEnglish);

    return Column(
      children: [
        // Weekday label row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdayLabels.map((label) {
            return Expanded(
              child: widget.weekdayBuilder?.call(context, label) ??
                  DefaultWeekdayHeader(
                    weekdayName: label,
                    nepaliFontFamily: widget.nepaliFontFamily,
                    useNepaliScript: widget.useNepaliScript && widget.controller.calendarMode == CalendarMode.bs,
                  ),
            );
          }).toList(),
        ),
        // Swipeable page view of calendar months
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _getMonthCount(),
            onPageChanged: (pageIndex) {
              final focusedMonth = _getDateForMonthIndex(pageIndex);
              widget.controller.setFocusedDate(focusedMonth);
            },
            itemBuilder: (context, pageIndex) {
              final monthDate = _getDateForMonthIndex(pageIndex);
              final days = _generateMonthDays(monthDate);

              return GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: 38.0,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final date = days[index];
                  final isOutsideMonth = !date.isSameMonth(monthDate);
                  final isToday = date.isToday;
                  final isSelected = date.isSameDay(widget.controller.selectedDate);
                  final isDisabled = date.isBefore(widget.controller.firstDate) ||
                      date.isAfter(widget.controller.lastDate);

                  final state = CalendarDayState(
                    isToday: isToday,
                    isSelected: isSelected,
                    isDisabled: isDisabled,
                    isOutsideMonth: isOutsideMonth,
                    isFocused: date.isSameDay(widget.controller.focusedDate),
                  );

                  // Try custom dayBuilder first
                  final customWidget = widget.dayBuilder?.call(context, date, state);
                  if (customWidget != null) {
                    return customWidget;
                  }

                  return DefaultDayCell(
                    date: date,
                    state: state,
                    useNepaliScript: widget.useNepaliScript,
                    nepaliFontFamily: widget.nepaliFontFamily,
                    showAlternativeDate: widget.showAlternativeDate,
                    onTap: (selected) {
                      widget.controller.selectDate(selected);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
