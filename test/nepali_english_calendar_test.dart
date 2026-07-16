import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:nepali_english_calendar/nepali_english_calendar.dart';

void main() {
  group('CalendarDate Tests', () {
    test('Conversion from AD to BS matches correctly', () {
      final adDate = DateTime(2026, 7, 15);
      final calendarDate = CalendarDate.fromAD(adDate);

      expect(calendarDate.mode, CalendarMode.ad);
      expect(calendarDate.ad, adDate);
      expect(calendarDate.bs.year, 2083);
      expect(calendarDate.bs.month, 3);
      expect(calendarDate.bs.day, 31);
    });

    test('Conversion from BS to AD matches correctly', () {
      final bsDate = NepaliDateTime(2083, 3, 32);
      final calendarDate = CalendarDate.fromBS(bsDate);

      expect(calendarDate.mode, CalendarMode.bs);
      expect(calendarDate.bs, bsDate);
      
      final expectedAd = bsDate.toDateTime();
      expect(calendarDate.ad.year, expectedAd.year);
      expect(calendarDate.ad.month, expectedAd.month);
      expect(calendarDate.ad.day, expectedAd.day);
    });

    test('Unified getters return correct mode-based values', () {
      final date = CalendarDate.fromAD(DateTime(2026, 7, 15));

      // AD Mode
      expect(date.year, 2026);
      expect(date.month, 7);
      expect(date.day, 15);

      // BS Mode
      final bsDate = date.copyWithMode(CalendarMode.bs);
      expect(bsDate.year, 2083);
      expect(bsDate.month, 3);
      expect(bsDate.day, 31);
    });

    test('weekdayIndex behaves consistently for both modes', () {
      // 2026-07-12 is Sunday
      final sun = CalendarDate.fromAD(DateTime(2026, 7, 12));
      expect(sun.weekdayIndex, 0); // Sunday should be 0
      expect(sun.copyWithMode(CalendarMode.bs).weekdayIndex, 0);

      // 2026-07-15 is Wednesday
      final wed = CalendarDate.fromAD(DateTime(2026, 7, 15));
      expect(wed.weekdayIndex, 3); // Wednesday should be 3
      expect(wed.copyWithMode(CalendarMode.bs).weekdayIndex, 3);

      // 2026-07-18 is Saturday
      final sat = CalendarDate.fromAD(DateTime(2026, 7, 18));
      expect(sat.weekdayIndex, 6); // Saturday should be 6
      expect(sat.copyWithMode(CalendarMode.bs).weekdayIndex, 6);
    });

    test('Date comparisons and calculations work', () {
      final d1 = CalendarDate.fromAD(DateTime(2026, 7, 15));
      final d2 = CalendarDate.fromAD(DateTime(2026, 7, 16));

      expect(d1.isBefore(d2), true);
      expect(d2.isAfter(d1), true);
      expect(d1.isSameDay(d2), false);

      final nextDay = d1.add(const Duration(days: 1));
      expect(nextDay.isSameDay(d2), true);
      expect(nextDay.mode, d1.mode);
    });
  });

  group('CalendarController Tests', () {
    test('Initial controller sets correct default states', () {
      final controller = CalendarController(calendarMode: CalendarMode.ad);
      expect(controller.calendarMode, CalendarMode.ad);
      expect(controller.calendarFormat, CalendarFormat.monthGrid);
      expect(controller.selectedDate.isToday, true);
    });

    test('Setting date clamps to range correctly', () {
      final controller = CalendarController(
        firstDate: CalendarDate.fromAD(DateTime(2026, 7, 1)),
        lastDate: CalendarDate.fromAD(DateTime(2026, 7, 31)),
        selectedDate: CalendarDate.fromAD(DateTime(2026, 7, 15)),
      );

      // Underflow clamp
      controller.selectDate(CalendarDate.fromAD(DateTime(2026, 6, 30)));
      expect(controller.selectedDate.day, 1);

      // Overflow clamp
      controller.selectDate(CalendarDate.fromAD(DateTime(2026, 8, 1)));
      expect(controller.selectedDate.day, 31);
    });

    test('Navigation increments or decrements months correctly', () {
      final controller = CalendarController(
        focusedDate: CalendarDate.fromAD(DateTime(2026, 7, 15), mode: CalendarMode.ad),
        calendarMode: CalendarMode.ad,
      );

      controller.nextMonth();
      expect(controller.focusedDate.month, 8);
      expect(controller.focusedDate.year, 2026);

      controller.previousMonth();
      expect(controller.focusedDate.month, 7);

      // BS Navigation
      controller.setCalendarMode(CalendarMode.bs);
      // July 15, 2026 is Ashad 32, 2083
      expect(controller.focusedDate.year, 2083);
      expect(controller.focusedDate.month, 3);

      controller.nextMonth();
      expect(controller.focusedDate.year, 2083);
      expect(controller.focusedDate.month, 4);
    });
  });

  group('CalendarWidget Widget Tests', () {
    testWidgets('Renders month grid by default with correct weekday labels', (WidgetTester tester) async {
      final controller = CalendarController(
        selectedDate: CalendarDate.fromAD(DateTime(2026, 7, 15)),
        calendarMode: CalendarMode.ad,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarWidget(
              controller: controller,
              useNepaliScript: false,
            ),
          ),
        ),
      );

      expect(find.byType(CalendarWidget), findsOneWidget);
      // Finds weekday header text for Sun, Mon...
      expect(find.text('Sun'), findsWidgets);
      expect(find.text('Mon'), findsWidgets);
      
      // Header displays month and year
      expect(find.text('July 2026'), findsOneWidget);
    });

    testWidgets('Can toggle formats between Month Grid and Horizontal Row', (WidgetTester tester) async {
      final controller = CalendarController(
        selectedDate: CalendarDate.fromAD(DateTime(2026, 7, 15)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarWidget(controller: controller),
          ),
        ),
      );

      // Initially grid format (standard height 280)
      expect(controller.calendarFormat, CalendarFormat.monthGrid);

      // Programmatically change format
      controller.setCalendarFormat(CalendarFormat.horizontalStrip);
      await tester.pump(const Duration(milliseconds: 400));

      expect(controller.calendarFormat, CalendarFormat.horizontalStrip);
      // Displays short weekday labels in upper-case for default horizontal cell
      expect(find.text('SUN'), findsWidgets);
    });

    testWidgets('Invokes custom day cell and header builders when provided', (WidgetTester tester) async {
      final controller = CalendarController(
        selectedDate: CalendarDate.fromAD(DateTime(2026, 7, 15)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarWidget(
              controller: controller,
              headerBuilder: (context, date, controller) {
                return const Text('CUSTOM HEADER VIEW');
              },
              dayBuilder: (context, date, state) {
                return Container(
                  key: ValueKey('day_${date.day}'),
                  child: Text('CELL-${date.day}'),
                );
              },
            ),
          ),
        ),
      );

      // Custom header rendered
      expect(find.text('CUSTOM HEADER VIEW'), findsOneWidget);
      expect(find.text('July 2026'), findsNothing);

      // Custom day cells rendered
      expect(find.text('CELL-15'), findsWidgets);
    });
  });
}
