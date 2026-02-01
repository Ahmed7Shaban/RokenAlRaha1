class QiblahUtils {
  static const double kaabaLat = 21.4225;
  static const double kaabaLong = 39.8262;

  /// Calculates estimated flight time in hours assuming average speed of 900 km/h.
  static String calculateFlightTime(double distanceInKm) {
    double hours = distanceInKm / 900;
    int h = hours.floor();
    int m = ((hours - h) * 60).round();

    if (h > 0) {
      return "$h ساعة و $m دقيقة";
    } else {
      return "$m دقيقة";
    }
  }
}
