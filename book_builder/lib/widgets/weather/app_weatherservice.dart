import 'package:book_builder/widgets/weather/weatherservice.dart';
import 'package:flutter/material.dart';

class AppWeatherService extends StatefulWidget {
  const AppWeatherService({super.key});

  @override
  State<AppWeatherService> createState() => _AppWeatherServiceState();
}

class _AppWeatherServiceState extends State<AppWeatherService> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _getWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weatherData = null;
    });

    try {
      final data = await _weatherService.fetchWeather(city);
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wetterbericht'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Suchfeld mit Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Stadtname',
                      hintText: 'z.B. Berlin, London, Tokyo',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) =>
                        _getWeather(), // Enter-Taste löst Suche aus
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.search, size: 30),
                  onPressed: _getWeather,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ladeindikator
            if (_isLoading) const CircularProgressIndicator(),

            // Fehlermeldung
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),

            // Wetterdaten
            if (_weatherData != null) ...[
              const SizedBox(height: 20),
              _WeatherCard(weatherData: _weatherData!),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget zur Anzeige der Wetterinformationen
class _WeatherCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const _WeatherCard({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    // Wichtige Werte aus der JSON-Antwort extrahieren [citation:9]
    final cityName = weatherData['name'] ?? 'Unbekannt';
    final temp = weatherData['main']['temp'] ?? 0.0;
    final feelsLike = weatherData['main']['feels_like'] ?? 0.0;
    final humidity = weatherData['main']['humidity'] ?? 0;
    final description =
        weatherData['weather'][0]['description'] ?? 'Keine Beschreibung';
    final iconCode = weatherData['weather'][0]['icon'] ?? '01d';

    // Icon-URL von OpenWeatherMap
    final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              cityName,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Image.network(iconUrl, height: 80, width: 80),
            Text(
              description,
              style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            Text(
              '${temp.toStringAsFixed(1)}°C',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoItem(
                  icon: Icons.thermostat,
                  label: 'Gefühlt',
                  value: '${feelsLike.toStringAsFixed(1)}°C',
                ),
                _InfoItem(
                  icon: Icons.water_drop,
                  label: 'Luftfeuchtigkeit',
                  value: '$humidity%',
                ),
                _InfoItem(
                  icon: Icons.air,
                  label: 'Wind',
                  value: '${weatherData['wind']['speed'] ?? 0} m/s',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
