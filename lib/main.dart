import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'data/datasources/firebase_datasource.dart';
import 'data/repositories/firebase_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'presentation/providers/booking_provider.dart';
import 'presentation/providers/car_wash_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await initializeDateFormatting('ru', null);

  // ============================================
  // ЗАГРУЗКА АВТОМОЕК (ВЫПОЛНИТЬ ОДИН РАЗ!)
  // ============================================
  final firebaseDataSource = FirebaseDataSource();
  try {
    await firebaseDataSource.seedCarWashes();
    debugPrint('✅ Автомойки загружены в Firestore');
  } catch (e) {
    debugPrint('❌ Ошибка загрузки: $e');
    // Игнорируем, если уже загружены
  }
  // ============================================
  
  runApp(const CarWashApp());
}

class CarWashApp extends StatelessWidget {
  const CarWashApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseDataSource = FirebaseDataSource();
    final firebaseRepository = FirebaseRepositoryImpl(firebaseDataSource);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(firebaseRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(firebaseRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CarWashProvider(
            firebaseRepository: firebaseRepository,
          )..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Sprinkle & Shine',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF00A8E8),
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00A8E8),
            primary: const Color(0xFF00A8E8),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF00A8E8),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}