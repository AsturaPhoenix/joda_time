import 'package:timezone/timezone.dart';

class TimeZone {
  static final utc = TimeZone.fromLocation(UTC);

  const TimeZone.fromLocation(this.value);
  TimeZone.forId(String id) : this.fromLocation(getLocation(id));
  final Location value;
}
