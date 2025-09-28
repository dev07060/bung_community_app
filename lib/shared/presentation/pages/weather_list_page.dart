import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:our_bung_play/shared/presentation/widgets/animated_weather_list.dart';

class WeatherListPage extends StatefulWidget {
  const WeatherListPage({super.key});

  @override
  State<WeatherListPage> createState() => _WeatherListPageState();
}

class _WeatherListPageState extends State<WeatherListPage> {
  final Set<int> _animatedItems = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.white,
              ),
              title: const Text('Weather List', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6B46C1), Color(0xFFDB2777)],
          ),
        ),
        child: AnimatedWeatherList(animatedItems: _animatedItems),
      ),
    );
  }
}
