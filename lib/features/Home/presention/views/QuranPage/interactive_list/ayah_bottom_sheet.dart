import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

class AyahBottomSheet extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;

  const AyahBottomSheet({
    Key? key,
    required this.surahNumber,
    required this.verseNumber,
  }) : super(key: key);

  @override
  State<AyahBottomSheet> createState() => _AyahBottomSheetState();
}

class _AyahBottomSheetState extends State<AyahBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Two main tabs: Tafsir, Translation
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Basic Surah Info
    final surahName = quran.getSurahNameArabic(widget.surahNumber);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 5),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 2. Title & Actions
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$surahName : آية ${widget.verseNumber}",
                      style: const TextStyle(
                        fontFamily: "Amiri",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _ActionButton(icon: Icons.copy, onTap: () {}),
                        const SizedBox(width: 8),
                        _ActionButton(icon: Icons.share, onTap: () {}),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.play_arrow_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(),

              // 3. Tab Bar
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: "التفسير"), // Tafsir
                  Tab(text: "الترجمة"), // Translation
                ],
              ),

              // 4. Content Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tafsir View
                    _ContentPlaceholder(
                      label: "جاري تحميل التفسير...",
                      icon: Icons.menu_book,
                      scrollController: scrollController,
                    ),
                    // Translation View
                    _ContentPlaceholder(
                      label: "جاري تحميل الترجمة...",
                      icon: Icons.translate,
                      scrollController: scrollController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.blueGrey),
      ),
    );
  }
}

class _ContentPlaceholder extends StatelessWidget {
  final String label;
  final IconData icon;
  final ScrollController scrollController;

  const _ContentPlaceholder({
    required this.label,
    required this.icon,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 30),
        Icon(icon, size: 50, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[500], fontSize: 16),
        ),
        const SizedBox(height: 20),
        // Simulate dummy text to show scrolling capability
        Text(
          "هنا سيظهر النص الكامل عند توفر الاتصال بالبيانات. هذا نص تجريبي يوضح مكان ظهور المحتوى.\n" *
              10,
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontSize: 16,
            height: 1.8,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
