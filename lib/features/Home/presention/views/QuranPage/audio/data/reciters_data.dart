class Reciter {
  final String id;
  final String name;
  final String subfolder; // For EveryAyah: Reciter_Name_128kbps

  const Reciter({
    required this.id,
    required this.name,
    required this.subfolder,
  });
}

// Data from http://everyayah.com/data/status.php
const List<Reciter> availableReciters = [
  Reciter(id: "alafasy", name: "مشاري العفاسي", subfolder: "Alafasy_128kbps"),
  Reciter(id: "husary", name: "محمود خليل الحصري", subfolder: "Husary_128kbps"),
  Reciter(
    id: "minshawi_mujawwad",
    name: "محمد صديق المنشاوي (مجود)",
    subfolder: "Minshawy_Mujawwad_192kbps",
  ),
  Reciter(
    id: "abdulbasit",
    name: "عبد الباسط عبد الصمد",
    subfolder: "Abdul_Basit_Murattal_192kbps",
  ),
  Reciter(
    id: "sudais",
    name: "عبد الرحمن السديس",
    subfolder: "Abdurrahmaan_As-Sudais_192kbps",
  ),
  Reciter(
    id: "shuraym",
    name: "سعود الشريم",
    subfolder: "Saood_ash-Shuraym_128kbps",
  ),
  Reciter(
    id: "hudaify",
    name: "علي بن عبد الرحمن الحذيفي",
    subfolder: "Hudhaify_128kbps",
  ),
];
