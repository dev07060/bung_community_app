import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class WeatherCard extends StatelessWidget {
  final int index;
  final double endOpacity;

  const WeatherCard({super.key, required this.index, required this.endOpacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: endOpacity,
      child: Transform.scale(
        scale: 0.9 + (0.1 * endOpacity),
        child: Transform.translate(
          offset: Offset(0, 50 * (1 - endOpacity)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: .2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sampleWeatherData[index].date,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      sampleWeatherData[index].time,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    Text(
                      sampleWeatherData[index].day,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      sampleWeatherData[index].weatherIcon,
                      color: Colors.white,
                      size: 32,
                    ),
                    const Gap(16),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${sampleWeatherData[index].temperature}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final sampleWeatherData = [
  WeatherData(date: "27th April", day: "Monday", time: "6:27am", temperature: "10", weatherIcon: Icons.cloud),
  WeatherData(date: "28th April", day: "Tuesday", time: "7:00am", temperature: "12", weatherIcon: Icons.wb_sunny),
  WeatherData(date: "29th April", day: "Wednesday", time: "6:45am", temperature: "9", weatherIcon: Icons.cloud_queue),
  WeatherData(date: "30th April", day: "Thursday", time: "7:15am", temperature: "11", weatherIcon: Icons.wb_cloudy),
  WeatherData(date: "1st May", day: "Friday", time: "6:30am", temperature: "13", weatherIcon: Icons.wb_sunny),
  WeatherData(date: "2nd May", day: "Saturday", time: "7:30am", temperature: "14", weatherIcon: Icons.wb_sunny),
  WeatherData(date: "3rd May", day: "Sunday", time: "6:50am", temperature: "12", weatherIcon: Icons.cloud),
  WeatherData(date: "4th May", day: "Monday", time: "7:10am", temperature: "11", weatherIcon: Icons.cloud_queue),
  WeatherData(date: "5th May", day: "Tuesday", time: "6:40am", temperature: "10", weatherIcon: Icons.wb_cloudy),
  WeatherData(date: "6th May", day: "Wednesday", time: "7:20am", temperature: "15", weatherIcon: Icons.wb_sunny),
  WeatherData(date: "7th May", day: "Thursday", time: "6:55am", temperature: "13", weatherIcon: Icons.cloud),
  WeatherData(date: "8th May", day: "Friday", time: "7:05am", temperature: "12", weatherIcon: Icons.cloud_queue),
  WeatherData(date: "27th April", day: "Monday", time: "6:27am", temperature: "10", weatherIcon: Icons.cloud),
  WeatherData(date: "28th April", day: "Tuesday", time: "7:00am", temperature: "12", weatherIcon: Icons.wb_sunny),
  WeatherData(date: "29th April", day: "Wednesday", time: "6:45am", temperature: "9", weatherIcon: Icons.cloud_queue),
  WeatherData(date: "30th April", day: "Thursday", time: "7:15am", temperature: "11", weatherIcon: Icons.wb_cloudy),
  WeatherData(date: "1st May", day: "Friday", time: "6:30am", temperature: "13", weatherIcon: Icons.wb_sunny),
  WeatherData(date: "2nd May", day: "Saturday", time: "7:30am", temperature: "14", weatherIcon: Icons.wb_sunny),
  WeatherData(date: "3rd May", day: "Sunday", time: "6:50am", temperature: "12", weatherIcon: Icons.cloud),
  WeatherData(date: "4th May", day: "Monday", time: "7:10am", temperature: "11", weatherIcon: Icons.cloud_queue),
  WeatherData(date: "5th May", day: "Tuesday", time: "6:40am", temperature: "10", weatherIcon: Icons.wb_cloudy),
  WeatherData(date: "6th May", day: "Wednesday", time: "7:20am", temperature: "15", weatherIcon: Icons.wb_sunny),
  WeatherData(date: "7th May", day: "Thursday", time: "6:55am", temperature: "13", weatherIcon: Icons.cloud),
  WeatherData(date: "8th May", day: "Friday", time: "7:05am", temperature: "12", weatherIcon: Icons.cloud_queue),
];

class WeatherData {
  final String date;
  final String day;
  final String time;
  final String temperature;
  final IconData weatherIcon;

  WeatherData({
    required this.date,
    required this.day,
    required this.time,
    required this.temperature,
    required this.weatherIcon,
  });
}
