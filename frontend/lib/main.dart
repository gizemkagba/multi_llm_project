import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/api_provider.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiProvider()),
      ],
      child: const MultiLlmApp(),
    ),
  );
}

class MultiLlmApp extends StatelessWidget {
  const MultiLlmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analiz Sistemi',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9F9FB), // Çok açık kurumsal gri
        colorScheme: const ColorScheme.light(
          primary: const Color(0xFFC61F1B), // Kurumsal Kırmızı
          secondary: const Color(0xFFC61F1B),
          surface: Colors.white,
          background: const Color(0xFFF9F9FB),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          margin: EdgeInsets.zero,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const NavigationShell(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFC61F1B), // Kırmızı üst şerit çizgisi
              width: 3.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFC61F1B), // Kırmızı aktif tab
          unselectedItemColor: Colors.grey[500],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: "Analiz Et",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: "Geçmiş",
            ),
          ],
        ),
      ),
    );
  }
}
