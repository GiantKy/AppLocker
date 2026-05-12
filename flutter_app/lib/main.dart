import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/locker_provider.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartLockerApp());
}

class SmartLockerApp extends StatelessWidget {
  const SmartLockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LockerProvider()),
      ],
      child: MaterialApp(
        title: 'Tủ Thông Minh',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.dark,
          ),
          fontFamily: 'sans-serif', // Dùng font hệ thống, không cần tải
          textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: 'sans-serif',
          ),
          scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
