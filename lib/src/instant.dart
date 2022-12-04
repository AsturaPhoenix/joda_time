import 'package:equatable/equatable.dart';

class Instant extends Equatable implements Comparable<Instant> {
  Instant(DateTime value) : value = value.toUtc().copyWith(microsecond: 0);
  Instant.fromMillisecondsSinceEpoch(int t)
      : this(DateTime.fromMillisecondsSinceEpoch(t, isUtc: true));
  Instant.now() : this(DateTime.now());
  final DateTime value;

  int get millisecondsSinceEpoch => value.millisecondsSinceEpoch;

  @override
  int compareTo(Instant other) => value.compareTo(other.value);

  @override
  List<Object?> get props => [value];

  /// All subclasses of Instant share the same notion of equality.
  @override
  bool operator ==(Object other) => other is Instant && value == other.value;

  @override
  int get hashCode => value.hashCode;

  Instant operator +(Duration delta) => Instant(value.add(delta));
  Instant operator -(Duration delta) => this + -delta;
}
