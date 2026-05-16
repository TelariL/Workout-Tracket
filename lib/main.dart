import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/navigation_menu.dart';
import 'screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ru', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
      ],

      locale: const Locale('ru'),
      home: const NavigationMenu(),
      //debugShowCheckedModeBanner: false,
      //home: FutureBuilder<bool>(
        //future: _isLoggedIn(),
        //builder: (context, snapshot) {

          //if (!snapshot.hasData) {
            //return const Scaffold(
              //body: Center(child: CircularProgressIndicator()),
            //);
          //}

          //if (snapshot.data!) {
            //return const NavigationMenu();
          //}

          //return const LoginScreen();
        //},
      //),
    );
  }
}