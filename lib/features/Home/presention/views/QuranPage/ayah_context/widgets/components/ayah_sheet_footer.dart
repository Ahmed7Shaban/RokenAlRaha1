import 'package:flutter/material.dart';
import '../ayah_action_button.dart';

class AyahSheetFooter extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final String? activeAction;
  final bool isBusy;

  const AyahSheetFooter({
    Key? key,
    required this.onCopy,
    required this.onShare,
    required this.onSave,
    this.activeAction,
    this.isBusy = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AyahActionButton(
            icon: Icons.copy_rounded,
            label: "Copy",
            color: Colors.orange,
            onTap: isBusy ? null : onCopy,
            isLoading: activeAction == 'copy',
          ),
          AyahActionButton(
            icon: Icons.share_rounded,
            label: "Share",
            color: Colors.blue,
            onTap: isBusy ? null : onShare,
            isLoading: activeAction == 'share',
          ),
          AyahActionButton(
            icon: Icons.save_alt_rounded,
            label: "Save",
            color: Colors.green,
            onTap: isBusy ? null : onSave,
            isLoading: activeAction == 'save',
          ),
        ],
      ),
    );
  }
}
