import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather/services/weather_services.dart';
import 'dart:ui';

import 'forecast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherServices _weatherService = WeatherServices();
  String _city = "Haripur";
  Map<String, dynamic>? _currentWeather;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final weatherData = await _weatherService.fetchCurrentWeather(_city);
      setState(() {
        _currentWeather = weatherData;
      });
    } catch (e) {
      print(e);
    }
  }

  void _showCitySelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter City"),
          content: TypeAheadField(
            suggestionsCallback: (pattern) async {
              return await _weatherService.fetchCitySuggestions(pattern);
            },
            builder: (context, controller, focusNode) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(

                  ),
                  labelText: "City",
                ),
              );
            },
            itemBuilder: (context, suggestion) {
              return ListTile(title: Text(suggestion["name"]));
            },

            onSelected: (city) {
              setState(() {
                _city = city['name'];
              });
            },
          ),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
            }, child: Text("cancel")),
            TextButton(onPressed: () {
              Navigator.pop(context);
              _fetchWeather();
            }, child: Text("Submit")),
          ],

        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentWeather == null
          ? Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2344),
              //  Colors.grey,

              Colors.blueGrey,
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      )
          : Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [

              Color(0xFF1A2344),
              Color(0xFF1A2344),
              Color(0xFF1A2344),
              Color(0xFF1A2344),

              Colors.grey,


            ],
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: _showCitySelectionDialog,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _city,
                      style: GoogleFonts.lato(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 36,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Image.network(
                    'http:${_currentWeather!['current']['condition']['icon']}',
                    height: 100.0,
                    width: 100.0,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    '${_currentWeather!['current']['temp_c'].round()}°C',
                    style: GoogleFonts.lato(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_currentWeather!['current']['condition']['text']}',
                    style: GoogleFonts.lato(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Max: ${_currentWeather!['forecast']['forecastday'][0]['day']['maxtemp_c']
                            .round()}°C',
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Min: ${_currentWeather!['forecast']['forecastday'][0]['day']['mintemp_c']
                            .round()}°C',
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWeatherDetail(
                    'Sunrise',
                    Icons.wb_sunny,
                    _currentWeather!['forecast']['forecastday'][0]['astro']['sunrise'],
                  ),
                  _buildWeatherDetail(
                    'Humidity',
                    Icons.opacity,
                    _currentWeather!['current']['humidity'],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWeatherDetail(
                    'Sunset',
                    Icons.brightness_3,
                    _currentWeather!['forecast']['forecastday'][0]['astro']['sunset'],
                  ),
                  _buildWeatherDetail(
                    'Wind (KPH)',
                    Icons.wind_power,
                    _currentWeather!['current']['wind_kph'],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Forecast(
                        city: _city,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Adjust the border radius here
                  ),
                ),
                child: Text(
                  "Next 7 Days Forecast",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, IconData icon, dynamic value) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      shadowColor: Colors.black45,
      color: Colors.white.withOpacity(0.1),
      child: Container(
        width: 120,
        height: 120,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.3),
              Colors.white24,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Check if value is null or empty before displaying
            Text(
              value != null ? value.toString() : 'N/A',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }}