import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roken_al_raha/core/widgets/lottie_loader.dart';
import 'package:roken_al_raha/source/app_images.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../helper/qiblah_direction_helper.dart';

class QiblahARView extends StatefulWidget {
  const QiblahARView({super.key});

  @override
  State<QiblahARView> createState() => _QiblahARViewState();
}

class _QiblahARViewState extends State<QiblahARView> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _isCameraPermissionGranted = true;
      });
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraPermissionGranted) {
      return Scaffold(
        body: Center(
          child: Text(
            'يرجى السماح بالوصول للكاميرا',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (_controller != null && _initializeControllerFuture != null)
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SizedBox.expand(child: CameraPreview(_controller!));
                } else {
                  return const Center(child: LottieLoader());
                }
              },
            ),

          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          StreamBuilder<QiblahDirection>(
            stream: FlutterQiblah.qiblahStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              final qiblahDirection = snapshot.data;
              if (qiblahDirection == null) return const SizedBox();

              final double angle = qiblahDirection.qiblah;
              final String direction = getDirectionFromDegree(angle);
              final String arabicAngle = convertToArabicNumbers(
                angle.toStringAsFixed(2),
              );

              var rotationAngle = angle * (math.pi / 180) * -1;

              // Check if aligned wih Qiblah (allowing small margin of error, e.g., 2 degrees)
              bool isAligned = angle.abs() < 2 || (360 - angle.abs()) < 2;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Virtual Kaaba appearing when aligned
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: isAligned ? 1.0 : 0.0,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldenYellow.withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              "assets/Images/backgroundSplash.jpg", // Using this as the 'Kaaba' or 'Mosque' visual for now as requested/available
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "أنت تواجه القبلة الآن",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldenYellow,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!isAligned) ...[
                    Text(
                      "وجه هاتفك نحو القبلة",
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                    SizedBox(height: 30),
                  ],

                  // Compass Ring
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: SvgPicture.asset("assets/Images/compass.svg"),
                        ),
                        Center(
                          child: Transform.rotate(
                            angle: rotationAngle,
                            child: Image.asset(Assets.compass, width: 220),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "اتجاه القبلة: $arabicAngle° ($direction)",
                    style: GoogleFonts.cairo(
                      textStyle: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldenYellow,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
