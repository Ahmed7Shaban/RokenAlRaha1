import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import '../Khatma/presentation/views/khatma_dashboard_view.dart';
import '../AudioQuran/audio_quran_page.dart';
import '../Hadith/presentation/pages/hadith_books_page.dart';
import '../QuranPage/SurahView/quran_page_view.dart';
import 'quran_button_card.dart';

class ButtonsList extends StatefulWidget {
  const ButtonsList({
    super.key,
    required this.buttonsItems,
    required this.width,
    required this.height,
    required this.heightList,
  });
  final double width;
  final double height;
  final double heightList;

  final List<Map<String, dynamic>> buttonsItems;
  @override
  State<ButtonsList> createState() => _ButtonsListState();
}

class _ButtonsListState extends State<ButtonsList> {
  late PageController _pageController;
  final double _viewportFraction = 0.75;
  final double _scaleFactor = 0.8;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.heightList, // Fixed height as requested
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.buttonsItems.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = widget.buttonsItems[index];

          // Use AnimatedBuilder to listen to scroll changes efficiently
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double page = 0.0;
              if (_pageController.position.haveDimensions) {
                page = _pageController.page ?? 0.0;
              } else {
                // Determine initial page based on controller's initialPage if needed
                page = _pageController.initialPage.toDouble();
                // Or just 0 if we haven't scrolled yet and standard start
              }

              double diff = (index - page).abs();
              if (diff > 1.0) diff = 1.0;
              final double scale = 1.0 - (diff * (1.0 - _scaleFactor));

              return FractionallySizedBox(
                widthFactor: 1.0,
                child: QuranButtonCard(
                  title: item['title'],
                  imagePath: item['image'],
                  scale: scale,
                  onTap: () {
                    final Widget? page = item['page'];
                    if (page != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => page),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("قريباً إن شاء الله")),
                      );
                    }
                  },
                  width: widget.width,
                  height: widget.height,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
