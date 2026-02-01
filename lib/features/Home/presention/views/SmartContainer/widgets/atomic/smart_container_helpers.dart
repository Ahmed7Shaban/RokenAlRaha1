import 'package:hijri/hijri_calendar.dart';

class SmartContainerHelpers {
  static String toArabicNums(int n) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String s = n.toString();
    for (int i = 0; i < english.length; i++) {
      s = s.replaceAll(english[i], arabic[i]);
    }
    return s.replaceAll('AM', 'ص').replaceAll('PM', 'م');
  }

  static String toArabicNumsStr(String s) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      s = s.replaceAll(english[i], arabic[i]);
    }
    return s.replaceAll('AM', 'ص').replaceAll('PM', 'م');
  }

  static String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    String hStr = toArabicNums(hours);
    String mStr = toArabicNums(minutes);
    if (hours > 0) {
      return "$hStr ساعة و$mStr دقيقة";
    } else {
      return "$mStr دقيقة";
    }
  }

  static String formatHijriDate(HijriCalendar hijri) {
    List<String> months = [
      "محرم",
      "صفر",
      "ربيع الأول",
      "ربيع الآخر",
      "جمادى الأولى",
      "جمادى الآخرة",
      "رجب",
      "شعبان",
      "رمضان",
      "شوال",
      "ذو القعدة",
      "ذو الحجة",
    ];
    String monthName = (hijri.hMonth > 0 && hijri.hMonth <= 12)
        ? months[hijri.hMonth - 1]
        : "";
    return "${toArabicNums(hijri.hDay)} $monthName ${toArabicNums(hijri.hYear)}";
  }

  static String mapPrayerNameArabic(dynamic prayer) {
    String name = prayer.toString().split('.').last;
    switch (name) {
      case 'fajr':
        return 'الفجر';
      case 'sunrise':
        return 'الشروق';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      case 'none':
        return '...';
      default:
        return name;
    }
  }
}
