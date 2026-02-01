import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart'; // Needed for Position
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/core/widgets/lottie_loader.dart';

class QiblahMapWidget extends StatefulWidget {
  final Position? currentPosition;
  final String currentAddress;
  final double distanceToKaaba;
  final LatLng kaabaLocation;

  const QiblahMapWidget({
    super.key,
    required this.currentPosition,
    required this.currentAddress,
    required this.distanceToKaaba,
    required this.kaabaLocation,
  });

  @override
  State<QiblahMapWidget> createState() => _QiblahMapWidgetState();
}

class _QiblahMapWidgetState extends State<QiblahMapWidget> {
  final MapController _mapController = MapController();
  bool _isMapMoved = false;

  @override
  void didUpdateWidget(covariant QiblahMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-center map when position becomes available mostly
    if (oldWidget.currentPosition == null && widget.currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recenterMap();
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _recenterMap() {
    if (widget.currentPosition != null) {
      _mapController.move(
        LatLng(
          widget.currentPosition!.latitude,
          widget.currentPosition!.longitude,
        ),
        13.0,
      );
      setState(() {
        _isMapMoved = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 35% of screen height
    final double mapHeight = MediaQuery.of(context).size.height * 0.35;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: mapHeight,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: widget.currentPosition == null
              ? _buildLoadingMap()
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          widget.currentPosition!.latitude,
                          widget.currentPosition!.longitude,
                        ),
                        initialZoom: 13.0,
                        onPositionChanged: (position, hasGesture) {
                          if (hasGesture) {
                            setState(() => _isMapMoved = true);
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          // Using CartoDB Voyager
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.roken.alraha',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [
                                LatLng(
                                  widget.currentPosition!.latitude,
                                  widget.currentPosition!.longitude,
                                ),
                                widget.kaabaLocation,
                              ],
                              strokeWidth: 3.5,
                              color: AppColors.goldenYellow,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                widget.currentPosition!.latitude,
                                widget.currentPosition!.longitude,
                              ),
                              width: 45,
                              height: 45,
                              child: const Icon(
                                Icons.my_location,
                                color: AppColors.primaryColor,
                                size: 35,
                                shadows: [
                                  Shadow(blurRadius: 5, color: Colors.black26),
                                ],
                              ),
                            ),
                            Marker(
                              point: widget.kaabaLocation,
                              width: 50,
                              height: 50,
                              child: Transform.translate(
                                offset: const Offset(0, -25),
                                child: const Icon(
                                  Icons.mosque,
                                  color: Colors.black,
                                  size: 45,
                                  shadows: [
                                    Shadow(blurRadius: 5, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Top Info Container Overlaid (Floating Card)
                    Positioned(
                      top: 15,
                      left: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.goldenYellow,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.currentAddress,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 12, thickness: 0.5),
                            Row(
                              children: [
                                Icon(
                                  Icons.straighten_outlined,
                                  color: AppColors.goldenYellow,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "المسافة للكعبة: ${widget.distanceToKaaba.toStringAsFixed(2)} كم",
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Recenter Button
                    if (_isMapMoved)
                      Positioned(
                        bottom: 15,
                        right: 15,
                        child: FloatingActionButton.small(
                          heroTag: "recenter_map",
                          backgroundColor: Colors.white,
                          elevation: 4,
                          child: Icon(
                            Icons.center_focus_strong,
                            color: AppColors.goldenYellow,
                          ),
                          onPressed: _recenterMap,
                        ),
                      ),

                    // Back Button
                    Positioned(
                      top: 15,
                      right: 15,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingMap() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LottieLoader(),
          const SizedBox(height: 10),
          Text(
            "جاري تحميل الخريطة...",
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
