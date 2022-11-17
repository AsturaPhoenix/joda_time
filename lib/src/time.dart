import 'dart:core';
import 'dart:core' as core;

import 'package:equatable/equatable.dart';

import 'date.dart';
import 'local_date_time.dart';
import 'period.dart';

class Time extends Equatable {
  /// Midnight.
  static const zero = Time(0, 0);
  const Time(this.hour, this.minute, [this.second = 0, this.millisecond = 0]);
  Time.fromCore(core.DateTime value)
      : this(value.hour, value.minute, value.second, value.millisecond);

  final int hour;
  final int minute;
  final int second;
  final int millisecond;

  @override
  List<Object?> get props => [hour, minute, second, millisecond];

  /// Adds a [Period] to this [Time] according to the default chronology. The
  /// result is truncated to the range [0:00:00.000, 24:00:00.000).
  Time operator +(Period delta) =>
      (LocalDateTime(Date.zero, this) + delta).time;
  Time operator -(Period delta) => this + -delta;
}
