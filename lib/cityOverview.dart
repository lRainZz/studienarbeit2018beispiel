import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;
import 'dart:convert';
import 'helper.dart';

class CityOverview extends StatefulWidget {
  @override
  createState() => CityOverviewState();

}

class CityOverviewState extends State<CityOverview> {

  List<CityData> _cityList   = new List();
  CityData       _activeCity;
  bool           _showSearch = false;
  bool           _isLoading  = false;
  List<CityData> _apiResults = new List();

  final _subject = new PublishSubject<String>();

  CityOverviewState() {
    if (globals.cityList.length == 0) {
      _cityList = new List();
    } else {
      _cityList = globals.cityList;
    }

    _activeCity = globals.activeCity;

    _subject.stream.debounce(new Duration(milliseconds: 600)).listen(_inputChanged);
  }

  _inputChanged(String input) {
    if (input.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      _clearSearchList();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _clearSearchList();

    String requestURL = 'https://api.apixu.com/v1/current.json?key=YOUR_API_KEY=' +  input;

    http.get(requestURL)
      .then((response) => response.body)
      .then(json.decode)
      .then((apiData) {

        if (apiData['error'] == null) {
          _addCity(apiData);
        }

      })
      .catchError(null)
      .then((e) {setState(() {
        _isLoading = false;
      });
    });
  }

  _addCity(dynamic apiCity) {
    var current  = apiCity['current'];
    var location = apiCity['location'];

    Weather  weather  = mapWeather(current);
    CityData cityData = mapCityData(location, weather, false);

    setState(() {
      _apiResults.add(cityData);
    });
  }

  _clearSearchList() {
    setState(() {
      _apiResults.clear();
    });
  }

  _setAsActive(CityData cityData) {
    setState(() {
      if (cityData == _activeCity) {
        _activeCity = null;
      } else {
        _activeCity = cityData;
      }
    });
  }

  _deleteFromList(CityData cityData) {
    setState(() {
      if (_cityList.contains(cityData)) {
        _cityList.remove(cityData);
      }

      if (_activeCity == cityData) {
        _activeCity = null;
      }
    });
  }

  Widget _buildSavedCitys() {
    return new ListView(
      padding: new EdgeInsets.all(16.0),
      children: _cityList.map((CityData cityData) {
        return new ListTile(
          key: new ObjectKey(cityData.id),
          leading: new Icon(
            (_activeCity == cityData) ? Icons.check_box : Icons.check_box_outline_blank,
          ),
          title: new Text(cityData.name),
          trailing: new IconButton(
            icon: new Icon(Icons.delete_forever),
            onPressed: () => _deleteFromList(cityData),
          ),
          onTap: () => _setAsActive(cityData),
        );
      }).toList(),
    );
  }

  _goBack() {
    globals.cityList = _cityList;
    globals.activeCity = _activeCity;

    Navigator.of(context).pop();
  }

  _buildListContent() {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back,
            color: Colors.black54
          ),
          onPressed: () => _goBack()
        ),
        title: new Text(
            'Saved Citys',
            style: new TextStyle(
                color: Colors.black54
            )
        ),
        backgroundColor: Colors.white,
      ),
      body: _buildSavedCitys(),
      floatingActionButton: new FloatingActionButton(
        elevation: 0.0,
        child: new Icon(
            Icons.add,
            color: Colors.white
        ),
        onPressed: () => setState(() {
          _showSearch = true;
        })
      ),
    );
  }

  Widget _showLoadingScreen() {
    return new Container(
      child: new Center(
          child: new CircularProgressIndicator()
      ),
    );
  }

  bool _isDouble(String cityName) {
    bool result = false;

    for (CityData city in _cityList) {
      if (city.name == cityName) {
        result = true;
      }
    }

    return result;
  }

  _addCityToList(CityData cityData) {
    // check doubles and set message
    if (!_isDouble(cityData.name) && (cityData != null)) {
      _clearSearchList();

      setState(() {
        _cityList.add(cityData);
        _showSearch = false;
      });
    }
  }

  List<Widget> _buildResultList(BuildContext context, List<CityData> apiResults) {
    if (apiResults.length == 0) {
      List<Widget> result = new List<Widget>();

      result.add(
          new ListTile(
            leading: new Icon(Icons.cancel),
            title: new Text(
              "No Results found" ,
              // style: new TextStyle(color: Colors.white30),
            ),
          )
      );

      return result;
    }

    return apiResults.map((CityData cityData) {
      return new ListTile(
          key: new ObjectKey(cityData.id),
          leading: new Icon(Icons.search),
          title: new Text (cityData.name),
          onTap: () => _addCityToList(cityData)
      );
    }).toList();
  }

  _buildSearchContent() {
    return new Scaffold(
      // key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Colors.white,
        leading: new IconButton(
          icon: new Icon(
            Icons.clear,
            color: Colors.black54
          ),
          onPressed: () =>
            setState(() {
              _showSearch = false;
              _clearSearchList();
              })),
        title: new TextField(
          style: new TextStyle(
            color: Colors.black,
            fontSize: 18.0,
          ),
          decoration: new InputDecoration.collapsed(
            hintStyle: new TextStyle(
            ),
            hintText: 'Search City ...',
          ),
          onChanged: (cityName) => (_subject.add(cityName)),
        ),
      ),
      body: _isLoading ? _showLoadingScreen() : new Container(
          child: new ListView(
            padding: new EdgeInsets.all(16.0),
            children: _buildResultList(context, _apiResults),
          )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: (_showSearch) ? _buildSearchContent() : _buildListContent()
    );
  }
}