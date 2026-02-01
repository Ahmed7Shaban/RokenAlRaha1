import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../widgets/ramadan_background.dart';
import '../../../../../routes/routes.dart';
import 'widget/card_item.dart';
import 'widget/masbaha_item_view.dart';
import 'cubit/masbaha_cubit.dart';
import 'date/tasbeeh_list.dart';
import 'date/istighfar_list.dart';
import 'masbaha_history_screen.dart';
import 'widget/masbaha_notification_settings_bottom_sheet.dart';
import 'widget/add_dhikr_bottom_sheet.dart';

class MasbahaMainView extends StatelessWidget {
  final int initialIndex;
  const MasbahaMainView({super.key, this.initialIndex = 0});
  static const String routeName = Routes.masbahaMainView;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MasbahaCubit()..loadDhikrs(),
      child: DefaultTabController(
        length: 2,
        initialIndex: initialIndex,
        child: Scaffold(
          floatingActionButton: Builder(
            builder: (context) {
              return FloatingActionButton(
                backgroundColor: AppColors.primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (_) => BlocProvider.value(
                      value: context.read<MasbahaCubit>(),
                      child: const AddDhikrBottomSheet(),
                    ),
                  );
                },
              );
            },
          ),
          body: Column(
            children: [
              // Custom App Bar with Tabs
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const BackButton(color: Colors.white),
                            Text(
                              'تسابيح واستغفار ',
                              style: GoogleFonts.tajawal(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'إعدادات التنبيه',
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(24),
                                        ),
                                      ),
                                      builder: (context) =>
                                          const MasbahaNotificationSettingsBottomSheet(),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.history,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'سجل التسبيح',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MasbahaHistoryScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      TabBar(
                        indicatorColor: Colors.white,
                        indicatorWeight: 4,
                        labelStyle: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                        unselectedLabelColor: Colors.white60,
                        labelColor: Colors.white,
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(text: 'التسبيح'),
                          Tab(text: 'الاستغفار'),
                        ],
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: RamadanBackground(
                  child: BlocBuilder<MasbahaCubit, MasbahaState>(
                    builder: (context, state) {
                      List<String> tasbeehs = tasbeehList;
                      List<String> istighfars = istighfarList;
                      List<String> customNames = [];

                      if (state is MasbahaListLoaded) {
                        tasbeehs = state.tasbeehItems;
                        istighfars = state.istighfarItems;
                        customNames = state.customItems
                            .map((e) => e['text'].toString())
                            .toList();
                      }

                      return TabBarView(
                        children: [
                          _MasbahaList(
                            list: tasbeehs,
                            customNames: customNames,
                          ),
                          _MasbahaList(
                            list: istighfars,
                            customNames: customNames,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasbahaList extends StatelessWidget {
  final List<String> list;
  final List<String> customNames;
  const _MasbahaList({required this.list, required this.customNames});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد عناصر',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 80,
      ), // extra bottom for FAB
      itemCount: list.length,
      itemBuilder: (context, index) {
        final itemTitle = list[index];
        final isCustom = customNames.contains(itemTitle);

        final card = CardItem(
          title: itemTitle,
          isCustom: isCustom,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (_) => MasbahaCubit(),
                  child: MasbahaItemView(title: itemTitle),
                ),
              ),
            );
          },
        );

        if (isCustom) {
          return Dismissible(
                key: Key(itemTitle), // Unique key for deletion
                direction: DismissDirection
                    .endToStart, // Swipe right-to-left (Arabic RTL: left-to-right visual)
                background: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 30),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                onDismissed: (direction) {
                  context.read<MasbahaCubit>().deleteCustomDhikr(itemTitle);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم حذف الذكر بنجاح',
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppColors.primaryColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: card,
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(
                begin: 0.2,
                end: 0,
                curve: Curves.easeOutCubic,
                duration: 400.ms,
                delay: (index * 50).ms,
              );
        }

        return card
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(
              begin: 0.2,
              end: 0,
              curve: Curves.easeOutCubic,
              duration: 400.ms,
              delay: (index * 50).ms,
            );
      },
    );
  }
}
