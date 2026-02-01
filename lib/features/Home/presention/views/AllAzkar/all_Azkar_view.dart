import 'package:flutter/material.dart';

import '../widgets/ramadan_background.dart';
import '../../../../../core/widgets/appbar_widget.dart';
import '../../../../../routes/routes.dart';
import '../widgets/card/services_grid.dart';
import 'date/zekr_item_list.dart';
import 'widgets/azkar_stats_widget.dart';
import 'widgets/smart_azkar_card.dart';
import 'widgets/atomic/azkar_search_bar.dart';
import 'widgets/atomic/azkar_empty_state.dart';
import 'widgets/atomic/azkar_list_header.dart';
import '../../../models/service_item.dart';

class AllAzkarView extends StatefulWidget {
  const AllAzkarView({super.key});
  static const String routeName = Routes.AllAzkar;

  @override
  State<AllAzkarView> createState() => _AllAzkarViewState();
}

class _AllAzkarViewState extends State<AllAzkarView> {
  // Filtered list state
  List<ServiceItem> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();

  /* 
    IMPORTANT: We're initializing with zekrItemList.
    Make sure zekrItemList is accessible. It's imported from 'date/zekr_item_list.dart'.
  */

  @override
  void initState() {
    super.initState();
    _filteredList = zekrItemList; // Initialize with full list
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredList = zekrItemList;
      } else {
        _filteredList = zekrItemList.where((item) {
          return item.label.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // AppbarWidget is not PreferredSizeWidget, so we place it in the body
      body: RamadanBackground(
        child: Column(
          children: [
            const AppbarWidget(title: "أذكار المسلم"),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Smart Suggestion Card
                    const SmartAzkarCard(),
                    const SizedBox(height: 20),

                    // Stats Widget
                    const AzkarStatsWidget(),
                    const SizedBox(height: 24),

                    // Search Bar
                    AzkarSearchBar(controller: _searchController),
                    const SizedBox(height: 24),

                    // Title for List
                    const AzkarListHeader(),
                    const SizedBox(height: 16),

                    // Grid
                    _filteredList.isEmpty
                        ? const AzkarEmptyState()
                        : ServicesGrid(list: _filteredList),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
