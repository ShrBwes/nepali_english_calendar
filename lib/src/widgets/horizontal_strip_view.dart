import 'package:flutter/material.dart';
import '../controller/calendar_controller.dart';
import '../models/calendar_date.dart';
import 'calendar_builders.dart';
import 'default_builders.dart';

class HorizontalStripView extends StatefulWidget {
  final CalendarController controller;
  final CalendarDayBuilder? dayBuilder;
  final bool useNepaliScript;
  final String? nepaliFontFamily;
  final bool showAlternativeDate;

  const HorizontalStripView({
    super.key,
    required this.controller,
    this.dayBuilder,
    required this.useNepaliScript,
    this.nepaliFontFamily,
    this.showAlternativeDate = false,
  });

  @override
  State<HorizontalStripView> createState() => _HorizontalStripViewState();
}

class _HorizontalStripViewState extends State<HorizontalStripView> {
  late ScrollController _scrollController;
  late int _totalDays;
  double _itemWidth = 68.0;
  double _containerWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _calculateTotalDays();

    widget.controller.addListener(_onControllerChanged);

    // Center the selected date on first layout frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(widget.controller.selectedDate, animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant HorizontalStripView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _calculateTotalDays();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToDate(widget.controller.selectedDate, animate: false);
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateTotalDays() {
    final start = widget.controller.firstDate.ad;
    final end = widget.controller.lastDate.ad;
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    final endUtc = DateTime.utc(end.year, end.month, end.day);
    _totalDays = endUtc.difference(startUtc).inDays + 1;
  }

  void _onControllerChanged() {
    if (mounted) {
      _scrollToDate(widget.controller.selectedDate);
    }
  }

  void _scrollToDate(CalendarDate date, {bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final start = widget.controller.firstDate.ad;
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    final dateUtc = DateTime.utc(date.ad.year, date.ad.month, date.ad.day);
    final index = dateUtc.difference(startUtc).inDays;

    final targetOffset = (index * _itemWidth) - (_containerWidth / 2) + (_itemWidth / 2);
    final clampedOffset = targetOffset.clamp(0.0, double.infinity);

    if (animate) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  CalendarDate _getDateForIndex(int index) {
    final start = widget.controller.firstDate;
    return start.addDays(index).copyWithMode(widget.controller.calendarMode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 80,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _containerWidth = constraints.maxWidth;
          _itemWidth = constraints.maxWidth / 7;
          return ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemExtent: _itemWidth,
            itemCount: _totalDays,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final date = _getDateForIndex(index);
              final isSelected = date.isSameDay(widget.controller.selectedDate);
              final isToday = date.isToday;
              final isDisabled = date.isBefore(widget.controller.firstDate) ||
                  date.isAfter(widget.controller.lastDate);

              final state = CalendarDayState(
                isToday: isToday,
                isSelected: isSelected,
                isDisabled: isDisabled,
                isOutsideMonth: false,
                isFocused: date.isSameDay(widget.controller.focusedDate),
              );

              final customWidget = widget.dayBuilder?.call(context, date, state);
              if (customWidget != null) {
                return SizedBox(
                  width: _itemWidth,
                  child: customWidget,
                );
              }

              final weekdayLabel = date.mode == CalendarMode.ad
                  ? CalendarHelper.adWeekdaysShort[date.ad.weekday % 7]
                  : (widget.useNepaliScript
                      ? CalendarHelper.bsWeekdaysShortNepali[date.bsSundayFirstIndex]
                      : CalendarHelper.bsWeekdaysShortEnglish[date.bsSundayFirstIndex]);

              final dayStr = date.day.toString();
              final displayText = (date.mode == CalendarMode.bs && widget.useNepaliScript)
                  ? CalendarHelper.toNepaliDigits(dayStr)
                  : dayStr;

              final String subText;
              if (date.mode == CalendarMode.bs) {
                subText = date.ad.day.toString();
              } else {
                subText = widget.useNepaliScript
                    ? CalendarHelper.toNepaliDigits(date.bs.day.toString())
                    : date.bs.day.toString();
              }

              Color? textColor;
              Color cardColor = Colors.transparent;
              Border? border;
              List<BoxShadow>? shadow;

              if (isSelected) {
                textColor = theme.colorScheme.onPrimary;
                cardColor = theme.colorScheme.primary;
                shadow = [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(60),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ];
              } else if (isToday) {
                textColor = theme.colorScheme.primary;
                border = Border.all(color: theme.colorScheme.primary, width: 1.5);
                cardColor = theme.colorScheme.surface;
              } else if (isDisabled) {
                textColor = theme.colorScheme.onSurface.withAlpha(80);
              } else {
                textColor = theme.colorScheme.onSurface;
                cardColor = theme.colorScheme.onSurface.withAlpha(15);
              }

              return Container(
                width: _itemWidth - 8,
                margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12.0),
                  border: border,
                  boxShadow: shadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isDisabled ? null : () => widget.controller.selectDate(date),
                    borderRadius: BorderRadius.circular(12.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                weekdayLabel.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary.withAlpha(200)
                                      : theme.colorScheme.onSurface.withAlpha(140),
                                  fontFamily: (date.mode == CalendarMode.bs && widget.useNepaliScript)
                                      ? widget.nepaliFontFamily
                                      : null,
                                ),
                              ),
                              Text(
                                displayText,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontFamily: (date.mode == CalendarMode.bs && widget.useNepaliScript)
                                      ? widget.nepaliFontFamily
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.showAlternativeDate)
                          Positioned(
                            bottom: 2,
                            right: 4,
                            child: Text(
                              subText,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary.withAlpha(200)
                                    : theme.colorScheme.onSurface.withAlpha(140),
                                fontFamily: (date.mode == CalendarMode.ad && widget.useNepaliScript)
                                    ? widget.nepaliFontFamily
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
