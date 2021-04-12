import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  String _id;
  String _title;
  String _description;
  String _imageUrl;
  double _price;
  bool _isFavorite;

  String get id => _id;
  String get title => _title;
  String get description => _description;
  String get imageUrl => _imageUrl;
  double get price => _price;
  bool get isFavorite => _isFavorite;
  Product({
    @required String id,
    @required String title,
    @required String description,
    @required String imageUrl,
    @required double price,
    bool isFavorite = false,
  }) {
    _id = id;
    _title = title;
    _description = description;
    _imageUrl = imageUrl;
    _price = price;
    _isFavorite = isFavorite;
  }

  void _setFavValue(bool newValue) {
    _isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userID) async {
    final oldStatus = isFavorite;
    _setFavValue(!isFavorite);

    notifyListeners();

    final url =
        "https://shop-app-4a8bc-default-rtdb.firebaseio.com/userFavorites/$userID/$id.json?auth=$token";
    try {
      final http.Response res =
          await http.put(Uri.parse(url), body: json.encode(isFavorite));
      if (res.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }

  Map<String, Object> getAsMap([String userId = ""]) {
    return userId.isEmpty
        ? {
            "title": title,
            "description": description,
            "imageUrl": imageUrl,
            "price": price,
          }
        : {
            "title": title,
            "description": description,
            "imageUrl": imageUrl,
            "price": price,
            "creatorId": userId,
          };
  }
}
