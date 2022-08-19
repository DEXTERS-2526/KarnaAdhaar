import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class Instance {
  static Future<SharedPreferences> _prefs;
  static List<String> numbers;

  static SharedPreferences prefs;

  static Future<SharedPreferences> GetSharedpreference() async {
    if (_prefs == null) {
      _prefs = SharedPreferences.getInstance();
      print("New Sharedpreference initialized 1");
    }

    if (prefs == null) {
      prefs = await _prefs;
      print("New Sharedpreference initialized 1");
    }
    print("SharedPreference instance is initialized.");
    return prefs;
  }

  static Future<void> SaveNumbers() async {
    final SharedPreferences prefs = await Instance.GetSharedpreference();
    for (var i = 0; i < numbers.length; i++) {
      String key = 'num' + (i + 1).toString();
      prefs.setString(key, numbers[i]);
      print("Saved Number Key: " + key + " value: " + numbers[i]);
    }
  }

  static Future<void> FetchNumbers() async {
    numbers = [];
    try {
      final SharedPreferences prefs = await Instance.GetSharedpreference();
      for (var i = 0; i < 5; i++) {
        String key = 'num' + (i + 1).toString();
        String num = prefs.getString(key);
        if (num != null) {
          numbers.add(num);
          print("Fetched Number Key: " + key);
        } else {
          print("Not found");
        }
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<bool> ClearSharedPreference() async {
    final SharedPreferences prefs = await Instance.GetSharedpreference();
    return prefs.clear();
  }

  static Future<Position> determinePosition() async {
    Position position;
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print(serviceEnabled);
    if (!serviceEnabled) {
      print("Location service disabled.");

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    print(permission);
    // position = await Geolocator.getLastKnownPosition();
    // if (position != null) {
    //   print(position);
    //   return position;
    // }
    var accuracy = await Geolocator.getLocationAccuracy();
    print(accuracy);
    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.reduced)
        .then((Position pos) {
      print(pos);
      position = pos;
    }).catchError((e) {
      print(e);
    });

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied");
        return Future.error('Location permissions are denied');
      }
      print("Location permissions given");
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    print(position);
    return position;
  }

  static Future<int> fetchTime() async {
    try {
      final SharedPreferences prefs = await Instance.GetSharedpreference();
      int time = prefs.getInt("Time");
      print("Time fetched" + time.toString());
      return time;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  static Future saveTime(int time) async {
    try {
      print("saving time - " + time.toString());
      final SharedPreferences prefs = await Instance.GetSharedpreference();
      prefs.setInt("Time", time);
      print("Time saved" + time.toString());
    } catch (e) {
      print(e);
    }
  }
}
