import 'dart:core';
import 'dart:core' as core;

import 'package:equatable/equatable.dart';

import 'date.dart';
import 'period.dart';
import 'time.dart';

class LocalDateTime extends Equatable implements Date, Time {
  const LocalDateTime(this.date, this.time);
  LocalDateTime.fromCore(core.DateTime value)
      : this(Date.fromCore(value), Time.fromCore(value));
  final Date date;
  final Time time;

  @override
  List<Object?> get props => [date, time];

  @override
  int get year => date.year;

  @override
  int get month => date.month;

  @override
  int get day => date.day;

  @override
  int get weekday => date.weekday;

  @override
  int get hour => time.hour;

  @override
  int get minute => time.minute;

  @override
  int get second => time.second;

  @override
  int get millisecond => time.millisecond;

  /// Adds a [Period] or milliseconds to this [LocalDateTime] according to the
  /// default chronology. Fields are added in order of descending significance.
  @override
  LocalDateTime operator +(dynamic p) => p is Period
      ? LocalDateTime.fromCore(core.DateTime.utc(
          year + p.years,
          month + p.months,
          day + p.days,
          hour + p.hours,
          minute + p.minutes,
          second + p.seconds,
          millisecond + p.milliseconds))
      : this + Period(milliseconds: p);

  @override
  LocalDateTime operator -(dynamic p) => this + -p;

  @override
  LocalDateTime operator &(Time time) => date & time;

  @override
  LocalDateTime nextWeekday(int weekday) =>
      LocalDateTime(date.nextWeekday(weekday), time);
}
