/// A time library vaguely based on
/// [Joda Time](https://www.joda.org/joda-time/).
///
/// An existing library [time_machine](https://pub.dev/packages/time_machine)
/// implements much of the same, but is missing some quality of life features
/// like extensions and interfaces, and seems too heavy to fork.
library joda;

export 'src/comparison.dart';
export 'src/date.dart';
export 'src/date_time.dart';
export 'src/instant.dart';
export 'src/local_date_time.dart';
export 'src/period.dart';
export 'src/time.dart';
export 'src/time_zone.dart';
