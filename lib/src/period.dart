import 'package:equatable/equatable.dart';

import 'date.dart';
import 'local_date_time.dart';
import 'time.dart';

class Period extends Equatable {
  const Period(
      {this.years = 0,
      this.months = 0,
      this.days = 0,
      this.hours = 0,
      this.minutes = 0,
      this.seconds = 0,
      this.milliseconds = 0});

  Period.fromStandardDuration(final Duration duration)
      : this(
            days: duration.inDays,
            hours: duration.inHours.remainder(24),
            minutes: duration.inMinutes.remainder(60),
            seconds: duration.inSeconds.remainder(60),
            milliseconds: duration.inMilliseconds.remainder(1000));

  /// Calculates the difference between two [Date]s as a period with [days] and
  /// finer populated. This handles [LocalDateTime]s as well. Although this
  /// signature does not cover [Time]-only cases, that is less important since
  /// times can be subtracted naively.
  Period.difference(Date later, Date earlier)
      : this.fromStandardDuration(
            later.toCoreFields().difference(earlier.toCoreFields()));

  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final int milliseconds;

  @override
  List<Object?> get props =>
      [years, months, days, hours, minutes, seconds, milliseconds];

  Period operator -() => Period(
      years: -years,
      months: -months,
      days: -days,
      hours: -hours,
      minutes: -minutes,
      seconds: -seconds,
      milliseconds: -milliseconds);

  /// Converts this period to a duration assuming a 24 hour day, 60 minute hour,
  /// and 60 second minute.
  Duration toStandardDuration() {
    if (years != 0 || months != 0) {
      throw UnsupportedError(
          'Years and months cannot be converted to a standard duration.');
    }

    return Duration(
        days: days,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds);
  }
}
