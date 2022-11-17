class Period {
  const Period(
      {this.years = 0,
      this.months = 0,
      this.days = 0,
      this.hours = 0,
      this.minutes = 0,
      this.seconds = 0,
      this.milliseconds = 0});
  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final int milliseconds;

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
