import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../../../core/theme/app_colors.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/cubit/quran_cubit.dart'; // For SearchMode

class SearchTextFieldView extends StatefulWidget {
  final String initialQuery;
  final Function(String query) onSearch;
  final VoidCallback onClear;
  final SearchMode activeMode;
  final Function(SearchMode) onModeChange;

  const SearchTextFieldView({
    super.key,
    required this.initialQuery,
    required this.onSearch,
    required this.onClear,
    required this.activeMode,
    required this.onModeChange,
  });

  @override
  State<SearchTextFieldView> createState() => _SearchTextFieldViewState();
}

class _SearchTextFieldViewState extends State<SearchTextFieldView> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(covariant SearchTextFieldView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != _controller.text) {
      if (widget.initialQuery.isEmpty && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Search Field
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? AppColors.primaryColor.withOpacity(0.15)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isFocused ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: _isFocused ? AppColors.primaryColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextField(
            focusNode: _focusNode,
            textDirection: TextDirection.rtl,
            controller: _controller,
            textAlignVertical: TextAlignVertical.center,
            onChanged: (value) {
              setState(() {});
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                widget.onSearch(value);
              });
            },
            style: const TextStyle(
              fontFamily: 'arsura',
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: _getHintText(),
              hintStyle: TextStyle(
                fontFamily: 'arsura',
                color: Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                height: 1.2,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _isFocused
                    ? AppColors.primaryColor
                    : Colors.grey.shade400,
                size: 24,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () {
                        _controller.clear();
                        widget.onClear();
                        setState(() {});
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 10,
              ),
              border: InputBorder.none,
            ),
          ),
        ),

        // 2. Mode Selector (Centered Segmented Buttons)
        Container(
          margin: const EdgeInsets.only(bottom: 12, top: 4),
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: [
              _buildModeChip("سورة بالاسم", SearchMode.surahName),
              const SizedBox(width: 8),
              _buildModeChip("سورة بالرقم", SearchMode.surahNumber),
              const SizedBox(width: 8),
              _buildModeChip("نص الآية", SearchMode.ayah),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeChip(String label, SearchMode mode) {
    final bool isSelected = widget.activeMode == mode;
    return GestureDetector(
      onTap: () => widget.onModeChange(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  String _getHintText() {
    switch (widget.activeMode) {
      case SearchMode.surahName:
        return 'ابحث باسم السورة (مثل: البقرة)...';
      case SearchMode.surahNumber:
        return 'ابحث برقم السورة (1-114)...';
      case SearchMode.ayah:
        return 'اكتب نص الآية...';
    }
  }
}
