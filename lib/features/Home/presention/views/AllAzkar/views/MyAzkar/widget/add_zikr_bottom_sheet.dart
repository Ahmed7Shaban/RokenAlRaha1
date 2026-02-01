import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../../../../core/theme/app_colors.dart';
import '../cubit/zikr_cubit.dart';
import '../model/zikr_model.dart';
import 'success_dialog.dart';
import 'zikr_text_field.dart';

class AddZikrBottomSheet extends StatefulWidget {
  final ZikrModel? zikr;
  const AddZikrBottomSheet({super.key, this.zikr});

  @override
  State<AddZikrBottomSheet> createState() => _AddZikrBottomSheetState();
}

class _AddZikrBottomSheetState extends State<AddZikrBottomSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _goalController = TextEditingController();
  int _count = 1;
  String _category = "عام";

  final List<String> _categories = ["عام", "دعاء", "تسبيح", "استغفار", "قرآن"];

  @override
  void initState() {
    super.initState();
    if (widget.zikr != null) {
      _titleController.text = widget.zikr!.title;
      _contentController.text = widget.zikr!.content;
      _count = widget.zikr!.count;
      _category = widget.zikr!.category; // Assumes field exists now
      _goalController.text = widget.zikr!.dailyGoal.toString();
    } else {
      _goalController.text = "100";
    }
  }

  void _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final goal = int.tryParse(_goalController.text) ?? 100;

    if (title.isEmpty || content.isEmpty) {
      // ignore: use_build_context_synchronously
      if (mounted) Animate().shake();
      return;
    }

    final zikr = ZikrModel(
      title: title,
      content: content,
      count: _count,
      category: _category,
      dailyGoal: goal,
      totalCount: widget.zikr?.totalCount ?? 0,
    );

    if (widget.zikr != null) {
      context.read<ZikrCubit>().updateZikrByKey(widget.zikr!.key, zikr);
    } else {
      context.read<ZikrCubit>().addZikr(zikr);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SuccessDialog(),
    );

    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      Navigator.of(context).pop(); // Close Dialog
      Navigator.of(context).pop(); // Close BottomSheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.zikr != null ? "تعديل الذكر" : "إضافة ذكر جديد",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                ZikrTextField(
                  controller: _titleController,
                  label: 'عنوان الذكر',
                  icon: Icons.title,
                ),
                const SizedBox(height: 15),

                // Content
                ZikrTextField(
                  controller: _contentController,
                  label: 'نص الذكر',
                  icon: Icons.notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 15),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _category,
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                  decoration: InputDecoration(
                    labelText: "التصنيف",
                    prefixIcon: const Icon(
                      Icons.category,
                      color: AppColors.primaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Daily Goal
                ZikrTextField(
                  controller: _goalController,
                  label: 'الهدف اليومي',
                  icon: Icons.track_changes,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _save,
                    icon: const Icon(Icons.save, color: AppColors.pureWhite),
                    label: Text(
                      widget.zikr != null ? "حفظ التعديلات" : 'حفظ الذكر',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
