import 'dart:core';
import 'dart:core' as core;

import 'package:timezone/timezone.dart' as tz;

import 'date.dart';
import 'instant.dart';
import 'local_date_time.dart';
import 'period.dart';
import 'time.dart';
import 'time_zone.dart';

class DateTime extends Instant implements LocalDateTime {
  DateTime(Instant instant, this.timeZone)
      : _local = core.DateTime.fromMillisecondsSinceEpoch(
            timeZone.value.translate(instant.millisecondsSinceEpoch),
            isUtc: true),
        super(instant.value);
  DateTime.fromCore(core.DateTime value, TimeZone timeZone)
      : this(Instant(value), timeZone);
  DateTime.fromMillisecondsSinceEpoch(int t, TimeZone timeZone)
      : this(Instant.fromMillisecondsSinceEpoch(t), timeZone);
  DateTime.now(TimeZone timeZone) : this(Instant.now(), timeZone);
  factory DateTime.resolve(LocalDateTime localDateTime, TimeZone timeZone,
          {ResolverFunction resolver = Resolvers.forEarlierOffset,
          ResolverFunction? springForward,
          ResolverFunction? fallBack}) =>
      Resolver._(localDateTime, timeZone).resolve(
          resolver: resolver, springForward: springForward, fallBack: fallBack);
  factory DateTime.atStartOfDay(Date date, TimeZone timeZone) =>
      DateTime.resolve(date & Time.zero, timeZone,
          resolver: Resolvers.forEarlierOffset);

  final TimeZone timeZone;
  tz.TimeZone get timeZoneOffset =>
      timeZone.value.timeZone(millisecondsSinceEpoch);

  final core.DateTime _local;

  /// Not used for equality or hash code.
  @override
  List<Object?> get props => [...super.props, timeZone];

  LocalDateTime get local => LocalDateTime.fromCore(_local);

  @override
  Date get date => Date.fromCore(_local);

  @override
  Time get time => Time.fromCore(_local);

  @override
  int get year => _local.year;

  @override
  int get month => _local.month;

  @override
  int get day => _local.day;

  @override
  int get weekday => _local.weekday;

  @override
  int get hour => _local.hour;

  @override
  int get minute => _local.minute;

  @override
  int get second => _local.second;

  @override
  int get millisecond => _local.millisecond;

  bool get isDst => timeZoneOffset.isDst;

  /// Variation of [operator +] that accepts resolver overrides.
  DateTime add(Period period,
          {ResolverFunction resolver = Resolvers.forEarlierOffset,
          ResolverFunction? springForward,
          ResolverFunction? fallBack}) =>
      DateTime.resolve(local + period, timeZone,
          springForward: springForward ?? resolver,
          fallBack: fallBack ?? resolver);

  /// Adds a [Period] or [Duration] to this [DateTime]. Periods operate on the
  /// local time while durations operate on the instant.
  ///
  /// The DST resolution policy of the period is [Resolvers.forEarlierOffset],
  /// which works well relative to the beginning of the day.
  @override
  DateTime operator +(dynamic delta) => delta is Duration
      ? DateTime(super + delta, timeZone)
      : add(delta as Period);

  /// Subtracts a [Period] or [Duration] from this [DateTime]. Periods operate
  /// on the local time while durations operate on the instant.
  ///
  /// The DST resolution policy of the period is [Resolvers.forEarlierOffset],
  /// which works well relative to the beginning of the day.
  @override
  DateTime operator -(dynamic delta) => this + -delta;

  DateTime withDate(Date date) => DateTime.resolve(date & time, timeZone);

  @override
  DateTime operator &(Time time) => DateTime.resolve(date & time, timeZone);

