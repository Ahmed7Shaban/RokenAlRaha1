import '../presention/views/AsmaaAllah/presentation/views/asmaa_allah_view.dart';
import '../presention/views/AudioQuran/audio_quran_page.dart';
import '../presention/views/Hadith/presentation/pages/hadith_books_page.dart';
import '../presention/views/Hamed/hamed_view.dart';
import '../presention/views/Masbaha/IstighfarView/istighfar_view.dart';
import '../presention/views/Masbaha/TasbeehView/tasbeeh_view.dart';
import '../presention/views/QuranPage/SurahView/quran_page_view.dart';

final List<Map<String, dynamic>> itemsQ = [
  {
    "title": "نور التلاوة",
    "image": "assets/Images/quranIM.jpg",
    "page": const QuranPageView(),
  },
  {
    "title": "نور السماع",
    "image": "assets/Images/quranRead.jpg",
    "page": const AudioQuranPage(),
  },
  {
    "title": "الميراث النبوي",
    "image": "assets/Images/hadith.jpg",
    "page": const HadithBooksPage(),
  },
];
final List<Map<String, dynamic>> itemsMasbaha = [
  {
    "title": "أسماء الله الحسنى",
    "image": "assets/Images/backimg3.jpg",
    "page": const AsmaaAllahView(),
  },
  {
    "title": "التسابيح",
    "image": "assets/Images/backimg2.jpg",
    "page": const TasbeehView(),
  },
  {
    "title": "الاستغفار",
    "image": "assets/Images/backimg2.jpg",
    "page": const IstighfarView(),
  },
  {
    "title": "مرافئ الحمد",
    "image": "assets/Images/backimg3.jpg",
    "page": const HamedView(),
  },
];
