import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/data/repositories/reading_settings_repository.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/data/repositories/last_read_repository.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/logic/cubit/last_read_cubit.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'constants.dart';
import 'core/ads/ad_service.dart';
import 'core/ads/cubit/ad_cubit.dart';
import 'core/services/welcome_notification_service.dart';
import 'features/Home/cubit/actionCubit/action_bottom_cubit.dart';
import 'features/Home/presention/views/AllAzkar/views/MyAzkar/cubit/zikr_cubit.dart';
import 'features/Home/presention/views/AllAzkar/views/MyAzkar/model/zikr_model.dart';
import 'features/Home/presention/views/Masbaha/model/masbaha_model.dart';
import 'features/Home/presention/views/QuranPage/quran/data/repositories/ayah_bookmark_repository.dart';
import 'features/Home/presention/views/QuranPage/quran/logic/cubit/ayah_bookmark_cubit.dart';
import 'generated/l10n.dart';
import 'routes/app_routes.dart';
import 'routes/routes.dart';
import 'services/adhan.dart';
import 'core/services/notification_service.dart';
import 'features/Home/presention/views/QuranPage/tafsir/data/models/translation_data.dart';
import 'package:roken_al_raha/features/Home/presention/views/AudioQuran/cubit/audio_quran_cubit.dart';
import 'package:roken_al_raha/core/widgets/global_audio_overlay.dart';
import 'package:roken_al_raha/services/hadith_notification_service.dart';
import 'features/Home/presention/views/AllAzkar/services/azkar_notification_helper.dart';
import 'features/Home/presention/views/Masbaha/services/masbaha_notification_helper.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:roken_al_raha/features/FajrAlarm/presentation/view/fajr_alarm_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final welcomeService = WelcomeNotificationService();
  await welcomeService.init();
  // Initialize time zones
  tz.initializeTimeZones();

  // Initialize heavy services with error handling
  try {
    await initializeHeavyServices();
  } catch (e) {
    debugPrint("Heavy Services Init Failed: $e");
  }

  // Initialize Repositories (Critical for App Start)
  // We await this one so bookmarks are available immediately when the UI builds
  AyahBookmarkRepository? ayahBookmarkRepo;
  try {
    ayahBookmarkRepo = await AyahBookmarkRepository.create();
  } catch (e) {
    debugPrint("AyahBookmarkRepository Init Failed: $e");
    // Handle fallback or rethrow if critical
  }

  if (ayahBookmarkRepo != null) {
    runApp(MyApp(ayahBookmarkRepo: ayahBookmarkRepo));
  } else {
    // Fallback or error screen could be shown here, but for now we log.
    debugPrint("Critical dependency missing, app cannot start correctly.");
    // You might want to runApp(ErrorApp()); here
  }
}

Future<void> initializeHeavyServices() async {
  // Hive Init
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(MasbahaModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ZikrModelAdapter());
  }
  if (!Hive.isAdapterRegistered(20)) {
    Hive.registerAdapter(TranslationDataAdapter());
  }

  await Hive.openBox<MasbahaModel>(Masbaha);
  await Hive.openBox<ZikrModel>(azkar);

  // Ads
  // await MobileAds.instance.initialize();
  // await AdService.init();
  // AdService.loadInterstitialAd();

  // Notifications
  final notificationService = NotificationService();
  await notificationService.init();

  // Setup listener for notification clicks
  notificationService.plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (details) {
      if (details.payload == 'fajr_alarm') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const FajrAlarmScreen()),
        );
      }
    },
  );
  await HadithNotificationService.init();
  await AzkarNotificationHelper.refreshAllNotifications();
  await MasbahaNotificationHelper.refreshAllNotifications();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final AyahBookmarkRepository ayahBookmarkRepo;

  const MyApp({Key? key, required this.ayahBookmarkRepo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 1. Existing Cubits
        BlocProvider(create: (_) => ActionBottomCubit()),
        BlocProvider(create: (_) => ZikrCubit()..init()),
        // BlocProvider(create: (_) => AdCubit()),
        // 2. New Global Cubits
        BlocProvider(create: (context) => AyahBookmarkCubit(ayahBookmarkRepo)),
        BlocProvider(
          create: (context) =>
              ReadingSettingsCubit(ReadingSettingsRepository()),
        ),
        BlocProvider(create: (context) => LastReadCubit(LastReadRepository())),
        // Promoted to Global for Floating Player
        BlocProvider(create: (context) => AudioQuranCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // Standard design size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // Localization
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            locale: const Locale('ar', 'EN'),

            navigatorKey: navigatorKey,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: Routes.splash,
            navigatorObservers: [GlobalRouteObserver()],

            builder: (context, child) {
              final widget = Directionality(
                textDirection: TextDirection.rtl,
                child: Stack(children: [if (child != null) child]),
              );

              return GlobalAudioOverlay(
                navigatorKey: navigatorKey,
                child: widget,
              );
            },
          );
        },
      ),
    );
  }
}
