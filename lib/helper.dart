import 'dart:core';

const String ASSET_BG_BLACKWHITE = 'res/img/AppLandScape_bw.png';

final int sunriseBegin = 5;  //  5 o'clock);
final int sunriseEnd   = 9;  //  9 o'clock);
final int sunsetBegin  = 17; // 17 o'clock);
final int sunsetEnd    = 21; // 21 o'clock);

// class for defining a new simple type of CityData
class CityData {
  final String name;
  final String region;
  final String localtime;
  final Weather weather;

  int  _id;
  bool _isActive = false;

  CityData(
      this.name,
      this.region,
      this.weather,
      this.localtime
      );

  setId(int id) {
    _id = id;
  }

  id() {
    return _id;
  }

  isActive() {
    return _isActive;
  }

  setActive(bool active) {
    _isActive = active;
  }
}

// class for defining a new simple type of Weather for CityData
class Weather {
  final String lastUpdated;
  final double tempC;
  final double tempF;
  final double feelsLikeC;
  final double feelsLikeF;
  final bool   isDay;
  final String condition;
  final String conditionIcon;
  final String windDirection;
  final double windKph;
  final double windMph;
  final int    humidity;

  int _id;

  Weather(
      this.lastUpdated,
      this.tempC,
      this.tempF,
      this.feelsLikeC,
      this.feelsLikeF,
      this.isDay,
      this.condition,
      this.conditionIcon,
      this.windDirection,
      this.windKph,
      this.windMph,
      this.humidity
      );

  setId(int id) {
    _id = id;
  }

  id() {
    return _id;
  }

}

Weather mapWeather(dynamic weatherJSON) {
  String lastUpdated   =            weatherJSON['last_updated'];
  double tempC         =            weatherJSON['temp_c'];
  double tempF         =            weatherJSON['temp_f'];
  double feelsLikeC    =            weatherJSON['feelslike_c'];
  double feelsLikeF    =            weatherJSON['feelslike_f'];
  bool   isDay         =           (weatherJSON['is_day'] == 1);
  String condition     =            weatherJSON['condition']['text'];
  String conditionIcon = 'https:' + weatherJSON['condition']['icon']; // URL must have protocol
  String windDirection =            weatherJSON['wind_dir'];
  double windKph       =            weatherJSON['wind_kph'];
  double windMph       =            weatherJSON['wind_mph'];
  int    humidity      =            weatherJSON['humidity'];

  return new Weather(
      lastUpdated,
      tempC,
      tempF,
      feelsLikeC,
      feelsLikeF,
      isDay,
      condition,
      conditionIcon,
      windDirection,
      windKph,
      windMph,
      humidity
  );
}

CityData mapCityData(dynamic cityDataJSON, Weather weather, bool isActive, [int idOld = 0]) {
  int    id        = idOld;
  String name      = cityDataJSON['name'];
  String region    = cityDataJSON['region'];
  String localtime = cityDataJSON['localtime'];

  CityData cityData = new CityData(
      name,
      region,
      weather,
      localtime
  );

  cityData.setId(id);

  cityData.setActive(isActive);

  return cityData;
}

String geTimeFromDateTime(String timeString) {
  return timeString.split(' ')[1];
}