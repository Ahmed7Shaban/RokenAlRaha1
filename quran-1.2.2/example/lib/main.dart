import 'package:flutter/material.dart'; // استيراد مكتبة Flutter الأساسية لإنشاء الواجهات
import 'package:quran/quran.dart' as quran; // استيراد مكتبة quran لإحضار معلومات القرآن، مع تعريف اسم مختصر quran

void main() {
  runApp(const MaterialApp(home: QuranExample()));
  // تشغيل التطبيق وعرض الصفحة الرئيسية QuranExample
}

class QuranExample extends StatefulWidget {
  const QuranExample() : super();
  // إنشاء ويدجت حالة StatefulWidget لأنها ستحتوي على واجهة ديناميكية

  @override
  State<QuranExample> createState() => _QuranExampleState();
// ربط ال StatefulWidget بالكلاس الذي يحتوي على منطق الواجهة _QuranExampleState
}

class _QuranExampleState extends State<QuranExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quran Demo"),
        // عنوان التطبيق في شريط الأعلى
      ),
      body: SingleChildScrollView(
        // يسمح بالتمرير إذا زاد المحتوى عن حجم الشاشة
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          // إضافة مسافة داخلية حول المحتوى
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // محاذاة المحتوى لليسار
            children: [
              Text("Juz Number: \n${quran.getJuzNumber(18, 1)}"),
              // عرض رقم الجزء الذي يحتوي على السورة 18، الآية 1

              Text("\nJuz URL: \n${quran.getJuzURL(15)}"),
              // عرض رابط الجزء 15 على موقع المصحف الإلكتروني

              Text("\nSurah and Verses in Juz 15: \n${quran.getSurahAndVersesFromJuz(15)}"),
              // عرض السور والآيات التي تنتمي للجزء 15

              Text("\nSurah Name: \n${quran.getSurahName(18)}"),
              // عرض اسم السورة رقم 18 باللغة العربية

              Text("\nSurah Name (English): \n${quran.getSurahNameEnglish(18)}"),
              // عرض اسم السورة رقم 18 باللغة الإنجليزية

              Text("\nSurah URL: \n${quran.getSurahURL(18)}"),
              // عرض رابط السورة رقم 18

              Text("\nTotal Verses: \n${quran.getVerseCount(18)}"),
              // عرض عدد الآيات في السورة رقم 18

              Text("\nPlace of Revelation: \n${quran.getPlaceOfRevelation(18)}"),
              // عرض مكان نزول السورة (مكة أو المدينة)

              const Text("\nBasmala: \n${quran.basmala}"),
              // عرض البسملة (بسم الله الرحمن الرحيم)

              Text("\nVerse 1: \n${quran.getVerse(18, 1)}"),
              // عرض الآية الأولى من السورة رقم 18
            ],
          ),
        ),
      ),
    );
  }
}
