import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/widgets/appbar_widget.dart';
import '../../../../../../../../core/widgets/empty_list.dart';
import '../cubit/zikr_cubit.dart';
import '../model/zikr_model.dart';
import 'add_zikr_bottom_sheet.dart';
import 'zikry_item.dart';

class BodyAzkary extends StatefulWidget {
  const BodyAzkary({super.key});

  @override
  State<BodyAzkary> createState() => _BodyAzkaryState();
}

class _BodyAzkaryState extends State<BodyAzkary> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    context.read<ZikrCubit>().loadZikr();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditSheet(ZikrModel zikr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddZikrBottomSheet(zikr: zikr),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppbarWidget(title: "أذكارى"),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: "ابحث في أذكارك...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),

        Expanded(
          child: BlocBuilder<ZikrCubit, ZikrState>(
            builder: (context, state) {
              if (state is ZikrError) {
                return Center(child: Text(state.message));
              }

              if (state is ZikrLoaded) {
                var list = state.zikrList;

                // Filter
                if (_searchQuery.isNotEmpty) {
                  list = list
                      .where(
                        (item) =>
                            item.title.toLowerCase().contains(_searchQuery) ||
                            item.content.toLowerCase().contains(_searchQuery),
                      )
                      .toList();
                }

                if (list.isEmpty) return const EmptyList();

                // Group by Category
                final Map<String, List<ZikrModel>> grouped = {};
                for (var item in list) {
                  // Handle if category is missing in older models
                  String cat = "عام";
                  try {
                    cat = item.category;
                  } catch (e) {}
                  grouped.putIfAbsent(cat, () => []).add(item);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final category = grouped.keys.elementAt(index);
                    final items = grouped[category]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          child: Chip(
                            label: Text(
                              category,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                        ...items
                            .map(
                              (zikr) => ZikryItem(
                                zikr: zikr,
                                onDeleted: () {
                                  final key = zikr.key; // Use key direct
                                  context.read<ZikrCubit>().deleteZikr(
                                    key as int,
                                  ); // Casting might vary
                                },
                                onEdit: () => _showEditSheet(zikr),
                              ),
                            )
                            .toList(),
                      ],
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
