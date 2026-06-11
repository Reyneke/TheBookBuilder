import 'dart:convert';

import 'package:http/http.dart' as http;

import '/env_files/api_key.dart'; // Deine ausgelagerte API-Datei

class WeatherService {
  // Basis-URL für aktuelle Wetterdaten (metrische Einheiten = Celsius)
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> fetchWeather(String cityName) async {
    // 1. URL mit Stadtnamen, API-Key und metrischen Einheiten zusammensetzen
    final Uri url = Uri.parse(
      '$_baseUrl?q=$cityName&appid=$openWeatherApiKey&units=metric&lang=de', // &lang=de für deutsche Beschreibungen
    );

    try {
      // 2. GET-Request an die API senden
      final response = await http.get(url);

      // 3. Statuscode prüfen
      if (response.statusCode == 200) {
        // Erfolg: JSON-Antwort in Map parsen
        return json.decode(response.body);
      } else {
        // Fehler: Werfen einer Exception mit der Fehlermeldung der API
        final errorBody = json.decode(response.body);
        throw Exception(
          'Fehler ${response.statusCode}: ${errorBody['message']}',
        );
      }
    } catch (e) {
      // Netzwerkfehler oder andere Exceptions abfangen
      throw Exception('Netzwerkfehler: $e');
    }
  }
}
