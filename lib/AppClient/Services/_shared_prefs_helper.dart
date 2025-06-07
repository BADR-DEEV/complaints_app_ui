import 'package:shared_preferences/shared_preferences.dart';

//------------in this service we allow our app to only have one instance of shared preferences-------------------
class SharedPrefs {
  late final SharedPreferences _sharedPrefs;
  static final SharedPrefs _instance = SharedPrefs._internal();

  factory SharedPrefs() => _instance;
  SharedPrefs._internal();

  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

//------------------isLoggedIn-------------------
  bool get isLoggedIn => _sharedPrefs.getBool(keyIsLoggedIn) ?? false;

  set isLoggedIn(bool value) {
    _sharedPrefs.setBool(keyIsLoggedIn, value);
  }

//---------------------LastUpdated----------------
  String? get token => _sharedPrefs.getString("token") ?? "";

  set token(String? value) {
    _sharedPrefs.setString("token", value ?? '');
  }

  //set token
  String? get userEmail => _sharedPrefs.getString("userEmail") ?? "";
  set userEmail(String? value) {
    _sharedPrefs.setString("userEmail", value ?? '');
  }

  //------------------clear--------------------
  Future<void> clear() async {
    await _sharedPrefs.clear();
  }

  //------------------language--------------------
  String get language => _sharedPrefs.getString("language") ?? "ar";
  set language(String value) {
    _sharedPrefs.setString("language", value);
  }

  String get userName => _sharedPrefs.getString("userName") ?? "";
  set userName(String value) {
    _sharedPrefs.setString("userName", value);
  }
}

// final sharedPrefs = SharedPrefs();
const String keyIsLoggedIn = "isLoggedIn";
