import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ForecastPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ForecastPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  List _forecastData = [];

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

    _getForecastData();
  }

  Future<void> _getForecastData() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final lat = position.latitude;
    final lon = position.longitude;
    final response = await http.get(
      Uri.parse('http://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=c5c531aa86ae03c2c016ac215165c12f&units=metric'),
    );

    if (response.statusCode == 200) {
      var forecastData = json.decode(response.body);
      var list = forecastData['list'] as List; 
      if (mounted) {
        setState(() {
          _forecastData = list;
        });
      }
    } else {
      throw Exception('Failed to load forecast data');
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
              const SizedBox(height: 70),
              const Text(
                '5-Day Forecast',
                style: TextStyle(fontSize: 30, color: Color.fromARGB(255, 49, 49, 49), fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _forecastData.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${_forecastData[index]['dt_txt']} - ${_forecastData[index]['main']['temp']}°C'),
                      subtitle: Text('Condition: ${_forecastData[index]['weather'][0]['description']}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}
