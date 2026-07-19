import 'package:flutter/material.dart';
import 'package:nepali_english_dual_calendar/nepali_english_dual_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nepali & English Calendar',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF818CF8), // Light Indigo
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const CalendarDemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalendarDemoScreen extends StatefulWidget {
  const CalendarDemoScreen({super.key});

  @override
  State<CalendarDemoScreen> createState() => _CalendarDemoScreenState();
}

class _CalendarDemoScreenState extends State<CalendarDemoScreen> {
  late CalendarController _calendarController;
  late CalendarController _customCalendarController;

  bool _enableModeToggle = true;
  bool _useNepaliScript = false;
  bool _showAlternativeDate = false;

  // Mock list of event dates (BS)
  final Set<String> _eventDatesBS = {
    '2083-03-31',
    '2083-04-01',
    '2083-04-05',
    '2083-04-10',
  };

  // Mock list of event dates (AD)
  final Set<String> _eventDatesAD = {
    '2026-07-15',
    '2026-07-16',
    '2026-07-20',
    '2026-07-25',
  };

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController(
      calendarMode: CalendarMode.ad,
      calendarFormat: CalendarFormat.monthGrid,
    );

    var lastSelectedPrimary = _calendarController.selectedDate;
    _calendarController.addListener(() {
      final currentSelected = _calendarController.selectedDate;
      if (!currentSelected.isSameDay(lastSelectedPrimary)) {
        lastSelectedPrimary = currentSelected;
        // ignore: avoid_print
        print('Primary Calendar selected date: $currentSelected');
      }
    });

    _customCalendarController = CalendarController(
      calendarMode: CalendarMode.bs,
      calendarFormat: CalendarFormat.monthGrid,
    );

