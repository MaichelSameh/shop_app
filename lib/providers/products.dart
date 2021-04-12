import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exeption.dart';

import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  String authToken;
  String userID;

  List<Product> get items => _items;

  List<Product> get favoriteItems =>
      items.where((element) => element.isFavorite == true).toList();

  getData(String authToken, String userID, List<Product> products) {
    this.authToken = authToken;
    this.userID = userID;
    this._items = products;
    notifyListeners();
  }

  Product findByID(String id) {
    return items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filteredString =
        filterByUser ? "orderBy='creatorId'&equalTo='$userID'" : "";
    var url =
        "https://shop-app-4a8bc-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filteredString";

    try {
      final http.Response res = await http.get(Uri.parse(url));
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      url =
          "https://shop-app-4a8bc-default-rtdb.firebaseio.com/userFavorites/$userID.json?auth=$authToken";
      final favRes = await http.get(Uri.parse(url));
      final favData = json.decode(favRes.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData["title"],
            description: prodData["description"],
            imageUrl: prodData["imageUrl"],
            price: double.parse(
              prodData["price"],
            ),
            isFavorite: favData == null ? false : favData[prodId] ?? false,
          ),
        );
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        "https://shop-app-4a8bc-default-rtdb.firebaseio.com/products.json?auth=$authToken";
    try {
      final res = await http.post(
        Uri.parse(url),
        body: json.encode(
          product.getAsMap(userID),
        ),
      );
      final newProduct = new Product(
        description: product.description,
        title: product.title,
        imageUrl: product.imageUrl,
        price: product.price,
        id: json.decode(res.body)["name"],
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = items.indexWhere((element) => id == element.id);
    if (prodIndex >= 0) {
      final url =
          "https://shop-app-4a8bc-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
      await http.patch(Uri.parse(url), body: newProduct.getAsMap());
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final prodIndex = items.indexWhere((element) => id == element.id);
    if (prodIndex >= 0) {
      final url =
          "https://shop-app-4a8bc-default-rtdb.firebaseio.com/products.json/$id?auth=$authToken";
      var product = items[prodIndex];
      _items.removeAt(prodIndex);
      notifyListeners();

      final res = await http.delete(Uri.parse(url));
      if (res.statusCode >= 400) {
        _items.insert(prodIndex, product);
        notifyListeners();
        throw HttpException("Could not delete Product.");
      }
      product = null;
    }
  }
}
