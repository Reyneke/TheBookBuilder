import 'dart:async';

import 'package:book_builder/main_app.dart';
import 'package:book_builder/widgets/time/timeservice.dart';
import 'package:flutter/material.dart';

class AppTimeWidget extends StatefulWidget {
  const AppTimeWidget({super.key});

  @override
  AppTimeWidgetState createState() => AppTimeWidgetState();
}

class AppTimeWidgetState extends State<AppTimeWidget> {
  final TimeService _timeService = TimeService();
  DateTime? _currentTime;
  String _selectedZone = 'Europe/Berlin';

  // Liste verfügbarer Zeitzonen (Auszug)
  final List<String> _timezones = [
    'Europe/Berlin',
    'Europe/London',
    'America/New_York',
    'Asia/Tokyo',
    'Australia/Sydney',
  ];

  Future<void> _fetchTime() async {
    try {
      final time = await _timeService.getTimeForZone(_selectedZone);
      setState(() {
        _currentTime = time;
      });
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred: $e', isError: true);
      } //(e);
      // Fehlerbehandlung im UI
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTime();
    // Optional: Alle 60 Sekunden aktualisieren
    Timer.periodic(Duration(minutes: 1), (timer) => _fetchTime());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        spacing: 8,
        children: [
          Text(
            _currentTime != null
                ? '${_currentTime!.hour.toString().padLeft(2, '0')}:${_currentTime!.minute.toString().padLeft(2, '0')}:${_currentTime!.second.toString().padLeft(2, '0')}'
                : 'Lade Uhrzeit...',
            //style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          Text(_selectedZone.replaceAll('/', ' / ')),
          SizedBox(height: 20),
          DropdownButton<String>(
            value: _selectedZone,
            items: _timezones.map((zone) {
              return DropdownMenuItem(value: zone, child: Text(zone));
            }).toList(),
            onChanged: (newZone) {
              setState(() => _selectedZone = newZone!);
              _fetchTime();
            },
          ),
        ],
      ),
    );
  }
}
