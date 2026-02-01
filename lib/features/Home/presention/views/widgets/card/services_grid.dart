import 'package:flutter/material.dart';
import '../../../../../../core/ads/ad_service.dart';
import '../../../../date/service_items_list.dart';
import '../../../../models/service_item.dart';
import '../card/card_services.dart';

class ServicesGrid extends StatefulWidget {
  const ServicesGrid({super.key, required this.list});
  final List<ServiceItem> list;

  @override
  State<ServicesGrid> createState() => _ServicesGridState();
}

class _ServicesGridState extends State<ServicesGrid> {
  int _tapCount = 0;

  void _handleTap(ServiceItem item) {
    _tapCount++;

    // if (_tapCount >= 3) {
    //   // AdService.showInterstitialAd();
    //   _tapCount = 0;
    // }

    Navigator.pushNamed(context, item.route);
    print("object: ${item.route}");
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130, // Adjust based on your preferred item width
        childAspectRatio:
            0.85, // Taller cards usually look better for icons+text
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: widget.list.length,
      itemBuilder: (context, index) {
        final item = widget.list[index];
        return CardServices(
          item: item,
          index: index,
          onTap: () => _handleTap(item),
        );
      },
    );
  }
}
