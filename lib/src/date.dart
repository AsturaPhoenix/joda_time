import 'dart:core';
import 'dart:core' as core;

import 'package:equatable/equatable.dart';

import 'local_date_time.dart';
import 'period.dart';
import 'time.dart';

class Date extends Equatable {
  static const zero = Date(1970, 1, 1);
  const Date(this.year, this.month, this.day);
  Date.fromCore(core.DateTime value) : this(value.year, value.month, value.day);

  final int year;
  final int month;
  final int day;

  @override
  List<Object?> get props => [year, month, day];

  int get weekday => DateTime(year, month, day).weekday;

  /// Adds a [Period] to this [Date] according to the default chronology. Fields
  /// are added in order of descending significance, so for example
  /// 2022-02-01 + 1 mo 30 d = 2022-03-31 (while 2022-02-01 + 30d = 2022-03-03).
  Date operator +(Period delta) =>
      (LocalDateTime(this, Time.zero) + delta).date;
  Date operator -(Period delta) => this + -delta;

  LocalDateTime operator &(Time time) => LocalDateTime(this, time);

  Date nextWeekday(int weekday) =>
      this + Period(days: (weekday - this.weekday) % DateTime.daysPerWeek);
}
