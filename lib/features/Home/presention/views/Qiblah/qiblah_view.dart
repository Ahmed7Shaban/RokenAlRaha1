import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../../../../../routes/routes.dart';
import 'widget/location_permission_error_widget.dart';
import 'widget/qiblah_ar_view.dart';
import 'widget/qiblah_compass.dart';
import 'widget/qiblah_map_widget.dart';

class QiblahView extends StatefulWidget {
  const QiblahView({Key? key}) : super(key: key);
  static const String routeName = Routes.QiblahView;
  @override
  State<QiblahView> createState() => _QiblahViewState();
}

class _QiblahViewState extends State<QiblahView> with WidgetsBindingObserver {
  bool _locationPermissionGranted = false;
  Position? _currentPosition;
  String _currentAddress = "جاري تحديد الموقع...";
  double _distanceToKaaba = 0;
  final LatLng _kaabaLocation = const LatLng(21.422487, 39.826206);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions({bool openSettings = false}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (openSettings) await Geolocator.openLocationSettings();
      if (mounted) setState(() => _locationPermissionGranted = false);
      return;
    }

    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
      if (status.isPermanentlyDenied && openSettings) await openAppSettings();
    }

    if (mounted) {
      setState(() {
        _locationPermissionGranted =
            (status.isGranted || status.isLimited) && serviceEnabled;
      });
      if (_locationPermissionGranted) {
        _getCurrentLocation();
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _kaabaLocation.latitude,
        _kaabaLocation.longitude,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _distanceToKaaba = distanceInMeters / 1000;
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            String city = place.locality ?? place.subAdministrativeArea ?? '';
            String gov = place.administrativeArea ?? '';
            String country = place.country ?? '';

            List<String> parts = [];
            if (city.isNotEmpty) parts.add(city);
            if (gov.isNotEmpty && gov != city) parts.add(gov);
            if (country.isNotEmpty) parts.add(country);

            _currentAddress = parts.join('، ');
          }
        });
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: _locationPermissionGranted
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QiblahARView()),
                );
              },
              child: const Icon(
                Icons.camera_alt,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            )
          : null,
      body: SafeArea(
        child: _locationPermissionGranted
            ? Column(
                children: [
                  QiblahMapWidget(
                    currentPosition: _currentPosition,
                    currentAddress: _currentAddress,
                    distanceToKaaba: _distanceToKaaba,
                    kaabaLocation: _kaabaLocation,
                  ),
                  Expanded(child: const QiblahCompass()),
                ],
              )
            : LocationPermissionErrorWidget(
                onRequestPermission: () =>
                    _checkPermissions(openSettings: true),
                onBack: () => Navigator.pop(context),
              ),
      ),
    );
  }
}
