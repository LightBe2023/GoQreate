import 'package:flutter/material.dart';
import 'package:go_qreate_teams/Features/Home/presentation/screens/home_screen.dart';
import 'package:go_qreate_teams/Features/Login/presentation/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Transform.scale(
            scale: 0.7, // Adjust the scale factor as needed
            child: FractionallySizedBox(
              widthFactor: 1.5, // Adjust the width factor as needed
              heightFactor: 1.5, // Adjust the height factor as needed
              child: Image.asset(
                'assets/images/big_logo.png',
                fit: BoxFit.contain, // or BoxFit.cover based on your preference
              ),
            ),
          ),
        ),
      ),
    );
  }
}
