import 'package:joda/time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_10y.dart';

void main() {
  initializeTimeZones();

  final defaultTimeZone = TimeZone.forId('America/Los_Angeles');

  group('conversion', () {
    test('Period from Duration', () {
      expect(
          Period.fromStandardDuration(
              const Duration(days: 3, hours: 2, minutes: 1)),
          equals(const Period(days: 3, hours: 2, minutes: 1)));
    });

    test('Period from negative Duration', () {
      expect(
          Period.fromStandardDuration(
              const Duration(days: -3, hours: -2, minutes: -1)),
          equals(const Period(days: -3, hours: -2, minutes: -1)));
    });
  });

  group('operators', () {
    test('DateTime', () {
      final leapFeb =
          DateTime.atStartOfDay(const Date(2000, 2, 1), defaultTimeZone);

      expect(
          leapFeb + const Period(months: 1),
          equals(
              DateTime.atStartOfDay(const Date(2000, 3, 1), defaultTimeZone)));
      expect(
          leapFeb + const Duration(days: 29),
          equals(
              DateTime.atStartOfDay(const Date(2000, 3, 1), defaultTimeZone)));

      expect(leapFeb < leapFeb + const Duration(milliseconds: 1), isTrue);
    });

    group('Period', () {
      test('difference involving February', () {
        expect(
            Period.difference(const Date(2022, 3, 4), const Date(2022, 2, 26)),
            equals(const Period(days: 6)));
      });

      test('difference across fall back', () {
        final fallBack = DateTime.resolve(
            const Date(2022, 11, 6) & const Time(1, 0), defaultTimeZone);
        expect(Period.difference(fallBack + const Duration(hours: 1), fallBack),
            const Period());
      });

      test('difference across spring forward', () {
        final springForward = DateTime.resolve(
            const Date(2022, 3, 13) & const Time(1, 0), defaultTimeZone);
        expect(
            Period.difference(
                springForward + const Duration(hours: 1), springForward),
            const Period(hours: 2));
      });
    });
  });

  void dstTest(String description, TimeZone tz,
      {required LocalDateTime springForward,
      required LocalDateTime fallBack,
      required Period change}) {
    group('DST $description', () {
      group('spring forward', () {
        test('passes through before the boundary', () {
          final local = springForward - 1;
          expect(DateTime.resolve(local, tz).local, equals(local));
        });

        test('passes through after the boundary', () {
          final local = springForward + change;
          expect(DateTime.resolve(local, tz).local, equals(local));
        });

        test('throws on the boundary', () {
          expect(
              () => DateTime.resolve(springForward, tz,
                  resolver: Resolvers.strict),
              throwsA(isA<DstError>()));
        });

        test('resolves the boundary', () {
          final local = springForward + const Period(minutes: 15);
          expect(
              DateTime.resolve(local, tz,
                      springForward: Resolvers.springForwardEarlier)
                  .local,
              equals(local - change));
          expect(
              DateTime.resolve(local, tz,
                      springForward: Resolvers.springForwardLater)
                  .local,
              equals(local + change));
        });

        test('default resolution adding Period to DateTime', () {
          expect(
              (DateTime.resolve(springForward - const Period(minutes: 15), tz) +
                      const Period(minutes: 30))
                  .local,
              equals(springForward + change + const Period(minutes: 15)));
        });
      });

      group('fall back', () {
        test('passes through before the boundary', () {
          final local = fallBack - change - 1;
          expect(DateTime.resolve(local, tz).local, equals(local));
        });

        test('passes through after the boundary', () {
          final local = fallBack;
          expect(DateTime.resolve(local, tz).local, equals(local));
        });

        test('throws on the boundary', () {
          expect(
              () => DateTime.resolve(fallBack - change, tz,
                  resolver: Resolvers.strict),
              throwsA(isA<DstError>()));
        });

        test('resolves the boundary', () {
          final later =
                  DateTime.resolve(fallBack, tz) - const Duration(minutes: 15),
              earlier = later - change.toStandardDuration();
          expect(earlier.local, equals(later.local));

          expect(
              DateTime.resolve(later.local, tz,
                  fallBack: Resolvers.fallBackEarlier),
              equals(earlier));
          expect(
              DateTime.resolve(later.local, tz,
                  fallBack: Resolvers.fallBackLater),
              equals(later));
        });

        test('default resolution adding Period to DateTime', () {
          final t0 = DateTime.resolve(
              fallBack - change - const Period(minutes: 15), tz);
          expect(t0 + const Period(minutes: 30),
              equals(t0 + const Duration(minutes: 30)));
        });
      });
    });
  }

  dstTest('with northwestern time zone', TimeZone.forId('America/Los_Angeles'),
      springForward: const LocalDateTime(Date(2022, 3, 13), Time(2, 0)),
      fallBack: const LocalDateTime(Date(2022, 11, 6), Time(2, 0)),
      change: const Period(hours: 1));
  dstTest('with time zone near UTC', TimeZone.forId('Europe/London'),
      springForward: const LocalDateTime(Date(2022, 03, 27), Time(1, 0)),
      fallBack: const LocalDateTime(Date(2022, 10, 30), Time(2, 0)),
      change: const Period(hours: 1));
  dstTest('with southeastern time zone and :30 offset',
      TimeZone.forId('Australia/Lord_Howe'),
      springForward: const LocalDateTime(Date(2022, 10, 2), Time(2, 0)),
      fallBack: const LocalDateTime(Date(2022, 4, 3), Time(2, 0)),
      change: const Period(minutes: 30));
}
