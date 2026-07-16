import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';
import '../controller/calendar_controller.dart';
import '../models/calendar_date.dart';
import 'calendar_builders.dart';
import 'default_builders.dart';
import 'month_grid_view.dart';
import 'horizontal_strip_view.dart';

class CalendarWidget extends StatefulWidget {
  final CalendarController? controller;
  final CalendarHeaderBuilder? headerBuilder;
  final CalendarWeekdayBuilder? weekdayBuilder;
  final CalendarDayBuilder? dayBuilder;
  final bool enableModeToggle;
  final bool useNepaliScript;
  final String? nepaliFontFamily;
  final bool showAlternativeDate;
  final EdgeInsetsGeometry padding;
  final BoxDecoration? decoration;

  const CalendarWidget({
    super.key,
    this.controller,
    this.headerBuilder,
    this.weekdayBuilder,
    this.dayBuilder,
    this.enableModeToggle = true,
    this.useNepaliScript = false,
    this.nepaliFontFamily,
    this.showAlternativeDate = false,
    this.padding = const EdgeInsets.all(8.0),
    this.decoration,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarController? _internalController;

  CalendarController get _effectiveController =>
      widget.controller ??
      (_internalController ??= CalendarController(
        calendarMode: widget.useNepaliScript ? CalendarMode.bs : CalendarMode.ad,
      ));

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  double _getGridHeight(CalendarDate date) {
    const double headerAndPadding = 44.0;
    int weekdayIndex;
    int daysInMonth;

    if (date.mode == CalendarMode.ad) {
      final firstOfMonth = DateTime(date.ad.year, date.ad.month, 1);
      weekdayIndex = firstOfMonth.weekday % 7;
      final nextMonth = DateTime(date.ad.year, date.ad.month + 1, 1);
      daysInMonth = nextMonth.subtract(const Duration(days: 1)).day;
    } else {
      final firstOfMonth = NepaliDateTime(date.bs.year, date.bs.month, 1);
      final val = firstOfMonth.weekday;
      weekdayIndex = val - 1;
      daysInMonth = date.bs.totalDays;
    }

    final totalWeeks = ((weekdayIndex + daysInMonth) / 7.0).ceil();
    return headerAndPadding + (totalWeeks * 38.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = _effectiveController;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final focusedDate = controller.focusedDate;
        final isMonthGrid = controller.calendarFormat == CalendarFormat.monthGrid;

        return Container(
          padding: widget.padding,
          decoration: widget.decoration ??
              BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: theme.colorScheme.outline.withAlpha(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Widget
              widget.headerBuilder?.call(context, focusedDate, controller) ??
                  DefaultCalendarHeader(
                    focusedDate: focusedDate,
                    controller: controller,
                    enableModeToggle: widget.enableModeToggle,
                    useNepaliScript: widget.useNepaliScript,
                    nepaliFontFamily: widget.nepaliFontFamily,
                    showAlternativeDate: widget.showAlternativeDate,
                  ),
              const SizedBox(height: 8),

              // Calendar Body: grid or horizontal strip
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: isMonthGrid ? _getGridHeight(focusedDate) : 80.0,
                child: isMonthGrid
                    ? MonthGridView(
                        controller: controller,
                        dayBuilder: widget.dayBuilder,
                        weekdayBuilder: widget.weekdayBuilder,
                        useNepaliScript: widget.useNepaliScript,
                        nepaliFontFamily: widget.nepaliFontFamily,
                        showAlternativeDate: widget.showAlternativeDate,
                      )
                    : HorizontalStripView(
                        controller: controller,
                        dayBuilder: widget.dayBuilder,
                        useNepaliScript: widget.useNepaliScript,
                        nepaliFontFamily: widget.nepaliFontFamily,
                        showAlternativeDate: widget.showAlternativeDate,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
