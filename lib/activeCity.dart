import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'globals.dart' as globals;
import 'helper.dart';


class ActiveCity extends StatefulWidget {
  @override
  createState() => ActiveCityState();
}

class ActiveCityState extends State<ActiveCity> {

  CityData     _activeCity;
  bool         _useImperial;


  // constructor
  ActiveCityState() {
    _activeCity = globals.activeCity;
  }

  _goToCityOverview() {
    // pushName to allow using hardware / software back button to go to activeCity
    Navigator.of(context).pushNamed('/cityOverview');
  }

  Widget _buildContent(CityData activeCity) {
    return new Column(
      children: _chooseContent(activeCity),
    );
  }

  List<Widget> _chooseContent(CityData activeCity) {
    List<Widget> widgets = new List<Widget>();

    widgets.add(_buildTopContent());

    if (activeCity != null) {
      widgets.add(_buildMiddleContent(activeCity));
      widgets.add(_buildBottomContent(activeCity));
    } else {
      widgets.add(_buildInActiveContent());
    }

    return widgets;
  }

  Widget _buildInActiveContent() {
    return new Padding(
        padding: new EdgeInsets.only(top: 100.0),
        child: new Center(
          child:
          new Text(
              'NO ACTIVE CITY',
              style: new TextStyle(
                  color: Colors.white,
                  fontSize: 25.0
              )
          ),
        )
    );

  }

  _refreshCity(CityData activeCity) {
    String requestURL = 'https://api.apixu.com/v1/current.json?key=YOUR_API_KEY=' +  activeCity.name;

    http.get(requestURL)
        .then((response) => response.body)
        .then(json.decode)
        .then((apiData) {
          _updateCity(apiData, activeCity);
    }); // no error catch

    // _scaffoldKey.currentState.removeCurrentSnackBar();
  }

  _updateCity(apiData, cityToRefresh) {
    var current  = apiData['current'];
    var location = apiData['location'];

    Weather  weather     = mapWeather(current);
    CityData newCityData = mapCityData(location, weather, true, cityToRefresh.id());

    int refreshIndex = globals.cityList.indexOf(cityToRefresh);

    globals.cityList[refreshIndex] = newCityData;

    setState(() {
      _activeCity = newCityData;
    });
  }

  double _getConditionTextSize(String condition) {
    int textSize = condition.length;
    double result;

    textSize >= 40 ? result = 11.0 : (textSize >= 32 ? result = 14.0 : (textSize > 26 ? result = 16.0 : result = 20.0));

    return result;
  }

  Widget _buildTopContent() {
    return new Padding(
      padding: new EdgeInsets.only(left: 25.0, right: 25.0, bottom: 10.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Align(
              child: new InkWell(
                child: new Icon(Icons.info, size: 25.0, color: Colors.white),
                onTap: () => print("Info button pressed"),
              ),
              alignment: Alignment.centerLeft,
            ),
          ),
          new Expanded(
              child: new Align(
                child: new InkWell(
                  child: new Icon(Icons.list, size: 30.0, color: Colors.white),
                  onTap: () => _goToCityOverview(),
                ),
                alignment: Alignment.centerRight,
              )
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleContent(CityData activeCity) {
    return new Column(
      children: <Widget>[
        new Center(
          child: new Text(
              geTimeFromDateTime(activeCity.localtime + '   '),
              style: new TextStyle(
                  color: Colors.white,
                  fontSize: 20.0
              )
          ),
        ),
        new Center(
          child: new Padding(
            padding: EdgeInsets.only(bottom: 30.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new InkWell(
                  onTap: () => _refreshCity(activeCity),
                  child: new Text(
                      '   ' + activeCity.name + '   ',
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 30.0,
                      )
                  ),
                ),
                new InkWell(
                    onTap: () => _refreshCity(activeCity),
                    child: new Icon(
                        Icons.refresh,
                        color: Colors.white30,
                        size: 30.0
                    )
                ),
              ],
            ),
          ),
        ),
        new Center(
          child: new Text(
            (_useImperial ? activeCity.weather.tempF.round().toString() : activeCity.weather.tempC.round().toString()) + '°',
            style: new TextStyle(
              color: Colors.white,
              fontSize: 80.0,
            ),
          ),
        ),
        new Center(
            child: new Text(
              'Feels like ' + ( _useImperial ? activeCity.weather.feelsLikeF.round().toString() : activeCity.weather.feelsLikeC.round().toString()) + '°',
              style: new TextStyle(
                color: Colors.white,
                fontSize: 17.5,
              ),
            )
        ),
      ],
    );
  }

  Widget _buildBottomContent(CityData activeCity) {
    return new Expanded(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new Container(
              decoration: new BoxDecoration(
                color: Colors.black45,
              ),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.only(left: 25.0, right: 10.0, top: 5.0, bottom: 5.0),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Align(
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                  'Condition',
                                  style: _getBottomTextStyle()
                              )
                          ),
                        ),
                        new Expanded(
                          flex: 2,
                          child:new Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new Text(
                                  activeCity.weather.condition,
                                  style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: _getConditionTextSize(activeCity.weather.condition)
                                  )
                              ),
                              new Image.network(
                                  activeCity.weather.conditionIcon,
                                  width:  50.0,
                                  height: 50.0
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Divider(color: Colors.white, height: 1.0),
                  new Padding(
                    padding: new EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                            child: new Align(
                              child: new Text(
                                  'Wind "' + activeCity.weather.windDirection + '"',
                                  style: _getBottomTextStyle()
                              ),
                              alignment: Alignment.centerLeft,
                            )
                        ),
                        new Expanded(
                            child: new Align(
                              child: new Text(
                                  _useImperial ? activeCity.weather.windMph.toString() + ' mph' : activeCity.weather.windKph.toString() + ' kph',
                                  style: _getBottomTextStyle()
                              ),
                              alignment: Alignment.centerRight,
                            )
                        )
                      ],
                    ),
                  ),
                  new Divider(color: Colors.white, height: 1.0),
                  new Padding(
                    padding: new EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 15.0),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                            child: new Align(
                                alignment: Alignment.centerLeft,
                                child: new Text(
                                    'Humidity',
                                    style: _getBottomTextStyle()
                                )
                            )
                        ),
                        new Expanded(
                            child: new Align(
                                alignment: Alignment.centerRight,
                                child: new Text(
                                    activeCity.weather.humidity.toString() + ' %',
                                    style: _getBottomTextStyle()
                                )
                            )
                        )
                      ],
                    ),
                  ),
                ],
              )
          ),
        ],
      ),
    );
  }

  TextStyle _getBottomTextStyle() {
    return new TextStyle(
        color: Colors.white,
        fontSize: 20.0
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
          padding: const EdgeInsets.only(top: 35.0),
          constraints: new BoxConstraints.expand(
            // full hd
            height: 1920.0,
            width: 1080.0,
          ),
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage(ASSET_BG_BLACKWHITE),
                  fit: BoxFit.fill
              )
          ),
          child: _buildContent(_activeCity)
      ),
    );
  }
}