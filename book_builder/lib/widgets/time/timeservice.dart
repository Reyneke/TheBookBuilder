import 'dart:convert';

import 'package:http/http.dart' as http;

class TimeService {
  // Methode zum Abrufen der Zeit für eine bestimmte Zeitzone
  Future<DateTime> getTimeForZone(String timezone) async {
    // URL für die gewünschte Zeitzone (z.B. Europe/Berlin, Asia/Dubai, America/New_York)
    final url = Uri.parse('http://worldtimeapi.org/api/timezone/$timezone');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Das Feld 'datetime' enthält die aktuelle UTC-Zeit als ISO-String
        final dateTime = DateTime.parse(data['datetime']);
        return dateTime;
      } else {
        throw Exception('Fehler beim Laden der Zeit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Netzwerkfehler: $e');
    }
  }
}