  /// Returns a copy of this [DateTime] with the time set to the start of the
  /// day.
  ///
  /// The time will normally be midnight, as that is the earliest time on any
  /// given day. However, in some time zones when Daylight Savings Time starts,
  /// there is no midnight because time jumps from 11:59 to 01:00. This method
  /// handles that situation by returning 01:00 on that date.
  ///
  /// https://www.joda.org/joda-time/apidocs/org/joda/time/DateTime.html#withTimeAtStartOfDay--
  DateTime withTimeAtStartOfDay() => DateTime.atStartOfDay(this, timeZone);

  @override
  core.DateTime toCoreFields() => local.toCoreFields();

  @override
  DateTime nextWeekday(int weekday) =>
      DateTime.resolve(local.nextWeekday(weekday), timeZone,
          resolver: Resolvers.forEarlierOffset);
}

typedef ResolverFunction = DateTime Function(Resolver resolver);

/// Inspired by https://pub.dev/documentation/time_machine/latest/time_machine/Resolvers-class.html
/// and TZDateTime.`_utcFromLocalDateTime`.
class Resolver {
  Resolver._(this.dateTime, this.timeZone) {
    final approximate = core.DateTime.utc(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            dateTime.hour,
            dateTime.minute,
            dateTime.second,
            dateTime.millisecond)
        .millisecondsSinceEpoch;
    final offset = timeZone.value.lookupTimeZone(approximate);

    if (approximate - offset.start > offset.end - approximate) {
      _za = offset;
      _zb = timeZone.value.lookupTimeZone(offset.end + 1);
    } else {
      _zb = offset;
      _za = timeZone.value.lookupTimeZone(offset.start - 1);
    }

    _ta = approximate - _za.timeZone.offset;
    _tb = approximate - _zb.timeZone.offset;
  }

  final LocalDateTime dateTime;
  final TimeZone timeZone;

  late final tz.TzInstant _za, _zb;
  late final int _ta, _tb;

  tz.TimeZone get earlierTimeZone => _za.timeZone;
  tz.TimeZone get laterTimeZone => _zb.timeZone;

  DateTime _asDateTime(int t) =>
      DateTime.fromMillisecondsSinceEpoch(t, timeZone);
  DateTime get forEarlierOffset => _asDateTime(_ta);
  DateTime get forLaterOffset => _asDateTime(_tb);
  DateTime get boundary => _asDateTime(_zb.start);

  DateTime resolve(
      {ResolverFunction resolver = Resolvers.strict,
      ResolverFunction? springForward,
      ResolverFunction? fallBack}) {
    bool isValid(int t, tz.TzInstant z) => z.start <= t && t < z.end;
    final va = isValid(_ta, _za), vb = isValid(_tb, _zb);
    if (va) {
      if (vb) {
        return (fallBack ?? resolver)(this);
      } else {
        return _asDateTime(_ta);
      }
    } else if (vb) {
      return _asDateTime(_tb);
    } else {
      return (springForward ?? resolver)(this);
    }
  }
}

class DstError extends Error {
  DstError(this.resolver);
  final Resolver resolver;

  @override
  String toString() =>
      'Failed resolution of ${resolver.dateTime} between ${resolver.forLaterOffset} and ${resolver.forEarlierOffset} about ${resolver.boundary}.';
}

class Resolvers {
  Resolvers._();

  /// Fails resolution by throwing [DstError].
  static DateTime strict(Resolver resolver) => throw DstError(resolver);

  /// Resolves according to the offset before the time change, picking later
  /// times for spring forward and earlier times for fall back, preserving the
  /// offset from the start of the day.
  ///
  /// This is a reasonable default for most operations.
  static DateTime forEarlierOffset(Resolver resolver) =>
      resolver.forEarlierOffset;

  /// Resolves according to the offset after the time change, picking earlier
  /// times for spring forward and later times for fall back, preserving the
  /// offset from the end of the day.
  static DateTime forLaterOffset(Resolver resolver) => resolver.forLaterOffset;

  static const fallBackEarlier = forEarlierOffset,
      fallBackLater = forLaterOffset,
      springForwardEarlier = forLaterOffset,
      springForwardLater = forEarlierOffset;
}
