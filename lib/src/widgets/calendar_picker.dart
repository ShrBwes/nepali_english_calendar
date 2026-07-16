import 'package:flutter/material.dart';
import '../controller/calendar_controller.dart';
import '../models/calendar_date.dart';
import 'calendar_builders.dart';
import 'calendar_widget.dart';

/// Shows a dialog containing the AD/BS calendar picker.
/// Returns the selected [CalendarDate] or `null` if cancelled.
Future<CalendarDate?> showNepaliEnglishDatePicker({
  required BuildContext context,
  CalendarDate? initialDate,
  CalendarDate? firstDate,
  CalendarDate? lastDate,
  CalendarMode? initialMode,
  CalendarFormat initialFormat = CalendarFormat.monthGrid,
  bool enableModeToggle = true,
  bool useNepaliScript = false,
  String? nepaliFontFamily,
  bool showAlternativeDate = false,
  CalendarHeaderBuilder? headerBuilder,
  CalendarWeekdayBuilder? weekdayBuilder,
  CalendarDayBuilder? dayBuilder,
  String cancelText = 'Cancel',
  String confirmText = 'OK',
}) async {
  final mode = initialMode ?? (useNepaliScript ? CalendarMode.bs : CalendarMode.ad);
  final controller = CalendarController(
    selectedDate: initialDate,
    calendarMode: mode,
    calendarFormat: initialFormat,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  return showDialog<CalendarDate>(
    context: context,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 340,
          color: theme.colorScheme.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CalendarWidget(
                controller: controller,
                enableModeToggle: enableModeToggle,
                useNepaliScript: useNepaliScript,
                nepaliFontFamily: nepaliFontFamily,
                showAlternativeDate: showAlternativeDate,
                headerBuilder: headerBuilder,
                weekdayBuilder: weekdayBuilder,
                dayBuilder: dayBuilder,
                decoration: const BoxDecoration(color: Colors.transparent),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              const Divider(height: 1),
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final applyFont = useNepaliScript && controller.calendarMode == CalendarMode.bs;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(null),
                          child: Text(
                            cancelText,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontFamily: applyFont ? nepaliFontFamily : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          onPressed: () => Navigator.of(context).pop(controller.selectedDate),
                          child: Text(
                            confirmText,
                            style: TextStyle(
                              fontFamily: applyFont ? nepaliFontFamily : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Shows a bottom sheet containing the AD/BS calendar picker.
/// Returns the selected [CalendarDate] or `null` if cancelled.
Future<CalendarDate?> showNepaliEnglishDatePickerBottomSheet({
  required BuildContext context,
  CalendarDate? initialDate,
  CalendarDate? firstDate,
  CalendarDate? lastDate,
  CalendarMode? initialMode,
  CalendarFormat initialFormat = CalendarFormat.monthGrid,
  bool enableModeToggle = true,
  bool useNepaliScript = false,
  String? nepaliFontFamily,
  bool showAlternativeDate = false,
  CalendarHeaderBuilder? headerBuilder,
  CalendarWeekdayBuilder? weekdayBuilder,
  CalendarDayBuilder? dayBuilder,
  String cancelText = 'Cancel',
  String confirmText = 'OK',
}) async {
  final mode = initialMode ?? (useNepaliScript ? CalendarMode.bs : CalendarMode.ad);
  final controller = CalendarController(
    selectedDate: initialDate,
    calendarMode: mode,
    calendarFormat: initialFormat,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  return showModalBottomSheet<CalendarDate>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              CalendarWidget(
                controller: controller,
                enableModeToggle: enableModeToggle,
                useNepaliScript: useNepaliScript,
                nepaliFontFamily: nepaliFontFamily,
                showAlternativeDate: showAlternativeDate,
                headerBuilder: headerBuilder,
                weekdayBuilder: weekdayBuilder,
                dayBuilder: dayBuilder,
                decoration: const BoxDecoration(color: Colors.transparent),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              const Divider(height: 1),
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final applyFont = useNepaliScript && controller.calendarMode == CalendarMode.bs;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(null),
                          child: Text(
                            cancelText,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontFamily: applyFont ? nepaliFontFamily : null,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () => Navigator.of(context).pop(controller.selectedDate),
                          child: Text(
                            confirmText,
                            style: TextStyle(
                              fontFamily: applyFont ? nepaliFontFamily : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
