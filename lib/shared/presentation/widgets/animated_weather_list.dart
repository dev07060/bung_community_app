import 'package:flutter/material.dart';
import 'package:our_bung_play/shared/presentation/widgets/weather_card.dart';

class AnimatedWeatherList extends StatelessWidget {
  const AnimatedWeatherList({
    super.key,
    required Set<int> animatedItems,
  }) : _animatedItems = animatedItems;

  final Set<int> _animatedItems;

  @override
  Widget build(BuildContext context) {
    const topViewInsets = 100;

    return ListView.builder(
      padding: const EdgeInsets.only(top: topViewInsets + 30, bottom: 30, left: 20, right: 20),
      itemCount: sampleWeatherData.length,
      itemBuilder: (context, index) {
        if (!_animatedItems.contains(index)) {
          _animatedItems.add(index);
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 500 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, double value, child) {
              return WeatherCard(index: index, endOpacity: value);
            },
          );
        }
        return WeatherCard(index: index, endOpacity: 1.0);
      },
    );
  }
}
