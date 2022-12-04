extension ComparisonOperators<T> on Comparable<T> {
  bool operator <(T other) => compareTo(other) < 0;
  bool operator <=(T other) => compareTo(other) <= 0;
  bool operator >(T other) => compareTo(other) > 0;
  bool operator >=(T other) => compareTo(other) >= 0;
}

T max<T extends Comparable>(T a, T b) => a >= b ? a : b;
T min<T extends Comparable>(T a, T b) => a <= b ? a : b;
