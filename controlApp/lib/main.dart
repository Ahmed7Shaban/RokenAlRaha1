import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/app_theme.dart';
import 'data/config_repository.dart';
import 'logic/admin_cubit.dart';
import 'presentation/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase.
  // Make sure you have added google-services.json (Android) or GoogleService-Info.plist (iOS)
  // or generated firebase_options.dart using flutterfire configure.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint(
      'Firebase initialization failed (expected if config files are missing): $e',
    );
  }

  runApp(const ControlApp());
}

class ControlApp extends StatelessWidget {
  const ControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the Repository and Cubit at the top level
    return RepositoryProvider(
      create: (context) => ConfigRepository(),
      child: BlocProvider(
        create: (context) =>
            AdminCubit(repository: context.read<ConfigRepository>()),
        child: MaterialApp(
          title: 'Roken Al Raha Admin',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const AdminDashboardScreen(),
        ),
      ),
    );
  }
}
