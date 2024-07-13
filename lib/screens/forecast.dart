import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/weather_services.dart';

class Forecast extends StatefulWidget {
  final String city;
  const Forecast({required this.city});

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  final WeatherServices _weatherService = WeatherServices();
  late String _city;
  List<dynamic>? _forecast;

  @override
  void initState() {
    super.initState();
    _city = widget.city; // Initialize _city with the widget's city parameter
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    try {
      final forecastData = await _weatherService.fetch7DayForecast(widget.city);
      setState(() {
        _forecast = forecastData['forecast']['forecastday'];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _forecast == null ? Container(
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
        ) : Container(
          height: MediaQuery.of(context).size.height,
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        "7 Day Forecast",
                        style: GoogleFonts.lato(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _forecast!.length,
                  itemBuilder: (context, index) {
                    final day = _forecast![index];
                    String iconUrl = 'https:${day['day']['condition']['icon']}';
                    return Padding(
                      padding: EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: AlignmentDirectional.topStart,
                                end: AlignmentDirectional.bottomEnd,
                                colors: [
                                  const Color(0xFF1A2344).withOpacity(0.5),
                                  const Color(0xFF1A2344).withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: ListTile(
                              leading: Image.network(iconUrl),
                              title: Text(
                                '${day['date']} \n ${day['day']['avgtemp_c'].round()}°C',
                                style: GoogleFonts.lato(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                '${day['day']['condition']['text']}',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  color: Colors.white
                                ),
                                // Adjust color if necessary
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Max: ${day['day']['maxtemp_c'].round()}°C',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Min: ${day['day']['mintemp_c'].round()}°C',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
