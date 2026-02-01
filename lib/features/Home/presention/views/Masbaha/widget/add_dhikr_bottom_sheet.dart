import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../cubit/masbaha_cubit.dart';

class AddDhikrBottomSheet extends StatefulWidget {
  const AddDhikrBottomSheet({super.key});

  @override
  State<AddDhikrBottomSheet> createState() => _AddDhikrBottomSheetState();
}

class _AddDhikrBottomSheetState extends State<AddDhikrBottomSheet> {
  final _textController = TextEditingController();
  String _selectedType = 'tasbeeh'; // or 'istighfar'
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'إضافة ذكر جديد',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'نص الذكر',
              hintText: 'أدخل الذكر هنا...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildRadioTile('تسبيح', 'tasbeeh')),
              const SizedBox(width: 10),
              Expanded(child: _buildRadioTile('استغفار', 'istighfar')),
            ],
          ),
          const SizedBox(height: 20),
          ListTile(
            onTap: _pickTime,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            leading: Icon(
              Icons.notifications_active,
              color: _selectedTime != null
                  ? AppColors.primaryColor
                  : Colors.grey,
            ),
            title: Text(
              _selectedTime != null
                  ? 'وقت التذكير: ${_formatTime(_selectedTime!)}'
                  : 'تحديد وقت للتذكير (اختياري)',
              style: GoogleFonts.tajawal(
                color: _selectedTime != null ? Colors.black87 : Colors.grey,
              ),
            ),
            trailing: _selectedTime != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () => setState(() => _selectedTime = null),
                  )
                : const Icon(Icons.arrow_drop_down),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                context.read<MasbahaCubit>().addCustomDhikr(
                  text: _textController.text,
                  type: _selectedType,
                  notificationTime: _selectedTime,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'حفظ الذكر',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String title, String value) {
    final isSelected = _selectedType == value;
    return InkWell(
      onTap: () => setState(() => _selectedType = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 20,
              ),
            if (isSelected) const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay.fromDateTime(dt).format(context);
  }
}
