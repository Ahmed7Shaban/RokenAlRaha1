import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PermissionsPageWidget extends StatefulWidget {
  const PermissionsPageWidget({super.key});

  @override
  State<PermissionsPageWidget> createState() => _PermissionsPageWidgetState();
}

class _PermissionsPageWidgetState extends State<PermissionsPageWidget> {
  bool _isLoading = false;

  PermissionStatus _locationStatus = PermissionStatus.denied;
  PermissionStatus _notificationStatus = PermissionStatus.denied;
  PermissionStatus _cameraStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final loc = await Permission.location.status;
    final notif = await Permission.notification.status;
    final cam = await Permission.camera.status;

    if (mounted) {
      setState(() {
        _locationStatus = loc;
        _notificationStatus = notif;
        _cameraStatus = cam;
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);

    // Request Location
    if (!_locationStatus.isGranted) {
      final status = await Permission.location.request();
      setState(() => _locationStatus = status);
    }

    // Request Notification
    if (!_notificationStatus.isGranted) {
      final status = await Permission.notification.request();
      setState(() => _notificationStatus = status);
    }

    // Request Camera
    if (!_cameraStatus.isGranted) {
      final status = await Permission.camera.request();
      setState(() => _cameraStatus = status);
    }

    setState(() => _isLoading = false);
  }

  bool get _allGranted =>
      _locationStatus.isGranted &&
      _notificationStatus.isGranted &&
      _cameraStatus.isGranted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "نحتاج إذنك لخدمتك",
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "لضمان أفضل تجربة روحانية، امنحنا هذه الصلاحيات:",
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),

          // Permissions List
          _buildPermissionItem(
            icon: Icons.location_on_rounded,
            title: "الموقع الجغرافي",
            description: "لمواقيت الصلاة والقبلة",
            color: Colors.orange,
            status: _locationStatus,
            delay: 100,
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            icon: Icons.notifications_active_rounded,
            title: "الإشعارات",
            description: "للتذكير بالصلاة والأذكار",
            color: Colors.purple,
            status: _notificationStatus,
            delay: 200,
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            icon: Icons.camera_alt_rounded,
            title: "الكاميرا",
            description: "للقبلة بالواقع المعزز",
            color: Colors.blue,
            status: _cameraStatus,
            delay: 300,
          ),

          const Spacer(),

          // Main Action Button
          SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _allGranted
                        ? Colors.green
                        : AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _allGranted
                                  ? "تم التفعيل بنجاح"
                                  : "تفعيل التجربة الكاملة",
                              style: GoogleFonts.tajawal(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (_allGranted) ...[
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                ),
              )
              .animate(target: _allGranted ? 1 : 0)
              .shimmer(duration: 1000.ms, color: Colors.white54),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required PermissionStatus status,
    required int delay,
  }) {
    final isGranted = status.isGranted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isGranted ? Colors.green.withOpacity(0.5) : Colors.transparent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isGranted
                  ? Colors.green.withOpacity(0.1)
                  : color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGranted ? Icons.check : icon,
              color: isGranted ? Colors.green : color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isGranted)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ).animate().scale(),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX();
  }
}
