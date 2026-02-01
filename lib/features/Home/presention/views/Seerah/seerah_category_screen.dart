import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../models/seerah_model.dart';
import 'controllers/seerah_controller.dart';
import 'widgets/seerah_card.dart';

class SeerahCategoryScreen extends StatefulWidget {
  final SeerahCategory category;

  const SeerahCategoryScreen({super.key, required this.category});

  @override
  State<SeerahCategoryScreen> createState() => _SeerahCategoryScreenState();
}

class _SeerahCategoryScreenState extends State<SeerahCategoryScreen> {
  final SeerahController _controller = SeerahController();

  List<SeerahItem> _items = [];
  List<String> _readIds = [];
  List<String> _bookmarkIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final items = await _controller.getItems(widget.category);
    final readIds = await _controller.getReadIds();
    final bookmarkIds = await _controller.getBookmarkIds();

    if (mounted) {
      setState(() {
        _items = items;
        _readIds = readIds;
        _bookmarkIds = bookmarkIds;
        _isLoading = false;
      });
    }
  }

  void _toggleReadStatus(String id, bool? value) async {
    if (value == null) return;
    await _controller.markAsRead(id, value);
    setState(() {
      if (value) {
        _readIds.add(id);
      } else {
        _readIds.remove(id);
      }
    });
  }

  void _toggleBookmark(String id) async {
    await _controller.toggleBookmark(id);
    setState(() {
      if (_bookmarkIds.contains(id)) {
        _bookmarkIds.remove(id);
      } else {
        _bookmarkIds.add(id);
      }
    });
  }

  Future<void> _shareSeerahCard(BuildContext context, SeerahItem item) async {
    await Share.share('${item.title}\n\n${item.content}\n\nتطبيق ركن الراحة');
    await _controller.incrementShareCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.category.displayName,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return _AnimatedListItem(
                  index: index,
                  child: SeerahCard(
                    item: item,
                    isLast: index == _items.length - 1,
                    isRead: _readIds.contains(item.id),
                    onReadToggle: (val) => _toggleReadStatus(item.id, val),
                    isBookmarked: _bookmarkIds.contains(item.id),
                    onBookmarkToggle: () => _toggleBookmark(item.id),
                    onShare: () => _shareSeerahCard(context, item),
                  ),
                );
              },
            ),
    );
  }
}

class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({required this.index, required this.child});

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    final delay = Duration(
      milliseconds: (widget.index % 10 * 50).clamp(0, 500),
    );

    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
