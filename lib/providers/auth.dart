import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/auth_screen.dart';

import '../models/http_exeption.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return (token != null);
  }

  String get token {
    if (_token != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _expiryDate != null) {
      return _token;
    } else {
      return null;
    }
  }

  String get userId {
    return _userId;
  }

  Future<void> authentication(
      String email, String password, AuthMode _authMode) async {
    final String urlSegment = _authMode == AuthMode.SignUp
        ? "accounts:signUp"
        : "accounts:signInWithPassword";
    final String url =
        "https://identitytoolkit.googleapis.com/v1/$urlSegment?key=AIzaSyDW2DemMYmaXeD60zQv72rbBZKsmMw362s";

    final userInputData = {
      "email": email,
      "password": password,
      "returnSecureToken": true,
    };

    try {
      final http.Response res = await http.post(
        Uri.parse(url),
        body: json.encode(userInputData),
      );
      final responseData = json.decode(res.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]).toString();
      }
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData["expiresIn"]),
        ),
      );

      _autoLogout();
      notifyListeners();

      SharedPreferences pref = await SharedPreferences.getInstance();
      String userData = json.encode(
        {
          "token": _token,
          "userId": _userId,
          "expiryDate": _expiryDate.toIso8601String(),
        },
      );
      pref.setString("userData", userData);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey("userData")) {
      String res = pref.getString("userData");
      Map<String, dynamic> userData = json.decode(res);
      _token = userData["token"];
      _userId = userData["userId"];
      _expiryDate = DateTime.parse(userData["expiryDate"]);

      _autoLogout();
      notifyListeners();
      return true;
    } else
      return false;
  }

  Future<void> _autoLogout() async {
    if (_authTimer != null) {
      _authTimer.cancel();
    }

    final int expiryIn = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: expiryIn), logout);
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove("userData");

    notifyListeners();
  }
}
