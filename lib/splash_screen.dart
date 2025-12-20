import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habitify/features/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Image.asset('assets/logo.png', width: 120, height: 120),
                SizedBox(height: 20),
                Text(
                  'Habitify',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: .bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'From',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    Icon(
                      Icons.code_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Rotibowif Dev',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: .w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
