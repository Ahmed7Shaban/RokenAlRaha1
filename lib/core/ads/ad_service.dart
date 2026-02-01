// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:flutter/foundation.dart'; // عشان debugPrint

// class AdService {
//   static Future<void> init() async {
//     await MobileAds.instance.initialize();
//     debugPrint("✅ AdMob Initialized");
//     loadInterstitialAd();
//   }

//   /// Banner Ad
//   static BannerAd createBannerAd({
//     required Function onLoaded,
//     required Function onFailed,
//   }) {
//     return BannerAd(
//       size: AdSize.banner,
//       adUnitId: 'ca-app-pub-3979581027567172/1227091144',
//      //  adUnitId: 'ca-app-pub-3940256099942544/9214589741', // ID تجريبي
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           debugPrint("✅ Banner Ad Loaded Successfully");
//           onLoaded();
//         },
//         onAdFailedToLoad: (ad, error) {
//           debugPrint("❌ Banner Ad Failed to Load: $error");
//           ad.dispose();
//           onFailed();
//         },
//       ),
//       request: const AdRequest(),
//     );
//   }

//   /// Interstitial Ad
//   static InterstitialAd? _interstitialAd;
//   static int _interstitialCounter = 0;
//   static const int _showEvery = 2; // هيظهر كل مرتين

//   static void loadInterstitialAd() {
//     debugPrint("📢 Loading Interstitial Ad...");
//     InterstitialAd.load(
//       adUnitId: 'ca-app-pub-3979581027567172/1305960698',
//      //  adUnitId: 'ca-app-pub-3940256099942544/1033173712', // ID تجريبي
//       request: const AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (ad) {
//           debugPrint("✅ Interstitial Ad Loaded Successfully");
//           _interstitialAd = ad;
//           _interstitialAd!.setImmersiveMode(true);
//         },
//         onAdFailedToLoad: (error) {
//           debugPrint("❌ Interstitial Ad Failed to Load: $error");
//           _interstitialAd = null;
//         },
//       ),
//     );
//   }

//   static void showInterstitialAd() {
//     _interstitialCounter++;
//     debugPrint("ℹ️ showInterstitialAd called ($_interstitialCounter times)");

//     if (_interstitialCounter % _showEvery == 0 && _interstitialAd != null) {
//       debugPrint("📢 Showing Interstitial Ad...");
//       _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
//         onAdDismissedFullScreenContent: (ad) {
//           debugPrint("ℹ️ Interstitial Ad Dismissed");
//           ad.dispose();
//           loadInterstitialAd();
//         },
//         onAdFailedToShowFullScreenContent: (ad, error) {
//           debugPrint("❌ Interstitial Ad Failed to Show: $error");
//           ad.dispose();
//           loadInterstitialAd();
//         },
//         onAdShowedFullScreenContent: (ad) {
//           debugPrint("✅ Interstitial Ad Shown");
//         },
//       );

//       _interstitialAd!.show();
//       _interstitialAd = null;
//     } else {
//       debugPrint("⚠️ Interstitial Ad Not Ready Yet");
//     }
//   }
// }
