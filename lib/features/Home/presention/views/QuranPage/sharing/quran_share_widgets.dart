import 'package:flutter/material.dart';

import 'package:roken_al_raha/features/Home/presention/views/QuranPage/QuranPageview/wiagets/quran_header.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/widgets/quran_rich_text.dart';
import 'package:roken_al_raha/core/widgets/shared_branding_widget.dart';

/// The layout widget that will be captured as an image.
class SharePageLayout extends StatelessWidget {
  final int pageIndex;
  final dynamic fullJsonData;
  final List<dynamic> chunkData;
  final bool isFirstChunk;
  final bool isLastChunk;

  const SharePageLayout({
    Key? key,
    required this.pageIndex,
    required this.fullJsonData,
    required this.chunkData,
    required this.isFirstChunk,
    required this.isLastChunk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We use a fixed width container matching generic mobile width logic
    // but scale it via ScreenUtil in the generator.
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Header (only on the first part of the page)
          // We check if the chunk contains the start of the page
          if (isFirstChunk)
            QuranHeader(pageIndex: pageIndex, jsonData: fullJsonData),

          if (isFirstChunk) const SizedBox(height: 20),

          // 2. The Content
          QuranRichText(
            pageIndex: pageIndex,
            jsonData: fullJsonData,
            selectedSpan: "", // No selection in shared image
            onSelectedSpanChange: (_) {},
            customData: chunkData,
          ),

          const SizedBox(height: 20),

          // 3. Footer (only on the last part)
          if (isLastChunk) _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          SharedBrandingWidget(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
          ),
          // Extra padding for aesthetics
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
