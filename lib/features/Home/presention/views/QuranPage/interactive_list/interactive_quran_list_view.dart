// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:quran/quran.dart' as quran;
// import '../ayah_context/widgets/ayah_card.dart';
// import '../ayah_context/widgets/ayah_options_sheet.dart';
// import '../ayah_context/logic/ayah_action_handler.dart';

// class InteractiveQuranListView extends StatefulWidget {
//   final int surahNumber;

//   const InteractiveQuranListView({
//     Key? key,
//     this.surahNumber = 1, // Default to Al-Fatiha for demo
//   }) : super(key: key);

//   @override
//   State<InteractiveQuranListView> createState() =>
//       _InteractiveQuranListViewState();
// }

// class _InteractiveQuranListViewState extends State<InteractiveQuranListView> {
//   int? _selectedVerse;
//   late final AyahActionHandler _actionHandler;

//   @override
//   void initState() {
//     super.initState();
//     _actionHandler = AyahActionHandler();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final verseCount = quran.getVerseCount(widget.surahNumber);
//     final surahName = quran.getSurahNameArabic(widget.surahNumber);

//     return Scaffold(
//       backgroundColor: const Color(0xffFFFDF5), // Light cream background
//       appBar: AppBar(
//         title: Text(
//           "سورة $surahName",
//           style: const TextStyle(
//             fontFamily: "Amiri",
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: Column(
//         children: [
//           // Optional Header Info
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             alignment: Alignment.center,
//             child: Text(
//               "بسم الله الرحمن الرحيم",
//               style: const TextStyle(
//                 fontFamily: "Amiri",
//                 fontSize: 24,
//                 color: Colors.black87,
//               ),
//             ),
//           ),

//           Expanded(
//             child: ListView.builder(
//               itemCount: verseCount,
//               padding: const EdgeInsets.only(
//                 bottom: 100,
//               ), // Space for fab or bottom sheet
//               itemBuilder: (context, index) {
//                 final verseNum = index + 1;
//                 final isSelected = _selectedVerse == verseNum;

//                 return AyahCard(
//                   surahNumber: widget.surahNumber,
//                   verseNumber: verseNum,
//                   isSelected: isSelected,
//                   onTap: () {
//                     setState(() {
//                       _selectedVerse = verseNum;
//                     });
//                     _showAyahBottomSheet(context, verseNum);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAyahBottomSheet(BuildContext context, int verseNum) {
//     // Determine Surah/Verse logic
//     final verseText = quran.getVerse(widget.surahNumber, verseNum);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true, // Allows sheet to be taller if needed
//       builder: (context) {
//         return AyahOptionsSheet(
//           surahNumber: widget.surahNumber,
//           verseNumber: verseNum,
//           verseText: verseText,
//           onTafsir: () async {
//             await _actionHandler.showTafsir(
//               context,
//               widget.surahNumber,
//               verseNum,
//             );
//             if (context.mounted) Navigator.pop(context);
//           },
//           onTranslation: () async {
//             await _actionHandler.showTranslation(
//               context,
//               widget.surahNumber,
//               verseNum,
//             );
//             if (context.mounted) Navigator.pop(context);
//           },
//           onSave: () async {
//             await _actionHandler.saveAyah(
//               context,
//               widget.surahNumber,
//               verseNum,
//             );
//             if (context.mounted) Navigator.pop(context);
//           },
//           onShare: () async {
//             // Do NOT pop immediately. Let the button show loading.
//             await _actionHandler.shareAyah(
//               context,
//               surahNumber: widget.surahNumber,
//               verseNumber: verseNum,
//               verseText: verseText,
//             );
//             // Optionally pop after share dialog opens, or keep sheet open.
//             // Keeping it open allows user to share again or do other actions.
//           },
//           onCopy: () async {
//             await _actionHandler.copyAyah(context, verseText);
//             if (context.mounted) Navigator.pop(context);
//           },
//         );
//       },
//     ).whenComplete(() {
//       setState(() {
//         _selectedVerse = null;
//       });
//     });
//   }
// }
