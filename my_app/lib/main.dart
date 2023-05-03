import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import "dart:convert";

void main() => runApp(const MaterialApp(home: WeatherApp()));

Future<Map<String, dynamic>>? weatherData;
bool dataIsLoaded = false;
bool isCelcius = true;

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Weather App"),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                child: Text("Weather App"),
              ),
              Row(
                children:  const [],
              ),
            ],
          ),
        ),
        body: Column(
          children: const [
            SizedBox(height: 75),
            WeatherCard(),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> getWeatherData(String? text) async {
  final response = await http.get(Uri.parse(
      "http://goweather.herokuapp.com/weather/${text != null ? text : 'homburg'}"));

  if (response.statusCode == 200) {
    dataIsLoaded = true;
    return json.decode(response.body);
  } else {
    dataIsLoaded = false;
    return {};
  }
}

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  Future<Map<String, dynamic>>? weatherData;
  String city = "";

  @override
  void initState() {
    super.initState();
    weatherData = getWeatherData(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        
        SizedBox(
          width: 375,
          child: TextField(
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.words,
            showCursor: true,
            onSubmitted: (text) {
              city = text;
              setState(() {
                weatherData = getWeatherData(text);
              });
            },
          ),
        ),
        const SizedBox(
          height: 100,
        ),
        FutureBuilder<Map<String, dynamic>>(
          future: weatherData,
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              children = <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      dataIsLoaded
                          ? city == ""
                              ? "Homburg"
                              : city
                          : "Error loading data",
                      style: const TextStyle(
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dataIsLoaded
                          ? sanitizeString(snapshot.requireData["temperature"])
                          : "",
                      style: const TextStyle(
                        fontSize: 80.0,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    Text(
                      dataIsLoaded ? "degrees" : "",
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    dataIsLoaded
                        ? getIcon(snapshot.requireData["description"])
                        : const Icon(size: 72, color: Colors.red, Icons.error),
                  ],
                ),
              ];
            } else if (snapshot.hasError) {
              throw Error();
            } else {
              children = <Widget>[
                const CircularProgressIndicator(),
              ];
            }
            return Center(
              child: Column(children: children),
            );
          },
        )
      ],
    );
  }
}

String sanitizeString(String data) {
  String dataTrimmed = data.trim();
  String dataSanitized = dataTrimmed
      .replaceAll("+", "")
      .replaceAll("Â", "")
      .replaceAll("C", "")
      .replaceAll("°", "");
  return dataSanitized;
}

Widget getIcon(String data) {
  if (data == "Sunny") {
    return const Icon(Icons.sunny, size: 80, color: Colors.yellow);
  } else if (data == "Rain shower") {
    return Icon(Icons.water_drop_rounded, size: 80, color: Colors.blue[300]);
  } else {
    return const Icon(Icons.error_outline_sharp, size: 80, color: Colors.red);
  }
}
