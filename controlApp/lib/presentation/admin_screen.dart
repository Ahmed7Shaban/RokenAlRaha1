import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/admin_cubit.dart';
import '../logic/admin_state.dart';
import '../core/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late TextEditingController _devUrlController;
  late TextEditingController _tiktokUrlController;

  @override
  void initState() {
    super.initState();
    _devUrlController = TextEditingController();
    _tiktokUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _devUrlController.dispose();
    _tiktokUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminCubit, AdminState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage ||
          previous.isSaving != current.isSaving,
      listener: (context, state) {
        if (state.status == AdminStatus.success &&
            _devUrlController.text.isEmpty) {
          _devUrlController.text = state.config.devUrl;
          _tiktokUrlController.text = state.config.tiktokUrl;
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Control Panel',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A), // Slate 900
                Color(0xFF1E1B4B), // Indigo 950
                Color(0xFF000000), // Black
              ],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<AdminCubit, AdminState>(
              builder: (context, state) {
                if (state.status == AdminStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Sync controllers if empty on load
                if (_devUrlController.text.isEmpty &&
                    state.config.devUrl.isNotEmpty) {
                  _devUrlController.text = state.config.devUrl;
                }
                if (_tiktokUrlController.text.isEmpty &&
                    state.config.tiktokUrl.isNotEmpty) {
                  _tiktokUrlController.text = state.config.tiktokUrl;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Settings'),
                      const SizedBox(height: 16),
                      _buildSwitchCard(
                        title: 'Support Section',
                        subtitle: state.config.isEnabled
                            ? 'Currently Visible to Users'
                            : 'Currently Hidden from Users',
                        value: state.config.isEnabled,
                        onChanged: (val) =>
                            context.read<AdminCubit>().updateIsEnabled(val),
                      ),
                      const SizedBox(height: 24),

                      _buildTextField(
                        controller: _devUrlController,
                        label: 'Developer Site URL',
                        icon: Icons.code,
                        onChanged: (val) =>
                            context.read<AdminCubit>().updateDevUrl(val),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _tiktokUrlController,
                        label: 'TikTok Profile URL',
                        icon: Icons.music_note,
                        onChanged: (val) =>
                            context.read<AdminCubit>().updateTiktokUrl(val),
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle('Live Preview'),
                      const SizedBox(height: 16),
                      _buildPreviewCard(state),

                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state.isSaving
                              ? null
                              : () async {
                                  final success = await context
                                      .read<AdminCubit>()
                                      .saveChanges();
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Settings updated successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: AppTheme.primary.withOpacity(0.5),
                          ),
                          child: state.isSaving
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Uploading...',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Update Settings Now',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Dashboard',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage Roken Al Raha configuration.',
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: AppTheme.accent,
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: value ? Colors.greenAccent : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accent,
            activeTrackColor: AppTheme.accent.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: AppTheme.primary),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(AdminState state) {
    if (!state.config.isEnabled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.visibility_off, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              'Support Section is Hidden',
              style: GoogleFonts.outfit(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Users will not see any of the links below.',
              style: GoogleFonts.inter(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_android, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                'Mobile Preview',
                style: GoogleFonts.inter(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPreviewTile(
            'Developer Website',
            Icons.language,
            state.config.devUrl,
          ),
          const Divider(height: 1),
          _buildPreviewTile(
            'TikTok Page',
            Icons.music_note,
            state.config.tiktokUrl,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTile(String title, IconData icon, String url) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        url.isNotEmpty ? url : 'No URL set',
        style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }
}