    var lastSelectedCustom = _customCalendarController.selectedDate;
    _customCalendarController.addListener(() {
      final currentSelected = _customCalendarController.selectedDate;
      if (!currentSelected.isSameDay(lastSelectedCustom)) {
        lastSelectedCustom = currentSelected;
        // ignore: avoid_print
        print('Custom Calendar selected date: $currentSelected');
      }
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _customCalendarController.dispose();
    super.dispose();
  }

  String _formatFullDate(CalendarDate date) {
    final adDayName = CalendarHelper.adWeekdaysShort[date.ad.weekday % 7];
    final adMonthName = CalendarHelper.adMonths[date.ad.month - 1];
    final adStr =
        '$adDayName, $adMonthName ${date.ad.day}, ${date.ad.year} (AD)';

    final bsDayIndex = date.bsSundayFirstIndex;
    final bsDayName = _useNepaliScript
        ? CalendarHelper.bsWeekdaysShortNepali[bsDayIndex]
        : CalendarHelper.bsWeekdaysShortEnglish[bsDayIndex];
    final bsMonthName = CalendarHelper.getMonthName(
      date,
      useNepaliScript: _useNepaliScript,
    );
    final bsDayStr = _useNepaliScript
        ? CalendarHelper.toNepaliDigits(date.bs.day.toString())
        : date.bs.day.toString();
    final bsYearStr = CalendarHelper.getYearString(
      date,
      useNepaliScript: _useNepaliScript,
    );
    final bsStr = '$bsDayName, $bsMonthName $bsDayStr, $bsYearStr (BS)';

    return 'AD: $adStr\nBS: $bsStr';
  }

  bool _hasEvent(CalendarDate date) {
    if (date.mode == CalendarMode.ad) {
      final key =
          '${date.ad.year}-${date.ad.month.toString().padLeft(2, '0')}-${date.ad.day.toString().padLeft(2, '0')}';
      return _eventDatesAD.contains(key);
    } else {
      final key =
          '${date.bs.year}-${date.bs.month.toString().padLeft(2, '0')}-${date.bs.day.toString().padLeft(2, '0')}';
      return _eventDatesBS.contains(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AD/BS Calendar & Picker'),
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Configurations Card
            Card(
              elevation: 0,
              color: theme.colorScheme.onSurface.withAlpha(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outline.withAlpha(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable AD/BS Switch Toggle'),
                      subtitle: const Text(
                        'Allows toggling between systems in the header',
                      ),
                      value: _enableModeToggle,
                      onChanged: (val) {
                        setState(() {
                          _enableModeToggle = val;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Use Nepali Script (BS only)'),
                      subtitle: const Text(
                        'Converts months & numbers to Nepali text',
                      ),
                      value: _useNepaliScript,
                      onChanged: (val) {
                        setState(() {
                          _useNepaliScript = val;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Show Alternative Date'),
                      subtitle: const Text(
                        'Displays English date in BS mode and vice versa (as in the printed calendar)',
                      ),
                      value: _showAlternativeDate,
                      onChanged: (val) {
                        setState(() {
                          _showAlternativeDate = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Main Interactive Calendar title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calendar View', style: theme.textTheme.titleMedium),
                ListenableBuilder(
                  listenable: _calendarController,
                  builder: (context, _) {
                    final isHorizontal =
                        _calendarController.calendarFormat ==
                        CalendarFormat.horizontalStrip;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isHorizontal ? Icons.linear_scale : Icons.grid_on,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isHorizontal ? 'Horizontal' : 'Grid',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: isHorizontal,
                          onChanged: (val) {
                            _calendarController.setCalendarFormat(
                              val
                                  ? CalendarFormat.horizontalStrip
                                  : CalendarFormat.monthGrid,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // The Calendar Widget
            CalendarWidget(
              controller: _calendarController,
              enableModeToggle: _enableModeToggle,
              useNepaliScript: _useNepaliScript,
              showAlternativeDate: _showAlternativeDate,
            ),
            const SizedBox(height: 16),

            // Selection Display Card
            ListenableBuilder(
              listenable: _calendarController,
              builder: (context, _) {
                return Card(
                  elevation: 4,
                  shadowColor: theme.colorScheme.primary.withAlpha(40),
                  color: theme.colorScheme.primaryContainer.withAlpha(90),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Selected Date',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatFullDate(_calendarController.selectedDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Modals and pickers triggers
            Text(
              'Dialog and Bottom Sheet Pickers',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Show Dialog Picker'),
                    onPressed: () async {
                      final selected = await showNepaliEnglishDatePicker(
                        context: context,
                        initialDate: _calendarController.selectedDate,
                        enableModeToggle: _enableModeToggle,
                        useNepaliScript: _useNepaliScript,
                        showAlternativeDate: _showAlternativeDate,
                        initialFormat: _calendarController.calendarFormat,
                      );
                      if (!context.mounted) return;
                      if (selected != null) {
                        _calendarController.selectDate(selected);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Picked date: ${selected.toString()}',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Show Sheet Picker'),
                    onPressed: () async {
                      final selected =
                          await showNepaliEnglishDatePickerBottomSheet(
                            context: context,
                            initialDate: _calendarController.selectedDate,
                            enableModeToggle: _enableModeToggle,
                            useNepaliScript: _useNepaliScript,
                            showAlternativeDate: _showAlternativeDate,
                            initialFormat: _calendarController.calendarFormat,
                          );
                      if (!context.mounted) return;
                      if (selected != null) {
                        _calendarController.selectDate(selected);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Picked date: ${selected.toString()}',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Fully Customized View
            Text(
              'Custom Styled Calendar with Event Dots',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Custom colors, header design, and calendar cell indicators for marked event dates.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            CalendarWidget(
              controller: _customCalendarController,
              enableModeToggle: true,
              useNepaliScript: true,
              // Overwrite default container decoration
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24.0),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.onSurface.withAlpha(15),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(60),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(20),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              // Overwrite Header builder with a clean custom header
              headerBuilder: (context, focusedDate, controller) {
                final monthName = CalendarHelper.getMonthName(
                  focusedDate,
                  useNepaliScript: true,
                );
                final yearName = CalendarHelper.getYearString(
                  focusedDate,
                  useNepaliScript: true,
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.stars, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            '$monthName $yearName'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.secondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 16),
                            onPressed: controller.previousMonth,
                          ),
                          TextButton(
                            onPressed: controller.toggleCalendarMode,
                            child: Text(
                              controller.calendarMode == CalendarMode.ad
                                  ? 'AD'
                                  : 'BS',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            onPressed: controller.nextMonth,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              // Custom Day cell builder highlighting event days
              dayBuilder: (context, date, state) {
                if (state.isOutsideMonth) {
                  return const SizedBox.shrink();
                }
                final hasEvent = _hasEvent(date);
                final isSelected = state.isSelected;
                final isToday = state.isToday;

                return GestureDetector(
                  onTap: state.isDisabled
                      ? null
                      : () => _customCalendarController.selectDate(date),
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.secondary
                          : isToday
                          ? theme.colorScheme.secondaryContainer.withAlpha(120)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isToday
                          ? Border.all(
                              color: theme.colorScheme.secondary,
                              width: 1.5,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: _showAlternativeDate
                              ? Alignment.centerLeft
                              : Alignment.center,
                          child: Padding(
                            padding: _showAlternativeDate
                                ? const EdgeInsets.only(left: 8.0, bottom: 6.0)
                                : EdgeInsets.zero,
                            child: Text(
                              CalendarHelper.toNepaliDigits(
                                date.day.toString(),
                              ),
                              style: TextStyle(
                                fontSize: _showAlternativeDate ? 14 : 15,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? theme.colorScheme.onSecondary
                                    : state.isDisabled
                                    ? Colors.grey.withAlpha(100)
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        if (_showAlternativeDate)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 4,
                                top: 2,
                                right: 3,
                                bottom: 2,
                              ),
                              child: Text(
                                date.mode == CalendarMode.bs
                                    ? date.ad.day.toString()
                                    : CalendarHelper.toNepaliDigits(
                                        date.bs.day.toString(),
                                      ),
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? theme.colorScheme.onSecondary.withAlpha(
                                          200,
                                        )
                                      : theme.colorScheme.onSurface.withAlpha(
                                          160,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        if (hasEvent)
                          Positioned(
                            bottom: 4,
                            left: _showAlternativeDate ? 8 : null,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.onSecondary
                                    : theme.colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
