import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  //Keys
  static String userLoggedInKey = "LOGGEDINKEY";
  static String usernameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";


  // Saving the data to SP
  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSF(String username) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setString(usernameKey, username);
  }

  static Future<bool> saveUserEmailSF(String userEmail) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setString(userEmailKey, userEmail);
  }


  // Getting the data to SP
  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(userLoggedInKey);
  }

  static Future<String?> getUserEmailFromSP() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(userEmailKey);
  }

  static Future<String?> getUserNameFromSP() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(usernameKey);
  }
}
