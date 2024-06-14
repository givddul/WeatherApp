import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _temperature = 'Loading...';
  String _weatherDescription = 'Loading...';
  String _time = 'Loading...';
  String _location = 'Loading...';
  String _imageName = 'loading.gif';

  @override
  void initState() {
    super.initState();
    _getLocationPermission();
  }

  Future<void> _getLocationPermission() async {
    PermissionStatus permission = await Permission.location.status;

    if (permission != PermissionStatus.granted) {
      PermissionStatus newPermission = await Permission.location.request();

      if (newPermission != PermissionStatus.granted) {
        return;
      }
    }

    _getWeatherData();
  }

  Future<void> _getWeatherData() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final lat = position.latitude;
    final lon = position.longitude;
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=c5c531aa86ae03c2c016ac215165c12f&units=metric'),
    );

    if (response.statusCode == 200) {
      var weatherData = json.decode(response.body);
      if (mounted) {
        setState(() {
          _temperature = weatherData['main']['temp'].toString();
          _weatherDescription = weatherData['weather'][0]['description'];
          _time = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
          _location =
              '${weatherData['name']}, ${weatherData['sys']['country']}';
          String weatherMain = weatherData['weather'][0]['main'].toLowerCase();
          if (_weatherDescription.contains('rain')) {
            _imageName = 'rain.gif';
          } else if (_weatherDescription.contains('clear')) {
            _imageName = 'clear.gif';
          } else if (_weatherDescription.contains('cloud')) {
            _imageName = 'cloud.gif';
          } else if (weatherMain == 'clear') {
            _imageName = 'clear.gif';
          } else if (weatherMain == 'clouds') {
            _imageName = 'cloud.gif';
          } else {
            _imageName = 'rain.gif';
          }
        });
      }
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/$_imageName'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'Temperature',
              style: TextStyle(
                  fontSize: 25,
                  color: Color.fromARGB(255, 58, 58, 58),
                  fontWeight: FontWeight.bold),
            ),
            Text(
              '$_temperature °C',
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w200),
            ),
            const SizedBox(height: 40),
            const Text(
              'Location',
              style: TextStyle(
                  fontSize: 23,
                  color: Color.fromARGB(255, 58, 58, 58),
                  fontWeight: FontWeight.bold),
            ),
            Text(
              _location,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            const Text(
              'Condition',
              style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 58, 58, 58),
                  fontWeight: FontWeight.bold),
            ),
            Text(
              _weatherDescription,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 10),
            const Text(
              'Last updated at',
              style: TextStyle(
                  fontSize: 15,
                  color: Color.fromARGB(255, 70, 70, 70),
                  fontWeight: FontWeight.bold),
            ),
            Text(
              _time,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
