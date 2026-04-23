import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import 'navigation_menu.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscureText = true;

  Future<void> _login() async {
    final success = await AuthService.login(
      username: _username.text,
      password: _password.text,
    );

    if (success) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NavigationMenu()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неверный логин или пароль')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 230, bottom: 106),
                  child: Text(
                    'Вход',
                    style: GoogleFonts.inter(
                      color: Color(0xFF363636),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _username,
                  decoration: InputDecoration(
                    hintText: 'Имя/Email',
                    hintStyle: GoogleFonts.inter(
                      color: Color(0xFF7C8BA0),
                      fontWeight: FontWeight.w500
                    ),
                    filled: true,
                    fillColor: Color(0xFFEDEDED),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 22, horizontal: 24),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.inter(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _password,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: 'Пароль',
                    hintStyle: GoogleFonts.inter(
                      color: Color(0xFF7C8BA0),
                      fontWeight: FontWeight.w500,
                      fontSize: 16
                    ),
                    filled: true,
                    fillColor: Color(0xFFEDEDED),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 22, horizontal: 24),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16), // сдвигаем влево
                      child: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xFF7C8BA0),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                  style: GoogleFonts.inter(),
                ),
                const SizedBox(height: 0),
                Padding(
                  padding: const EdgeInsets.only(left: 210.0),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Забыли пароль?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Color(0xFF7C8BA0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Color(0xFF363636),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Войти',
                      style: GoogleFonts.inter(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Нет аккаунта? ',
                        style: GoogleFonts.inter(
                          color: Color(0xFF7C8BA0),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Создать аккаунт',
                          style: GoogleFonts.inter(
                            color: Color(0xFF5E82FF),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

      ),
    );
  }
}
