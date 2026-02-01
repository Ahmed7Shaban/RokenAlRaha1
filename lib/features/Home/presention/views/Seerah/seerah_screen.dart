import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../models/seerah_model.dart';
import 'controllers/seerah_controller.dart';
import 'seerah_category_screen.dart';
import 'widgets/achievement_badges_section.dart';
import 'salat_on_prophet_view.dart';

class SeerahScreen extends StatefulWidget {
  static const String routeName = '/Seerah';
  const SeerahScreen({super.key});

  @override
  State<SeerahScreen> createState() => _SeerahScreenState();
}

class _SeerahScreenState extends State<SeerahScreen> {
  final SeerahController _controller = SeerahController();

  // State
  List<AchievementBadge> _badges = [];
  List<String> _readIds = [];
  int _totalItems = 0;
  int _shareCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Ensure data is loaded to calculate global stats
    await _controller.loadAllData();

    final readIds = await _controller.getReadIds();
    final total = await _controller.getTotalCount();
    final shareCount = await _controller.getShareCount();

    if (mounted) {
      setState(() {
        _readIds = readIds;
        _totalItems = total;
        _shareCount = shareCount;
        _calculateBadges();
        _isLoading = false;
      });
    }
  }

  void _calculateBadges() {
    final doneLifeEvents = _controller.checkCategoryCompleted(
      SeerahCategory.lifeEvents,
      _readIds,
    );
    final doneFamily = _controller.checkCategoryCompleted(
      SeerahCategory.family,
      _readIds,
    );
    final doneBattles = _controller.checkCategoryCompleted(
      SeerahCategory.battles,
      _readIds,
    );

    final doneHalfway = _totalItems > 0 && _readIds.length >= (_totalItems / 2);
    final doneSeal = _totalItems > 0 && _readIds.length == _totalItems;
    final doneAmbassador = _shareCount >= 10;

    _badges = [
      AchievementBadge(
        title: "المستفتح",
        description: "وسام يُمنح عند قراءة أول حدث في السيرة.",
        icon: Icons.flag_rounded,
        color: Colors.blue,
        isUnlocked: _readIds.isNotEmpty,
      ),
      AchievementBadge(
        title: "السيرة النبوية",
        description: "وسام إتمام قسم السيرة النبوية.",
        icon: Icons.menu_book_rounded,
        color: Colors.purple,
        isUnlocked: doneLifeEvents,
      ),
      AchievementBadge(
        title: "آل البيت",
        description: "وسام إتمام قسم آل البيت.",
        icon: Icons.family_restroom_rounded,
        color: Colors.pink,
        isUnlocked: doneFamily,
      ),
      AchievementBadge(
        title: "المجاهد",
        description: "وسام إتمام قسم الغزوات.",
        icon: Icons.shield_rounded,
        color: Colors.orange,
        isUnlocked: doneBattles,
      ),
      AchievementBadge(
        title: "نصف الطريق",
        description: "وسام يُمنح عند قراءة نصف السيرة.",
        icon: Icons.timeline_rounded,
        color: Colors.teal,
        isUnlocked: doneHalfway,
      ),
      AchievementBadge(
        title: "سفير السيرة",
        description: "وسام يُمنح عند مشاركة 10 مقتطفات.",
        icon: Icons.share_rounded,
        color: Colors.indigo,
        isUnlocked: doneAmbassador,
      ),
      AchievementBadge(
        title: "خاتم السيرة",
        description: "وسام ختم السيرة النبوية كاملة.",
        icon: Icons.workspace_premium_rounded,
        color: Colors.amber,
        isUnlocked: doneSeal,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        title: Column(
          children: [
            Text(
              "السيرة العطرة",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            if (!_isLoading && _totalItems > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "تم إنجاز ${_readIds.length} من $_totalItems",
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mosque_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SalatOnProphetView(),
                ),
              );
            },
            tooltip: 'الصلاة على النبي',
          ),
        ],
      ),
      body: _isLoading
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  AchievementBadgesSection(badges: _badges),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "الأقسام الرئيسية",
                        style: GoogleFonts.tajawal(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardGrid(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildDashboardGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: SeerahCategory.values.length,
      itemBuilder: (context, index) {
        final category = SeerahCategory.values[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(SeerahCategory category) {
    IconData icon;
    Color color;
    switch (category) {
      case SeerahCategory.lifeEvents:
        icon = Icons.import_contacts_rounded;
        color = const Color(0xFFD4AF37); // Gold
        break;
      case SeerahCategory.family:
        icon = Icons.family_restroom;
        color = const Color(0xFF4CAF50); // Green
        break;
      case SeerahCategory.battles:
        icon = Icons.security;
        color = const Color(0xFFE57373); // Red
        break;
      case SeerahCategory.topics:
        icon = Icons.auto_stories;
        color = const Color(0xFF64B5F6); // Blue
        break;
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SeerahCategoryScreen(category: category),
          ),
        );
        _loadInitialData(); // Refresh progress
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              category.displayName,
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Optional: Show count or items
            FutureBuilder<List<SeerahItem>>(
              future: _controller.getItems(category),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    "${snapshot.data!.length} مقال",
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  );
                }
                return SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: List.generate(
                4,
                (index) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
